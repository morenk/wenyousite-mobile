import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';

typedef CoverAnimationLoader =
    Future<Uint8List> Function(String url, CancelToken cancel);
typedef CoverAnimationCodecFactory =
    Future<ui.Codec> Function(Uint8List bytes, int width);

Future<ui.Codec> decodeCoverAnimation(Uint8List bytes, int width) =>
    ui.instantiateImageCodec(bytes, targetWidth: width, allowUpscaling: false);

Future<Uint8List> loadCoverAnimation(String url, CancelToken cancel) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  try {
    final response = await dio.get<List<int>>(
      url,
      cancelToken: cancel,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (count, _) {
        if (count > 32 * 1024 * 1024) cancel.cancel('cover size limit');
      },
    );
    return Uint8List.fromList(response.data!);
  } finally {
    dio.close(force: true);
  }
}

/// 不把多帧 codec 放进全局 ImageCache；租约结束时取消下载、定时器并释放 codec。
class ControlledCoverAnimation extends StatefulWidget {
  const ControlledCoverAnimation({
    required this.url,
    required this.playing,
    required this.poster,
    this.lease,
    this.phase,
    this.source,
    this.decodeWidth,
    this.loader = loadCoverAnimation,
    this.codecFactory = decodeCoverAnimation,
    this.onFirstFrameDecoded,
    this.onFirstFramePainted,
    super.key,
  });

  final String url;
  final bool playing;
  final Widget poster;
  final ValueListenable<bool>? lease;
  final ValueListenable<CoverPlaybackPhase>? phase;
  final CoverAnimationSource? source;
  final int? decodeWidth;
  final CoverAnimationLoader loader;
  final CoverAnimationCodecFactory codecFactory;

  /// 可选的受控性能采样；未提供时不创建计时、日志或网络事件。
  final VoidCallback? onFirstFrameDecoded;

  /// 对应 RawImage 所在帧完成绘制后通知，不等同显示屏已完成扫描。
  final VoidCallback? onFirstFramePainted;

  @override
  State<ControlledCoverAnimation> createState() =>
      _ControlledCoverAnimationState();
}

class _ControlledCoverAnimationState extends State<ControlledCoverAnimation> {
  CancelToken? _cancel;
  ui.Codec? _codec;
  ui.Image? _frame;
  Timer? _timer;
  int _generation = 0;
  int _framesShown = 0;
  bool _started = false;
  Duration? _frameDuration;
  bool _firstPaintScheduled = false;

  bool get _playing => widget.phase != null
      ? widget.phase!.value == CoverPlaybackPhase.playing
      : widget.lease?.value ?? widget.playing;
  bool get _active => _playing;

  @override
  void initState() {
    super.initState();
    widget.lease?.addListener(_leaseChanged);
    widget.phase?.addListener(_leaseChanged);
  }

  void _leaseChanged() {
    if (!_active) _stop();
    _sync();
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ControlledCoverAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lease != widget.lease) {
      oldWidget.lease?.removeListener(_leaseChanged);
      widget.lease?.addListener(_leaseChanged);
      _stop();
    }
    if (oldWidget.phase != widget.phase) {
      oldWidget.phase?.removeListener(_leaseChanged);
      widget.phase?.addListener(_leaseChanged);
      _stop();
    }
    if (oldWidget.url != widget.url ||
        oldWidget.playing != widget.playing ||
        oldWidget.source != widget.source ||
        oldWidget.codecFactory != widget.codecFactory ||
        oldWidget.decodeWidth != widget.decodeWidth) {
      _stop();
    }
    _sync();
  }

  void _sync() {
    if (!_active) return;
    if (_started) {
      _scheduleNext();
      return;
    }
    _started = true;
    final width =
        widget.decodeWidth ??
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round()
            .clamp(1, 1080);
    unawaited(_start(++_generation, width));
  }

  Future<void> _start(int generation, int width) async {
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      final url = widget.url;
      final source = widget.source;
      ui.Codec? codec;
      for (var attempt = 0; attempt < 2; attempt++) {
        final data = source != null
            ? await source.load(url, cancel)
            : CoverAnimationData(await widget.loader(url, cancel));
        if (!_current(generation)) return;
        try {
          codec = await widget.codecFactory(data.bytes, width);
          break;
        } on Object {
          await source?.invalidate(url);
          if (!_current(generation) || !data.fromCache || attempt != 0) rethrow;
        }
      }
      if (codec == null) return;
      if (!_current(generation)) {
        codec.dispose();
        return;
      }
      _codec = codec;
      await _next(generation);
    } on Object {
      if (_current(generation)) {
        _release();
        setState(() {});
      }
    }
  }

  bool _current(int generation) =>
      mounted && _active && generation == _generation;

  Future<void> _next(int generation) async {
    final codec = _codec;
    if (codec == null || !_current(generation) || !_playing) {
      return;
    }
    try {
      final next = await codec.getNextFrame();
      if (!_current(generation)) {
        next.image.dispose();
        return;
      }
      final old = _frame;
      setState(() => _frame = next.image);
      _disposeAfterPaint(old);
      _framesShown++;
      if (_framesShown == 1) widget.onFirstFrameDecoded?.call();
      _frameDuration = next.duration;
      final finished =
          codec.frameCount <= 1 ||
          (codec.repetitionCount >= 0 &&
              _framesShown >= codec.frameCount * (codec.repetitionCount + 1));
      if (finished) {
        codec.dispose();
        _codec = null;
        return;
      }
      _scheduleNext();
    } on Object {
      if (_current(generation)) {
        _release();
        setState(() {});
      }
    }
  }

  void _scheduleNext() {
    final duration = _frameDuration;
    if (!_playing || _codec == null || duration == null || _timer != null) {
      return;
    }
    // 完整保留每帧显示时长；在途解码先消耗duration，重建不能再排一帧。
    final generation = _generation;
    _timer = Timer(duration, () {
      _timer = null;
      _frameDuration = null;
      unawaited(_next(generation));
    });
  }

  void _disposeAfterPaint(ui.Image? image) {
    if (image == null) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
      image.dispose();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
  }

  void _release() {
    _cancel?.cancel('cover stopped');
    _cancel = null;
    _timer?.cancel();
    _timer = null;
    _codec?.dispose();
    _codec = null;
    _disposeAfterPaint(_frame);
    _frame = null;
    _framesShown = 0;
    _frameDuration = null;
    _firstPaintScheduled = false;
  }

  void _stop() {
    _generation++;
    _started = false;
    _release();
  }

  @override
  Widget build(BuildContext context) {
    if (!_playing || _frame == null) return widget.poster;
    if (!_firstPaintScheduled && widget.onFirstFramePainted != null) {
      _firstPaintScheduled = true;
      final generation = _generation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_current(generation) && _frame != null) {
          widget.onFirstFramePainted?.call();
        }
      });
    }
    return RawImage(
      image: _frame,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }

  @override
  void dispose() {
    widget.lease?.removeListener(_leaseChanged);
    widget.phase?.removeListener(_leaseChanged);
    _stop();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_byte_cache.dart';

typedef CoverAnimationLoader =
    Future<Uint8List> Function(String url, CancelToken cancel);

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
    this.byteCache,
    this.loader = loadCoverAnimation,
    super.key,
  });

  final String url;
  final bool playing;
  final Widget poster;
  final ValueListenable<bool>? lease;
  final CoverAnimationByteCache? byteCache;
  final CoverAnimationLoader loader;

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

  bool get _playing => widget.lease?.value ?? widget.playing;

  @override
  void initState() {
    super.initState();
    widget.lease?.addListener(_leaseChanged);
  }

  void _leaseChanged() {
    _stop();
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
    if (oldWidget.url != widget.url || oldWidget.playing != widget.playing) {
      _stop();
    }
    _sync();
  }

  void _sync() {
    if (!_playing || _started) return;
    _started = true;
    final width =
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
      final bytes =
          widget.byteCache?.get(url) ?? await widget.loader(url, cancel);
      if (!_current(generation)) return;
      widget.byteCache?.put(url, bytes);
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width,
        allowUpscaling: false,
      );
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
      mounted && _playing && generation == _generation;

  Future<void> _next(int generation) async {
    final codec = _codec;
    if (codec == null || !_current(generation)) return;
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
      final finished =
          codec.frameCount <= 1 ||
          (codec.repetitionCount >= 0 &&
              _framesShown >= codec.frameCount * (codec.repetitionCount + 1));
      if (finished) {
        codec.dispose();
        _codec = null;
        return;
      }
      _timer = Timer(next.duration, () => unawaited(_next(generation)));
    } on Object {
      if (_current(generation)) {
        _release();
        setState(() {});
      }
    }
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
  }

  void _stop() {
    _generation++;
    _started = false;
    _release();
  }

  @override
  Widget build(BuildContext context) => _playing && _frame != null
      ? RawImage(
          image: _frame,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        )
      : widget.poster;

  @override
  void dispose() {
    widget.lease?.removeListener(_leaseChanged);
    _stop();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/application/audio_playback.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/audio_save_button.dart';

/// 只展示已授权投影元数据；初始构建、滚入屏幕均不读取音频。
const _audioCodeStyle = TextStyle(fontFamily: 'monospace');

class WenyouAudioPlayer extends ConsumerStatefulWidget {
  const WenyouAudioPlayer({
    required this.audio,
    required this.label,
    this.labelRuns = const [],
    this.showSave = true,
    super.key,
  });
  final MediaAudio audio;
  final String label;
  final List<MarkdownAudioLabelRun> labelRuns;
  final bool showSave;
  @override
  ConsumerState<WenyouAudioPlayer> createState() => _WenyouAudioPlayerState();
}

class _WenyouAudioPlayerState extends ConsumerState<WenyouAudioPlayer>
    with WidgetsBindingObserver {
  final _owner = Object();
  late AudioPlaybackController _playback;
  bool _activeRoute = true;
  bool _foreground = true;
  bool _visible = true;
  bool _dragging = false;
  bool _seekCompleted = false;
  bool _readyForSeek = false;
  final _seekPosition = ValueNotifier<double?>(null);
  double? get _targetPosition => _seekPosition.value;
  set _targetPosition(double? value) => _seekPosition.value = value;
  int _interaction = 0;
  Future<void> _seekQueue = Future<void>.value();
  Timer? _seekDeadline;
  ScrollPosition? _scroll;
  final _sliderFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _playback = ref.read(audioPlaybackProvider);
    WidgetsBinding.instance.addObserver(this);
    _playback.addListener(_playbackChanged);
    _sliderFocus.addListener(_focusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeRoute = ModalRoute.isCurrentOf(context) ?? true;
    final scroll = Scrollable.maybeOf(context)?.position;
    if (!identical(_scroll, scroll)) {
      _scroll?.removeListener(_syncVisibility);
      _scroll = scroll;
      _scroll?.addListener(_syncVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncVisibility());
    if (!_activeRoute) {
      _clearInteraction();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_activeRoute) unawaited(_playback.deactivate(_owner));
      });
    }
  }

  @override
  void didUpdateWidget(covariant WenyouAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.sourceUrl != widget.audio.sourceUrl) {
      _clearInteraction();
      _playback.release(_owner);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _foreground = state == AppLifecycleState.resumed;
      if (!_foreground) _clearInteraction();
    });
    if (!_foreground) unawaited(_playback.deactivate(_owner));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll?.removeListener(_syncVisibility);
    _sliderFocus.dispose();
    _playback.removeListener(_playbackChanged);
    _clearInteraction();
    // 解析子树重挂时新卡片可能已订阅同一控制器；树解锁后再通知，
    // release 仍按旧 owner 校验，不会停止已切换的新播放目标。
    scheduleMicrotask(() => _playback.release(_owner));
    _seekPosition.dispose();
    super.dispose();
  }

  void _clearInteraction() {
    _seekDeadline?.cancel();
    _seekDeadline = null;
    _interaction++;
    _dragging = false;
    _seekCompleted = false;
    _targetPosition = null;
  }

  void _focusChanged() {
    if (!mounted) return;
    setState(() {
      if (!_sliderFocus.hasFocus) _clearInteraction();
    });
  }

  void _playbackChanged() {
    if (!_playback.owns(_owner) || _playback.error != null) {
      _readyForSeek = false;
      _clearInteraction();
      return;
    }
    if (!_playback.status.loading) _readyForSeek = true;
    if (!_dragging &&
        _seekCompleted &&
        _targetPosition != null &&
        (_playback.status.position.inMilliseconds - _targetPosition!).abs() <
            (_playback.status.playing ? 2000 : 500)) {
      _targetPosition = null;
      _seekDeadline?.cancel();
    }
  }

  void _syncVisibility() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final viewport = RenderAbstractViewport.maybeOf(box);
    final visible =
        viewport == null ||
        MatrixUtils.transformRect(
          box.getTransformTo(viewport),
          Offset.zero & box.size,
        ).overlaps(viewport.paintBounds);
    if (visible != _visible) setState(() => _visible = visible);
  }

  void _beginSeek(double value) {
    setState(() {
      _seekDeadline?.cancel();
      _interaction++;
      _dragging = true;
      _seekCompleted = false;
      _targetPosition = value;
    });
  }

  void _endSeek(double value) {
    if (!_dragging) return;
    final interaction = _interaction;
    setState(() {
      _dragging = false;
      _targetPosition = value;
    });
    // 平台未发回位置时回到真实状态，绝不无限冻结预览时间。
    _seekDeadline = Timer(const Duration(seconds: 3), () {
      if (mounted && interaction == _interaction) setState(_clearInteraction);
    });
    // 连续 seek 串行，旧原生操作完成后才执行最终目标；媒体事件不能
    // 覆盖手指目标，直到这一轮 seek 完成且读回实际位置。
    _seekQueue = _seekQueue.then((_) async {
      if (!mounted ||
          interaction != _interaction ||
          !_activeRoute ||
          !_foreground ||
          !_playback.owns(_owner)) {
        return;
      }
      await _playback.seek(_owner, Duration(milliseconds: value.round()));
      if (!mounted || interaction != _interaction) return;
      setState(() {
        _seekCompleted = true;
        _playbackChanged();
      });
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _playback,
    builder: (context, _) {
      final current = _playback.owns(_owner);
      final state = current ? _playback.status : const AudioPlaybackStatus();
      final total = widget.audio.durationMs.toDouble();
      final label = widget.label.trim().isEmpty ? '音频' : widget.label;
      final tokens = context.wenyouTokens;
      final reduceMotion =
          wenyouAnimationsDisabled(context) ||
          MediaQuery.accessibleNavigationOf(context);
      final animate = _foreground && _activeRoute && _visible && !reduceMotion;
      final playing = state.playing && !state.completed && _foreground;
      // 已就绪后的暂时缓冲不能撤销手指正在进行的拖动。
      final canSeek = current && _readyForSeek && _activeRoute && _foreground;
      return TickerMode(
        enabled: animate,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AnimatedContainer(
            duration: animate ? WenyouFoundationMotion.standard : Duration.zero,
            curve: wenyouStandardMotionCurve,
            decoration: BoxDecoration(
              color: tokens.panel,
              border: Border.all(
                color: _sliderFocus.hasFocus
                    ? tokens.brandForeground.withValues(alpha: 0.6)
                    : playing
                    ? tokens.brandForeground.withValues(alpha: 0.20)
                    : tokens.border.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(
                context.wenyouTokens.radiusCompact,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      AudioPlaybackButton(
                        label: label,
                        playing: playing,
                        loading: state.loading,
                        reduceMotion: !animate,
                        onPressed: _activeRoute && _foreground
                            ? () {
                                setState(_clearInteraction);
                                unawaited(
                                  _playback.toggle(_owner, widget.audio),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Transform.translate(
                                offset: const Offset(0, 2),
                                child: Text.rich(
                                  TextSpan(
                                    children: widget.labelRuns.isEmpty
                                        ? [TextSpan(text: label)]
                                        : [
                                            for (final run in widget.labelRuns)
                                              TextSpan(
                                                text: run.text,
                                                style:
                                                    (run.marks.contains('code')
                                                            ? _audioCodeStyle
                                                            : const TextStyle())
                                                        .copyWith(
                                                          fontWeight:
                                                              run.marks
                                                                  .contains(
                                                                    'strong',
                                                                  )
                                                              ? FontWeight.bold
                                                              : null,
                                                          fontStyle:
                                                              run.marks
                                                                  .contains(
                                                                    'em',
                                                                  )
                                                              ? FontStyle.italic
                                                              : null,
                                                          decoration:
                                                              run.marks
                                                                      .contains(
                                                                        'del',
                                                                      ) ||
                                                                  run.marks
                                                                      .contains(
                                                                        's',
                                                                      )
                                                              ? TextDecoration
                                                                    .lineThrough
                                                              : null,
                                                        ),
                                              ),
                                          ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.wenyouCompactBody,
                                ),
                              ),
                            ),
                            ValueListenableBuilder<double?>(
                              valueListenable: _seekPosition,
                              builder: (context, target, _) {
                                final position =
                                    (target ??
                                            state.position.inMilliseconds
                                                .toDouble())
                                        .clamp(0.0, total)
                                        .toDouble();
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final captionStyle = Theme.of(
                                      context,
                                    ).textTheme.wenyouUtilityCaption;
                                    final metrics = TextPainter(
                                      text: TextSpan(
                                        text:
                                            '${_time(total.round())} / ${_time(total.round())}',
                                        style: captionStyle,
                                      ),
                                      textDirection: TextDirection.ltr,
                                      textScaler: MediaQuery.textScalerOf(
                                        context,
                                      ),
                                    )..layout();
                                    final stacked =
                                        constraints.maxWidth -
                                            metrics.width -
                                            12 <
                                        80;
                                    metrics.dispose();
                                    final slider = TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        end:
                                            !reduceMotion &&
                                                (_dragging ||
                                                    _sliderFocus.hasFocus)
                                            ? 6
                                            : 4,
                                      ),
                                      duration: animate
                                          ? WenyouFoundationMotion.fast
                                          : Duration.zero,
                                      curve: wenyouStandardMotionCurve,
                                      builder: (context, radius, _) => SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: context
                                              .wenyouTokens
                                              .brandForeground,
                                          thumbColor: context
                                              .wenyouTokens
                                              .brandForeground,
                                          inactiveTrackColor: tokens.border,
                                          disabledInactiveTrackColor:
                                              tokens.border,
                                          disabledActiveTrackColor:
                                              tokens.brandForeground,
                                          disabledThumbColor:
                                              tokens.brandForeground,
                                          trackHeight: 2,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: radius,
                                            disabledThumbRadius: 4,
                                            elevation: 0,
                                            pressedElevation: 0,
                                          ),
                                          overlayShape:
                                              SliderComponentShape.noOverlay,
                                          showValueIndicator:
                                              ShowValueIndicator.never,
                                        ),
                                        child: SizedBox(
                                          height: 48,
                                          child: Listener(
                                            onPointerCancel: (_) =>
                                                setState(_clearInteraction),
                                            child: Slider(
                                              focusNode: _sliderFocus,
                                              padding: EdgeInsets.zero,
                                              label: '播放进度',
                                              value: position,
                                              max: total,
                                              semanticFormatterCallback: (value) =>
                                                  '播放进度，${_time(value.round())}',
                                              onChangeStart: canSeek
                                                  ? _beginSeek
                                                  : null,
                                              onChanged: canSeek
                                                  ? (value) =>
                                                        _targetPosition = value
                                                  : null,
                                              onChangeEnd: canSeek
                                                  ? _endSeek
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    final time = Padding(
                                      padding: EdgeInsets.only(
                                        left: stacked ? 0 : 12,
                                        bottom: stacked ? 4 : 0,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          ExcludeSemantics(
                                            child: Opacity(
                                              opacity: 0,
                                              child: Text(
                                                '${_time(total.round())} / ${_time(total.round())}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .wenyouUtilityCaption,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${_time(position.round())} / ${_time(total.round())}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .wenyouUtilityCaption
                                                .copyWith(
                                                  color: tokens.mutedText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                    return stacked
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [slider, time],
                                          )
                                        : Row(
                                            children: [
                                              Expanded(child: slider),
                                              time,
                                            ],
                                          );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      if (widget.showSave)
                        AudioSaveButton(audio: widget.audio, label: label),
                    ],
                  ),
                ),
                if (current && _playback.error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Text(
                      _playback.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
  String _time(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

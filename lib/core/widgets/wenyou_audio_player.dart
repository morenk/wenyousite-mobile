import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_audio_projection.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/application/audio_playback.dart';
import 'package:wenyousite_mobile/features/media/data/just_audio_playback_driver.dart';

/// 只展示已授权投影元数据；初始构建、滚入屏幕均不读取音频。
class WenyouAudioPlayer extends ConsumerStatefulWidget {
  const WenyouAudioPlayer({
    required this.audio,
    required this.label,
    this.labelRuns = const [],
    super.key,
  });
  final MediaAudio audio;
  final String label;
  final List<MarkdownAudioLabelRun> labelRuns;
  @override
  ConsumerState<WenyouAudioPlayer> createState() => _WenyouAudioPlayerState();
}

class _WenyouAudioPlayerState extends ConsumerState<WenyouAudioPlayer>
    with WidgetsBindingObserver {
  final _owner = Object();
  late AudioPlaybackController _playback;
  bool _activeRoute = true;
  @override
  void initState() {
    super.initState();
    _playback = ref.read(audioPlaybackProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeRoute =
        (ModalRoute.isCurrentOf(context) ?? true) &&
        TickerMode.valuesOf(context).enabled;
    if (!_activeRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_activeRoute) unawaited(_playback.deactivate(_owner));
      });
    }
  }

  @override
  void didUpdateWidget(covariant WenyouAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.sourceUrl != widget.audio.sourceUrl) {
      _playback.release(_owner);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_playback.deactivate(_owner));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playback.release(_owner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _playback,
    builder: (context, _) {
      final current = _playback.owns(_owner);
      final state = current ? _playback.status : const AudioPlaybackStatus();
      final total = widget.audio.durationMs.toDouble();
      final position = state.position.inMilliseconds
          .toDouble()
          .clamp(0.0, total)
          .toDouble();
      final label = widget.label.trim().isEmpty ? '音频' : widget.label;
      final tokens = context.wenyouTokens;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.panel,
            border: Border.all(color: tokens.border.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(
              context.wenyouTokens.radiusCompact,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Row(
                  children: [
                    Semantics(
                      label: '$label，${state.playing ? '暂停' : '播放'}',
                      button: true,
                      child: ExcludeSemantics(
                        child: IconButton(
                          padding: const EdgeInsets.all(6),
                          style: IconButton.styleFrom(
                            foregroundColor: tokens.onAccentedBackground,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          onPressed: _activeRoute
                              ? () => unawaited(
                                  _playback.toggle(_owner, widget.audio),
                                )
                              : null,
                          icon: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tokens.accentedBackground,
                              shape: BoxShape.circle,
                            ),
                            child: state.loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : WenyouIcon(
                                    state.playing
                                        ? WenyouIconIds.mediaPause
                                        : WenyouIconIds.mediaPlay,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text.rich(
                              TextSpan(
                                children: widget.labelRuns.isEmpty
                                    ? [TextSpan(text: label)]
                                    : [
                                        for (final run in widget.labelRuns)
                                          TextSpan(
                                            text: run.text,
                                            style: TextStyle(
                                              fontWeight:
                                                  run.marks.contains('strong')
                                                  ? FontWeight.bold
                                                  : null,
                                              fontStyle:
                                                  run.marks.contains('em')
                                                  ? FontStyle.italic
                                                  : null,
                                              decoration:
                                                  run.marks.contains('del') ||
                                                      run.marks.contains('s')
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              fontFamily:
                                                  run.marks.contains('code')
                                                  ? 'monospace'
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
                          Row(
                            children: [
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor:
                                        context.wenyouTokens.brandForeground,
                                    thumbColor:
                                        context.wenyouTokens.brandForeground,
                                    inactiveTrackColor: tokens.border,
                                    disabledInactiveTrackColor: tokens.border,
                                    disabledActiveTrackColor:
                                        tokens.brandForeground,
                                    disabledThumbColor: tokens.brandForeground,
                                    trackHeight: 2,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 4,
                                      disabledThumbRadius: 4,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 24,
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 48,
                                    child: Slider(
                                      padding: EdgeInsets.zero,
                                      label: '播放进度',
                                      value: position,
                                      max: total,
                                      semanticFormatterCallback: (value) =>
                                          '播放进度，${_time(value.round())}',
                                      onChanged: current && !state.loading
                                          ? (value) => unawaited(
                                              _playback.seek(
                                                _owner,
                                                Duration(
                                                  milliseconds: value.round(),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  '${_time(position.round())} / ${_time(total.round())}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .wenyouUtilityCaption
                                      .copyWith(color: tokens.mutedText),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
      );
    },
  );
  String _time(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

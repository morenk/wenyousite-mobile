import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/animation/wenyou_motion.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';

/// 缩放仅作用于内部视觉，按钮命中与读屏区域始终保持 48dp。
class AudioPlaybackButton extends StatefulWidget {
  const AudioPlaybackButton({
    required this.label,
    required this.playing,
    required this.loading,
    required this.reduceMotion,
    required this.onPressed,
    super.key,
  });
  final String label;
  final bool playing;
  final bool loading;
  final bool reduceMotion;
  final VoidCallback? onPressed;

  @override
  State<AudioPlaybackButton> createState() => _AudioPlaybackButtonState();
}

class _AudioPlaybackButtonState extends State<AudioPlaybackButton> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final reduceMotion =
        widget.reduceMotion || wenyouAnimationsDisabled(context);
    final duration = reduceMotion ? Duration.zero : WenyouFoundationMotion.fast;
    return Semantics(
      label: '${widget.label}，${widget.playing ? '暂停' : '播放'}',
      button: true,
      enabled: widget.onPressed != null,
      onTap: widget.onPressed,
      child: ExcludeSemantics(
        child: IconButton(
          statesController: _states,
          padding: const EdgeInsets.all(6),
          style: IconButton.styleFrom(
            foregroundColor: tokens.onAccentedBackground,
            splashFactory: NoSplash.splashFactory,
          ),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: widget.onPressed,
          icon: ListenableBuilder(
            listenable: _states,
            builder: (context, _) => AnimatedScale(
              scale:
                  !reduceMotion && _states.value.contains(WidgetState.pressed)
                  ? 0.96
                  : 1,
              duration: duration,
              curve: wenyouStandardMotionCurve,
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.accentedBackground,
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: duration,
                  child: widget.loading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 18,
                          height: 18,
                          child: WenyouCircularProgressIndicator(
                            reduceMotion: widget.reduceMotion,
                            strokeWidth: 2,
                          ),
                        )
                      : WenyouIcon(
                          widget.playing
                              ? WenyouIconIds.mediaPause
                              : WenyouIconIds.mediaPlay,
                          key: ValueKey(widget.playing),
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

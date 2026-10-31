import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/audio_playback_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_indicator.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_audios.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

class EditorPendingAudioWidget extends StatelessWidget {
  const EditorPendingAudioWidget({
    required this.audios,
    this.locked = false,
    super.key,
  });
  final EditorPendingAudios audios;
  final bool locked;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: audios,
    builder: (context, _) => ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 160),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (audios.selecting && !audios.preparingSelection)
              Row(
                children: [
                  const Expanded(child: WenyouLinearProgressIndicator()),
                  TextButton(
                    onPressed: () => unawaited(audios.cancelSelection()),
                    child: const Text('取消选择'),
                  ),
                ],
              ),
            if (audios.selectionFailure != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      audios.selectionFailure!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: locked ? null : () => unawaited(audios.pick()),
                    child: const Text('重新选择'),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

/// 状态来自本机上传队列；未完成时不创建播放驱动或任何音源请求。
class EditorPendingAudioCard extends StatelessWidget {
  const EditorPendingAudioCard({
    required this.id,
    required this.label,
    required this.onRemove,
    this.audios,
    this.locked = false,
    super.key,
  });
  final String id;
  final String label;
  final VoidCallback onRemove;
  final EditorPendingAudios? audios;
  final bool locked;

  @override
  Widget build(BuildContext context) => audios == null
      ? _build(context)
      : ListenableBuilder(
          listenable: audios!,
          builder: (context, _) => _build(context),
        );

  Widget _build(BuildContext context) {
    final item = audios?.items[id];
    final failure = item == null ? '本机音频缺失，请移除后重新选择。' : item.failure;
    final paused = item?.awaitingContinue == true;
    final stage = item?.progress.stage;
    final tokens = context.wenyouTokens;
    return Container(
      key: ValueKey('pending-audio-$id'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border.all(color: tokens.border.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(tokens.radiusCompact),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AudioPlaybackButton(
                label: label,
                playing: false,
                loading: false,
                reduceMotion: true,
                onPressed: null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.wenyouCompactBody,
                        ),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final status = paused
                            ? '已暂停'
                            : switch (stage) {
                                AudioUploadStage.uploading => '上传中',
                                AudioUploadStage.confirming => '确认中',
                                AudioUploadStage.processing => '处理中',
                                _ => '准备中',
                              };
                        final text = failure == null ? status : '上传失败';
                        final style = Theme.of(
                          context,
                        ).textTheme.wenyouUtilityCaption;
                        final metrics = TextPainter(
                          text: TextSpan(text: text, style: style),
                          textDirection: TextDirection.ltr,
                          textScaler: MediaQuery.textScalerOf(context),
                        )..layout();
                        final stacked =
                            constraints.maxWidth - metrics.width - 12 < 80;
                        metrics.dispose();
                        final track = SizedBox(
                          height: 48,
                          child: Center(
                            child: WenyouLinearProgressIndicator(
                              value:
                                  stage == AudioUploadStage.confirming ||
                                      stage == AudioUploadStage.processing
                                  ? 1
                                  : item?.progress.fraction ?? 0,
                              semanticsLabel: '音频上传进度',
                              minHeight: 2,
                              stopIndicatorRadius: 0,
                              borderRadius: BorderRadius.circular(1),
                              color: tokens.brandForeground,
                              backgroundColor: tokens.border,
                            ),
                          ),
                        );
                        final caption = Padding(
                          padding: EdgeInsets.only(
                            left: stacked ? 0 : 12,
                            bottom: stacked ? 4 : 0,
                          ),
                          child: Text(text, style: style),
                        );
                        if (failure != null) return track;
                        return stacked
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [track, caption],
                              )
                            : Row(
                                children: [
                                  Expanded(child: track),
                                  caption,
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: item?.active == true ? '取消上传' : '移除音频',
                onPressed: locked ? null : onRemove,
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
              ),
            ],
          ),
          if (failure != null || paused)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: failure == null
                        ? const SizedBox()
                        : Text(
                            failure == '音频上传失败，请重试。' ? '上传失败' : failure,
                            style: Theme.of(context).textTheme.wenyouCaption
                                .copyWith(
                                  // 保留原紧凑标签的字距；其余字形属性沿用 caption。
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                  ),
                  if (item != null && (failure != null || paused))
                    TextButton(
                      onPressed: locked
                          ? null
                          : () => unawaited(
                              item.terminalFailure
                                  ? audios!.reselect(id)
                                  : audios!.retry(id),
                            ),
                      child: Text(
                        item.terminalFailure
                            ? '重新选择'
                            : paused
                            ? '继续'
                            : '重试',
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

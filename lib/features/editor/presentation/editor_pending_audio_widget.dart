import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
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
            if (audios.selecting)
              Row(
                children: [
                  const Expanded(child: LinearProgressIndicator()),
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
            for (final item in audios.visible)
              Padding(
                key: ValueKey('pending-audio-${item.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.input?.filename ?? '音频',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.failure != null)
                            Text(
                              item.failure!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            )
                          else if (item.awaitingContinue)
                            const Text('已暂停')
                          else ...[
                            Text(switch (item.progress.stage) {
                              AudioUploadStage.preparing => '正在准备音频',
                              AudioUploadStage.uploading => '正在上传音频',
                              AudioUploadStage.confirming => '正在确认音频',
                              AudioUploadStage.processing => '正在处理音频',
                            }, style: Theme.of(context).textTheme.labelSmall),
                            LinearProgressIndicator(
                              value: item.progress.fraction,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.failure != null || item.awaitingContinue)
                      TextButton(
                        onPressed: locked
                            ? null
                            : () => unawaited(
                                item.terminalFailure
                                    ? audios.reselect(item.id)
                                    : audios.retry(item.id),
                              ),
                        child: Text(
                          item.terminalFailure
                              ? '重新选择'
                              : item.awaitingContinue
                              ? '继续'
                              : '重试',
                        ),
                      ),
                    IconButton(
                      tooltip: '移除音频',
                      onPressed: locked ? null : () => audios.remove(item.id),
                      icon: const WenyouIcon(
                        WenyouIconIds.actionClose,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

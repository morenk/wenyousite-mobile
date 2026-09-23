import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_images.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

class EditorPendingImageWidget extends StatelessWidget {
  const EditorPendingImageWidget({
    required this.id,
    required this.images,
    super.key,
  });
  final String id;
  final EditorPendingImages images;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: images,
      builder: (context, _) {
        final item = images.images[id];
        final state = item?.state;
        final failed = item == null || item.missing || state?.failure != null;
        final delayed = state?.phase == MediaUploadTaskPhase.processingPending;
        return Container(
          key: images.anchorFor(id),
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 320),
          color: context.wenyouTokens.softPanel,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 120,
                  minHeight: 120,
                ),
                child: PendingImageOverlay(
                  key: ValueKey('pending-image-$id'),
                  active: state?.isActivelyWorking ?? false,
                  failed: failed,
                  onFailureTap: () async {
                    final action = await showPendingImageActions(
                      context,
                      title: delayed ? '图片准备较久' : '图片未完成',
                      retryLabel: delayed ? '继续等待' : '重试',
                      removeLabel: '移除图片',
                      detail: state?.failure?.userMessage,
                      canRetry:
                          item?.input != null &&
                          state?.failure?.canRetry != false &&
                          !images.waitingToPublish,
                    );
                    if (!context.mounted) return;
                    if (action == PendingImageAction.retry) {
                      unawaited(images.retry(id));
                    }
                    if (action == PendingImageAction.remove) images.remove(id);
                  },
                  child: item?.input != null
                      ? MediaUploadInputImage(
                          input: item!.input!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(
                            height: 120,
                            child: Center(child: Text('本机图片不可用')),
                          ),
                        )
                      : const SizedBox(
                          height: 120,
                          child: Center(child: Text('本机图片不可用')),
                        ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: '移除图片',
                onPressed: images.waitingToPublish
                    ? null
                    : () => images.remove(id),
                icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditorPublishWaiting extends StatelessWidget {
  const EditorPublishWaiting({required this.images, super.key});
  final EditorPendingImages images;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: images,
    builder: (context, _) => images.waitingToPublish
        ? DelayedPendingNotice(
            waiting: true,
            child: Row(
              children: [
                Expanded(child: Text('还有 ${images.pendingCount} 张图片未就绪')),
                TextButton(
                  onPressed: images.cancelPublish,
                  child: const Text('取消发布'),
                ),
              ],
            ),
          )
        : images.saveFailure != null
        ? Text(
            images.saveFailure!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        : const SizedBox.shrink(),
  );
}

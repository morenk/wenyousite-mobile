import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_progress_ring.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_pending_images.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

class EditorPendingImageWidget extends StatefulWidget {
  const EditorPendingImageWidget({
    required this.id,
    required this.images,
    super.key,
  });
  final String id;
  final EditorPendingImages images;
  @override
  State<EditorPendingImageWidget> createState() =>
      _EditorPendingImageWidgetState();
}

class _EditorPendingImageWidgetState extends State<EditorPendingImageWidget> {
  bool _showProgress = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showProgress = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.images,
      builder: (context, _) {
        final item = widget.images.images[widget.id];
        final state = item?.state;
        final failed = item == null || item.missing || state?.failure != null;
        final delayed = state?.phase == MediaUploadTaskPhase.processingPending;
        final fraction = state?.phase == MediaUploadTaskPhase.uploading
            ? state?.progress?.fraction
            : null;
        return Container(
          key: ValueKey('pending-image-${widget.id}'),
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 320),
          color: context.wenyouTokens.softPanel,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (item?.input != null)
                MediaUploadInputImage(
                  input: item!.input!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 120,
                    child: Center(child: Text('本机图片不可用')),
                  ),
                )
              else
                const SizedBox(
                  height: 120,
                  child: Center(child: Text('本机图片不可用')),
                ),
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (failed) ...[
                      Text(delayed ? '图片准备较久' : '未完成'),
                      if (item?.input != null &&
                          state?.failure?.canRetry != false)
                        TextButton(
                          onPressed: widget.images.waitingToPublish
                              ? null
                              : () => widget.images.retry(widget.id),
                          child: Text(delayed ? '继续' : '重试'),
                        ),
                    ] else if (_showProgress) ...[
                      WenyouProgressRing(value: fraction),
                      if (fraction != null)
                        Text(' ${(fraction * 100).round()}%'),
                    ],
                    TextButton(
                      onPressed: widget.images.waitingToPublish
                          ? null
                          : () => widget.images.remove(widget.id),
                      child: const Text('移除'),
                    ),
                  ],
                ),
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
        ? Row(
            children: [
              Expanded(child: Text('还有 ${images.pendingCount} 张图片未就绪')),
              TextButton(
                onPressed: images.cancelPublish,
                child: const Text('取消发布'),
              ),
            ],
          )
        : images.saveFailure != null
        ? Text(
            images.saveFailure!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        : const SizedBox.shrink(),
  );
}

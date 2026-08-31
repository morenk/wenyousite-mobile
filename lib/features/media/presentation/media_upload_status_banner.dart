import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';

class MediaUploadStatusBanner extends StatelessWidget {
  const MediaUploadStatusBanner({
    required this.state,
    required this.onCancel,
    this.onRetry,
    this.cancelLabel = '取消上传',
    this.retryLabel = '重试上传',
    this.cancelKey,
    this.retryKey,
    super.key,
  });

  final MediaUploadTaskState state;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;
  final String cancelLabel;
  final String retryLabel;
  final Key? cancelKey;
  final Key? retryKey;

  @override
  Widget build(BuildContext context) {
    final currentFailure = state.failure;
    if (currentFailure != null) {
      return WenyouStatusBanner(
        message: currentFailure.userMessage,
        detail: currentFailure.resolvedPresentation.problemDetail,
        tone: WenyouStatusTone.error,
        action: currentFailure.canRetry && onRetry != null
            ? TextButton(
                key: retryKey,
                onPressed: onRetry,
                child: Text(retryLabel),
              )
            : null,
      );
    }
    if (!state.isBusy) return const SizedBox.shrink();
    return WenyouStatusBanner(
      message: state.progressLabel,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: state.progress?.fraction),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: cancelKey,
              onPressed: onCancel,
              child: Text(cancelLabel),
            ),
          ),
        ],
      ),
    );
  }
}

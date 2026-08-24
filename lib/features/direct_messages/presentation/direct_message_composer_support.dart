import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class DirectMessageComposerStatusLine extends StatelessWidget {
  const DirectMessageComposerStatusLine({
    required this.icon,
    required this.message,
    this.error = false,
    this.onRetry,
    this.onDismiss,
    this.retryKey,
    this.dismissKey,
    super.key,
  });

  final String icon;
  final String message;
  final bool error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final Key? retryKey;
  final Key? dismissKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = error
        ? Theme.of(context).colorScheme.error
        : tokens.mutedText;
    return Row(
      children: [
        WenyouIcon(icon, size: 16, color: color),
        SizedBox(width: tokens.space4),
        Expanded(
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
        if (onRetry != null)
          IconButton(
            key: retryKey,
            onPressed: onRetry,
            tooltip: '重试',
            visualDensity: VisualDensity.compact,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
          ),
        if (onDismiss != null)
          IconButton(
            key: dismissKey,
            onPressed: onDismiss,
            tooltip: '关闭',
            visualDensity: VisualDensity.compact,
            icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
          ),
      ],
    );
  }
}

class DirectMessageImagePreview extends StatelessWidget {
  const DirectMessageImagePreview({
    required this.image,
    this.onRemove,
    super.key,
  });

  final MediaUploadInput image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      key: const Key('direct-message-composer-attachment'),
      decoration: BoxDecoration(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: Image.memory(
              image.bytes,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              cacheWidth: 192,
              gaplessPlayback: true,
            ),
          ),
          SizedBox(width: tokens.space8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              '[图片]',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            key: const Key('direct-message-composer-remove-image'),
            onPressed: onRemove,
            tooltip: '移除图片',
            icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
          ),
        ],
      ),
    );
  }
}

class DirectMessageUploadProgress extends StatelessWidget {
  const DirectMessageUploadProgress({
    required this.state,
    required this.onCancel,
    super.key,
  });

  final MediaUploadTaskState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: state.progress?.fraction,
          ),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Text(
            state.progressLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        IconButton(
          key: const Key('direct-message-composer-cancel-upload'),
          onPressed: onCancel,
          tooltip: '取消上传',
          visualDensity: VisualDensity.compact,
          icon: const WenyouIcon(WenyouIconIds.actionClose, size: 18),
        ),
      ],
    );
  }
}

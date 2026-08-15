part of 'direct_message_widgets.dart';

class _ComposerStatusLine extends StatelessWidget {
  const _ComposerStatusLine({
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, this.onRemove});

  final UploadedEditorImage image;
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
            child: WenyouCachedImage(
              imageUrl: image.url,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
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

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.state, required this.onCancel});

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
            switch (state.phase) {
              MediaUploadTaskPhase.picking => '正在打开相册…',
              MediaUploadTaskPhase.preparing => '正在准备图片…',
              MediaUploadTaskPhase.uploading
                  when state.progress?.fraction != null =>
                '正在上传 ${(state.progress!.fraction! * 100).round()}%',
              MediaUploadTaskPhase.uploading => '正在上传图片…',
              MediaUploadTaskPhase.confirming => '正在确认图片…',
              MediaUploadTaskPhase.processing => '正在处理图片…',
              MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => '',
            },
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

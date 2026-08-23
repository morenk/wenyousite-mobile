import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MomentComposeImageStrip extends StatelessWidget {
  const MomentComposeImageStrip({
    required this.images,
    required this.coverMediaId,
    required this.uploadState,
    required this.pendingIndex,
    required this.pendingCount,
    required this.onAdd,
    required this.onCancelUpload,
    required this.onRetryUpload,
    required this.onCoverSelected,
    required this.onRemove,
    required this.onReorder,
    super.key,
  });

  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final MediaUploadTaskState uploadState;
  final int pendingIndex;
  final int pendingCount;
  final VoidCallback? onAdd;
  final VoidCallback? onCancelUpload;
  final VoidCallback? onRetryUpload;
  final ValueChanged<String> onCoverSelected;
  final ValueChanged<String> onRemove;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      key: const Key('moment-compose-images'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('图片', style: Theme.of(context).textTheme.titleSmall),
            ),
            Text(
              '${images.length}/9',
              key: const Key('moment-compose-image-count'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ],
        ),
        SizedBox(height: tokens.space8),
        SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (images.isNotEmpty)
                Expanded(
                  child: ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    itemCount: images.length,
                    onReorderItem: onReorder,
                    itemBuilder: (context, index) => _ComposeThumbnail(
                      key: ValueKey(images[index].mediaId),
                      image: images[index],
                      index: index,
                      imageCount: images.length,
                      isCover: images[index].mediaId == coverMediaId,
                      onCoverSelected: onCoverSelected,
                      onRemove: onRemove,
                      onMove: (targetIndex) => onReorder(index, targetIndex),
                    ),
                  ),
                ),
              if (images.isNotEmpty && images.length < 9)
                SizedBox(width: tokens.space8),
              if (images.length < 9)
                _AddImageTile(onPressed: onAdd)
              else if (images.isEmpty)
                const SizedBox.shrink(),
            ],
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: tokens.space4),
          Text(
            '点按选择封面，长按调整顺序',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ],
        if (uploadState.isBusy) ...[
          SizedBox(height: tokens.space8),
          LinearProgressIndicator(value: uploadState.progress?.fraction),
          Row(
            children: [
              Expanded(child: Text(_progressLabel(uploadState))),
              TextButton(
                key: const Key('moment-compose-cancel-upload'),
                onPressed: onCancelUpload,
                child: const Text('取消上传'),
              ),
            ],
          ),
        ],
        if (uploadState.failure case final failure?) ...[
          SizedBox(height: tokens.space8),
          WenyouStatusBanner(
            key: const Key('moment-compose-upload-failure'),
            message: failure.userMessage,
            detail: failure.requestId == null
                ? null
                : '问题编号：${failure.requestId}',
            tone: WenyouStatusTone.error,
            action: Wrap(
              spacing: tokens.space8,
              children: [
                TextButton(
                  key: const Key('moment-compose-cancel-upload'),
                  onPressed: onCancelUpload,
                  child: const Text('取消上传'),
                ),
                if (failure.canRetry)
                  TextButton(
                    key: const Key('moment-compose-retry-upload'),
                    onPressed: onRetryUpload,
                    child: const Text('重新上传'),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _progressLabel(MediaUploadTaskState state) {
    final position = pendingCount == 0
        ? ''
        : ' ${pendingIndex.clamp(0, pendingCount - 1) + 1}/$pendingCount';
    return switch (state.phase) {
      MediaUploadTaskPhase.picking => '正在打开相册…',
      MediaUploadTaskPhase.preparing => '正在准备图片$position…',
      MediaUploadTaskPhase.uploading when state.progress?.fraction != null =>
        '正在上传$position ${((state.progress!.fraction ?? 0) * 100).round()}%',
      MediaUploadTaskPhase.uploading => '正在上传图片$position…',
      MediaUploadTaskPhase.confirming => '正在确认图片$position…',
      MediaUploadTaskPhase.processing => '正在处理图片$position…',
      MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => '',
    };
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return SizedBox.square(
      dimension: 88,
      child: Material(
        color: tokens.softPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius12),
          side: BorderSide(color: tokens.border),
        ),
        child: InkWell(
          key: const Key('moment-compose-add-image'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const WenyouIcon(WenyouIconIds.actionAddImage),
              SizedBox(height: tokens.space4),
              const Text('添加图片'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposeThumbnail extends StatelessWidget {
  const _ComposeThumbnail({
    required this.image,
    required this.index,
    required this.imageCount,
    required this.isCover,
    required this.onCoverSelected,
    required this.onRemove,
    required this.onMove,
    super.key,
  });

  final UploadedEditorImage image;
  final int index;
  final int imageCount;
  final bool isCover;
  final ValueChanged<String> onCoverSelected;
  final ValueChanged<String> onRemove;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final semanticsActions = <CustomSemanticsAction, VoidCallback>{
      CustomSemanticsAction(label: '移除图片'): () => onRemove(image.mediaId),
      if (index > 0)
        CustomSemanticsAction(label: '向前移动'): () => onMove(index - 1),
      if (index < imageCount - 1)
        CustomSemanticsAction(label: '向后移动'): () => onMove(index + 1),
    };
    return Semantics(
      container: true,
      button: true,
      selected: isCover,
      label: '图片 ${index + 1}${isCover ? '，当前封面' : '，点按设为封面'}',
      onTap: () => onCoverSelected(image.mediaId),
      customSemanticsActions: semanticsActions,
      child: ExcludeSemantics(
        child: SizedBox(
          width: 96,
          child: Padding(
            padding: EdgeInsets.only(right: tokens.space8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ReorderableDelayedDragStartListener(
                    index: index,
                    child: Material(
                      color: tokens.softPanel,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radius12),
                        side: BorderSide(
                          color: isCover
                              ? tokens.brandForeground
                              : tokens.border,
                          width: isCover ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onCoverSelected(image.mediaId),
                        child: WenyouCachedImage(
                          imageUrl: image.url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isCover)
                  Positioned(
                    left: tokens.space4,
                    bottom: tokens.space4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.brandSurface,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space8,
                          vertical: tokens.space4,
                        ),
                        child: Text(
                          '封面',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: tokens.onBrandSurface),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: -4,
                  right: 0,
                  child: Tooltip(
                    message: '移除图片 ${index + 1}',
                    child: SizedBox.square(
                      dimension: tokens.minimumTouchTarget,
                      child: InkResponse(
                        onTap: () => onRemove(image.mediaId),
                        radius: tokens.minimumTouchTarget / 2,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: tokens.text.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox.square(
                              dimension: 24,
                              child: Center(
                                child: WenyouIcon(
                                  WenyouIconIds.actionClose,
                                  size: 14,
                                  color: tokens.background,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

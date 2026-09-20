import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/media_ui.dart';

class MomentComposeImageStrip extends StatelessWidget {
  const MomentComposeImageStrip({
    required this.images,
    required this.coverMediaId,
    required this.uploadState,
    required this.pendingImages,
    required this.onAdd,
    required this.onRetry,
    required this.order,
    required this.onCoverSelected,
    required this.onRemove,
    required this.onReorder,
    super.key,
  });

  final List<UploadedEditorImage> images;
  final String? coverMediaId;
  final MediaUploadTaskState uploadState;
  final List<MomentPendingComposeImage> pendingImages;
  final VoidCallback? onAdd;
  final ValueChanged<String> onRetry;
  final List<String> order;
  final ValueChanged<String> onCoverSelected;
  final ValueChanged<String> onRemove;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (images.isEmpty &&
        pendingImages.isEmpty &&
        !uploadState.isBusy &&
        uploadState.failure == null) {
      return Align(
        key: const Key('moment-compose-images'),
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: tokens.minimumTouchTarget,
          child: OutlinedButton.icon(
            key: const Key('moment-compose-add-image'),
            onPressed: onAdd,
            icon: const WenyouIcon(WenyouIconIds.actionAddImage, size: 18),
            label: const Text('添加图片'),
          ),
        ),
      );
    }
    return Column(
      key: const Key('moment-compose-images'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '图片',
                style: Theme.of(context).textTheme.wenyouCompactTitle,
              ),
            ),
            Text(
              '${images.length + pendingImages.length}/9',
              key: const Key('moment-compose-image-count'),
              style: Theme.of(
                context,
              ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
            ),
          ],
        ),
        SizedBox(height: tokens.space8),
        SizedBox(
          height: 88,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  key: const Key('moment-compose-image-list'),
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false,
                  itemCount: order.length,
                  onReorderItem: onReorder,
                  itemBuilder: (context, index) {
                    final id = order[index];
                    final pending = pendingImages
                        .where((item) => item.id == id)
                        .firstOrNull;
                    if (pending != null) {
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(id),
                        index: index,
                        child: MomentPendingImageThumbnail(
                          pending: pending,
                          index: index,
                          isCover: id == coverMediaId,
                          onCover: () => onCoverSelected(id),
                          onRemove: () => onRemove(id),
                          onRetry: () => onRetry(id),
                        ),
                      );
                    }
                    return _ComposeThumbnail(
                      key: ValueKey(id),
                      image: images.firstWhere((image) => image.mediaId == id),
                      index: index,
                      imageCount: order.length,
                      isCover: id == coverMediaId,
                      onCoverSelected: onCoverSelected,
                      onRemove: onRemove,
                      onMove: (target) => onReorder(index, target),
                    );
                  },
                ),
              ),
              if (order.length < 9) SizedBox(width: tokens.space8),
              if (order.length < 9) _AddImageTile(onPressed: onAdd),
            ],
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: tokens.space4),
          Text(
            '点按选择封面，长按调整顺序',
            style: Theme.of(
              context,
            ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
          ),
        ],
      ],
    );
  }
}

class MomentPendingComposeImage {
  const MomentPendingComposeImage({
    required this.input,
    required this.id,
    required this.state,
    required this.completed,
    required this.active,
    required this.failed,
  });

  final String id;
  final MediaUploadInput input;
  final MediaUploadTaskState state;
  final bool completed;
  final bool active;
  final bool failed;
}

class MomentPendingImageThumbnail extends StatefulWidget {
  const MomentPendingImageThumbnail({
    required this.pending,
    required this.index,
    required this.onRemove,
    required this.onRetry,
    this.onCover,
    this.isCover = false,
    super.key,
  });
  final MomentPendingComposeImage pending;
  final int index;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final VoidCallback? onCover;
  final bool isCover;
  @override
  State<MomentPendingImageThumbnail> createState() => _PendingThumbnailState();
}

class _PendingThumbnailState extends State<MomentPendingImageThumbnail> {
  Timer? _timer;
  bool _showProgress = false;
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
    final tokens = context.wenyouTokens;
    final pending = widget.pending;
    final slow = pending.state.phase == MediaUploadTaskPhase.processingPending;
    final fraction = pending.state.phase == MediaUploadTaskPhase.uploading
        ? pending.state.progress?.fraction
        : null;
    return Semantics(
      image: true,
      selected: widget.isCover,
      label: '图片 ${widget.index + 1}${widget.isCover ? '，当前封面' : ''}',
      child: SizedBox(
        width: 112,
        child: Padding(
          padding: EdgeInsets.only(right: tokens.space8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: widget.onCover,
                  child: MediaUploadInputImage(
                    input: pending.input,
                    key: ValueKey('moment-local-thumbnail-${widget.index}'),
                    fit: BoxFit.cover,
                    cacheWidth: 264,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: tokens.softPanel,
                      child: WenyouIcon(
                        WenyouIconIds.actionImage,
                        color: tokens.mutedText,
                      ),
                    ),
                  ),
                ),
                if (widget.isCover)
                  Positioned(
                    left: 4,
                    top: 4,
                    child: ColoredBox(
                      color: tokens.brandSurface,
                      child: const Text('封面'),
                    ),
                  ),
                if (!pending.failed && !pending.completed && _showProgress)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: tokens.background,
                      child: fraction == null
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('${(fraction * 100).round()}%'),
                    ),
                  ),
                if (pending.failed)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: tokens.background,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(slow ? '图片准备较久' : '未完成'),
                          TextButton(
                            key: ValueKey('moment-retry-${pending.id}'),
                            onPressed: widget.onRetry,
                            child: Text(slow ? '继续' : '重试'),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    tooltip: '移除图片 ${widget.index + 1}',
                    onPressed: widget.onRemove,
                    icon: const WenyouIcon(WenyouIconIds.actionClose, size: 14),
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
  final bool reorderable = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final semanticsActions = <CustomSemanticsAction, VoidCallback>{
      CustomSemanticsAction(label: '移除图片'): () => onRemove(image.mediaId),
      if (reorderable && index > 0)
        CustomSemanticsAction(label: '向前移动'): () => onMove(index - 1),
      if (reorderable && index < imageCount - 1)
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
                  child: _maybeReorderable(
                    index,
                    Material(
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
                          imageUrl: image.previewUrls.first,
                          fallbackImageUrls: image.previewUrls
                              .skip(1)
                              .toList(growable: false),
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
                          style: Theme.of(context).textTheme.wenyouCaption
                              .copyWith(color: tokens.onBrandSurface),
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

  Widget _maybeReorderable(int index, Widget child) => reorderable
      ? ReorderableDelayedDragStartListener(index: index, child: child)
      : child;
}

MediaUploadTaskState aggregateMomentUploadState(
  List<MomentPendingComposeImage> pending,
) {
  final failure = pending
      .map((image) => image.state)
      .where((state) => state.failure != null)
      .firstOrNull;
  if (failure != null) return failure;
  return pending
          .map((image) => image.state)
          .where((state) => state.isBusy)
          .firstOrNull ??
      const MediaUploadTaskState();
}

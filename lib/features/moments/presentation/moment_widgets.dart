import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

class MomentContentPadding extends StatelessWidget {
  const MomentContentPadding({
    required this.child,
    this.top = 0,
    this.bottom = 0,
    super.key,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}

class MomentCardTile extends StatelessWidget {
  const MomentCardTile({
    required this.moment,
    required this.onTap,
    this.onAuthorTap,
    this.onLike,
    this.onBookmark,
    this.busy = false,
    super.key,
  });

  final MomentCard moment;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: Key('moment-open-${moment.id}'),
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(tokens.radius20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(tokens.radius20),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: moment.coverType == MomentCoverType.image
                        ? MomentCoverImage(media: moment.coverMedia!)
                        : MomentTextCover(
                            theme: moment.textCoverTheme,
                            title: moment.title,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.space16,
                    tokens.space16,
                    tokens.space16,
                    tokens.space12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moment.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (moment.contentExcerpt.isNotEmpty) ...[
                        SizedBox(height: tokens.space8),
                        Text(
                          moment.contentExcerpt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space12,
              0,
              tokens.space8,
              tokens.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: MomentAuthorLine(
                    author: moment.author,
                    createdAt: moment.createdAt,
                    onTap: onAuthorTap,
                  ),
                ),
                _MomentCountAction(
                  key: Key('moment-like-${moment.id}'),
                  icon: moment.viewerLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${moment.likeCount}',
                  selected: moment.viewerLiked,
                  onPressed: busy ? null : onLike,
                  tooltip: moment.viewerLiked ? '取消点赞' : '点赞',
                ),
                _MomentCountAction(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${moment.commentCount}',
                  onPressed: onTap,
                  tooltip: '查看评论',
                ),
                IconButton(
                  key: Key('moment-bookmark-${moment.id}'),
                  onPressed: busy ? null : onBookmark,
                  tooltip: moment.viewerBookmarked ? '取消收藏' : '收藏',
                  icon: Icon(
                    moment.viewerBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: moment.viewerBookmarked ? tokens.focus : null,
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

class MomentTextCover extends StatelessWidget {
  const MomentTextCover({required this.theme, required this.title, super.key});

  final MomentTextCoverTheme theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (theme) {
      MomentTextCoverTheme.rose => (
        WenyouFoundationPalette.accent,
        WenyouFoundationPalette.onAccent,
      ),
      MomentTextCoverTheme.lilac => (
        WenyouFoundationPalette.infoSoft,
        WenyouFoundationPalette.info,
      ),
      MomentTextCoverTheme.mint => (
        WenyouFoundationPalette.successSoft,
        WenyouFoundationPalette.success,
      ),
      MomentTextCoverTheme.amber => (
        WenyouFoundationPalette.warningSoft,
        WenyouFoundationPalette.warning,
      ),
    };
    return ColoredBox(
      color: background,
      child: Padding(
        padding: EdgeInsets.all(context.wenyouTokens.space24),
        child: Center(
          child: Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class MomentAuthorLine extends StatelessWidget {
  const MomentAuthorLine({
    required this.author,
    this.createdAt,
    this.onTap,
    super.key,
  });

  final MomentAuthor author;
  final DateTime? createdAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MomentAvatar(author: author, size: 32),
        SizedBox(width: tokens.space8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (createdAt != null)
                Text(
                  DateFormat('MM-dd HH:mm').format(createdAt!.toLocal()),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
            ],
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusPill),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space4),
        child: content,
      ),
    );
  }
}

class MomentAvatar extends StatelessWidget {
  const MomentAvatar({required this.author, this.size = 40, super.key});

  final MomentAuthor author;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.55,
        color: tokens.mutedText,
      ),
    );
    return Semantics(
      image: true,
      label: '${author.username} 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: author.avatarUrl == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: author.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class MomentGallery extends StatelessWidget {
  const MomentGallery({required this.images, super.key});

  final List<MomentMedia> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final tokens = context.wenyouTokens;
    final columns = images.length == 1
        ? 1
        : images.length == 2
        ? 2
        : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: tokens.space8,
        mainAxisSpacing: tokens.space8,
        childAspectRatio: images.length == 1
            ? (images.first.aspectRatio ?? 4 / 3).clamp(0.75, 1.8)
            : 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Semantics(
          button: true,
          image: true,
          label: '查看第 ${index + 1} 张动态图片，共 ${images.length} 张',
          child: Material(
            color: tokens.softPanel,
            borderRadius: BorderRadius.circular(tokens.radius12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('moment-image-$index'),
              onTap: () => openMomentGallery(context, images, index),
              child: CachedNetworkImage(
                imageUrl: image.bestContentUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, _, _) =>
                    Icon(Icons.broken_image_outlined, color: tokens.mutedText),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> openMomentGallery(
  BuildContext context,
  List<MomentMedia> images,
  int initialIndex,
) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          _MomentGalleryViewer(images: images, initialIndex: initialIndex),
    ),
  );
}

class _MomentGalleryViewer extends StatefulWidget {
  const _MomentGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<MomentMedia> images;
  final int initialIndex;

  @override
  State<_MomentGalleryViewer> createState() => _MomentGalleryViewerState();
}

class _MomentGalleryViewerState extends State<_MomentGalleryViewer> {
  late final PageController _pageController;
  late int _index;
  var _dragDistance = 0.0;
  var _zoomed = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.images.length}'),
        leading: IconButton(
          key: const Key('moment-gallery-close'),
          onPressed: () => Navigator.pop(context),
          tooltip: '关闭图片预览',
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _zoomed
            ? null
            : (details) => _dragDistance += details.delta.dy,
        onVerticalDragEnd: _zoomed
            ? null
            : (_) {
                if (_dragDistance > 120) Navigator.pop(context);
                _dragDistance = 0;
              },
        child: PageView.builder(
          controller: _pageController,
          physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
          onPageChanged: (index) => setState(() {
            _index = index;
            _zoomed = false;
          }),
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return _ZoomableMomentImage(
              key: ValueKey(widget.images[index].id),
              image: widget.images[index],
              onZoomChanged: (zoomed) {
                if (mounted && _zoomed != zoomed) {
                  setState(() => _zoomed = zoomed);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _ZoomableMomentImage extends StatefulWidget {
  const _ZoomableMomentImage({
    required this.image,
    required this.onZoomChanged,
    super.key,
  });

  final MomentMedia image;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableMomentImage> createState() => _ZoomableMomentImageState();
}

class _ZoomableMomentImageState extends State<_ZoomableMomentImage> {
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_reportZoom);
  }

  @override
  void dispose() {
    _transformationController
      ..removeListener(_reportZoom)
      ..dispose();
    super.dispose();
  }

  void _reportZoom() {
    widget.onZoomChanged(
      _transformationController.value.getMaxScaleOnAxis() > 1.01,
    );
  }

  void _toggleZoom() {
    final zoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    _transformationController.value = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()..scaleByDouble(2.5, 2.5, 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.image.url,
            fit: BoxFit.contain,
            placeholder: (_, _) => const CircularProgressIndicator(),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}

class MomentCoverImage extends StatelessWidget {
  const MomentCoverImage({required this.media, super.key});

  final MomentMedia media;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return CachedNetworkImage(
      imageUrl: media.bestFeedUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => ColoredBox(
        color: tokens.softPanel,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: tokens.softPanel,
        child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
      ),
    );
  }
}

class _MomentCountAction extends StatelessWidget {
  const _MomentCountAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.selected = false,
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '$tooltip，$label',
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: selected ? tokens.focus : null),
        label: Text(label),
        style: TextButton.styleFrom(
          minimumSize: Size(
            tokens.minimumTouchTarget,
            tokens.minimumTouchTarget,
          ),
          padding: EdgeInsets.symmetric(horizontal: tokens.space8),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

class MomentCardTile extends StatelessWidget {
  const MomentCardTile({
    required this.moment,
    required this.onTap,
    this.onAuthorTap,
    this.onLike,
    this.onBookmark,
    this.pendingAction,
    super.key,
  });

  final MomentCard moment;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final MomentInteractionAction? pendingAction;

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
                if (moment.coverType == MomentCoverType.image ||
                    moment.contentExcerpt.isNotEmpty)
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
                        if (moment.coverType == MomentCoverType.image)
                          Text(
                            moment.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.wenyouListTitle,
                          ),
                        if (moment.contentExcerpt.isNotEmpty) ...[
                          if (moment.coverType == MomentCoverType.image)
                            SizedBox(height: tokens.space8),
                          Text(
                            moment.contentExcerpt,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.wenyouCompactBody,
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
                      ? WenyouIconIds.actionLike
                      : WenyouIconIds.actionLike,
                  label: formatWenyouCompactCount(moment.likeCount),
                  semanticValue: '${moment.likeCount}',
                  selected: moment.viewerLiked,
                  kind: WenyouInteractionKind.like,
                  pending: pendingAction == MomentInteractionAction.like,
                  onPressed: pendingAction == null ? onLike : null,
                  interactive: onLike != null,
                  tooltip: moment.viewerLiked ? '取消点赞' : '点赞',
                ),
                _MomentCountAction(
                  icon: WenyouIconIds.metricComments,
                  label: formatWenyouCompactCount(moment.commentCount),
                  semanticValue: '${moment.commentCount}',
                  onPressed: onTap,
                  tooltip: '查看评论',
                ),
                WenyouInteractionToggle(
                  key: Key('moment-bookmark-${moment.id}'),
                  kind: WenyouInteractionKind.bookmark,
                  selected: moment.viewerBookmarked,
                  pending: pendingAction == MomentInteractionAction.bookmark,
                  onPressed: pendingAction == null ? onBookmark : null,
                  interactive: onBookmark != null,
                  semanticLabel: moment.viewerBookmarked ? '取消收藏' : '收藏',
                  padding: EdgeInsets.symmetric(horizontal: tokens.space4),
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
    final tokens = context.wenyouTokens;
    final (background, foreground) = switch (theme) {
      MomentTextCoverTheme.rose => (
        tokens.accentedBackground,
        tokens.onAccentedBackground,
      ),
      MomentTextCoverTheme.lilac => (tokens.infoSoft, tokens.info),
      MomentTextCoverTheme.mint => (tokens.successSoft, tokens.success),
      MomentTextCoverTheme.amber => (tokens.warningSoft, tokens.warning),
    };
    return ColoredBox(
      color: background,
      child: Padding(
        padding: EdgeInsets.all(tokens.space24),
        child: Center(
          child: Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.wenyouPageTitle.copyWith(color: foreground),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      author.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.wenyouLabel,
                    ),
                  ),
                  SizedBox(width: tokens.space4),
                  WenyouLevelBadge(level: author.level),
                ],
              ),
              if (createdAt != null)
                WenyouTimeText(
                  value: createdAt!,
                  semanticsPrefix: '发布时间：',
                  style: Theme.of(context).textTheme.wenyouUtilityCaption
                      .copyWith(color: tokens.mutedText),
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
    return WenyouAvatar(
      username: author.username,
      avatarUrl: author.avatarUrl,
      size: size,
    );
  }
}

class MomentGallery extends ConsumerStatefulWidget {
  const MomentGallery({
    required this.momentId,
    required this.images,
    this.coverMedia,
    super.key,
  });

  final String momentId;
  final List<MomentMedia> images;
  final MomentMedia? coverMedia;

  @override
  ConsumerState<MomentGallery> createState() => _MomentGalleryState();
}

class _MomentGalleryState extends ConsumerState<MomentGallery> {
  static const _minimumAspectRatio = 3 / 4;
  static const _maximumAspectRatio = 16 / 10;
  static const _maximumStageHeight = 672.0;

  late final PageController _pageController;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant MomentGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    String? currentImageId;
    if (_index < oldWidget.images.length) {
      currentImageId = oldWidget.images[_index].id;
    }
    final updatedIndex = currentImageId == null
        ? 0
        : widget.images.indexWhere((image) => image.id == currentImageId);
    final nextIndex = updatedIndex < 0 ? 0 : updatedIndex;
    if (_index == nextIndex) return;
    _index = nextIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(_index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const SizedBox.shrink();
    final stickersEnabled = ref.watch(stickersEnabledProvider);
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    final tokens = context.wenyouTokens;
    final ratio =
        (widget.coverMedia?.aspectRatio ?? images.first.aspectRatio ?? 1)
            .clamp(_minimumAspectRatio, _maximumAspectRatio)
            .toDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight = MediaQuery.sizeOf(context).height * 0.72;
        final maximumHeight = math.min(viewportHeight, _maximumStageHeight);
        final stageHeight = math.min(
          constraints.maxWidth / ratio,
          maximumHeight,
        );
        return Semantics(
          container: true,
          label: images.length == 1
              ? '动态图片，共 1 张'
              : '动态图片轮播，共 ${images.length} 张，左右滑动切换',
          child: SizedBox(
            key: const Key('moment-detail-gallery'),
            width: double.infinity,
            height: stageHeight,
            child: Material(
              color: tokens.softPanel,
              borderRadius: BorderRadius.circular(tokens.radius12),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                button: true,
                label: '查看第 ${_index + 1} 张动态图片，共 ${images.length} 张',
                child: GestureDetector(
                  key: const Key('moment-detail-image'),
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTap: () => openMomentGallery(
                    context,
                    images,
                    _index,
                    onAddToStickers: !stickersEnabled || !authenticated
                        ? null
                        : (item) => ref
                              .read(
                                stickerCollectionControllerProvider.notifier,
                              )
                              .importSourceForFeedback(
                                StickerMomentImageSource(
                                  momentId: widget.momentId,
                                  mediaId: item.id! as String,
                                ),
                              ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        key: const Key('moment-detail-carousel'),
                        controller: _pageController,
                        physics: images.length == 1
                            ? const NeverScrollableScrollPhysics()
                            : const PageScrollPhysics(),
                        onPageChanged: (index) =>
                            setState(() => _index = index),
                        itemCount: images.length,
                        itemBuilder: (context, index) => _MomentGalleryPage(
                          image: images[index],
                          index: index,
                          imageCount: images.length,
                        ),
                      ),
                      if (images.length > 1)
                        Positioned(
                          right: tokens.space8,
                          bottom: tokens.space8,
                          child: IgnorePointer(
                            child: Semantics(
                              liveRegion: true,
                              label: '第 ${_index + 1} 张，共 ${images.length} 张',
                              excludeSemantics: true,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: tokens.text.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(
                                    tokens.radiusPill,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: tokens.space8,
                                    vertical: tokens.space4,
                                  ),
                                  child: Text(
                                    '${_index + 1} / ${images.length}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .wenyouUtilityCaption
                                        .copyWith(
                                          color: tokens.background,
                                          fontWeight: FontWeight.w700,
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
          ),
        );
      },
    );
  }
}

class _MomentGalleryPage extends StatelessWidget {
  const _MomentGalleryPage({
    required this.image,
    required this.index,
    required this.imageCount,
  });

  final MomentMedia image;
  final int index;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      key: Key('moment-image-$index'),
      image: true,
      label: '第 ${index + 1} 张动态图片，共 $imageCount 张',
      excludeSemantics: true,
      child: WenyouCachedImage(
        key: Key('moment-content-image-$index'),
        imageUrl: image.bestContentUrl,
        fallbackImageUrls: image.contentUrls.skip(1).toList(growable: false),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        placeholder: (_, _) => _MomentImageStatus(
          icon: const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: '第 ${index + 1} 张图片加载中',
        ),
        errorWidget: (_, _, _) => _MomentImageStatus(
          icon: WenyouIcon(
            WenyouIconIds.statusImageUnavailable,
            color: tokens.mutedText,
          ),
          label: '第 ${index + 1} 张图片加载失败',
          detail: '点按查看原图',
        ),
      ),
    );
  }
}

class _MomentImageStatus extends StatelessWidget {
  const _MomentImageStatus({
    required this.icon,
    required this.label,
    this.detail,
  });

  final Widget icon;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: tokens.space8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.wenyouCaption,
            ),
            if (detail != null) ...[
              SizedBox(height: tokens.space4),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> openMomentGallery(
  BuildContext context,
  List<MomentMedia> images,
  int initialIndex, {
  Future<String> Function(WenyouImageViewerItem item)? onAddToStickers,
}) {
  return pushWenyouFullscreenPage<void>(
    context: context,
    builder: (_) => ContentImageViewerPage(
      items: [
        for (final image in images)
          WenyouImageViewerItem(
            id: image.id,
            url: image.url,
            fallbackUrls: image.contentUrls
                .where((url) => url != image.url)
                .toList(growable: false),
            semanticLabel: '动态图片',
          ),
      ],
      initialIndex: initialIndex,
      closeKey: const Key('moment-gallery-close'),
      onAddToStickers: onAddToStickers,
    ),
  );
}

class MomentCoverImage extends StatelessWidget {
  const MomentCoverImage({required this.media, super.key});

  final MomentMedia media;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouCachedImage(
      imageUrl: media.bestFeedUrl,
      fallbackImageUrls: media.feedUrls.skip(1).toList(growable: false),
      fit: BoxFit.cover,
      cacheWidth: 320,
      placeholder: (_, _) => ColoredBox(
        color: tokens.softPanel,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: tokens.softPanel,
        child: WenyouIcon(
          WenyouIconIds.statusImageUnavailable,
          color: tokens.mutedText,
        ),
      ),
    );
  }
}

class _MomentCountAction extends StatelessWidget {
  const _MomentCountAction({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.semanticValue,
    this.selected = false,
    this.kind,
    this.pending = false,
    this.onPressed,
    this.interactive = true,
    super.key,
  });

  final String icon;
  final String label;
  final String tooltip;
  final String? semanticValue;
  final bool selected;
  final WenyouInteractionKind? kind;
  final bool pending;
  final VoidCallback? onPressed;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (kind case final interactionKind?) {
      return WenyouInteractionToggle(
        kind: interactionKind,
        selected: selected,
        pending: pending,
        onPressed: onPressed,
        interactive: interactive,
        semanticLabel: '$tooltip，${semanticValue ?? label}',
        supporting: Text(
          label,
          style: Theme.of(context).textTheme.wenyouUtilityCaption,
        ),
      );
    }
    return Semantics(
      button: true,
      label: '$tooltip，${semanticValue ?? label}',
      child: TextButton.icon(
        onPressed: onPressed,
        icon: WenyouIcon(icon, size: 20, color: selected ? tokens.focus : null),
        label: Text(
          label,
          style: Theme.of(context).textTheme.wenyouUtilityLabel,
        ),
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

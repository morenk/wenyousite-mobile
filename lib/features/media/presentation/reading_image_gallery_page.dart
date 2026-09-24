import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/content_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_image_viewer_page.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_playback_image.dart';
import 'package:wenyousite_mobile/features/media/application/reading_gallery_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

export 'package:wenyousite_mobile/features/media/domain/reading_image_gallery.dart';

class ReadingGalleryTarget {
  const ReadingGalleryTarget({
    required this.scope,
    required this.scopeId,
    this.order = ReadingGalleryOrder.oldest,
    this.authorId,
  });
  final ReadingGalleryScope scope;
  final String scopeId;
  final ReadingGalleryOrder order;
  final String? authorId;
}

Future<void> openReadingImageGallery(
  BuildContext context, {
  required ReadingGalleryTarget target,
  required String sourceId,
  required int version,
  required int imageIndex,
  required String url,
  MediaDisplay? display,
  String? mediaId,
  bool animated = false,
  List<String> previewUrls = const [],
  List<ReadingGalleryImage>? initialImages,
  Future<String> Function(ReadingGalleryImage image)? onCollect,
}) async {
  final router = GoRouter.maybeOf(context);
  final bucket = PageStorage.maybeOf(context);
  Widget buildViewer(BuildContext context) => ReadingImageGalleryPage(
    request: ReadingGalleryRequest(
      scope: target.scope,
      scopeId: target.scopeId,
      anchorId: sourceId,
      anchorVersion: version,
      anchorIndex: imageIndex,
      order: target.order,
      authorId: target.authorId,
    ),
    initialImage:
        initialImages?[imageIndex] ??
        ReadingGalleryImage(
          id: 'local-click',
          sourceId: sourceId,
          sourceVersion: version,
          imageIndex: imageIndex,
          imageCount: 1,
          url: url,
          display: display,
          mediaId: mediaId,
          animated: animated,
          previewUrls: previewUrls,
        ),
    initialImages: initialImages,
    onCollect: onCollect,
  );
  final location = await pushWenyouFullscreenPage<String>(
    context: context,
    builder: (context) => bucket == null
        ? buildViewer(context)
        : PageStorage(bucket: bucket, child: buildViewer(context)),
  );
  if (location != null && context.mounted) await router?.push<void>(location);
}

class ReadingImageGalleryPage extends ConsumerStatefulWidget {
  const ReadingImageGalleryPage({
    required this.request,
    required this.initialImage,
    this.initialImages,
    this.onCollect,
    super.key,
  });
  final ReadingGalleryRequest request;
  final ReadingGalleryImage initialImage;
  final List<ReadingGalleryImage>? initialImages;
  final Future<String> Function(ReadingGalleryImage image)? onCollect;

  @override
  ConsumerState<ReadingImageGalleryPage> createState() =>
      _ReadingImageGalleryPageState();
}

class _ReadingImageGalleryPageState
    extends ConsumerState<ReadingImageGalleryPage> {
  late final ReadingGalleryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReadingGalleryController(
      repository: ref.read(readingGalleryRepositoryProvider),
      request: widget.request,
      initialImage: widget.initialImage,
      initialImages: widget.initialImages,
    );
    _controller.addListener(_changed);
    unawaited(
      _controller.start().then((_) {
        if (mounted && _controller.initialized) {
          _select(_controller.currentIndex);
        }
      }),
    );
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    _controller.select(index);
    if (_controller.failure != null) return;
    if (index <= 2) {
      unawaited(_controller.loadMore(ReadingGalleryDirection.previous));
    }
    if (index >= _controller.images.length - 3) {
      unawaited(_controller.loadMore(ReadingGalleryDirection.next));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(viewerScopeProvider, (previous, next) {
      if (previous != null && previous != next) _controller.invalidate();
    });
    final authenticated = ref.watch(
      sessionControllerProvider.select((session) => session.isAuthenticated),
    );
    final currentCanCollect =
        widget.request.scope == ReadingGalleryScope.subthread ||
        widget.request.scope == ReadingGalleryScope.postReplies ||
        _controller.current?.mediaId != null;
    if (_controller.unavailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('查看图片')),
        body: const Center(child: Text('图片暂时不可见')),
      );
    }
    final images = _controller.images;
    return ContentImageViewerPage(
      closeKey: const Key('moment-gallery-close'),
      items: [
        for (final image in images)
          WenyouImageViewerItem(
            id: image.occurrenceKey,
            url: image.url,
            display: image.display,
            semanticLabel: _label(image),
          ),
      ],
      initialIndex: _controller.currentIndex,
      imageBuilder: (context, index, current) {
        final image = images[index];
        if (!image.animated && !(image.display?.animated ?? false)) return null;
        final local = (widget.initialImages ?? [widget.initialImage])
            .where((candidate) => candidate.sameOccurrence(image))
            .firstOrNull;
        return WenyouPlaybackImage(
          previewUrls: local?.previewUrls ?? image.previewUrls,
          animationUrl: image.display?.url ?? image.url,
          allowPlayback: current,
          foregroundColor: context.wenyouTokens.onImageViewerBackground,
          width: double.infinity,
          height: double.infinity,
        );
      },
      titleBuilder: (index, _) =>
          _controller.initialized ||
              (widget.request.scope == ReadingGalleryScope.moment &&
                  widget.initialImages != null)
          ? _label(images[index])
          : '查看图片',
      onPageChanged: _select,
      onAddToStickers:
          !authenticated ||
              widget.onCollect == null ||
              !_controller.initialized ||
              !currentCanCollect
          ? null
          : (item) async {
              final image = images.firstWhere(
                (image) => image.occurrenceKey == item.id,
              );
              return widget.onCollect!(image);
            },
      extraActions: [
        if (_controller.initialized)
          IconButton(
            onPressed: () {
              final image = _controller.current!;
              final location = image.momentId != null
                  ? AppRouteLocations.moment(
                      image.momentId!,
                      commentId:
                          widget.request.scope == ReadingGalleryScope.moment
                          ? null
                          : image.sourceId,
                    )
                  : image.parentPostId != null
                  ? AppRouteLocations.postReplies(
                      image.threadId!,
                      image.parentPostId!,
                      postId: image.sourceId,
                    )
                  : image.floorNumber == null
                  ? AppRouteLocations.thread(
                      image.threadId!,
                      subthreadId: image.subthreadId!,
                    )
                  : AppRouteLocations.thread(
                      image.threadId!,
                      postId: image.sourceId,
                    );
              Navigator.pop(context, location);
            },
            tooltip: widget.request.scope == ReadingGalleryScope.moment
                ? '定位到动态'
                : widget.request.scope == ReadingGalleryScope.momentComments ||
                      widget.request.scope == ReadingGalleryScope.momentReplies
                ? '定位到所在评论'
                : widget.request.scope == ReadingGalleryScope.postReplies
                ? '定位到所在回复'
                : _controller.current!.floorNumber == null
                ? '定位到所在正文'
                : '定位到所在楼层',
            icon: const WenyouIcon(WenyouIconIds.navigationExplore),
          ),
      ],
      bottomOverlay: _controller.needsReload
          ? Text(
              '内容已更新，请关闭图片后重新打开',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.wenyouTokens.onImageViewerBackground,
              ),
            )
          : _controller.failure != null
          ? TextButton(
              onPressed: () => unawaited(
                _controller.retry().then((_) {
                  if (mounted && _controller.initialized) {
                    _select(_controller.currentIndex);
                  }
                }),
              ),
              child: const Text('图集加载失败，重试'),
            )
          : null,
    );
  }

  String _label(ReadingGalleryImage image) {
    final position = '${image.imageIndex + 1} / ${image.imageCount}';
    return switch (widget.request.scope) {
      ReadingGalleryScope.moment => position,
      ReadingGalleryScope.subthread =>
        '${image.floorNumber == null ? '正文' : '第 ${image.floorNumber} 楼'} · $position',
      ReadingGalleryScope.postReplies => '楼中楼回复 · $position',
      ReadingGalleryScope.momentComments => '评论 · $position',
      ReadingGalleryScope.momentReplies => '评论回复 · $position',
    };
  }
}

import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_models.dart';

ThreadFeedCardModel mapThreadFeedCardResponse(
  HomeThreadListItemResponseDto item,
) {
  final preview = item.preview.trim();
  return ThreadFeedCardModel(
    id: item.id,
    title: item.title,
    categorySlug: item.category,
    status: _mapHomeThreadStatus(item.status),
    isPinned: item.pinned,
    isPrivate:
        item.visibility == HomeThreadListItemResponseDtoVisibilityEnum.PRIVATE,
    isPublished: item.published,
    ownerId: item.owner.id,
    ownerName: item.owner.username,
    ownerAvatarUrl: _safeHttpUrl(item.owner.avatar),
    ownerLevel: item.owner.level.toInt(),
    preview: preview.isEmpty ? null : preview,
    tags: item.topicTags
        .map(
          (relation) =>
              ThreadFeedTag(id: relation.tag.id, name: relation.tag.name),
        )
        .toList(growable: false),
    coverImageUrls: item.coverImages
        .where((url) {
          final uri = Uri.tryParse(url);
          return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
        })
        .take(1)
        .toList(growable: false),
    coverMedia: mapThreadFeedCoverMedia(item.coverMedia, item.coverImages),
    memberCount: item.count.members.toInt(),
    playerCount: item.count.players.toInt(),
    postCount: item.count.posts.toInt(),
    tipTotal: item.tipTotal,
    lastActivityAt: latestThreadActivityAt(
      updatedAt: item.updatedAt,
      defaultSubthreadLastPostAt: item.defaultSubthread?.lastPostAt,
    ),
  );
}

ThreadFeedCoverMedia? mapThreadFeedCoverMedia(
  ThreadCoverMediaResponseDto? media,
  Iterable<String> coverImages,
) {
  if (media == null || coverImages.isEmpty) return null;
  String? safeUrl(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return normalized;
  }

  final url = safeUrl(media.url);
  if (url == null || url != safeUrl(coverImages.first)) return null;
  final poster = safeUrl(media.posterUrl);
  final variants = <ThreadFeedCoverPreviewVariant>[];
  if (media.animated == true && poster != null && poster != url) {
    for (final variant
        in media.previewVariants?.take(2) ??
            <ThreadCoverPreviewVariantResponseDto>[]) {
      final previewUrl = safeUrl(variant.url);
      if (previewUrl == null ||
          previewUrl == url ||
          previewUrl == poster ||
          variant.width < 1 ||
          variant.width > 800 ||
          variant.height < 1 ||
          variant.height > 800 ||
          variant.bytes < 1 ||
          variant.bytes > 32 * 1024 * 1024 ||
          variants.any((item) => item.url == previewUrl)) {
        continue;
      }
      variants.add(
        ThreadFeedCoverPreviewVariant(
          url: previewUrl,
          width: variant.width,
          height: variant.height,
          bytes: variant.bytes,
        ),
      );
    }
    variants.sort((a, b) {
      final area = (a.width * a.height).compareTo(b.width * b.height);
      if (area != 0) return area;
      final size = a.bytes.compareTo(b.bytes);
      return size != 0 ? size : a.url.compareTo(b.url);
    });
  }
  return ThreadFeedCoverMedia(
    url: url,
    animated: media.animated,
    posterUrl: media.animated != false && poster == url ? null : poster,
    previewVariants: variants.take(2).toList(growable: false),
  );
}

String? _safeHttpUrl(String? value) {
  if (value == null) return null;
  final uri = Uri.tryParse(value);
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  return value;
}

ThreadFeedStatus _mapHomeThreadStatus(
  HomeThreadListItemResponseDtoStatusEnum value,
) {
  if (value == HomeThreadListItemResponseDtoStatusEnum.RECRUITING) {
    return ThreadFeedStatus.recruiting;
  }
  if (value == HomeThreadListItemResponseDtoStatusEnum.CLOSED) {
    return ThreadFeedStatus.closed;
  }
  if (value == HomeThreadListItemResponseDtoStatusEnum.FINISHED) {
    return ThreadFeedStatus.finished;
  }
  return ThreadFeedStatus.unknown;
}

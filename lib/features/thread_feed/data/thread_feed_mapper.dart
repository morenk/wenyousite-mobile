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

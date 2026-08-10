import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_feed_models.dart';

HomeThreadCardModel mapHomeThreadCardResponse(
  HomeThreadListItemResponseDto item,
) {
  final preview = item.preview?.trim();
  return HomeThreadCardModel(
    id: item.id,
    title: item.title,
    categorySlug: item.category,
    status: _mapHomeThreadStatus(item.status),
    isPinned: item.pinned,
    ownerId: item.owner.id,
    ownerName: item.owner.username,
    ownerAvatarUrl: item.owner.avatar,
    ownerLevel: item.owner.level.toInt(),
    preview: preview == null || preview.isEmpty ? null : preview,
    tags: item.topicTags
        .map(
          (relation) =>
              HomeThreadTag(id: relation.tag.id, name: relation.tag.name),
        )
        .toList(growable: false),
    coverImageUrls: item.coverImages
        .where((url) {
          final uri = Uri.tryParse(url);
          return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
        })
        .take(3)
        .toList(growable: false),
    memberCount: item.count.members.toInt(),
    playerCount: item.count.players.toInt(),
    postCount: item.count.posts.toInt(),
    tipTotal: item.tipTotal,
    lastActivityAt: item.defaultSubthread?.lastPostAt ?? item.updatedAt,
  );
}

HomeThreadStatus _mapHomeThreadStatus(
  HomeThreadListItemResponseDtoStatusEnum value,
) {
  if (value == HomeThreadListItemResponseDtoStatusEnum.RECRUITING) {
    return HomeThreadStatus.recruiting;
  }
  if (value == HomeThreadListItemResponseDtoStatusEnum.CLOSED) {
    return HomeThreadStatus.closed;
  }
  if (value == HomeThreadListItemResponseDtoStatusEnum.FINISHED) {
    return HomeThreadStatus.finished;
  }
  return HomeThreadStatus.unknown;
}

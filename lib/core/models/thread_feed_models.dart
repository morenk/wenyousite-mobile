export 'package:wenyousite_mobile/core/models/thread_category_presentation.dart'
    show HomeCategory;

enum HomeThreadStatus {
  recruiting('招募中'),
  closed('已停招'),
  finished('已完结'),
  unknown('状态未知');

  const HomeThreadStatus(this.label);

  final String label;
}

class HomeThreadTag {
  const HomeThreadTag({required this.id, required this.name});

  final String id;
  final String name;
}

class ThreadFeedCardModel {
  const ThreadFeedCardModel({
    required this.id,
    required this.title,
    required this.status,
    required this.ownerName,
    required this.ownerLevel,
    required this.memberCount,
    required this.postCount,
    this.isPinned = false,
    this.isPrivate = false,
    this.isPublished = true,
    this.ownerId = '',
    this.tags = const [],
    this.coverImageUrls = const [],
    this.playerCount,
    this.tipTotal = '0',
    this.createdAt,
    this.lastActivityAt,
    this.categorySlug,
    this.ownerAvatarUrl,
    this.preview,
  }) : assert(createdAt != null || lastActivityAt != null);

  final String id;
  final String title;
  final String? categorySlug;
  final HomeThreadStatus status;
  final bool isPinned;
  final bool isPrivate;
  final bool isPublished;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int ownerLevel;
  final String? preview;
  final List<HomeThreadTag> tags;
  final List<String> coverImageUrls;
  final int memberCount;
  final int? playerCount;
  final int postCount;
  final String tipTotal;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;

  DateTime get activityAt => lastActivityAt ?? createdAt!;
}

typedef HomeThreadCardModel = ThreadFeedCardModel;

DateTime latestThreadActivityAt({
  required DateTime updatedAt,
  DateTime? defaultSubthreadLastPostAt,
}) {
  if (defaultSubthreadLastPostAt != null &&
      defaultSubthreadLastPostAt.isAfter(updatedAt)) {
    return defaultSubthreadLastPostAt;
  }
  return updatedAt;
}

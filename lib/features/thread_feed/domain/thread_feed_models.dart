export 'package:wenyousite_mobile/features/thread_feed/domain/thread_category_presentation.dart'
    show ThreadCategory;

enum ThreadFeedStatus {
  recruiting('招募中'),
  closed('已停招'),
  finished('已完结'),
  unknown('状态未知');

  const ThreadFeedStatus(this.label);

  final String label;
}

class ThreadFeedTag {
  const ThreadFeedTag({required this.id, required this.name});

  final String id;
  final String name;
}

class ThreadFeedCoverMedia {
  const ThreadFeedCoverMedia({
    required this.url,
    this.animated,
    this.posterUrl,
    this.previewVariants = const [],
  });

  final String url;
  final bool? animated;
  final String? posterUrl;
  final List<ThreadFeedCoverPreviewVariant> previewVariants;

  String? get staticUrl => posterUrl;
  String? get animationUrl =>
      animated == true && staticUrl != null ? url : null;
}

class ThreadFeedCoverPreviewVariant {
  const ThreadFeedCoverPreviewVariant({
    required this.url,
    required this.width,
    required this.height,
    required this.bytes,
  });
  final String url;
  final int width;
  final int height;
  final int bytes;
}

/// 同时满足绘制宽高的最小档；没有足够大的档位时只选最大可用档。
String? selectThreadCoverAnimation({
  required List<ThreadFeedCoverPreviewVariant> variants,
  required String? originalUrl,
  required double width,
  required double height,
  required double devicePixelRatio,
}) {
  if (originalUrl == null || variants.isEmpty) return originalUrl;
  final physicalWidth = width * devicePixelRatio;
  final physicalHeight = height * devicePixelRatio;
  for (final variant in variants) {
    if (variant.width >= physicalWidth && variant.height >= physicalHeight) {
      return variant.url;
    }
  }
  return variants.last.url;
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
    this.coverMedia,
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
  final ThreadFeedStatus status;
  final bool isPinned;
  final bool isPrivate;
  final bool isPublished;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int ownerLevel;
  final String? preview;
  final List<ThreadFeedTag> tags;
  final List<String> coverImageUrls;
  final ThreadFeedCoverMedia? coverMedia;
  final int memberCount;
  final int? playerCount;
  final int postCount;
  final String tipTotal;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;

  DateTime get activityAt => lastActivityAt ?? createdAt!;
}

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

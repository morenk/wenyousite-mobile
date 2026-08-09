import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum PublicUserContentTab {
  created('创建', '创建的主题'),
  played('参与', '以玩家身份参与的主题'),
  replies('回复', '最近公开回复'),
  bookmarks('收藏', '公开收藏的主题');

  const PublicUserContentTab(this.label, this.description);

  final String label;
  final String description;
}

enum PublicUserContentPhase { idle, loading, ready, failed }

enum PublicUserThreadStatus { recruiting, closed, finished, unknown }

class PublicUserProfileModel {
  const PublicUserProfileModel({
    required this.id,
    required this.username,
    required this.level,
    required this.followingCount,
    required this.followerCount,
    required this.receivedTipTotal,
    required this.receivedTipCount,
    required this.showRecentReplies,
    required this.showPlayedThreads,
    required this.showBookmarks,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isBlocked,
    required this.isBlockedBy,
    required this.isDeactivated,
    this.avatarUrl,
    this.bio,
    this.createdAt,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int level;
  final int followingCount;
  final int followerCount;
  final String receivedTipTotal;
  final int receivedTipCount;
  final bool showRecentReplies;
  final bool showPlayedThreads;
  final bool showBookmarks;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isBlocked;
  final bool isBlockedBy;
  final bool isDeactivated;
  final DateTime? createdAt;

  List<PublicUserContentTab> get availableContentTabs => [
    PublicUserContentTab.created,
    if (showPlayedThreads) PublicUserContentTab.played,
    if (showRecentReplies) PublicUserContentTab.replies,
    if (showBookmarks) PublicUserContentTab.bookmarks,
  ];
}

class PublicUserThreadModel {
  const PublicUserThreadModel({
    required this.id,
    required this.title,
    required this.status,
    required this.isPrivate,
    required this.ownerName,
    required this.ownerLevel,
    required this.createdAt,
    required this.memberCount,
    required this.postCount,
    this.categorySlug,
  });

  final String id;
  final String title;
  final String? categorySlug;
  final PublicUserThreadStatus status;
  final bool isPrivate;
  final String ownerName;
  final int ownerLevel;
  final DateTime createdAt;
  final int memberCount;
  final int postCount;
}

class PublicUserReplyModel {
  const PublicUserReplyModel({
    required this.id,
    required this.threadId,
    required this.threadTitle,
    required this.subthreadId,
    required this.subthreadTitle,
    required this.preview,
    required this.createdAt,
    this.floorNumber,
    this.parentPostId,
  });

  final String id;
  final String threadId;
  final String threadTitle;
  final String subthreadId;
  final String subthreadTitle;
  final String preview;
  final DateTime createdAt;
  final int? floorNumber;
  final String? parentPostId;
}

class PublicUserContentSection<T> {
  const PublicUserContentSection({
    this.phase = PublicUserContentPhase.idle,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final PublicUserContentPhase phase;
  final List<T> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
}

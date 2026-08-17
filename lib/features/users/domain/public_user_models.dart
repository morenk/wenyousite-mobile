import 'package:wenyousite_mobile/core/models/thread_feed_models.dart';
import 'package:wenyousite_mobile/features/users/domain/profile_cover_models.dart';

enum PublicUserContentTab {
  created('创建', '创建的主题'),
  played('参与', '以玩家身份参与的主题'),
  replies('回复', '最近公开回复'),
  bookmarks('收藏', '公开收藏的主题');

  const PublicUserContentTab(this.label, this.description);

  final String label;
  final String description;
}

typedef PublicUserThreadStatus = HomeThreadStatus;

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
    this.profileCover,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final ProfileCoverModel? profileCover;
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

class PublicUserActivitySummary {
  const PublicUserActivitySummary({
    required this.momentCount,
    required this.createdThreadCount,
    required this.playedThreadCount,
    required this.replyCount,
  });

  final int momentCount;
  final int createdThreadCount;
  final int? playedThreadCount;
  final int? replyCount;
}

typedef PublicUserThreadModel = ThreadFeedCardModel;

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

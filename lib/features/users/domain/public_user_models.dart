class PublicUserProfileModel {
  const PublicUserProfileModel({
    required this.id,
    required this.username,
    required this.level,
    required this.followingCount,
    required this.followerCount,
    required this.receivedTipTotal,
    required this.receivedTipCount,
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
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isBlocked;
  final bool isBlockedBy;
  final bool isDeactivated;
  final DateTime? createdAt;
}

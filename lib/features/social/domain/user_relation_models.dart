class UserRelationTarget {
  const UserRelationTarget({
    required this.userId,
    required this.username,
    required this.isFollowing,
    required this.isBlocked,
    required this.isBlockedBy,
    required this.followerCount,
  });

  final String userId;
  final String username;
  final bool isFollowing;
  final bool isBlocked;
  final bool isBlockedBy;
  final int followerCount;

  @override
  bool operator ==(Object other) {
    return other is UserRelationTarget &&
        other.userId == userId &&
        other.username == username &&
        other.isFollowing == isFollowing &&
        other.isBlocked == isBlocked &&
        other.isBlockedBy == isBlockedBy &&
        other.followerCount == followerCount;
  }

  @override
  int get hashCode => Object.hash(
    userId,
    username,
    isFollowing,
    isBlocked,
    isBlockedBy,
    followerCount,
  );
}

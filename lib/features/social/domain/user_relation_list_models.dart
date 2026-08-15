enum UserRelationListKind { following, followers, blocks }

class UserRelationListTarget {
  const UserRelationListTarget.public({
    required this.kind,
    required this.userId,
  }) : assert(userId != null);

  const UserRelationListTarget.current({required this.kind}) : userId = null;

  final UserRelationListKind kind;
  final String? userId;

  bool get isCurrentUser => userId == null;

  @override
  bool operator ==(Object other) {
    return other is UserRelationListTarget &&
        other.kind == kind &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(kind, userId);
}

class UserRelationListItem {
  const UserRelationListItem({
    required this.userId,
    required this.username,
    required this.level,
    required this.relatedAt,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final int level;
  final DateTime relatedAt;
}

enum ThreadSubscriptionType { thread, user }

class ThreadSubscriptionRecord {
  const ThreadSubscriptionRecord({
    required this.id,
    required this.threadId,
    required this.type,
    required this.createdAt,
    this.targetUserId,
  });

  final String id;
  final String threadId;
  final ThreadSubscriptionType type;
  final String? targetUserId;
  final DateTime createdAt;
}

class ThreadSubscriptionCandidate {
  const ThreadSubscriptionCandidate({
    required this.userId,
    required this.username,
    required this.level,
    this.avatarUrl,
  });

  final String userId;
  final String username;
  final int level;
  final String? avatarUrl;
}

enum ThreadInvitationStatus {
  recruiting('招募中'),
  closed('已停招'),
  finished('已完结'),
  unknown('状态未知');

  const ThreadInvitationStatus(this.label);

  final String label;
}

class ThreadInvitationLink {
  const ThreadInvitationLink({
    required this.id,
    required this.threadId,
    required this.token,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String token;
  final Uri url;
  final DateTime createdAt;
}

class ThreadInvitationPreview {
  const ThreadInvitationPreview({
    required this.threadId,
    required this.title,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    required this.memberCount,
    required this.createdAt,
    required this.alreadyJoined,
    this.categorySlug,
    this.ownerAvatarUrl,
  });

  final String threadId;
  final String title;
  final String? categorySlug;
  final ThreadInvitationStatus status;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final int memberCount;
  final DateTime createdAt;
  final bool alreadyJoined;

  ThreadInvitationPreview copyWith({bool? alreadyJoined}) {
    return ThreadInvitationPreview(
      threadId: threadId,
      title: title,
      categorySlug: categorySlug,
      status: status,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
      memberCount: memberCount,
      createdAt: createdAt,
      alreadyJoined: alreadyJoined ?? this.alreadyJoined,
    );
  }
}

class ThreadInvitationJoinResult {
  const ThreadInvitationJoinResult({
    required this.memberId,
    required this.threadId,
    required this.threadTitle,
    required this.userId,
  });

  final String memberId;
  final String threadId;
  final String threadTitle;
  final String userId;
}

enum ThreadMemberManagementRole {
  owner('楼主'),
  collaborator('协作者'),
  participant('参与人'),
  unknown('未知身份');

  const ThreadMemberManagementRole(this.label);

  final String label;
}

class ThreadMemberManagementMember {
  const ThreadMemberManagementMember({
    required this.id,
    required this.userId,
    required this.username,
    required this.level,
    required this.role,
    required this.playerMarked,
    required this.joinedAt,
    this.avatarUrl,
  });

  final String id;
  final String userId;
  final String username;
  final int level;
  final String? avatarUrl;
  final ThreadMemberManagementRole role;
  final bool playerMarked;
  final DateTime joinedAt;
}

class ThreadMemberManagementBootstrap {
  const ThreadMemberManagementBootstrap({
    required this.threadId,
    required this.threadTitle,
    required this.actorIsOwner,
    required this.members,
  });

  final String threadId;
  final String threadTitle;
  final bool actorIsOwner;
  final List<ThreadMemberManagementMember> members;

  ThreadMemberManagementBootstrap replaceMember(
    ThreadMemberManagementMember updated,
  ) {
    return ThreadMemberManagementBootstrap(
      threadId: threadId,
      threadTitle: threadTitle,
      actorIsOwner: actorIsOwner,
      members: List.unmodifiable([
        for (final member in members)
          if (member.userId == updated.userId) updated else member,
      ]),
    );
  }
}

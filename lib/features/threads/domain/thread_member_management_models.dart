import 'package:wenyousite_mobile/core/network/api_failure.dart';

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

enum ThreadMemberManagementPhase { loading, ready, failed }

enum ThreadMemberManagementAction { player, role }

class ThreadMemberManagementState {
  const ThreadMemberManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.pendingUserId,
    this.pendingAction,
  });

  const ThreadMemberManagementState.loading()
    : this(phase: ThreadMemberManagementPhase.loading);

  final ThreadMemberManagementPhase phase;
  final ThreadMemberManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final String? pendingUserId;
  final ThreadMemberManagementAction? pendingAction;

  bool get isUpdating => pendingUserId != null;

  ThreadMemberManagementState copyWith({
    ThreadMemberManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? pendingUserId = _unset,
    Object? pendingAction = _unset,
  }) {
    return ThreadMemberManagementState(
      phase: phase ?? this.phase,
      bootstrap: identical(bootstrap, _unset)
          ? this.bootstrap
          : bootstrap as ThreadMemberManagementBootstrap?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      pendingUserId: identical(pendingUserId, _unset)
          ? this.pendingUserId
          : pendingUserId as String?,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as ThreadMemberManagementAction?,
    );
  }
}

class ThreadPlayerExitState {
  const ThreadPlayerExitState({this.isSubmitting = false, this.failure});

  final bool isSubmitting;
  final ApiFailure? failure;
}

const _unset = Object();

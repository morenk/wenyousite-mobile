import 'package:wenyousite_mobile/core/network/api_failure.dart';

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

enum UserRelationListPhase { loading, ready, failed }

class UserRelationListState {
  const UserRelationListState({
    required this.phase,
    this.items = const [],
    this.failure,
    this.pendingUnblockUserId,
    this.actionFailure,
  });

  const UserRelationListState.loading()
    : this(phase: UserRelationListPhase.loading);

  final UserRelationListPhase phase;
  final List<UserRelationListItem> items;
  final ApiFailure? failure;
  final String? pendingUnblockUserId;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingUnblockUserId != null;

  UserRelationListState copyWith({
    UserRelationListPhase? phase,
    List<UserRelationListItem>? items,
    ApiFailure? failure,
    String? pendingUnblockUserId,
    ApiFailure? actionFailure,
    bool clearPending = false,
    bool clearActionFailure = false,
  }) {
    return UserRelationListState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      failure: failure ?? this.failure,
      pendingUnblockUserId: clearPending
          ? null
          : (pendingUnblockUserId ?? this.pendingUnblockUserId),
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
    );
  }
}

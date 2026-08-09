import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum UserRelationAction { follow, block }

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

class UserRelationState {
  const UserRelationState({
    required this.isFollowing,
    required this.isBlocked,
    required this.isBlockedBy,
    required this.followerCount,
    this.pendingAction,
    this.failure,
    this.successMessage,
  });

  factory UserRelationState.fromTarget(UserRelationTarget target) {
    return UserRelationState(
      isFollowing: target.isFollowing,
      isBlocked: target.isBlocked,
      isBlockedBy: target.isBlockedBy,
      followerCount: target.followerCount,
    );
  }

  final bool isFollowing;
  final bool isBlocked;
  final bool isBlockedBy;
  final int followerCount;
  final UserRelationAction? pendingAction;
  final ApiFailure? failure;
  final String? successMessage;

  bool get isPending => pendingAction != null;

  UserRelationState copyWith({
    bool? isFollowing,
    bool? isBlocked,
    bool? isBlockedBy,
    int? followerCount,
    UserRelationAction? pendingAction,
    ApiFailure? failure,
    String? successMessage,
    bool clearPending = false,
    bool clearFeedback = false,
  }) {
    return UserRelationState(
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isBlockedBy: isBlockedBy ?? this.isBlockedBy,
      followerCount: followerCount ?? this.followerCount,
      pendingAction: clearPending
          ? null
          : (pendingAction ?? this.pendingAction),
      failure: clearFeedback ? null : (failure ?? this.failure),
      successMessage: clearFeedback
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

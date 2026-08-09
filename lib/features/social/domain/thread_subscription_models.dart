import 'package:wenyousite_mobile/core/network/api_failure.dart';

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

class ThreadSubscriptionTarget {
  const ThreadSubscriptionTarget({required this.threadId, this.viewerUserId});

  final String threadId;
  final String? viewerUserId;

  @override
  bool operator ==(Object other) {
    return other is ThreadSubscriptionTarget &&
        other.threadId == threadId &&
        other.viewerUserId == viewerUserId;
  }

  @override
  int get hashCode => Object.hash(threadId, viewerUserId);
}

enum ThreadSubscriptionPhase { loading, ready, failed }

class ThreadSubscriptionState {
  const ThreadSubscriptionState({
    required this.phase,
    this.subscriptions = const [],
    this.candidates = const [],
    this.failure,
    this.pendingType,
    this.pendingTargetUserId,
    this.actionFailure,
    this.successMessage,
  });

  const ThreadSubscriptionState.loading()
    : this(phase: ThreadSubscriptionPhase.loading);

  final ThreadSubscriptionPhase phase;
  final List<ThreadSubscriptionRecord> subscriptions;
  final List<ThreadSubscriptionCandidate> candidates;
  final ApiFailure? failure;
  final ThreadSubscriptionType? pendingType;
  final String? pendingTargetUserId;
  final ApiFailure? actionFailure;
  final String? successMessage;

  bool get isPending => pendingType != null;

  ThreadSubscriptionRecord? get threadSubscription {
    for (final subscription in subscriptions) {
      if (subscription.type == ThreadSubscriptionType.thread) {
        return subscription;
      }
    }
    return null;
  }

  ThreadSubscriptionRecord? userSubscriptionFor(String userId) {
    for (final subscription in subscriptions) {
      if (subscription.type == ThreadSubscriptionType.user &&
          subscription.targetUserId == userId) {
        return subscription;
      }
    }
    return null;
  }

  int get userSubscriptionCount => subscriptions
      .where((item) => item.type == ThreadSubscriptionType.user)
      .length;
}

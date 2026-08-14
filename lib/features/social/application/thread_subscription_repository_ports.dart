import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

abstract interface class ThreadSubscriptionRepository {
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(String threadId);

  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  });

  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  });

  Future<void> remove(String subscriptionId);
}

final threadSubscriptionRepositoryProvider =
    Provider<ThreadSubscriptionRepository>((ref) {
      return const _UnboundThreadSubscriptionRepository();
    });

class _UnboundThreadSubscriptionRepository
    implements ThreadSubscriptionRepository {
  const _UnboundThreadSubscriptionRepository();

  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(String threadId) {
    return Future.error(_error());
  }

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) => Future.error(_error());

  @override
  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  }) => Future.error(_error());

  @override
  Future<void> remove(String subscriptionId) => Future.error(_error());
}

StateError _error() => StateError('主题订阅仓储尚未在应用组合根绑定。');

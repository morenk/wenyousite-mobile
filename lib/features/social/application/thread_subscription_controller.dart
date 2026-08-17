import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class ThreadSubscriptionController
    extends StateNotifier<ThreadSubscriptionState> {
  ThreadSubscriptionController(this._repository, this.target)
    : super(const ThreadSubscriptionState.loading()) {
    load();
  }

  final ThreadSubscriptionRepository _repository;
  final ThreadSubscriptionTarget target;
  var _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const ThreadSubscriptionState.loading();
    try {
      final subscriptionsFuture = _repository.fetchSubscriptions(
        target.threadId,
      );
      final candidatesFuture = _repository.fetchCandidates(
        target.threadId,
        viewerUserId: target.viewerUserId,
      );
      final results = await Future.wait<Object>([
        subscriptionsFuture,
        candidatesFuture,
      ]);
      final subscriptions = results[0] as List<ThreadSubscriptionRecord>;
      final candidates = results[1] as List<ThreadSubscriptionCandidate>;
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadSubscriptionState(
        phase: ThreadSubscriptionPhase.ready,
        subscriptions: subscriptions,
        candidates: candidates,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadSubscriptionState(
        phase: ThreadSubscriptionPhase.failed,
        failure: _asFailure(error, '订阅状态加载失败，请稍后重试。'),
      );
    }
  }

  Future<bool> toggleThread() async {
    if (state.phase != ThreadSubscriptionPhase.ready || state.isPending) {
      return false;
    }
    final existing = state.threadSubscription;
    _beginAction(ThreadSubscriptionType.thread);
    try {
      final updated = List<ThreadSubscriptionRecord>.of(state.subscriptions);
      if (existing == null) {
        updated.add(
          await _repository.create(
            threadId: target.threadId,
            type: ThreadSubscriptionType.thread,
          ),
        );
      } else {
        await _repository.remove(existing.id);
        updated.removeWhere((item) => item.id == existing.id);
      }
      if (!mounted) return false;
      _completeAction(updated, existing == null ? '已订阅帖子官方更新。' : '已取消官方更新订阅。');
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      _failAction(error, '官方更新订阅失败，请稍后重试。');
      return false;
    }
  }

  Future<bool> toggleUser(String userId) async {
    if (state.phase != ThreadSubscriptionPhase.ready || state.isPending) {
      return false;
    }
    if (!state.candidates.any((candidate) => candidate.userId == userId)) {
      state = ThreadSubscriptionState(
        phase: ThreadSubscriptionPhase.ready,
        subscriptions: state.subscriptions,
        candidates: state.candidates,
        actionFailure: const ApiFailure(userMessage: '这名玩家已不在可订阅列表，请刷新后重试。'),
      );
      return false;
    }
    final existing = state.userSubscriptionFor(userId);
    _beginAction(ThreadSubscriptionType.user, targetUserId: userId);
    try {
      final updated = List<ThreadSubscriptionRecord>.of(state.subscriptions);
      if (existing == null) {
        updated.add(
          await _repository.create(
            threadId: target.threadId,
            type: ThreadSubscriptionType.user,
            targetUserId: userId,
          ),
        );
      } else {
        await _repository.remove(existing.id);
        updated.removeWhere((item) => item.id == existing.id);
      }
      if (!mounted) return false;
      _completeAction(
        updated,
        existing == null ? '已订阅这名玩家的新发言。' : '已取消这名玩家的发言订阅。',
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      _failAction(error, '玩家发言订阅失败，请稍后重试。');
      return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = ThreadSubscriptionState(
      phase: state.phase,
      subscriptions: state.subscriptions,
      candidates: state.candidates,
      failure: state.failure,
      pendingType: state.pendingType,
      pendingTargetUserId: state.pendingTargetUserId,
      successMessage: state.successMessage,
    );
  }

  String? takeSuccessMessage() {
    final message = state.successMessage;
    if (message == null) return null;
    state = ThreadSubscriptionState(
      phase: state.phase,
      subscriptions: state.subscriptions,
      candidates: state.candidates,
      failure: state.failure,
      pendingType: state.pendingType,
      pendingTargetUserId: state.pendingTargetUserId,
      actionFailure: state.actionFailure,
    );
    return message;
  }

  void _beginAction(ThreadSubscriptionType type, {String? targetUserId}) {
    state = ThreadSubscriptionState(
      phase: ThreadSubscriptionPhase.ready,
      subscriptions: state.subscriptions,
      candidates: state.candidates,
      pendingType: type,
      pendingTargetUserId: targetUserId,
    );
  }

  void _completeAction(
    List<ThreadSubscriptionRecord> subscriptions,
    String message,
  ) {
    state = ThreadSubscriptionState(
      phase: ThreadSubscriptionPhase.ready,
      subscriptions: List.unmodifiable(subscriptions),
      candidates: state.candidates,
      successMessage: message,
    );
  }

  void _failAction(Object error, String fallback) {
    state = ThreadSubscriptionState(
      phase: ThreadSubscriptionPhase.ready,
      subscriptions: state.subscriptions,
      candidates: state.candidates,
      actionFailure: _asFailure(error, fallback),
    );
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final threadSubscriptionControllerProvider = StateNotifierProvider.autoDispose
    .family<
      ThreadSubscriptionController,
      ThreadSubscriptionState,
      ThreadSubscriptionTarget
    >((ref, target) {
      return ThreadSubscriptionController(
        ref.watch(threadSubscriptionRepositoryProvider),
        target,
      );
    }, dependencies: [threadSubscriptionRepositoryProvider]);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class ThreadSubscriptionController
    extends StateNotifier<ThreadSubscriptionState> {
  ThreadSubscriptionController(
    this._repository,
    this.target, {
    this._reconciler = const WriteReconciler(),
  }) : super(const ThreadSubscriptionState.loading()) {
    load();
  }

  final ThreadSubscriptionRepository _repository;
  final ThreadSubscriptionTarget target;
  final WriteReconciler _reconciler;
  var _loadEpoch = 0;
  var _actionEpoch = 0;

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
    return _toggle(
      type: ThreadSubscriptionType.thread,
      existing: existing,
      completedMessage: existing == null ? '已订阅帖子官方更新。' : '已取消官方更新订阅。',
      failureMessage: '官方更新订阅失败，请稍后重试。',
    );
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
    return _toggle(
      type: ThreadSubscriptionType.user,
      targetUserId: userId,
      existing: existing,
      completedMessage: existing == null ? '已订阅这名玩家的新发言。' : '已取消这名玩家的发言订阅。',
      failureMessage: '玩家发言订阅失败，请稍后重试。',
    );
  }

  Future<bool> _toggle({
    required ThreadSubscriptionType type,
    required ThreadSubscriptionRecord? existing,
    required String completedMessage,
    required String failureMessage,
    String? targetUserId,
  }) async {
    final desiredSubscribed = existing == null;
    final epoch = ++_actionEpoch;
    _beginAction(type, targetUserId: targetUserId);
    final before = state.subscriptions;
    final outcome = await _reconciler
        .run<ThreadSubscriptionRecord?, List<ThreadSubscriptionRecord>>(
          write: () async {
            if (desiredSubscribed) {
              return _repository.create(
                threadId: target.threadId,
                type: type,
                targetUserId: targetUserId,
              );
            }
            await _repository.remove(existing.id);
            return null;
          },
          read: () => _repository.fetchSubscriptions(target.threadId),
          targetReached: (subscriptions) {
            final found = subscriptions.any(
              (item) =>
                  item.threadId == target.threadId &&
                  item.type == type &&
                  item.targetUserId == targetUserId,
            );
            return found == desiredSubscribed;
          },
          failureMessage: failureMessage,
          convergentBusinessCodes: desiredSubscribed
              ? const {40904}
              : const {40407},
          isCurrent: () => mounted && epoch == _actionEpoch,
          onProgress: (progress) {
            if (!mounted || epoch != _actionEpoch) return;
            state = ThreadSubscriptionState(
              phase: ThreadSubscriptionPhase.ready,
              subscriptions: state.subscriptions,
              candidates: state.candidates,
              pendingType: type,
              pendingTargetUserId: targetUserId,
              actionOutcome: WriteOutcomeStatus.confirming,
              actionRequestId: progress.requestId,
            );
          },
        );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;

    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        final projection = outcome.projection;
        if (projection != null) {
          _completeAction(projection, completedMessage);
        } else {
          final updated = List<ThreadSubscriptionRecord>.of(before);
          if (desiredSubscribed) {
            final created = outcome.writeValue;
            if (created != null) updated.add(created);
          } else {
            updated.removeWhere((item) => item.id == existing.id);
          }
          _completeAction(updated, completedMessage);
        }
        return true;
      case WriteOutcomeStatus.failed:
        _failAction(outcome.failure!, failureMessage);
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = ThreadSubscriptionState(
          phase: ThreadSubscriptionPhase.ready,
          subscriptions: outcome.projection ?? before,
          candidates: state.candidates,
          actionOutcome: WriteOutcomeStatus.indeterminate,
          actionRequestId: outcome.requestId,
        );
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  void clearActionFeedback() {
    if (state.actionFailure == null && state.actionOutcome == null) return;
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

  void clearActionFailure() => clearActionFeedback();

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
      actionOutcome: state.actionOutcome,
      actionRequestId: state.actionRequestId,
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

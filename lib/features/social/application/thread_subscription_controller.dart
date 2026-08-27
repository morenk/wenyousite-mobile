import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class ThreadSubscriptionController
    extends StateNotifier<ThreadSubscriptionState> {
  ThreadSubscriptionController(
    this._repository,
    this.threadId, {
    this.viewerUserId,
    this._reconciler = const WriteReconciler(),
  }) : super(const ThreadSubscriptionState.loading()) {
    load();
  }

  final ThreadSubscriptionRepository _repository;
  final String threadId;
  final String? viewerUserId;
  final WriteReconciler _reconciler;
  var _loadEpoch = 0;
  var _candidateEpoch = 0;
  var _actionEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    final candidateEpoch = ++_candidateEpoch;
    state = const ThreadSubscriptionState.loading();
    final subscriptionsFuture = _capture(
      _repository.fetchSubscriptions(threadId),
    );
    final candidatesFuture = _capture(
      _repository.fetchCandidates(threadId, viewerUserId: viewerUserId),
    );
    final subscriptionsResult = await subscriptionsFuture;
    if (!mounted || epoch != _loadEpoch) return;
    final subscriptionError = subscriptionsResult.error;
    if (subscriptionError != null) {
      state = ThreadSubscriptionState(
        phase: ThreadSubscriptionPhase.failed,
        failure: _asFailure(subscriptionError, '订阅状态加载失败，请稍后重试。'),
      );
      return;
    }
    state = ThreadSubscriptionState(
      phase: ThreadSubscriptionPhase.ready,
      subscriptions: subscriptionsResult.value!,
      isLoadingCandidates: true,
    );
    final candidatesResult = await candidatesFuture;
    if (!mounted || epoch != _loadEpoch || candidateEpoch != _candidateEpoch) {
      return;
    }
    _completeCandidates(candidatesResult);
  }

  Future<void> retryCandidates() async {
    if (state.phase != ThreadSubscriptionPhase.ready ||
        state.isLoadingCandidates ||
        state.isPending) {
      return;
    }
    final epoch = ++_candidateEpoch;
    state = _copyState(isLoadingCandidates: true, clearCandidateFailure: true);
    final result = await _capture(
      _repository.fetchCandidates(threadId, viewerUserId: viewerUserId),
    );
    if (!mounted || epoch != _candidateEpoch) return;
    _completeCandidates(result);
  }

  Future<bool> toggleThread() async {
    if (state.phase != ThreadSubscriptionPhase.ready || state.isPending) {
      return false;
    }
    final existing = state.threadSubscription;
    return _toggle(
      type: ThreadSubscriptionType.thread,
      existing: existing,
      completedMessage: existing == null ? '已订阅主题官方更新。' : '已取消官方更新订阅。',
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
        isLoadingCandidates: state.isLoadingCandidates,
        candidateFailure: state.candidateFailure,
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
                threadId: threadId,
                type: type,
                targetUserId: targetUserId,
              );
            }
            await _repository.remove(existing.id);
            return null;
          },
          read: () => _repository.fetchSubscriptions(threadId),
          targetReached: (subscriptions) {
            final found = subscriptions.any(
              (item) =>
                  item.threadId == threadId &&
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
              isLoadingCandidates: state.isLoadingCandidates,
              candidateFailure: state.candidateFailure,
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
          isLoadingCandidates: state.isLoadingCandidates,
          candidateFailure: state.candidateFailure,
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
      isLoadingCandidates: state.isLoadingCandidates,
      failure: state.failure,
      candidateFailure: state.candidateFailure,
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
      isLoadingCandidates: state.isLoadingCandidates,
      failure: state.failure,
      candidateFailure: state.candidateFailure,
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
      isLoadingCandidates: state.isLoadingCandidates,
      candidateFailure: state.candidateFailure,
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
      isLoadingCandidates: state.isLoadingCandidates,
      candidateFailure: state.candidateFailure,
      successMessage: message,
    );
  }

  void _failAction(Object error, String fallback) {
    state = ThreadSubscriptionState(
      phase: ThreadSubscriptionPhase.ready,
      subscriptions: state.subscriptions,
      candidates: state.candidates,
      isLoadingCandidates: state.isLoadingCandidates,
      candidateFailure: state.candidateFailure,
      actionFailure: _asFailure(error, fallback),
    );
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }

  void _completeCandidates(
    ({List<ThreadSubscriptionCandidate>? value, Object? error}) result,
  ) {
    state = _copyState(
      candidates: result.value,
      isLoadingCandidates: false,
      candidateFailure: result.error == null
          ? null
          : _asFailure(result.error!, '玩家列表加载失败，请稍后重试。'),
      clearCandidateFailure: result.error == null,
    );
  }

  ThreadSubscriptionState _copyState({
    List<ThreadSubscriptionCandidate>? candidates,
    bool? isLoadingCandidates,
    ApiFailure? candidateFailure,
    bool clearCandidateFailure = false,
  }) {
    return ThreadSubscriptionState(
      phase: state.phase,
      subscriptions: state.subscriptions,
      candidates: candidates ?? state.candidates,
      isLoadingCandidates: isLoadingCandidates ?? state.isLoadingCandidates,
      failure: state.failure,
      candidateFailure: clearCandidateFailure
          ? null
          : (candidateFailure ?? state.candidateFailure),
      pendingType: state.pendingType,
      pendingTargetUserId: state.pendingTargetUserId,
      actionFailure: state.actionFailure,
      actionOutcome: state.actionOutcome,
      actionRequestId: state.actionRequestId,
      successMessage: state.successMessage,
    );
  }
}

Future<({T? value, Object? error})> _capture<T>(Future<T> future) async {
  try {
    return (value: await future, error: null);
  } on Object catch (error) {
    return (value: null, error: error);
  }
}

final threadSubscriptionControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadSubscriptionController, ThreadSubscriptionState, String>(
      (ref, threadId) {
        final sessionScope = ref.watch(sessionScopeProvider);
        return ThreadSubscriptionController(
          ref.watch(threadSubscriptionRepositoryProvider),
          threadId,
          viewerUserId: sessionScope.accountId,
        );
      },
      dependencies: [
        threadSubscriptionRepositoryProvider,
        sessionScopeProvider,
      ],
    );

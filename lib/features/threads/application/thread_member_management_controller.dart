import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_member_management_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

import 'thread_member_management_state.dart';
export 'thread_member_management_state.dart';

class ThreadMemberManagementController
    extends StateNotifier<ThreadMemberManagementState> {
  ThreadMemberManagementController(
    this._threadId,
    this._repository, {
    this._reconciler = const WriteReconciler(),
  }) : super(const ThreadMemberManagementState.loading()) {
    load();
  }

  final String _threadId;
  final ThreadMemberManagementRepository _repository;
  final WriteReconciler _reconciler;
  var _loadEpoch = 0;
  var _actionEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const ThreadMemberManagementState.loading();
    try {
      final bootstrap = await _repository.load(_threadId);
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadMemberManagementState(
        phase: ThreadMemberManagementPhase.ready,
        bootstrap: bootstrap,
      );
    } on ApiFailure catch (failure) {
      if (!mounted || epoch != _loadEpoch) return;
      state = ThreadMemberManagementState(
        phase: ThreadMemberManagementPhase.failed,
        failure: failure,
      );
    }
  }

  Future<bool> togglePlayer(ThreadMemberManagementMember member) {
    return _update(
      member: member,
      action: ThreadMemberManagementAction.player,
      playerMarked: !member.playerMarked,
    );
  }

  Future<bool> toggleCollaborator(ThreadMemberManagementMember member) {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || !bootstrap.actorIsOwner) {
      return Future.value(false);
    }
    final role = member.role == ThreadMemberManagementRole.collaborator
        ? ThreadMemberManagementRole.participant
        : ThreadMemberManagementRole.collaborator;
    return _update(
      member: member,
      action: ThreadMemberManagementAction.role,
      role: role,
    );
  }

  Future<bool> _update({
    required ThreadMemberManagementMember member,
    required ThreadMemberManagementAction action,
    ThreadMemberManagementRole? role,
    bool? playerMarked,
  }) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isUpdating) return false;
    if (member.role == ThreadMemberManagementRole.owner ||
        member.role == ThreadMemberManagementRole.unknown) {
      return false;
    }
    state = state.copyWith(
      pendingUserId: member.userId,
      pendingAction: action,
      failure: null,
    );
    final epoch = ++_actionEpoch;
    final outcome = await _reconciler
        .run<ThreadMemberManagementMember, ThreadMemberManagementBootstrap>(
          write: () => _repository.updateMember(
            threadId: _threadId,
            userId: member.userId,
            role: role,
            playerMarked: playerMarked,
          ),
          read: () => _repository.load(_threadId),
          targetReached: (latest) {
            final matches = latest.members.where(
              (candidate) => candidate.userId == member.userId,
            );
            if (matches.length != 1) return false;
            final current = matches.single;
            return (role == null || current.role == role) &&
                (playerMarked == null || current.playerMarked == playerMarked);
          },
          failureMessage: '成员设置失败，请稍后重试。',
          isCurrent: () => mounted && epoch == _actionEpoch,
          onProgress: (progress) {
            if (!mounted || epoch != _actionEpoch) return;
            state = state.copyWith(
              actionOutcome: WriteOutcomeStatus.confirming,
              actionRequestId: progress.requestId,
              actionOutcomeFailure: progress.failure,
            );
          },
        );
    if (outcome.isDiscarded || !mounted || epoch != _actionEpoch) return false;
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        state = state.copyWith(
          bootstrap:
              outcome.projection ??
              bootstrap.replaceMember(outcome.writeValue!),
          pendingUserId: null,
          pendingAction: null,
          failure: null,
          actionOutcome: null,
          actionRequestId: null,
        );
        return true;
      case WriteOutcomeStatus.failed:
        state = state.copyWith(
          pendingUserId: null,
          pendingAction: null,
          failure: outcome.failure,
          actionOutcome: null,
          actionRequestId: null,
        );
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = state.copyWith(
          bootstrap: outcome.projection ?? bootstrap,
          pendingUserId: null,
          pendingAction: null,
          failure: null,
          actionOutcome: WriteOutcomeStatus.indeterminate,
          actionRequestId: outcome.requestId,
          actionOutcomeFailure: outcome.failure,
        );
        return false;
      case WriteOutcomeStatus.confirming:
        return false;
    }
  }

  void clearFailure() {
    if (!state.isUpdating) {
      state = state.copyWith(
        failure: null,
        actionOutcome: null,
        actionRequestId: null,
      );
    }
  }
}

class ThreadPlayerExitController extends StateNotifier<ThreadPlayerExitState> {
  ThreadPlayerExitController(this._threadId, this._repository)
    : super(const ThreadPlayerExitState());

  final String _threadId;
  final ThreadMemberManagementRepository _repository;

  Future<bool> exit() async {
    if (state.isSubmitting) return false;
    state = const ThreadPlayerExitState(isSubmitting: true);
    try {
      await _repository.exitPlayer(_threadId);
      if (!mounted) return false;
      state = const ThreadPlayerExitState();
      return true;
    } on ApiFailure catch (failure) {
      if (!mounted) return false;
      state = ThreadPlayerExitState(failure: failure);
      return false;
    }
  }

  void clearFailure() {
    if (!state.isSubmitting) state = const ThreadPlayerExitState();
  }
}

final threadMemberManagementControllerProvider = StateNotifierProvider
    .autoDispose
    .family<
      ThreadMemberManagementController,
      ThreadMemberManagementState,
      String
    >((ref, threadId) {
      return ThreadMemberManagementController(
        threadId,
        ref.watch(threadMemberManagementRepositoryProvider),
      );
    }, dependencies: [threadMemberManagementRepositoryProvider]);

final threadPlayerExitControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadPlayerExitController, ThreadPlayerExitState, String>((
      ref,
      threadId,
    ) {
      return ThreadPlayerExitController(
        threadId,
        ref.watch(threadMemberManagementRepositoryProvider),
      );
    }, dependencies: [threadMemberManagementRepositoryProvider]);

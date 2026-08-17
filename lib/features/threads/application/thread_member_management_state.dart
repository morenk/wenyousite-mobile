import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_member_management_models.dart';

enum ThreadMemberManagementPhase { loading, ready, failed }

enum ThreadMemberManagementAction { player, role }

class ThreadMemberManagementState {
  const ThreadMemberManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.pendingUserId,
    this.pendingAction,
    this.actionOutcome,
    this.actionRequestId,
  });

  const ThreadMemberManagementState.loading()
    : this(phase: ThreadMemberManagementPhase.loading);

  final ThreadMemberManagementPhase phase;
  final ThreadMemberManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final String? pendingUserId;
  final ThreadMemberManagementAction? pendingAction;
  final WriteOutcomeStatus? actionOutcome;
  final String? actionRequestId;

  bool get isUpdating => pendingUserId != null;

  ThreadMemberManagementState copyWith({
    ThreadMemberManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? pendingUserId = _unset,
    Object? pendingAction = _unset,
    Object? actionOutcome = _unset,
    Object? actionRequestId = _unset,
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
      actionOutcome: identical(actionOutcome, _unset)
          ? this.actionOutcome
          : actionOutcome as WriteOutcomeStatus?,
      actionRequestId: identical(actionRequestId, _unset)
          ? this.actionRequestId
          : actionRequestId as String?,
    );
  }
}

class ThreadPlayerExitState {
  const ThreadPlayerExitState({this.isSubmitting = false, this.failure});

  final bool isSubmitting;
  final ApiFailure? failure;
}

const _unset = Object();

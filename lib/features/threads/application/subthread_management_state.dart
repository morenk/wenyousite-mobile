import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/subthread_management_models.dart';

enum SubthreadManagementPhase { loading, ready, failed }

enum SubthreadManagementAction {
  loadingDetail,
  creating,
  updating,
  deleting,
  reordering,
}

sealed class MutationSubmitResult<T> {
  const MutationSubmitResult._();

  const factory MutationSubmitResult.completed(T value) =
      MutationSubmitCompleted<T>;

  const factory MutationSubmitResult.failed(ApiFailure failure) =
      MutationSubmitFailed<T>;

  const factory MutationSubmitResult.indeterminate({String? requestId}) =
      MutationSubmitIndeterminate<T>;
}

final class MutationSubmitCompleted<T> extends MutationSubmitResult<T> {
  const MutationSubmitCompleted(this.value) : super._();

  final T value;
}

final class MutationSubmitFailed<T> extends MutationSubmitResult<T> {
  const MutationSubmitFailed(this.failure) : super._();

  final ApiFailure failure;
}

final class MutationSubmitIndeterminate<T> extends MutationSubmitResult<T> {
  const MutationSubmitIndeterminate({this.requestId}) : super._();

  final String? requestId;
}

class SubthreadManagementState {
  const SubthreadManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.pendingAction,
    this.pendingItemId,
    this.actionOutcome,
    this.actionRequestId,
  });

  const SubthreadManagementState.loading()
    : this(phase: SubthreadManagementPhase.loading);

  final SubthreadManagementPhase phase;
  final SubthreadManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final SubthreadManagementAction? pendingAction;
  final String? pendingItemId;
  final WriteOutcomeStatus? actionOutcome;
  final String? actionRequestId;

  bool get isBusy => pendingAction != null;

  SubthreadManagementState copyWith({
    SubthreadManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? pendingAction = _unset,
    Object? pendingItemId = _unset,
    Object? actionOutcome = _unset,
    Object? actionRequestId = _unset,
  }) {
    return SubthreadManagementState(
      phase: phase ?? this.phase,
      bootstrap: identical(bootstrap, _unset)
          ? this.bootstrap
          : bootstrap as SubthreadManagementBootstrap?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as SubthreadManagementAction?,
      pendingItemId: identical(pendingItemId, _unset)
          ? this.pendingItemId
          : pendingItemId as String?,
      actionOutcome: identical(actionOutcome, _unset)
          ? this.actionOutcome
          : actionOutcome as WriteOutcomeStatus?,
      actionRequestId: identical(actionRequestId, _unset)
          ? this.actionRequestId
          : actionRequestId as String?,
    );
  }
}

const _unset = Object();

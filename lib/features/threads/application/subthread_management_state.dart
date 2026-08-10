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

class SubthreadManagementState {
  const SubthreadManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.pendingAction,
    this.pendingItemId,
  });

  const SubthreadManagementState.loading()
    : this(phase: SubthreadManagementPhase.loading);

  final SubthreadManagementPhase phase;
  final SubthreadManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final SubthreadManagementAction? pendingAction;
  final String? pendingItemId;

  bool get isBusy => pendingAction != null;

  SubthreadManagementState copyWith({
    SubthreadManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? pendingAction = _unset,
    Object? pendingItemId = _unset,
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
    );
  }
}

const _unset = Object();

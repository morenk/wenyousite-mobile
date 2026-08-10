import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

enum ThreadManagementPhase { loading, ready, failed }

class ThreadManagementState {
  const ThreadManagementState({
    required this.phase,
    this.bootstrap,
    this.failure,
    this.conflict,
    this.isSaving = false,
    this.isDeleting = false,
  });

  const ThreadManagementState.loading()
    : this(phase: ThreadManagementPhase.loading);

  final ThreadManagementPhase phase;
  final ThreadManagementBootstrap? bootstrap;
  final ApiFailure? failure;
  final ThreadManagementConflict? conflict;
  final bool isSaving;
  final bool isDeleting;

  bool get isBusy => isSaving || isDeleting;

  ThreadManagementState copyWith({
    ThreadManagementPhase? phase,
    Object? bootstrap = _unset,
    Object? failure = _unset,
    Object? conflict = _unset,
    bool? isSaving,
    bool? isDeleting,
  }) {
    return ThreadManagementState(
      phase: phase ?? this.phase,
      bootstrap: identical(bootstrap, _unset)
          ? this.bootstrap
          : bootstrap as ThreadManagementBootstrap?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      conflict: identical(conflict, _unset)
          ? this.conflict
          : conflict as ThreadManagementConflict?,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

const _unset = Object();

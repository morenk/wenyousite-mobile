import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_management_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_management_models.dart';

import 'thread_management_state.dart';
export 'thread_management_state.dart';

class ThreadManagementController extends StateNotifier<ThreadManagementState> {
  ThreadManagementController(this._threadId, this._repository)
    : super(const ThreadManagementState.loading()) {
    load();
  }

  final String _threadId;
  final ThreadManagementRepository _repository;

  Future<void> load() async {
    state = const ThreadManagementState.loading();
    try {
      final bootstrap = await _repository.load(_threadId);
      state = ThreadManagementState(
        phase: ThreadManagementPhase.ready,
        bootstrap: bootstrap,
      );
    } on ApiFailure catch (failure) {
      state = ThreadManagementState(
        phase: ThreadManagementPhase.failed,
        failure: failure,
      );
    }
  }

  Future<bool> save(ThreadManagementDraft draft) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy) return false;
    if (!draft.differsFrom(bootstrap.thread)) return true;
    state = state.copyWith(isSaving: true, failure: null, conflict: null);
    try {
      final updated = await _repository.update(
        current: bootstrap.thread,
        draft: draft,
      );
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(thread: updated),
        isSaving: false,
        failure: null,
      );
      return true;
    } on ApiFailure catch (failure) {
      if (failure.businessCode == 40002 || failure.httpStatus == 409) {
        await _resolveConflict(failure, draft);
      } else {
        state = state.copyWith(isSaving: false, failure: failure);
      }
      return false;
    }
  }

  Future<void> _resolveConflict(
    ApiFailure conflictFailure,
    ThreadManagementDraft pending,
  ) async {
    try {
      final latest = await _repository.load(_threadId);
      state = state.copyWith(
        isSaving: false,
        failure: conflictFailure,
        conflict: ThreadManagementConflict(latest: latest, pending: pending),
      );
    } on ApiFailure catch (reloadFailure) {
      state = state.copyWith(
        isSaving: false,
        failure: reloadFailure,
        conflict: null,
      );
    }
  }

  Future<bool> overwriteConflict() async {
    final conflict = state.conflict;
    if (conflict == null || state.isBusy) return false;
    state = state.copyWith(isSaving: true, failure: null, conflict: null);
    try {
      final updated = await _repository.update(
        current: conflict.latest.thread,
        draft: conflict.pending,
      );
      state = state.copyWith(
        bootstrap: conflict.latest.copyWith(thread: updated),
        isSaving: false,
      );
      return true;
    } on ApiFailure catch (failure) {
      if (failure.businessCode == 40002 || failure.httpStatus == 409) {
        await _resolveConflict(failure, conflict.pending);
      } else {
        state = state.copyWith(isSaving: false, failure: failure);
      }
      return false;
    }
  }

  void adoptLatest() {
    final conflict = state.conflict;
    if (conflict == null || state.isBusy) return;
    state = state.copyWith(
      bootstrap: conflict.latest,
      failure: null,
      conflict: null,
    );
  }

  Future<bool> remove() async {
    final thread = state.bootstrap?.thread;
    if (thread == null || state.isBusy || !thread.isOwner) return false;
    state = state.copyWith(isDeleting: true, failure: null, conflict: null);
    try {
      await _repository.remove(thread.id);
      state = state.copyWith(isDeleting: false);
      return true;
    } on ApiFailure catch (failure) {
      state = state.copyWith(isDeleting: false, failure: failure);
      return false;
    }
  }

  void clearFailure() {
    if (state.isBusy) return;
    state = state.copyWith(failure: null);
  }
}

final threadManagementControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadManagementController, ThreadManagementState, String>((
      ref,
      threadId,
    ) {
      return ThreadManagementController(
        threadId,
        ref.watch(threadManagementRepositoryProvider),
      );
    });

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';

enum RemoteThreadDraftsPhase { loading, ready, failed }

class RemoteThreadDraftsState {
  const RemoteThreadDraftsState({
    this.phase = RemoteThreadDraftsPhase.loading,
    this.drafts = const [],
    this.failure,
    this.removingId,
    this.removeFailure,
  });

  final RemoteThreadDraftsPhase phase;
  final List<ThreadRemoteDraftSummary> drafts;
  final ApiFailure? failure;
  final String? removingId;
  final ApiFailure? removeFailure;

  bool get isRemoving => removingId != null;

  RemoteThreadDraftsState copyWith({
    RemoteThreadDraftsPhase? phase,
    List<ThreadRemoteDraftSummary>? drafts,
    Object? failure = _unset,
    Object? removingId = _unset,
    Object? removeFailure = _unset,
  }) {
    return RemoteThreadDraftsState(
      phase: phase ?? this.phase,
      drafts: drafts ?? this.drafts,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      removingId: identical(removingId, _unset)
          ? this.removingId
          : removingId as String?,
      removeFailure: identical(removeFailure, _unset)
          ? this.removeFailure
          : removeFailure as ApiFailure?,
    );
  }
}

const _unset = Object();

class RemoteThreadDraftsController
    extends StateNotifier<RemoteThreadDraftsState> {
  RemoteThreadDraftsController(this._repository, {bool autoStart = true})
    : super(const RemoteThreadDraftsState()) {
    if (autoStart) unawaited(load());
  }

  final ThreadComposeRepository _repository;
  int _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = state.copyWith(
      phase: RemoteThreadDraftsPhase.loading,
      failure: null,
      removeFailure: null,
    );
    try {
      final drafts = await _repository.fetchDrafts();
      if (!mounted || epoch != _loadEpoch) return;
      state = RemoteThreadDraftsState(
        phase: RemoteThreadDraftsPhase.ready,
        drafts: drafts,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = RemoteThreadDraftsState(
        phase: RemoteThreadDraftsPhase.failed,
        drafts: state.drafts,
        failure: _asFailure(error, '云端草稿加载失败，请重试。'),
      );
    }
  }

  Future<bool> remove(ThreadRemoteDraftSummary draft) async {
    if (state.phase != RemoteThreadDraftsPhase.ready || state.isRemoving) {
      return false;
    }
    state = state.copyWith(removingId: draft.id, removeFailure: null);
    try {
      await _repository.removeDraft(draft.id);
      if (!mounted) return false;
      state = state.copyWith(
        drafts: List.unmodifiable(
          state.drafts.where((item) => item.id != draft.id),
        ),
        removingId: null,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        removingId: null,
        removeFailure: _asFailure(error, '云端草稿没有删除成功，请重试。'),
      );
      return false;
    }
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final remoteThreadDraftsControllerProvider =
    StateNotifierProvider.autoDispose<
      RemoteThreadDraftsController,
      RemoteThreadDraftsState
    >((ref) {
      ref.watch(sessionControllerProvider);
      return RemoteThreadDraftsController(
        ref.watch(threadComposeRepositoryProvider),
      );
    }, dependencies: [threadComposeRepositoryProvider]);

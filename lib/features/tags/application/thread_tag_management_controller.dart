import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/write_reconciler.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_repository_ports.dart';
import 'package:wenyousite_mobile/features/tags/application/tag_states.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

export 'package:wenyousite_mobile/features/tags/application/tag_states.dart';

class ThreadTagManagementController
    extends StateNotifier<ThreadTagManagementState> {
  ThreadTagManagementController(
    this._threadId,
    this._repository, {
    bool autoStart = true,
    this._reconciler = const WriteReconciler(),
  }) : super(const ThreadTagManagementState.loading()) {
    if (autoStart) unawaited(load());
  }

  final String _threadId;
  final TagRepository _repository;
  final WriteReconciler _reconciler;
  int _loadEpoch = 0;
  int _searchEpoch = 0;
  int _mutationEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    ++_searchEpoch;
    state = const ThreadTagManagementState.loading();
    try {
      final bootstrap = await _repository.loadManagement(_threadId);
      if (epoch != _loadEpoch) return;
      state = ThreadTagManagementState(
        phase: ThreadTagManagementPhase.ready,
        bootstrap: bootstrap,
      );
    } on Object catch (error) {
      if (epoch != _loadEpoch) return;
      state = ThreadTagManagementState(
        phase: ThreadTagManagementPhase.failed,
        failure: _asFailure(error, '主题标签加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> search(String query) async {
    if (state.phase != ThreadTagManagementPhase.ready || state.isMutating) {
      return;
    }
    final normalized = normalizeTagName(query);
    final epoch = ++_searchEpoch;
    state = state.copyWith(query: normalized, isSearching: true, failure: null);
    try {
      final suggestions = await _repository.search(normalized);
      if (epoch != _searchEpoch) return;
      final bootstrap = state.bootstrap;
      if (bootstrap == null) return;
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(suggestions: suggestions),
        isSearching: false,
      );
    } on Object catch (error) {
      if (epoch != _searchEpoch) return;
      state = state.copyWith(
        isSearching: false,
        failure: _asFailure(error, '标签搜索失败，请重试。'),
      );
    }
  }

  Future<bool> addExisting(TopicTagModel candidate) async {
    final bootstrap = state.bootstrap;
    if (!_canAdd(bootstrap) ||
        bootstrap!.tags.any((item) => item.id == candidate.id)) {
      return false;
    }
    state = state.copyWith(
      mutatingTagId: candidate.id,
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
      actionOutcomeFailure: null,
    );
    try {
      final latest = await _repository.findById(candidate.id);
      if (latest.name != candidate.name) {
        throw const ApiFailure(userMessage: '标签已经变化，请重新搜索后再添加。');
      }
      return _addWithReconciliation(
        write: () =>
            _repository.addToThread(threadId: _threadId, name: latest.name),
        targetReached: (value) => value.id == latest.id,
        fallback: '标签添加失败，请重试。',
      );
    } on Object catch (error) {
      state = state.copyWith(
        mutatingTagId: null,
        failure: _asFailure(error, '标签添加失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> addByName(String name) async {
    final bootstrap = state.bootstrap;
    final normalized = normalizeTagName(name);
    final validation = validateTagName(normalized);
    if (!_canAdd(bootstrap) || validation != null) {
      if (validation != null) {
        state = state.copyWith(failure: ApiFailure(userMessage: validation));
      }
      return false;
    }
    if (bootstrap!.tags.any((item) => item.name == normalized)) return false;
    state = state.copyWith(
      mutatingTagId: 'add:$normalized',
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
      actionOutcomeFailure: null,
    );
    try {
      return _addWithReconciliation(
        write: () =>
            _repository.addToThread(threadId: _threadId, name: normalized),
        targetReached: (value) => value.name == normalized,
        fallback: '标签添加失败，请重试。',
      );
    } on Object catch (error) {
      state = state.copyWith(
        mutatingTagId: null,
        failure: _asFailure(error, '标签添加失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> remove(TopicTagModel tag) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy) return false;
    if (!bootstrap.tags.any((item) => item.id == tag.id)) return false;
    state = state.copyWith(
      mutatingTagId: tag.id,
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
      actionOutcomeFailure: null,
    );
    final epoch = ++_mutationEpoch;
    final outcome = await _reconciler.run<void, ThreadTagManagementBootstrap>(
      write: () =>
          _repository.removeFromThread(threadId: _threadId, tagId: tag.id),
      read: () => _repository.loadManagement(_threadId),
      targetReached: (latest) => !latest.tags.any((item) => item.id == tag.id),
      failureMessage: '标签移除失败，请重试。',
      isCurrent: () => mounted && epoch == _mutationEpoch,
      onProgress: (progress) => _showConfirming(epoch, progress.failure),
    );
    if (outcome.isDiscarded || !mounted || epoch != _mutationEpoch) {
      return false;
    }
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        final next = bootstrap.tags
            .where((item) => item.id != tag.id)
            .toList(growable: false);
        state = state.copyWith(
          bootstrap: outcome.projection ?? bootstrap.copyWith(tags: next),
          mutatingTagId: null,
          failure: null,
          actionOutcome: null,
          actionRequestId: null,
          actionOutcomeFailure: null,
        );
        return true;
      case WriteOutcomeStatus.failed:
        state = state.copyWith(
          mutatingTagId: null,
          failure: outcome.failure,
          actionOutcome: null,
          actionRequestId: null,
          actionOutcomeFailure: null,
        );
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = state.copyWith(
          bootstrap: outcome.projection ?? bootstrap,
          mutatingTagId: null,
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

  Future<bool> _addWithReconciliation({
    required Future<TopicTagModel> Function() write,
    required bool Function(TopicTagModel value) targetReached,
    required String fallback,
  }) async {
    final before = state.bootstrap!;
    final epoch = ++_mutationEpoch;
    final outcome = await _reconciler
        .run<TopicTagModel, ThreadTagManagementBootstrap>(
          write: write,
          read: () => _repository.loadManagement(_threadId),
          targetReached: (latest) => latest.tags.any(targetReached),
          failureMessage: fallback,
          isCurrent: () => mounted && epoch == _mutationEpoch,
          onProgress: (progress) => _showConfirming(epoch, progress.failure),
        );
    if (outcome.isDiscarded || !mounted || epoch != _mutationEpoch) {
      return false;
    }
    switch (outcome.status) {
      case WriteOutcomeStatus.completed:
        if (outcome.projection != null) {
          state = state.copyWith(
            bootstrap: outcome.projection,
            mutatingTagId: null,
            failure: null,
            actionOutcome: null,
            actionRequestId: null,
            actionOutcomeFailure: null,
          );
        } else {
          _commitAdded(outcome.writeValue!);
        }
        return true;
      case WriteOutcomeStatus.failed:
        state = state.copyWith(
          mutatingTagId: null,
          failure: outcome.failure,
          actionOutcome: null,
          actionRequestId: null,
          actionOutcomeFailure: null,
        );
        return false;
      case WriteOutcomeStatus.indeterminate:
        state = state.copyWith(
          bootstrap: outcome.projection ?? before,
          mutatingTagId: null,
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

  void _showConfirming(int epoch, ApiFailure? failure) {
    if (!mounted || epoch != _mutationEpoch) return;
    state = state.copyWith(
      actionOutcome: WriteOutcomeStatus.confirming,
      actionRequestId: failure?.requestId,
      actionOutcomeFailure: failure,
    );
  }

  void clearFailure() {
    if (state.isMutating) return;
    state = state.copyWith(
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
      actionOutcomeFailure: null,
    );
  }

  bool _canAdd(ThreadTagManagementBootstrap? bootstrap) {
    return bootstrap != null &&
        !state.isBusy &&
        bootstrap.tags.length < maxThreadTagCount;
  }

  void _commitAdded(TopicTagModel added) {
    final bootstrap = state.bootstrap!;
    final tags = [...bootstrap.tags];
    if (!tags.any((item) => item.id == added.id)) tags.add(added);
    tags.sort(_compareTags);
    final suggestions = [...bootstrap.suggestions];
    final index = suggestions.indexWhere((item) => item.id == added.id);
    if (index == -1) {
      suggestions.add(added);
      suggestions.sort(_compareTags);
    } else {
      suggestions[index] = added;
    }
    state = state.copyWith(
      bootstrap: bootstrap.copyWith(
        tags: List.unmodifiable(tags),
        suggestions: List.unmodifiable(suggestions),
      ),
      mutatingTagId: null,
      failure: null,
      actionOutcome: null,
      actionRequestId: null,
      actionOutcomeFailure: null,
    );
  }

  int _compareTags(TopicTagModel left, TopicTagModel right) {
    final byOrder = left.sortOrder.compareTo(right.sortOrder);
    return byOrder != 0 ? byOrder : left.name.compareTo(right.name);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final threadTagManagementControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadTagManagementController, ThreadTagManagementState, String>((
      ref,
      threadId,
    ) {
      return ThreadTagManagementController(
        threadId,
        ref.watch(tagRepositoryProvider),
      );
    }, dependencies: [tagRepositoryProvider]);

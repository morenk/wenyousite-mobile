import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
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
  }) : super(const ThreadTagManagementState.loading()) {
    if (autoStart) unawaited(load());
  }

  final String _threadId;
  final TagRepository _repository;
  int _loadEpoch = 0;
  int _searchEpoch = 0;

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
        failure: _asFailure(error, '主题标签没有加载完成，请稍后重试。'),
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
    state = state.copyWith(mutatingTagId: candidate.id, failure: null);
    try {
      final latest = await _repository.findById(candidate.id);
      if (latest.name != candidate.name) {
        throw const ApiFailure(userMessage: '标签已经变化，请重新搜索后再添加。');
      }
      final added = await _repository.addToThread(
        threadId: _threadId,
        name: latest.name,
      );
      _commitAdded(added);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        mutatingTagId: null,
        failure: _asFailure(error, '标签添加失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> createAndAdd(String name) async {
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
    state = state.copyWith(mutatingTagId: 'create:$normalized', failure: null);
    try {
      TopicTagModel tag;
      try {
        tag = await _repository.create(normalized);
      } on ApiFailure catch (failure) {
        if (failure.businessCode != 40905) rethrow;
        final matches = await _repository.search(normalized);
        final exact = matches.where((item) => item.name == normalized).toList();
        if (exact.length != 1) {
          throw const ApiFailure(userMessage: '同名标签已经存在，请重新搜索后添加。');
        }
        tag = await _repository.findById(exact.single.id);
      }
      final added = await _repository.addToThread(
        threadId: _threadId,
        name: tag.name,
      );
      _commitAdded(added);
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        mutatingTagId: null,
        failure: _asFailure(error, '标签创建失败，请重试。'),
      );
      return false;
    }
  }

  Future<bool> remove(TopicTagModel tag) async {
    final bootstrap = state.bootstrap;
    if (bootstrap == null || state.isBusy) return false;
    if (!bootstrap.tags.any((item) => item.id == tag.id)) return false;
    state = state.copyWith(mutatingTagId: tag.id, failure: null);
    try {
      await _repository.removeFromThread(threadId: _threadId, tagId: tag.id);
      final next = bootstrap.tags
          .where((item) => item.id != tag.id)
          .toList(growable: false);
      state = state.copyWith(
        bootstrap: bootstrap.copyWith(tags: next),
        mutatingTagId: null,
      );
      return true;
    } on Object catch (error) {
      state = state.copyWith(
        mutatingTagId: null,
        failure: _asFailure(error, '标签移除失败，请重试。'),
      );
      return false;
    }
  }

  void clearFailure() {
    if (state.isMutating) return;
    state = state.copyWith(failure: null);
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

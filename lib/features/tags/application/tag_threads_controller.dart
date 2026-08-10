import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/tags/data/tag_repository.dart';
import 'package:wenyousite_mobile/features/tags/domain/tag_models.dart';

class TagThreadsController extends StateNotifier<TagThreadsState> {
  TagThreadsController(this._tagId, this._repository, {bool autoStart = true})
    : super(const TagThreadsState.loading()) {
    if (autoStart) unawaited(loadInitial());
  }

  final String _tagId;
  final TagRepository _repository;
  int _requestEpoch = 0;

  Future<void> loadInitial() async {
    final epoch = ++_requestEpoch;
    state = const TagThreadsState.loading();
    try {
      final result = await _repository.loadTagThreads(_tagId);
      if (epoch != _requestEpoch) return;
      state = TagThreadsState(
        phase: TagThreadsPhase.ready,
        tag: result.tag,
        categories: result.categories,
        items: result.page.items,
        cursor: result.page.cursor,
        hasMore: result.page.hasMore,
      );
    } on Object catch (error) {
      if (epoch != _requestEpoch) return;
      state = TagThreadsState(
        phase: TagThreadsPhase.failed,
        failure: _asFailure(error, '标签主题没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> refresh() async {
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      transientFailure: null,
    );
    try {
      final result = await _repository.loadTagThreads(_tagId);
      if (epoch != _requestEpoch) return;
      state = state.copyWith(
        phase: TagThreadsPhase.ready,
        tag: result.tag,
        categories: result.categories,
        items: result.page.items,
        cursor: result.page.cursor,
        hasMore: result.page.hasMore,
        failure: null,
        transientFailure: null,
        isRefreshing: false,
      );
    } on Object catch (error) {
      if (epoch != _requestEpoch) return;
      final failure = _asFailure(error, '标签主题刷新失败，请重试。');
      if (state.tag == null) {
        state = TagThreadsState(
          phase: TagThreadsPhase.failed,
          failure: failure,
        );
      } else {
        state = state.copyWith(
          isRefreshing: false,
          transientFailure: failure,
          transientRetryAction: TagThreadsRetryAction.refresh,
        );
      }
    }
  }

  Future<void> loadMore() async {
    if (state.phase != TagThreadsPhase.ready ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final epoch = _requestEpoch;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _repository.fetchTagThreads(
        tagId: _tagId,
        cursor: state.cursor,
      );
      if (epoch != _requestEpoch) return;
      final seen = state.items.map((item) => item.id).toSet();
      state = state.copyWith(
        items: [
          ...state.items,
          ...page.items.where((item) => seen.add(item.id)),
        ],
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiFailure catch (failure) {
      if (epoch != _requestEpoch) return;
      if (failure.isInvalidCursor) {
        await refresh();
        return;
      }
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: failure,
        transientRetryAction: TagThreadsRetryAction.loadMore,
      );
    } on Object catch (error) {
      if (epoch != _requestEpoch) return;
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: _asFailure(error, '加载更多标签主题失败，请重试。'),
        transientRetryAction: TagThreadsRetryAction.loadMore,
      );
    }
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }
}

final tagThreadsControllerProvider = StateNotifierProvider.autoDispose
    .family<TagThreadsController, TagThreadsState, String>((ref, tagId) {
      return TagThreadsController(tagId, ref.watch(tagRepositoryProvider));
    });

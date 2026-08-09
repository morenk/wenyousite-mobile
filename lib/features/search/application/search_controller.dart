import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

class SearchController extends StateNotifier<SearchState> {
  SearchController(this._repository) : super(const SearchState());

  final SearchRepository _repository;
  int _queryEpoch = 0;

  Future<void> submit(String rawQuery) async {
    final query = rawQuery.trim();
    _queryEpoch += 1;
    state = SearchState(query: query, activeTab: state.activeTab);
    if (query.isEmpty) return;
    await _loadTab(state.activeTab, query, _queryEpoch);
  }

  Future<void> selectTab(SearchResultTab tab) async {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab);
    if (!state.hasQuery || !_sectionIsIdle(tab)) return;
    await _loadTab(tab, state.query, _queryEpoch);
  }

  Future<void> retryActive() {
    if (!state.hasQuery) return Future.value();
    return _loadTab(state.activeTab, state.query, _queryEpoch);
  }

  Future<void> refreshActive() => retryActive();

  Future<void> loadMorePosts() async {
    final section = state.posts;
    if (!state.isPostQueryValid ||
        section.phase != SearchSectionPhase.ready ||
        section.isLoadingMore ||
        !section.hasMore) {
      return;
    }
    final epoch = _queryEpoch;
    final query = state.query;
    state = state.copyWith(
      posts: SearchSectionState(
        phase: section.phase,
        items: section.items,
        cursor: section.cursor,
        hasMore: section.hasMore,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _repository.searchPosts(query, cursor: section.cursor);
      if (!_isCurrent(epoch, query)) return;
      final seen = section.items.map((item) => item.id).toSet();
      state = state.copyWith(
        posts: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: List.unmodifiable([
            ...section.items,
            ...page.items.where((item) => seen.add(item.id)),
          ]),
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on ApiFailure catch (failure) {
      if (!_isCurrent(epoch, query)) return;
      if (failure.isInvalidCursor) {
        await _loadPosts(query, epoch);
        return;
      }
      state = state.copyWith(
        posts: SearchSectionState(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: failure,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        posts: SearchSectionState(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: _asFailure(error, '加载更多搜索结果失败，请重试。'),
        ),
      );
    }
  }

  void clear() {
    _queryEpoch += 1;
    state = SearchState(activeTab: state.activeTab);
  }

  Future<void> _loadTab(SearchResultTab tab, String query, int epoch) {
    return switch (tab) {
      SearchResultTab.threads => _loadThreads(query, epoch),
      SearchResultTab.users => _loadUsers(query, epoch),
      SearchResultTab.posts => _loadPosts(query, epoch),
    };
  }

  Future<void> _loadThreads(String query, int epoch) async {
    state = state.copyWith(
      threads: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final items = await _repository.searchThreads(query);
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        threads: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: items,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        threads: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '主题搜索没有完成，请稍后重试。'),
        ),
      );
    }
  }

  Future<void> _loadUsers(String query, int epoch) async {
    state = state.copyWith(
      users: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final items = await _repository.searchUsers(query);
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        users: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: items,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        users: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '用户搜索没有完成，请稍后重试。'),
        ),
      );
    }
  }

  Future<void> _loadPosts(String query, int epoch) async {
    if (query.runes.length < 2) return;
    state = state.copyWith(
      posts: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final page = await _repository.searchPosts(query);
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        posts: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: page.items,
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        posts: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '正文搜索没有完成，请稍后重试。'),
        ),
      );
    }
  }

  bool _sectionIsIdle(SearchResultTab tab) {
    return switch (tab) {
      SearchResultTab.threads => state.threads.phase == SearchSectionPhase.idle,
      SearchResultTab.users => state.users.phase == SearchSectionPhase.idle,
      SearchResultTab.posts => state.posts.phase == SearchSectionPhase.idle,
    };
  }

  bool _isCurrent(int epoch, String query) =>
      mounted && epoch == _queryEpoch && query == state.query;

  ApiFailure _asFailure(Object error, String message) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: message, cause: error);
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
      final controller = SearchController(ref.watch(searchRepositoryProvider));
      ref.listen(
        sessionControllerProvider.select((session) => session.status),
        (previous, next) {
          if (previous != null && previous != next) controller.clear();
        },
      );
      return controller;
    });

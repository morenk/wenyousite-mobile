import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/search/application/search_repository_ports.dart';
import 'package:wenyousite_mobile/features/search/application/search_states.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

export 'package:wenyousite_mobile/features/search/application/search_states.dart';

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
    if (!state.isContentQueryValid ||
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

  Future<void> loadMoreMoments() async {
    final section = state.moments;
    if (!state.isContentQueryValid ||
        section.phase != SearchSectionPhase.ready ||
        section.isLoadingMore ||
        !section.hasMore) {
      return;
    }
    final epoch = _queryEpoch;
    final query = state.query;
    state = state.copyWith(
      moments: SearchSectionState(
        phase: section.phase,
        items: section.items,
        cursor: section.cursor,
        hasMore: section.hasMore,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _repository.searchMoments(
        query,
        cursor: section.cursor,
      );
      if (!_isCurrent(epoch, query)) return;
      final seen = section.items.map((item) => item.id).toSet();
      state = state.copyWith(
        moments: SearchSectionState(
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
        await _loadMoments(query, epoch);
        return;
      }
      state = state.copyWith(
        moments: SearchSectionState(
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
        moments: SearchSectionState(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: _asFailure(error, '加载更多动态搜索结果失败，请重试。'),
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
      SearchResultTab.overview => _loadOverview(query, epoch),
      SearchResultTab.moments => _loadMoments(query, epoch),
      SearchResultTab.threads => _loadThreads(query, epoch),
      SearchResultTab.users => _loadUsers(query, epoch),
      SearchResultTab.posts => _loadPosts(query, epoch),
    };
  }

  Future<void> _loadOverview(String query, int epoch) async {
    state = state.copyWith(
      overview: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final result = await _repository.searchOverview(query);
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        overview: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: [result],
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        overview: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '综合搜索没有完成，请稍后重试。'),
        ),
      );
    }
  }

  Future<void> _loadMoments(String query, int epoch) async {
    if (query.runes.length < 2) return;
    state = state.copyWith(
      moments: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final page = await _repository.searchMoments(query);
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        moments: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: page.items,
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = state.copyWith(
        moments: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '动态搜索没有完成，请稍后重试。'),
        ),
      );
    }
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
      SearchResultTab.overview =>
        state.overview.phase == SearchSectionPhase.idle,
      SearchResultTab.moments => state.moments.phase == SearchSectionPhase.idle,
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
    }, dependencies: [searchRepositoryProvider]);

class ThreadPostSearchController extends StateNotifier<ThreadPostSearchState> {
  ThreadPostSearchController(this._repository, this._threadId)
    : super(const ThreadPostSearchState());

  final SearchRepository _repository;
  final String _threadId;
  int _queryEpoch = 0;

  Future<void> submit(String rawQuery) async {
    final query = rawQuery.trim();
    final epoch = ++_queryEpoch;
    state = ThreadPostSearchState(query: query);
    if (query.runes.length < 2) return;
    await _loadFirstPage(query, epoch);
  }

  Future<void> retry() {
    if (!state.isQueryValid) return Future.value();
    return _loadFirstPage(state.query, _queryEpoch);
  }

  Future<void> loadMore() async {
    final section = state.results;
    if (!state.isQueryValid ||
        section.phase != SearchSectionPhase.ready ||
        section.isLoadingMore ||
        !section.hasMore) {
      return;
    }
    final epoch = _queryEpoch;
    final query = state.query;
    state = ThreadPostSearchState(
      query: query,
      results: SearchSectionState(
        phase: section.phase,
        items: section.items,
        cursor: section.cursor,
        hasMore: section.hasMore,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _repository.searchThreadPosts(
        _threadId,
        query,
        cursor: section.cursor,
      );
      if (!_isCurrent(epoch, query)) return;
      final seen = section.items.map((item) => item.id).toSet();
      state = ThreadPostSearchState(
        query: query,
        results: SearchSectionState(
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
        await _loadFirstPage(query, epoch);
        return;
      }
      state = ThreadPostSearchState(
        query: query,
        results: SearchSectionState(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: failure,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = ThreadPostSearchState(
        query: query,
        results: SearchSectionState(
          phase: section.phase,
          items: section.items,
          cursor: section.cursor,
          hasMore: section.hasMore,
          failure: _asFailure(error, '加载更多主题内搜索结果失败，请重试。'),
        ),
      );
    }
  }

  void clear() {
    _queryEpoch += 1;
    state = const ThreadPostSearchState();
  }

  Future<void> _loadFirstPage(String query, int epoch) async {
    state = ThreadPostSearchState(
      query: query,
      results: const SearchSectionState(phase: SearchSectionPhase.loading),
    );
    try {
      final page = await _repository.searchThreadPosts(_threadId, query);
      if (!_isCurrent(epoch, query)) return;
      state = ThreadPostSearchState(
        query: query,
        results: SearchSectionState(
          phase: SearchSectionPhase.ready,
          items: page.items,
          cursor: page.cursor,
          hasMore: page.hasMore,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch, query)) return;
      state = ThreadPostSearchState(
        query: query,
        results: SearchSectionState(
          phase: SearchSectionPhase.failed,
          failure: _asFailure(error, '主题内搜索没有完成，请稍后重试。'),
        ),
      );
    }
  }

  bool _isCurrent(int epoch, String query) =>
      mounted && epoch == _queryEpoch && query == state.query;

  ApiFailure _asFailure(Object error, String message) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: message, cause: error);
  }
}

final threadPostSearchControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadPostSearchController, ThreadPostSearchState, String>((
      ref,
      threadId,
    ) {
      final controller = ThreadPostSearchController(
        ref.watch(searchRepositoryProvider),
        threadId,
      );
      ref.listen(
        sessionControllerProvider.select((session) => session.status),
        (previous, next) {
          if (previous != null && previous != next) controller.clear();
        },
      );
      return controller;
    }, dependencies: [searchRepositoryProvider]);

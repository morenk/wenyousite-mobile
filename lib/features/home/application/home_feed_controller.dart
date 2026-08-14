import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/request_epoch.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/home/application/home_repository_ports.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

enum HomeFeedPhase { loading, ready, failed }

enum HomeFeedRetryAction { refresh, loadMore }

const _unset = Object();

class HomeFeedState {
  const HomeFeedState({
    this.phase = HomeFeedPhase.loading,
    this.categories = const [],
    this.items = const [],
    this.query = const HomeFeedQuery(),
    this.cursor,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.failure,
    this.transientFailure,
    this.transientRetryAction = HomeFeedRetryAction.refresh,
  });

  final HomeFeedPhase phase;
  final List<HomeCategory> categories;
  final List<HomeThreadCardModel> items;
  final HomeFeedQuery query;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final HomeFeedRetryAction transientRetryAction;

  HomeFeedState copyWith({
    HomeFeedPhase? phase,
    List<HomeCategory>? categories,
    List<HomeThreadCardModel>? items,
    HomeFeedQuery? query,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    HomeFeedRetryAction? transientRetryAction,
  }) {
    return HomeFeedState(
      phase: phase ?? this.phase,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      query: query ?? this.query,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      transientRetryAction: transientRetryAction ?? this.transientRetryAction,
    );
  }
}

class HomeFeedController extends StateNotifier<HomeFeedState> {
  HomeFeedController(this._repository, {bool autoStart = true})
    : super(const HomeFeedState()) {
    if (autoStart) unawaited(loadInitial());
  }

  final HomeRepository _repository;
  final _requestEpoch = RequestEpoch();

  Future<void> loadInitial() => _loadFirstPage(loadCategories: true);

  Future<void> refresh() async {
    final epoch = _requestEpoch.begin();
    state = state.copyWith(
      isRefreshing: true,
      isLoadingMore: false,
      transientFailure: null,
    );
    try {
      final results = await Future.wait<Object>([
        _repository.fetchCategories(),
        _repository.fetchThreads(query: state.query),
      ]);
      final categories = results[0] as List<HomeCategory>;
      final page = results[1] as CursorPage<HomeThreadCardModel>;
      if (!_requestEpoch.isCurrent(epoch)) return;
      state = state.copyWith(
        phase: HomeFeedPhase.ready,
        categories: categories,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshing: false,
        failure: null,
        transientFailure: null,
      );
    } on Object catch (error) {
      if (!_requestEpoch.isCurrent(epoch)) return;
      final failure = _asFailure(error, '刷新主题列表失败，请稍后重试。');
      if (state.items.isEmpty) {
        state = state.copyWith(
          phase: HomeFeedPhase.failed,
          isRefreshing: false,
          failure: failure,
        );
      } else {
        state = state.copyWith(
          isRefreshing: false,
          transientFailure: failure,
          transientRetryAction: HomeFeedRetryAction.refresh,
        );
      }
    }
  }

  Future<void> selectCategory(String? slug) async {
    if (state.query.categorySlug == slug) return;
    state = state.copyWith(
      query: HomeFeedQuery(
        categorySlug: slug,
        tagId: state.query.tagId,
        sort: state.query.sort,
        status: state.query.status,
      ),
    );
    await _loadFirstPage(loadCategories: false);
  }

  Future<void> selectSort(HomeFeedSort sort) async {
    if (state.query.sort == sort) return;
    state = state.copyWith(
      query: HomeFeedQuery(
        categorySlug: state.query.categorySlug,
        tagId: state.query.tagId,
        sort: sort,
        status: state.query.status,
      ),
    );
    await _loadFirstPage(loadCategories: false);
  }

  Future<void> selectStatus(HomeThreadStatusFilter status) async {
    if (state.query.status == status) return;
    state = state.copyWith(
      query: HomeFeedQuery(
        categorySlug: state.query.categorySlug,
        tagId: state.query.tagId,
        sort: state.query.sort,
        status: status,
      ),
    );
    await _loadFirstPage(loadCategories: false);
  }

  Future<void> clearFilters() async {
    final alreadyClear =
        state.query.categorySlug == null &&
        state.query.sort == HomeFeedSort.recommended &&
        state.query.status == HomeThreadStatusFilter.all;
    if (alreadyClear) {
      await refresh();
      return;
    }
    state = state.copyWith(query: const HomeFeedQuery());
    await _loadFirstPage(loadCategories: false);
  }

  Future<void> loadMore() async {
    if (state.phase != HomeFeedPhase.ready ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }
    final epoch = _requestEpoch.current;
    final query = state.query;
    state = state.copyWith(isLoadingMore: true, transientFailure: null);
    try {
      final page = await _repository.fetchThreads(
        query: query,
        cursor: state.cursor,
      );
      if (!_requestEpoch.isCurrent(epoch)) return;
      final appended = mergeUniqueBy(
        state.items,
        page.items,
        keyOf: (item) => item.id,
      );
      state = state.copyWith(
        items: appended,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on ApiFailure catch (failure) {
      if (!_requestEpoch.isCurrent(epoch)) return;
      if (failure.isInvalidCursor) {
        await _loadFirstPage(loadCategories: false);
        return;
      }
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: failure,
        transientRetryAction: HomeFeedRetryAction.loadMore,
      );
    } on Object catch (error) {
      if (!_requestEpoch.isCurrent(epoch)) return;
      state = state.copyWith(
        isLoadingMore: false,
        transientFailure: _asFailure(error, '加载更多主题失败，请重试。'),
        transientRetryAction: HomeFeedRetryAction.loadMore,
      );
    }
  }

  Future<void> _loadFirstPage({required bool loadCategories}) async {
    final epoch = _requestEpoch.begin();
    state = state.copyWith(
      phase: HomeFeedPhase.loading,
      items: const [],
      cursor: null,
      hasMore: false,
      isRefreshing: false,
      isLoadingMore: false,
      failure: null,
      transientFailure: null,
    );
    try {
      final results = await Future.wait<Object>([
        loadCategories
            ? _repository.fetchCategories()
            : Future.value(state.categories),
        _repository.fetchThreads(query: state.query),
      ]);
      final categories = results[0] as List<HomeCategory>;
      final page = results[1] as CursorPage<HomeThreadCardModel>;
      if (!_requestEpoch.isCurrent(epoch)) return;
      state = state.copyWith(
        phase: HomeFeedPhase.ready,
        categories: categories,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!_requestEpoch.isCurrent(epoch)) return;
      state = state.copyWith(
        phase: HomeFeedPhase.failed,
        failure: _asFailure(error, '主题列表没有加载完成，请稍后重试。'),
      );
    }
  }

  ApiFailure _asFailure(Object error, String message) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: message, cause: error);
  }
}

final homeFeedControllerProvider =
    StateNotifierProvider<HomeFeedController, HomeFeedState>((ref) {
      final controller = HomeFeedController(ref.watch(homeRepositoryProvider));
      ref.listen(
        sessionControllerProvider.select((session) => session.status),
        (previous, next) {
          if (previous == null ||
              previous == next ||
              next == SessionStatus.restoring) {
            return;
          }
          unawaited(controller.refresh());
        },
      );
      return controller;
    }, dependencies: [homeRepositoryProvider]);

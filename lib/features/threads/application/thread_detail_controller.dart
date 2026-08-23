import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/models/paging.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_repository_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

enum ThreadDetailPhase { loading, ready, failed }

enum ThreadDetailRetryAction { refresh, floors, loadMore }

const _unset = Object();

class ThreadDetailState {
  const ThreadDetailState({
    this.phase = ThreadDetailPhase.loading,
    this.detail,
    this.selectedSubthreadId,
    this.floors = const [],
    this.cursor,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingFloors = false,
    this.isLoadingMore = false,
    this.isPrefetchingFloors = false,
    this.failure,
    this.transientFailure,
    this.retryAction = ThreadDetailRetryAction.refresh,
    this.floorOrder = ThreadFloorOrder.oldest,
    this.floorAuthorId,
  });

  final ThreadDetailPhase phase;
  final ThreadDetailModel? detail;
  final String? selectedSubthreadId;
  final List<ThreadFloorModel> floors;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingFloors;
  final bool isLoadingMore;
  final bool isPrefetchingFloors;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final ThreadDetailRetryAction retryAction;
  final ThreadFloorOrder floorOrder;
  final String? floorAuthorId;

  ThreadSubthreadModel? get selectedSubthread =>
      detail?.subthreadById(selectedSubthreadId);

  ThreadDetailState copyWith({
    ThreadDetailPhase? phase,
    Object? detail = _unset,
    Object? selectedSubthreadId = _unset,
    List<ThreadFloorModel>? floors,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingFloors,
    bool? isLoadingMore,
    bool? isPrefetchingFloors,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    ThreadDetailRetryAction? retryAction,
    ThreadFloorOrder? floorOrder,
    Object? floorAuthorId = _unset,
  }) {
    return ThreadDetailState(
      phase: phase ?? this.phase,
      detail: identical(detail, _unset)
          ? this.detail
          : detail as ThreadDetailModel?,
      selectedSubthreadId: identical(selectedSubthreadId, _unset)
          ? this.selectedSubthreadId
          : selectedSubthreadId as String?,
      floors: floors ?? this.floors,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingFloors: isLoadingFloors ?? this.isLoadingFloors,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPrefetchingFloors: isPrefetchingFloors ?? this.isPrefetchingFloors,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      retryAction: retryAction ?? this.retryAction,
      floorOrder: floorOrder ?? this.floorOrder,
      floorAuthorId: identical(floorAuthorId, _unset)
          ? this.floorAuthorId
          : floorAuthorId as String?,
    );
  }
}

class ThreadDetailController extends StateNotifier<ThreadDetailState> {
  ThreadDetailController(
    this._repository,
    this.threadId, {
    bool autoStart = true,
  }) : super(const ThreadDetailState()) {
    if (autoStart) unawaited(loadInitial());
  }

  final ThreadDetailRepository _repository;
  final String threadId;
  int _requestEpoch = 0;

  Future<void> loadInitial() async {
    final epoch = ++_requestEpoch;
    state = const ThreadDetailState();
    try {
      final detail = await _repository.fetchThread(threadId);
      if (!_isCurrent(epoch)) return;
      final selectedId = detail.preferredSubthreadId();
      state = state.copyWith(
        phase: ThreadDetailPhase.ready,
        detail: detail,
        selectedSubthreadId: selectedId,
        isLoadingFloors: selectedId != null,
      );
      if (selectedId != null) {
        await _loadFirstFloors(epoch, selectedId);
      }
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = state.copyWith(
        phase: ThreadDetailPhase.failed,
        failure: _asFailure(error, '主题详情加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> refresh() async {
    final previousSelectedId = state.selectedSubthreadId;
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      isRefreshing: true,
      isLoadingFloors: false,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: null,
    );
    try {
      final detail = await _repository.fetchThread(threadId);
      if (!_isCurrent(epoch)) return;
      final selectedId = detail.preferredSubthreadId(state.selectedSubthreadId);
      final selectionChanged = selectedId != previousSelectedId;
      state = state.copyWith(
        phase: ThreadDetailPhase.ready,
        detail: detail,
        selectedSubthreadId: selectedId,
        floorAuthorId: selectionChanged ? null : state.floorAuthorId,
        floors: const [],
        cursor: null,
        hasMore: false,
        failure: null,
        isLoadingFloors: selectedId != null,
      );
      if (selectedId == null) {
        state = state.copyWith(isRefreshing: false);
        return;
      }
      await _loadFirstFloors(epoch, selectedId);
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      final failure = _asFailure(error, '刷新主题详情失败，请稍后重试。');
      if (_isRestricted(failure)) {
        _hideRestrictedContent(failure);
        return;
      }
      if (state.detail == null) {
        state = state.copyWith(
          phase: ThreadDetailPhase.failed,
          isRefreshing: false,
          failure: failure,
        );
      } else {
        state = state.copyWith(
          isRefreshing: false,
          transientFailure: failure,
          retryAction: ThreadDetailRetryAction.refresh,
        );
      }
    }
  }

  /// Refreshes counts, permissions and thread metadata without discarding the
  /// currently loaded floor window. This is used after a successful post
  /// mutation so the reader's scroll position remains stable.
  Future<void> refreshMetadata() async {
    final previousSelectedId = state.selectedSubthreadId;
    final wasLoadingFloors = state.isLoadingFloors;
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      transientFailure: null,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      retryAction: null,
    );
    try {
      final detail = await _repository.fetchThread(threadId);
      if (!_isCurrent(epoch)) return;
      final selectedId = detail.preferredSubthreadId(previousSelectedId);
      final selectionChanged = selectedId != previousSelectedId;
      final shouldReloadFloors =
          selectedId != null && (selectionChanged || wasLoadingFloors);
      state = state.copyWith(
        phase: ThreadDetailPhase.ready,
        detail: detail,
        selectedSubthreadId: selectedId,
        floorAuthorId: selectionChanged ? null : state.floorAuthorId,
        floors: shouldReloadFloors ? const [] : state.floors,
        cursor: shouldReloadFloors ? null : state.cursor,
        hasMore: shouldReloadFloors ? false : state.hasMore,
        isLoadingFloors: shouldReloadFloors,
        failure: null,
      );
      if (shouldReloadFloors) {
        await _loadFirstFloors(epoch, selectedId);
      }
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      final failure = _asFailure(error, '主题信息刷新失败，请稍后重试。');
      if (_isRestricted(failure)) {
        _hideRestrictedContent(failure);
        return;
      }
      state = state.copyWith(
        isLoadingFloors: false,
        transientFailure: failure,
        retryAction: ThreadDetailRetryAction.refresh,
      );
    }
  }

  Future<void> selectSubthread(String subthreadId) async {
    if (state.selectedSubthreadId == subthreadId ||
        state.detail?.subthreadById(subthreadId) == null) {
      return;
    }
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      selectedSubthreadId: subthreadId,
      floorAuthorId: null,
      floors: const [],
      cursor: null,
      hasMore: false,
      isLoadingFloors: true,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: null,
    );
    await _loadFirstFloors(epoch, subthreadId);
  }

  Future<void> setFloorOrder(ThreadFloorOrder order) async {
    await applyFloorFilters(order: order, authorId: state.floorAuthorId);
  }

  Future<void> setFloorAuthor(String? authorId) async {
    await applyFloorFilters(order: state.floorOrder, authorId: authorId);
  }

  Future<void> applyFloorFilters({
    required ThreadFloorOrder order,
    required String? authorId,
  }) async {
    final selectedId = state.selectedSubthreadId;
    final normalizedAuthorId = switch (authorId?.trim()) {
      final value? when value.isNotEmpty => value,
      _ => null,
    };
    if ((state.floorOrder == order &&
            state.floorAuthorId == normalizedAuthorId) ||
        selectedId == null ||
        state.phase != ThreadDetailPhase.ready) {
      return;
    }
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      floorOrder: order,
      floorAuthorId: normalizedAuthorId,
      floors: const [],
      cursor: null,
      hasMore: false,
      isLoadingFloors: true,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: null,
    );
    await _loadFirstFloors(epoch, selectedId);
  }

  Future<void> retryFloors() async {
    final selectedId = state.selectedSubthreadId;
    if (selectedId == null) return;
    final epoch = ++_requestEpoch;
    state = state.copyWith(
      floors: const [],
      cursor: null,
      hasMore: false,
      isLoadingFloors: true,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: null,
    );
    await _loadFirstFloors(epoch, selectedId);
  }

  Future<void> loadMore() => prefetchRemainingFloors();

  /// Fetches all remaining text pages sequentially. The page starts this only
  /// after the first frame, while the sliver remains responsible for lazily
  /// creating image widgets inside its bounded cache neighborhood.
  Future<void> prefetchRemainingFloors() async {
    final selectedId = state.selectedSubthreadId;
    if (state.phase != ThreadDetailPhase.ready ||
        selectedId == null ||
        state.isLoadingFloors ||
        state.isPrefetchingFloors ||
        !state.hasMore) {
      return;
    }
    final epoch = _requestEpoch;
    final order = state.floorOrder;
    final authorId = state.floorAuthorId;
    final seenCursors = <String>{};
    var didRestartInvalidCursor = false;
    state = state.copyWith(
      isLoadingMore: true,
      isPrefetchingFloors: true,
      transientFailure: null,
    );

    while (_matchesFloorRequest(epoch, selectedId, order, authorId) &&
        state.hasMore) {
      final cursor = state.cursor;
      if (cursor == null || !seenCursors.add(cursor)) {
        _finishFloorPrefetchFailure(
          const ApiFailure(userMessage: '楼层位置异常，请重试。'),
        );
        return;
      }
      try {
        final page = await _repository.fetchFloors(
          subthreadId: selectedId,
          cursor: cursor,
          order: order,
          authorId: authorId,
        );
        if (!_matchesFloorRequest(epoch, selectedId, order, authorId)) return;
        final merged = mergeUniqueBy(
          state.floors,
          page.items,
          keyOf: (item) => item.id,
        );
        state = state.copyWith(
          floors: _sortFloors(merged, order),
          cursor: page.cursor,
          hasMore: page.hasMore,
          transientFailure: null,
        );
      } on Object catch (error) {
        if (!_matchesFloorRequest(epoch, selectedId, order, authorId)) return;
        final failure = _asFailure(error, '加载更多楼层失败，请稍后重试。');
        if (_isRestricted(failure)) {
          _hideRestrictedContent(failure);
          return;
        }
        if (failure.isInvalidCursor && !didRestartInvalidCursor) {
          didRestartInvalidCursor = true;
          seenCursors.clear();
          try {
            final firstPage = await _repository.fetchFloors(
              subthreadId: selectedId,
              order: order,
              authorId: authorId,
            );
            if (!_matchesFloorRequest(epoch, selectedId, order, authorId)) {
              return;
            }
            state = state.copyWith(
              floors: _sortFloors(firstPage.items, order),
              cursor: firstPage.cursor,
              hasMore: firstPage.hasMore,
              transientFailure: null,
            );
            continue;
          } on Object catch (restartError) {
            if (!_matchesFloorRequest(epoch, selectedId, order, authorId)) {
              return;
            }
            final restartFailure = _asFailure(restartError, '楼层重新加载失败，请稍后重试。');
            if (_isRestricted(restartFailure)) {
              _hideRestrictedContent(restartFailure);
              return;
            }
            _finishFloorPrefetchFailure(restartFailure);
            return;
          }
        }
        _finishFloorPrefetchFailure(failure);
        return;
      }
    }

    if (_matchesFloorRequest(epoch, selectedId, order, authorId)) {
      state = state.copyWith(isLoadingMore: false, isPrefetchingFloors: false);
    }
  }

  Future<void> _loadFirstFloors(int epoch, String subthreadId) async {
    try {
      final page = await _repository.fetchFloors(
        subthreadId: subthreadId,
        order: state.floorOrder,
        authorId: state.floorAuthorId,
      );
      if (!_isCurrent(epoch) || state.selectedSubthreadId != subthreadId) {
        return;
      }
      state = state.copyWith(
        floors: _sortFloors(page.items, state.floorOrder),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshing: false,
        isLoadingFloors: false,
        isPrefetchingFloors: false,
        transientFailure: null,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch) || state.selectedSubthreadId != subthreadId) {
        return;
      }
      final failure = _asFailure(error, '楼层加载失败，请稍后重试。');
      if (_isRestricted(failure)) {
        _hideRestrictedContent(failure);
        return;
      }
      state = state.copyWith(
        isRefreshing: false,
        isLoadingFloors: false,
        transientFailure: failure,
        retryAction: ThreadDetailRetryAction.floors,
      );
    }
  }

  bool _isCurrent(int epoch) => mounted && epoch == _requestEpoch;

  bool _matchesFloorRequest(
    int epoch,
    String subthreadId,
    ThreadFloorOrder order,
    String? authorId,
  ) =>
      _isCurrent(epoch) &&
      state.selectedSubthreadId == subthreadId &&
      state.floorOrder == order &&
      state.floorAuthorId == authorId;

  void _finishFloorPrefetchFailure(ApiFailure failure) {
    state = state.copyWith(
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: failure,
      retryAction: ThreadDetailRetryAction.loadMore,
    );
  }

  bool _isRestricted(ApiFailure failure) =>
      failure.httpStatus == 403 || failure.httpStatus == 404;

  void _hideRestrictedContent(ApiFailure failure) {
    state = state.copyWith(
      phase: ThreadDetailPhase.failed,
      detail: null,
      selectedSubthreadId: null,
      floorAuthorId: null,
      floors: const [],
      cursor: null,
      hasMore: false,
      isRefreshing: false,
      isLoadingFloors: false,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      failure: failure,
      transientFailure: null,
    );
  }

  List<ThreadFloorModel> _sortFloors(
    Iterable<ThreadFloorModel> floors,
    ThreadFloorOrder order,
  ) {
    final sorted = floors.toList()
      ..sort((left, right) {
        final leftNumber = left.floorNumber;
        final rightNumber = right.floorNumber;
        if (leftNumber == null && rightNumber == null) return 0;
        if (leftNumber == null) return 1;
        if (rightNumber == null) return -1;
        final comparison = leftNumber.compareTo(rightNumber);
        return order == ThreadFloorOrder.oldest ? comparison : -comparison;
      });
    return List.unmodifiable(sorted);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final threadDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ThreadDetailController, ThreadDetailState, String>((ref, threadId) {
      return ThreadDetailController(
        ref.watch(threadDetailRepositoryProvider),
        threadId,
      );
    }, dependencies: [threadDetailRepositoryProvider]);

final threadPostTargetProvider = FutureProvider.autoDispose
    .family<ThreadPostTargetModel, String>((ref, postId) {
      ref.watch(sessionScopeProvider);
      return ref.watch(threadDetailRepositoryProvider).fetchPostTarget(postId);
    }, dependencies: [threadDetailRepositoryProvider, sessionScopeProvider]);

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
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
    this.window,
    this.pinnedFloors = const [],
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
  final DiscussionWindowBuffer<ThreadFloorModel>? window;
  final List<ThreadFloorModel> pinnedFloors;
  int get maxNumber => window?.maxNumber ?? 0;
  bool get hasBefore => window?.beforeCursor != null;
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
    Object? window = _unset,
    List<ThreadFloorModel>? pinnedFloors,
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
      window: identical(window, _unset)
          ? this.window
          : window as DiscussionWindowBuffer<ThreadFloorModel>?,
      pinnedFloors: pinnedFloors ?? this.pinnedFloors,
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
  bool _retryBefore = false;
  String? visibleFloorId;
  bool Function()? canApplyPage;
  void Function()? beforeWindowApply;

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

  /// 删除已确认后保留已加载窗口，统计重读会取消旧分页请求，避免迟到结果补回。
  Future<void> removeDeletedFloor(String floorId) async {
    final window = state.window;
    if (window != null) {
      state = _withWindow(
        window.removeWhere((item) => item.id == floorId),
        pins: state.pinnedFloors.where((item) => item.id != floorId).toList(),
      );
    }
    if (visibleFloorId == floorId) {
      visibleFloorId = state.floors.firstOrNull?.id;
    }
    await refreshMetadata();
  }

  Future<void> refresh() async {
    final previousSelectedId = state.selectedSubthreadId;
    var metadataVerified = false;
    final refreshId = visibleFloorId ?? state.floors.firstOrNull?.id;
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
      metadataVerified = true;
      state = state.copyWith(detail: detail, failure: null);
      if (selectionChanged || state.window == null) {
        state = state.copyWith(
          selectedSubthreadId: selectedId,
          floorAuthorId: selectionChanged ? null : state.floorAuthorId,
          floors: const [],
          window: null,
          pinnedFloors: const [],
          cursor: null,
          hasMore: false,
          isLoadingFloors: selectedId != null,
        );
        if (selectedId != null) {
          await _loadFirstFloors(epoch, selectedId);
        } else {
          state = state.copyWith(isRefreshing: false);
        }
        return;
      }
      final result = await _readWindow(
        subthreadId: selectedId!,
        order: state.floorOrder,
        authorId: state.floorAuthorId,
        postId: refreshId,
        active: () => _isCurrent(epoch),
      );
      if (!_isCurrent(epoch)) return;
      beforeWindowApply?.call();
      state = _withWindow(
        DiscussionWindowBuffer(result.page),
        pins: const [],
      ).copyWith(floorAuthorId: result.author);
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      final failure = _asFailure(error, '刷新主题详情失败，请稍后重试。');
      if (metadataVerified &&
          failure.httpStatus == 404 &&
          refreshId != null &&
          state.window != null) {
        beforeWindowApply?.call();
        state = _withWindow(
          state.window!.removeWhere((item) => item.id == refreshId),
          pins: state.pinnedFloors
              .where((item) => item.id != refreshId)
              .toList(),
        );
        visibleFloorId = state.floors.firstOrNull?.id;
        return;
      }
      if (failure.httpStatus == 403 ||
          (!metadataVerified && failure.httpStatus == 404)) {
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
        window: shouldReloadFloors ? null : state.window,
        pinnedFloors: shouldReloadFloors ? const [] : state.pinnedFloors,
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
      window: null,
      pinnedFloors: const [],
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
      window: null,
      pinnedFloors: const [],
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
      window: null,
      pinnedFloors: const [],
      cursor: null,
      hasMore: false,
      isLoadingFloors: true,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      transientFailure: null,
    );
    await _loadFirstFloors(epoch, selectedId);
  }

  ThreadDetailState _withWindow(
    DiscussionWindowBuffer<ThreadFloorModel> window, {
    List<ThreadFloorModel>? pins,
  }) {
    final pinned = pins ?? state.pinnedFloors;
    final ids = pinned.map((item) => item.id).toSet();
    return state.copyWith(
      window: window,
      pinnedFloors: pinned,
      floors: [
        ...pinned,
        ...window.items.where((item) => !ids.contains(item.id)),
      ],
      cursor: window.afterCursor,
      hasMore: window.afterCursor != null,
      isLoadingFloors: false,
      isLoadingMore: false,
      isPrefetchingFloors: false,
      isRefreshing: false,
      transientFailure: null,
    );
  }

  Future<
    ({DiscussionWindow<ThreadFloorModel> page, String? author, bool cleared})
  >
  _readWindow({
    required String subthreadId,
    required ThreadFloorOrder order,
    required String? authorId,
    int? number,
    String? postId,
    String? cursor,
    bool Function()? active,
  }) async {
    try {
      return (
        page: await _repository.fetchFloorWindow(
          subthreadId: subthreadId,
          number: number,
          postId: postId,
          cursor: cursor,
          order: order,
          authorId: authorId,
        ),
        author: authorId,
        cleared: false,
      );
    } on ApiFailure catch (failure) {
      if (failure.businessCode != 40010 ||
          authorId == null ||
          (number == null && postId == null) ||
          active == null ||
          !active()) {
        rethrow;
      }
      return (
        page: await _repository.fetchFloorWindow(
          subthreadId: subthreadId,
          number: number,
          postId: postId,
          order: order,
        ),
        author: null,
        cleared: true,
      );
    }
  }

  Future<({String id, bool clearedAuthor})?> locate({
    int? number,
    String? postId,
    required String subthreadId,
    required ThreadFloorOrder order,
    required String? authorId,
    required bool Function() active,
  }) async {
    if (state.phase != ThreadDetailPhase.ready ||
        state.detail?.subthreadById(subthreadId) == null) {
      return null;
    }
    final epoch = ++_requestEpoch;
    state = state.copyWith(isLoadingMore: false, isPrefetchingFloors: false);
    bool current() => _isCurrent(epoch) && active();
    final result = await _readWindow(
      subthreadId: subthreadId,
      order: order,
      authorId: authorId,
      number: number,
      postId: postId,
      active: current,
    );
    if (!current()) return null;
    final id = result.page.targetId;
    if (id == null) throw const ApiFailure(userMessage: '未找到该楼层。');
    state = _withWindow(DiscussionWindowBuffer(result.page), pins: const [])
        .copyWith(
          selectedSubthreadId: subthreadId,
          floorOrder: order,
          floorAuthorId: result.author,
        );
    visibleFloorId = id;
    return (id: id, clearedAuthor: result.cleared);
  }

  Future<void> locateFloor(String id) async {
    if (state.floors.any((item) => item.id == id)) return;
    final scope = state.selectedSubthreadId;
    if (scope == null) return;
    final epoch = _requestEpoch;
    try {
      await locate(
        postId: id,
        subthreadId: scope,
        order: state.floorOrder,
        authorId: state.floorAuthorId,
        active: () => mounted,
      );
    } on Object catch (error) {
      if (!mounted || _requestEpoch != epoch + 1) return;
      _finishFloorPrefetchFailure(_asFailure(error, '目标楼层加载失败，请重试。'));
    }
  }

  Future<void> loadMore() => loadAdjacent(before: _retryBefore);
  Future<void> prefetchRemainingFloors() => loadAdjacent();
  Future<void> loadAdjacent({bool before = false}) async {
    final selected = state.selectedSubthreadId;
    final window = state.window;
    final cursor = before ? window?.beforeCursor : window?.afterCursor;
    if (selected == null ||
        state.phase != ThreadDetailPhase.ready ||
        state.isLoadingFloors ||
        state.isRefreshing ||
        state.isPrefetchingFloors ||
        cursor == null ||
        canApplyPage?.call() == false) {
      return;
    }
    final epoch = _requestEpoch;
    _retryBefore = before;
    state = state.copyWith(
      isLoadingMore: true,
      isPrefetchingFloors: true,
      transientFailure: null,
    );
    try {
      DiscussionWindow<ThreadFloorModel> page;
      var replace = false;
      try {
        page = (await _readWindow(
          subthreadId: selected,
          order: state.floorOrder,
          authorId: state.floorAuthorId,
          cursor: cursor,
        )).page;
      } on ApiFailure catch (failure) {
        if (!failure.isInvalidCursor || !_isCurrent(epoch)) rethrow;
        page = (await _readWindow(
          subthreadId: selected,
          order: state.floorOrder,
          authorId: state.floorAuthorId,
          postId: visibleFloorId ?? state.floors.firstOrNull?.id,
        )).page;
        replace = true;
      }
      if (!_isCurrent(epoch)) return;
      if (canApplyPage?.call() == false) {
        state = state.copyWith(
          isLoadingMore: false,
          isPrefetchingFloors: false,
        );
        return;
      }
      if (!replace &&
          (before ? page.beforeCursor : page.afterCursor) == cursor) {
        throw const ApiFailure(userMessage: '楼层位置没有更新，请重试。');
      }
      final next = replace
          ? DiscussionWindowBuffer(page)
          : window!.extend(
              page,
              before: before,
              idOf: (item) => item.id,
              visibleId: visibleFloorId,
            );
      beforeWindowApply?.call();
      state = _withWindow(next, pins: replace ? const [] : null);
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      final failure = _asFailure(error, '更多楼层加载失败，请重试。');
      if (failure.httpStatus == 403 || failure.httpStatus == 404) {
        _hideRestrictedContent(failure);
      } else {
        _finishFloorPrefetchFailure(failure);
      }
    }
  }

  Future<void> _loadFirstFloors(int epoch, String subthreadId) async {
    try {
      final page = await _repository.fetchFloorWindow(
        subthreadId: subthreadId,
        order: state.floorOrder,
        authorId: state.floorAuthorId,
      );
      if (!_isCurrent(epoch) || state.selectedSubthreadId != subthreadId) {
        return;
      }
      visibleFloorId = null;
      state = _withWindow(DiscussionWindowBuffer(page), pins: page.pinnedItems);
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
      window: null,
      pinnedFloors: const [],
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

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

typedef ThreadDetailControllerScope = ({
  String threadId,
  Object pageInstanceToken,
});

final threadDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<
      ThreadDetailController,
      ThreadDetailState,
      ThreadDetailControllerScope
    >((ref, scope) {
      ref.watch(viewerScopeProvider);
      return ThreadDetailController(
        ref.watch(threadDetailRepositoryProvider),
        scope.threadId,
      );
    }, dependencies: [viewerScopeProvider, threadDetailRepositoryProvider]);

final threadPostTargetProvider = FutureProvider.autoDispose
    .family<ThreadPostTargetModel, String>((ref, postId) {
      ref.watch(viewerScopeProvider);

      return ref.watch(threadDetailRepositoryProvider).fetchPostTarget(postId);
    }, dependencies: [threadDetailRepositoryProvider, viewerScopeProvider]);

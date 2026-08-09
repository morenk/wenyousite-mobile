import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

class BookmarkListController extends StateNotifier<BookmarkListState> {
  BookmarkListController(this._repository)
    : super(const BookmarkListState.loading()) {
    load();
  }

  final BookmarkListRepository _repository;
  var _loadEpoch = 0;

  Future<void> load() async {
    final epoch = ++_loadEpoch;
    state = const BookmarkListState.loading();
    try {
      final page = await _repository.fetchPage();
      if (!mounted || epoch != _loadEpoch) return;
      state = BookmarkListState(
        phase: BookmarkListPhase.ready,
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = BookmarkListState(
        phase: BookmarkListPhase.failed,
        failure: _asFailure(error, '收藏列表没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.phase != BookmarkListPhase.ready ||
        state.isBusy ||
        !state.hasMore) {
      return;
    }
    final epoch = _loadEpoch;
    final oldItems = state.items;
    state = BookmarkListState(
      phase: BookmarkListPhase.ready,
      items: oldItems,
      cursor: state.cursor,
      hasMore: state.hasMore,
      isLoadingMore: true,
    );
    try {
      final page = await _repository.fetchPage(cursor: state.cursor);
      if (!mounted || epoch != _loadEpoch) return;
      state = BookmarkListState(
        phase: BookmarkListPhase.ready,
        items: List.unmodifiable([...oldItems, ...page.items]),
        cursor: page.cursor,
        hasMore: page.hasMore,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _loadEpoch) return;
      state = BookmarkListState(
        phase: BookmarkListPhase.ready,
        items: oldItems,
        cursor: state.cursor,
        hasMore: state.hasMore,
        loadMoreFailure: _asFailure(error, '更多收藏没有加载完成，请稍后重试。'),
      );
    }
  }

  Future<bool> removeBookmark(String bookmarkId) async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return false;
    if (!state.items.any((item) => item.bookmarkId == bookmarkId)) return false;
    final oldItems = state.items;
    final oldCursor = state.cursor;
    final oldHasMore = state.hasMore;
    final oldLoadMoreFailure = state.loadMoreFailure;
    state = BookmarkListState(
      phase: BookmarkListPhase.ready,
      items: oldItems,
      cursor: oldCursor,
      hasMore: oldHasMore,
      loadMoreFailure: oldLoadMoreFailure,
      pendingBookmarkId: bookmarkId,
    );
    try {
      await _repository.remove(bookmarkId);
      if (!mounted) return false;
      final updated = oldItems
          .where((item) => item.bookmarkId != bookmarkId)
          .toList(growable: false);
      final nextCursor = oldCursor == bookmarkId
          ? (updated.isEmpty ? null : updated.last.bookmarkId)
          : oldCursor;
      state = BookmarkListState(
        phase: BookmarkListPhase.ready,
        items: updated,
        cursor: nextCursor,
        hasMore: oldHasMore,
        loadMoreFailure: oldLoadMoreFailure,
      );
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = BookmarkListState(
        phase: BookmarkListPhase.ready,
        items: oldItems,
        cursor: oldCursor,
        hasMore: oldHasMore,
        loadMoreFailure: oldLoadMoreFailure,
        actionFailure: _asFailure(error, '取消收藏没有完成，请稍后重试。'),
      );
      return false;
    }
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = BookmarkListState(
      phase: state.phase,
      items: state.items,
      cursor: state.cursor,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      failure: state.failure,
      loadMoreFailure: state.loadMoreFailure,
      pendingBookmarkId: state.pendingBookmarkId,
    );
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }
}

final bookmarkListControllerProvider =
    StateNotifierProvider.autoDispose<
      BookmarkListController,
      BookmarkListState
    >(
      (ref) =>
          BookmarkListController(ref.watch(bookmarkListRepositoryProvider)),
    );

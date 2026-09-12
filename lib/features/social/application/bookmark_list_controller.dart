import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/visibility_cache_invalidation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/application/social_states.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

export 'package:wenyousite_mobile/features/social/application/social_states.dart';

class BookmarkListController extends StateNotifier<BookmarkListState> {
  BookmarkListController(this._repository, {String? initialFolderId})
    : super(
        BookmarkListState(
          phase: BookmarkListPhase.loading,
          selectedFolderId: initialFolderId,
          isLoadingFolders: true,
          isRefreshingList: true,
        ),
      ) {
    load();
  }

  final BookmarkListRepository _repository;
  var _listEpoch = 0;
  var _folderEpoch = 0;

  Future<void> load() async {
    if (state.pendingBookmarkId != null) return;
    final selectedFolderId = state.selectedFolderId;
    final listEpoch = ++_listEpoch;
    final folderEpoch = ++_folderEpoch;
    state = BookmarkListState(
      phase: BookmarkListPhase.loading,
      selectedFolderId: selectedFolderId,
      isLoadingFolders: true,
      isRefreshingList: true,
    );

    final pageTask = _capture(_repository.fetchPage(folderId: selectedFolderId))
        .then((result) {
          if (!mounted || listEpoch != _listEpoch) return;
          final page = result.value;
          state = state.copyWith(
            phase: page == null
                ? BookmarkListPhase.failed
                : BookmarkListPhase.ready,
            items: page?.items ?? const [],
            cursor: page?.cursor,
            hasMore: page?.hasMore ?? false,
            isRefreshingList: false,
            failure: result.error == null
                ? null
                : _asFailure(result.error!, '收藏列表加载失败，请稍后重试。'),
          );
        });
    final foldersTask = _capture(_repository.fetchFolders()).then((result) {
      if (!mounted || folderEpoch != _folderEpoch) return;
      state = state.copyWith(
        folders: result.value ?? const [],
        isLoadingFolders: false,
        folderFailure: result.error == null
            ? null
            : _asFailure(result.error!, '收藏夹分类加载失败，请稍后重试。'),
      );
    });
    await Future.wait([pageTask, foldersTask]);
  }

  Future<void> refresh() async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return;
    final selectedFolderId = state.selectedFolderId;
    final oldItems = state.items;
    final oldFolders = state.folders;
    final listEpoch = ++_listEpoch;
    final folderEpoch = ++_folderEpoch;
    state = state.copyWith(
      isRefreshingList: true,
      isLoadingFolders: true,
      failure: null,
      folderFailure: null,
      loadMoreFailure: null,
      actionFailure: null,
    );

    final pageTask = _capture(_repository.fetchPage(folderId: selectedFolderId))
        .then((result) {
          if (!mounted || listEpoch != _listEpoch) return;
          final page = result.value;
          state = state.copyWith(
            items: page?.items ?? oldItems,
            cursor: page == null ? state.cursor : page.cursor,
            hasMore: page?.hasMore ?? state.hasMore,
            isRefreshingList: false,
            failure: result.error == null
                ? null
                : _asFailure(result.error!, '刷新收藏列表失败，请稍后重试。'),
          );
        });
    final foldersTask = _capture(_repository.fetchFolders()).then((result) {
      if (!mounted || folderEpoch != _folderEpoch) return;
      state = state.copyWith(
        folders: result.value ?? oldFolders,
        isLoadingFolders: false,
        folderFailure: result.error == null
            ? null
            : _asFailure(result.error!, '刷新收藏夹数量失败，请稍后重试。'),
      );
    });
    await Future.wait([pageTask, foldersTask]);
  }

  Future<void> reloadFolders() async {
    if (state.phase != BookmarkListPhase.ready || state.isLoadingFolders) {
      return;
    }
    final epoch = ++_folderEpoch;
    state = state.copyWith(isLoadingFolders: true, folderFailure: null);
    try {
      final folders = await _repository.fetchFolders();
      if (!mounted || epoch != _folderEpoch) return;
      state = state.copyWith(
        folders: folders,
        isLoadingFolders: false,
        folderFailure: null,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _folderEpoch) return;
      state = state.copyWith(
        isLoadingFolders: false,
        folderFailure: _asFailure(error, '收藏夹分类加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> selectFolder(String? folderId, {bool force = false}) async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return;
    if (folderId != null && state.folderById(folderId) == null) return;
    if (!force && folderId == state.selectedFolderId) return;
    await _loadSelectedFolder(folderId);
  }

  Future<void> retrySelectedFolder() async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return;
    await _loadSelectedFolder(state.selectedFolderId);
  }

  Future<void> _loadSelectedFolder(String? folderId) async {
    final epoch = ++_listEpoch;
    state = state.copyWith(
      selectedFolderId: folderId,
      items: const [],
      cursor: null,
      hasMore: false,
      isRefreshingList: true,
      failure: null,
      loadMoreFailure: null,
      actionFailure: null,
    );
    try {
      final page = await _repository.fetchPage(folderId: folderId);
      if (!mounted || epoch != _listEpoch) return;
      state = state.copyWith(
        items: page.items,
        cursor: page.cursor,
        hasMore: page.hasMore,
        isRefreshingList: false,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _listEpoch) return;
      state = state.copyWith(
        isRefreshingList: false,
        failure: _asFailure(error, '这个收藏夹加载失败，请稍后重试。'),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.phase != BookmarkListPhase.ready ||
        state.isBusy ||
        !state.hasMore) {
      return;
    }
    final epoch = _listEpoch;
    final oldItems = state.items;
    state = state.copyWith(isLoadingMore: true, loadMoreFailure: null);
    try {
      final page = await _repository.fetchPage(
        cursor: state.cursor,
        folderId: state.selectedFolderId,
      );
      if (!mounted || epoch != _listEpoch) return;
      state = state.copyWith(
        items: List.unmodifiable([...oldItems, ...page.items]),
        cursor: page.cursor,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } on Object catch (error) {
      if (!mounted || epoch != _listEpoch) return;
      final failure = _asFailure(error, '更多收藏加载失败，请稍后重试。');
      if (failure.isInvalidCursor) {
        state = state.copyWith(isLoadingMore: false);
        await _loadSelectedFolder(state.selectedFolderId);
        return;
      }
      state = state.copyWith(isLoadingMore: false, loadMoreFailure: failure);
    }
  }

  Future<BookmarkFolderItem?> createFolder(String name) async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return null;
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.runes.length > 24) {
      state = state.copyWith(
        actionFailure: const ApiFailure(userMessage: '收藏夹名称需为 1–24 个字符。'),
      );
      return null;
    }
    state = state.copyWith(isCreatingFolder: true, actionFailure: null);
    try {
      final folder = await _repository.createFolder(trimmedName);
      if (!mounted) return null;
      state = state.copyWith(
        folders: List.unmodifiable([...state.folders, folder]),
        selectedFolderId: folder.id,
        items: const [],
        cursor: null,
        hasMore: false,
        failure: null,
        folderFailure: null,
      );
      await _refreshAfterCreation(folder);
      return folder;
    } on Object catch (error) {
      if (!mounted) return null;
      state = state.copyWith(
        isCreatingFolder: false,
        actionFailure: _asFailure(error, '新建收藏夹失败，请稍后重试。'),
      );
      return null;
    }
  }

  Future<void> _refreshAfterCreation(BookmarkFolderItem folder) async {
    final listEpoch = ++_listEpoch;
    final folderEpoch = ++_folderEpoch;
    final fallbackFolders = state.folders;
    state = state.copyWith(isRefreshingList: true, isLoadingFolders: true);
    final pageTask = _capture(_repository.fetchPage(folderId: folder.id)).then((
      result,
    ) {
      if (!mounted || listEpoch != _listEpoch) return;
      final page = result.value;
      state = state.copyWith(
        items: page?.items ?? const [],
        cursor: page?.cursor,
        hasMore: page?.hasMore ?? false,
        isRefreshingList: false,
        isCreatingFolder: false,
        failure: result.error == null
            ? null
            : _asFailure(result.error!, '刷新新收藏夹失败，请下拉重试。'),
      );
    });
    final foldersTask = _capture(_repository.fetchFolders()).then((result) {
      if (!mounted || folderEpoch != _folderEpoch) return;
      state = state.copyWith(
        folders: result.value ?? fallbackFolders,
        isLoadingFolders: false,
        folderFailure: result.error == null
            ? null
            : _asFailure(result.error!, '刷新收藏夹数量失败，请下拉重试。'),
      );
    });
    await Future.wait([pageTask, foldersTask]);
  }

  Future<bool> moveBookmark(String bookmarkId, String folderId) async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return false;
    final item = state.items
        .where((item) => item.bookmarkId == bookmarkId)
        .firstOrNull;
    if (item == null ||
        state.folderById(folderId) == null ||
        item.folderId == folderId) {
      return false;
    }
    return _mutateBookmark(item, folderId: folderId);
  }

  Future<bool> removeBookmark(String bookmarkId) async {
    if (state.phase != BookmarkListPhase.ready || state.isBusy) return false;
    final item = state.items
        .where((item) => item.bookmarkId == bookmarkId)
        .firstOrNull;
    if (item == null) return false;
    return _mutateBookmark(item);
  }

  Future<bool> _mutateBookmark(
    BookmarkListItem item, {
    String? folderId,
  }) async {
    final before = state;
    final epoch = ++_listEpoch;
    ++_folderEpoch;
    final items = [
      for (final candidate in before.items)
        if (candidate.bookmarkId != item.bookmarkId)
          candidate
        else if (folderId != null && before.selectedFolderId == null)
          candidate.copyWithFolderId(folderId),
    ];
    final folders = [
      for (final folder in before.folders)
        BookmarkFolderItem(
          id: folder.id,
          name: folder.name,
          isDefault: folder.isDefault,
          createdAt: folder.createdAt,
          bookmarkCount:
              (folder.bookmarkCount +
                      (folder.id == item.folderId ? -1 : 0) +
                      (folder.id == folderId ? 1 : 0))
                  .clamp(0, 1 << 31),
        ),
    ];
    state = state.copyWith(
      items: items,
      folders: folders,
      pendingBookmarkId: item.bookmarkId,
      pendingAction: folderId == null
          ? BookmarkPendingAction.remove
          : BookmarkPendingAction.move,
      actionFailure: null,
    );
    try {
      if (folderId == null) {
        await _repository.remove(item.bookmarkId);
      } else {
        await _repository.move(item.bookmarkId, folderId);
      }
      if (!mounted || epoch != _listEpoch) return false;
      await _refreshAfterMutation(items);
      return true;
    } on Object catch (error) {
      if (!mounted || epoch != _listEpoch) return false;
      final failure = _asFailure(
        error,
        folderId == null ? '取消收藏失败，请重试。' : '移动收藏失败，请重试。',
      );
      state = before.copyWith(actionFailure: failure);
      if (failure.hasUnknownWriteOutcome) {
        // 分页缺少目标不能证明删除成功，只校准当前目录，不重复发送写请求。
        await refresh();
        if (mounted) state = state.copyWith(actionFailure: failure);
      }
      return false;
    }
  }

  Future<void> _refreshAfterMutation(
    List<BookmarkListItem> fallbackItems,
  ) async {
    final selectedFolderId = state.selectedFolderId;
    final fallbackFolders = state.folders;
    final listEpoch = ++_listEpoch;
    final folderEpoch = ++_folderEpoch;
    state = state.copyWith(
      items: fallbackItems,
      cursor: null,
      hasMore: false,
      isRefreshingList: true,
      isLoadingFolders: true,
      failure: null,
      folderFailure: null,
      loadMoreFailure: null,
    );
    final pageTask = _capture(_repository.fetchPage(folderId: selectedFolderId))
        .then((result) {
          if (!mounted || listEpoch != _listEpoch) return;
          final page = result.value;
          state = state.copyWith(
            items: page?.items ?? fallbackItems,
            cursor: page?.cursor,
            hasMore: page?.hasMore ?? false,
            isRefreshingList: false,
            pendingBookmarkId: null,
            pendingAction: null,
            failure: result.error == null
                ? null
                : _asFailure(result.error!, '操作已完成，但刷新收藏列表失败。'),
          );
        });
    final foldersTask = _capture(_repository.fetchFolders()).then((result) {
      if (!mounted || folderEpoch != _folderEpoch) return;
      state = state.copyWith(
        folders: result.value ?? fallbackFolders,
        isLoadingFolders: false,
        folderFailure: result.error == null
            ? null
            : _asFailure(result.error!, '操作已完成，但刷新收藏夹数量失败。'),
      );
    });
    await Future.wait([pageTask, foldersTask]);
  }

  void clearActionFailure() {
    if (state.actionFailure == null) return;
    state = state.copyWith(actionFailure: null);
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

class _CaptureResult<T> {
  const _CaptureResult({this.value, this.error});

  final T? value;
  final Object? error;
}

Future<_CaptureResult<T>> _capture<T>(Future<T> future) async {
  try {
    return _CaptureResult(value: await future);
  } on Object catch (error) {
    return _CaptureResult(error: error);
  }
}

final bookmarkListControllerProvider = StateNotifierProvider.autoDispose
    .family<BookmarkListController, BookmarkListState, String?>((
      ref,
      initialFolderId,
    ) {
      ref.watch(viewerScopeProvider);
      return BookmarkListController(
        ref.watch(bookmarkListRepositoryProvider),
        initialFolderId: initialFolderId,
      );
    }, dependencies: [viewerScopeProvider, bookmarkListRepositoryProvider]);

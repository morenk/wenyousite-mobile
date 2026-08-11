import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum BookmarkedThreadStatus { recruiting, closed, finished, unknown }

class BookmarkFolderItem {
  const BookmarkFolderItem({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.bookmarkCount,
    required this.createdAt,
  });

  final String id;
  final String name;
  final bool isDefault;
  final int bookmarkCount;
  final DateTime createdAt;
}

class BookmarkListItem {
  const BookmarkListItem({
    required this.bookmarkId,
    required this.threadId,
    required this.title,
    required this.status,
    required this.isPrivate,
    required this.isPinned,
    required this.ownerName,
    required this.ownerLevel,
    required this.createdAt,
    required this.memberCount,
    required this.postCount,
    required this.tipTotal,
    this.folderId,
    this.categorySlug,
  });

  final String bookmarkId;
  final String? folderId;
  final String threadId;
  final String title;
  final String? categorySlug;
  final BookmarkedThreadStatus status;
  final bool isPrivate;
  final bool isPinned;
  final String ownerName;
  final int ownerLevel;
  final DateTime createdAt;
  final int memberCount;
  final int postCount;
  final String tipTotal;

  BookmarkListItem copyWithFolderId(String folderId) {
    return BookmarkListItem(
      bookmarkId: bookmarkId,
      folderId: folderId,
      threadId: threadId,
      title: title,
      categorySlug: categorySlug,
      status: status,
      isPrivate: isPrivate,
      isPinned: isPinned,
      ownerName: ownerName,
      ownerLevel: ownerLevel,
      createdAt: createdAt,
      memberCount: memberCount,
      postCount: postCount,
      tipTotal: tipTotal,
    );
  }
}

enum BookmarkListPhase { loading, ready, failed }

enum BookmarkPendingAction { move, remove }

const _unset = Object();

class BookmarkListState {
  const BookmarkListState({
    required this.phase,
    this.folders = const [],
    this.items = const [],
    this.selectedFolderId,
    this.cursor,
    this.hasMore = false,
    this.isLoadingFolders = false,
    this.isRefreshingList = false,
    this.isLoadingMore = false,
    this.isCreatingFolder = false,
    this.failure,
    this.folderFailure,
    this.loadMoreFailure,
    this.pendingBookmarkId,
    this.pendingAction,
    this.actionFailure,
  });

  const BookmarkListState.loading()
    : this(
        phase: BookmarkListPhase.loading,
        isLoadingFolders: true,
        isRefreshingList: true,
      );

  final BookmarkListPhase phase;
  final List<BookmarkFolderItem> folders;
  final List<BookmarkListItem> items;
  final String? selectedFolderId;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingFolders;
  final bool isRefreshingList;
  final bool isLoadingMore;
  final bool isCreatingFolder;
  final ApiFailure? failure;
  final ApiFailure? folderFailure;
  final ApiFailure? loadMoreFailure;
  final String? pendingBookmarkId;
  final BookmarkPendingAction? pendingAction;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingBookmarkId != null || isCreatingFolder;
  bool get isBusy =>
      isRefreshingList || isLoadingMore || isLoadingFolders || isMutating;
  int get totalBookmarkCount =>
      folders.fold(0, (total, folder) => total + folder.bookmarkCount);

  BookmarkFolderItem? folderById(String? id) {
    if (id == null) return null;
    for (final folder in folders) {
      if (folder.id == id) return folder;
    }
    return null;
  }

  BookmarkListState copyWith({
    BookmarkListPhase? phase,
    List<BookmarkFolderItem>? folders,
    List<BookmarkListItem>? items,
    Object? selectedFolderId = _unset,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingFolders,
    bool? isRefreshingList,
    bool? isLoadingMore,
    bool? isCreatingFolder,
    Object? failure = _unset,
    Object? folderFailure = _unset,
    Object? loadMoreFailure = _unset,
    Object? pendingBookmarkId = _unset,
    Object? pendingAction = _unset,
    Object? actionFailure = _unset,
  }) {
    return BookmarkListState(
      phase: phase ?? this.phase,
      folders: folders ?? this.folders,
      items: items ?? this.items,
      selectedFolderId: identical(selectedFolderId, _unset)
          ? this.selectedFolderId
          : selectedFolderId as String?,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingFolders: isLoadingFolders ?? this.isLoadingFolders,
      isRefreshingList: isRefreshingList ?? this.isRefreshingList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isCreatingFolder: isCreatingFolder ?? this.isCreatingFolder,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      folderFailure: identical(folderFailure, _unset)
          ? this.folderFailure
          : folderFailure as ApiFailure?,
      loadMoreFailure: identical(loadMoreFailure, _unset)
          ? this.loadMoreFailure
          : loadMoreFailure as ApiFailure?,
      pendingBookmarkId: identical(pendingBookmarkId, _unset)
          ? this.pendingBookmarkId
          : pendingBookmarkId as String?,
      pendingAction: identical(pendingAction, _unset)
          ? this.pendingAction
          : pendingAction as BookmarkPendingAction?,
      actionFailure: identical(actionFailure, _unset)
          ? this.actionFailure
          : actionFailure as ApiFailure?,
    );
  }
}

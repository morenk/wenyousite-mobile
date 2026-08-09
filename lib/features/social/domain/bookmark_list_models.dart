import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum BookmarkedThreadStatus { recruiting, closed, finished, unknown }

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
    this.categorySlug,
  });

  final String bookmarkId;
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
}

enum BookmarkListPhase { loading, ready, failed }

class BookmarkListState {
  const BookmarkListState({
    required this.phase,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
    this.pendingBookmarkId,
    this.actionFailure,
  });

  const BookmarkListState.loading() : this(phase: BookmarkListPhase.loading);

  final BookmarkListPhase phase;
  final List<BookmarkListItem> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final ApiFailure? failure;
  final ApiFailure? loadMoreFailure;
  final String? pendingBookmarkId;
  final ApiFailure? actionFailure;

  bool get isMutating => pendingBookmarkId != null;
  bool get isBusy => isLoadingMore || isMutating;
}

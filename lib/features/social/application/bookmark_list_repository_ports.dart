import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

abstract interface class BookmarkListRepository {
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  });

  Future<List<BookmarkFolderItem>> fetchFolders();

  Future<BookmarkFolderItem> createFolder(String name);

  Future<void> move(String bookmarkId, String folderId);

  Future<void> remove(String bookmarkId);
}

final bookmarkListRepositoryProvider = Provider<BookmarkListRepository>((ref) {
  return const _UnboundBookmarkListRepository();
});

class _UnboundBookmarkListRepository implements BookmarkListRepository {
  const _UnboundBookmarkListRepository();

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() => Future.error(_error());

  @override
  Future<BookmarkFolderItem> createFolder(String name) {
    return Future.error(_error());
  }

  @override
  Future<void> move(String bookmarkId, String folderId) {
    return Future.error(_error());
  }

  @override
  Future<void> remove(String bookmarkId) => Future.error(_error());
}

StateError _error() => StateError('收藏列表仓储尚未在应用组合根绑定。');

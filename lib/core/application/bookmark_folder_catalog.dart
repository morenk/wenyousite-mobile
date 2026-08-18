import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';

abstract interface class BookmarkFolderCatalog {
  Future<List<BookmarkFolderItem>> fetchFolders();
}

final bookmarkFolderCatalogProvider = Provider<BookmarkFolderCatalog>((ref) {
  return const _UnboundBookmarkFolderCatalog();
});

class _UnboundBookmarkFolderCatalog implements BookmarkFolderCatalog {
  const _UnboundBookmarkFolderCatalog();

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() {
    return Future.error(StateError('收藏夹目录尚未在应用组合根绑定。'));
  }
}

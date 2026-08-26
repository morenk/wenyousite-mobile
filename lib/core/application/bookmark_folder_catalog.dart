import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';

enum BookmarkFolderContentKind { thread, moment }

abstract interface class BookmarkFolderCatalog {
  Future<List<BookmarkFolderItem>> fetchFolders();

  Future<BookmarkFolderItem> createFolder(String name);
}

final bookmarkFolderCatalogProvider =
    Provider.family<BookmarkFolderCatalog, BookmarkFolderContentKind>((
      ref,
      kind,
    ) {
      return _UnboundBookmarkFolderCatalog(kind);
    });

class _UnboundBookmarkFolderCatalog implements BookmarkFolderCatalog {
  const _UnboundBookmarkFolderCatalog(this.kind);

  final BookmarkFolderContentKind kind;

  @override
  Future<BookmarkFolderItem> createFolder(String name) {
    return Future.error(_error());
  }

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() {
    return Future.error(_error());
  }

  StateError _error() => StateError('${kind.name} 收藏夹目录尚未在应用组合根绑定。');
}

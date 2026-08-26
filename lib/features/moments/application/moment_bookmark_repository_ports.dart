import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';

abstract interface class MomentBookmarkRepository
    implements BookmarkFolderCatalog {
  Future<CursorPage<MomentCard>> fetchPage({
    required String folderId,
    String? cursor,
    int limit = 20,
  });

  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  });

  Future<void> moveBookmark(String momentId, String folderId);
}

final momentBookmarkRepositoryProvider = Provider<MomentBookmarkRepository>((
  ref,
) {
  return const _UnboundMomentBookmarkRepository();
});

class _UnboundMomentBookmarkRepository implements MomentBookmarkRepository {
  const _UnboundMomentBookmarkRepository();

  @override
  Future<BookmarkFolderItem> createFolder(String name) =>
      Future.error(_error());

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() => Future.error(_error());

  @override
  Future<CursorPage<MomentCard>> fetchPage({
    required String folderId,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<void> moveBookmark(String momentId, String folderId) =>
      Future.error(_error());

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) => Future.error(_error());

  StateError _error() => StateError('动态收藏仓储尚未在应用组合根绑定。');
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

void main() {
  test('从收藏夹内容路由进入时首屏直接请求目标收藏夹', () async {
    final repository = _FakeRepository(
      fetchHandler: ({cursor, folderId}) async => CursorPage(
        items: [_item('bookmark-1', folderId: folderId)],
        hasMore: false,
      ),
    );
    final controller = BookmarkListController(
      repository,
      initialFolderId: 'folder-custom',
    );
    addTearDown(controller.dispose);
    await _settle();

    expect(repository.requests.single.folderId, 'folder-custom');
    expect(controller.state.selectedFolderId, 'folder-custom');
  });

  test('首次读取和加载更多原样回传服务端游标与当前分类', () async {
    final repository = _FakeRepository(
      fetchHandler: ({cursor, folderId}) async => switch (cursor) {
        null => CursorPage(
          items: [
            _item('bookmark-1', folderId: 'folder-default'),
            _item('bookmark-2', folderId: 'folder-default'),
          ],
          cursor: 'opaque-next',
          hasMore: true,
        ),
        'opaque-next' => CursorPage(
          items: [_item('bookmark-3', folderId: 'folder-default')],
          hasMore: false,
        ),
        _ => throw StateError('unexpected cursor'),
      },
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    await controller.loadMore();

    expect(controller.state.items.map((item) => item.bookmarkId), [
      'bookmark-1',
      'bookmark-2',
      'bookmark-3',
    ]);
    expect(repository.requests, [
      (cursor: null, folderId: null),
      (cursor: 'opaque-next', folderId: null),
    ]);
    expect(controller.state.hasMore, isFalse);
  });

  test('取消后从当前分类首屏权威刷新，不把收藏 ID 伪造成游标', () async {
    var firstPageReads = 0;
    final repository = _FakeRepository(
      fetchHandler: ({cursor, folderId}) async {
        expect(cursor, isNull);
        firstPageReads += 1;
        return firstPageReads == 1
            ? CursorPage(
                items: [
                  _item('bookmark-1', folderId: 'folder-default'),
                  _item('bookmark-2', folderId: 'folder-default'),
                ],
                cursor: 'opaque-before-remove',
                hasMore: true,
              )
            : CursorPage(
                items: [_item('bookmark-1', folderId: 'folder-default')],
                cursor: 'opaque-after-remove',
                hasMore: true,
              );
      },
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.removeBookmark('bookmark-2'), isTrue);

    expect(repository.removedIds, ['bookmark-2']);
    expect(repository.requests, [
      (cursor: null, folderId: null),
      (cursor: null, folderId: null),
    ]);
    expect(controller.state.cursor, 'opaque-after-remove');
    expect(
      controller.state.items.map((item) => item.bookmarkId),
      contains('bookmark-1'),
    );
  });

  test('收藏夹读取失败不遮断全部收藏列表', () async {
    final repository = _FakeRepository(
      folderFailure: const ApiFailure(
        userMessage: '分类失败',
        requestId: 'folders-request',
      ),
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(controller.state.phase, BookmarkListPhase.ready);
    expect(controller.state.items, isNotEmpty);
    expect(controller.state.folders, isEmpty);
    expect(controller.state.folderFailure?.requestId, 'folders-request');
  });

  test('收藏夹读取较慢时全部收藏首屏仍可先展示', () async {
    final folders = Completer<List<BookmarkFolderItem>>();
    final repository = _FakeRepository(folderCompleter: folders);
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    expect(controller.state.phase, BookmarkListPhase.ready);
    expect(controller.state.items, isNotEmpty);
    expect(controller.state.isLoadingFolders, isTrue);

    folders.complete([
      _folder('folder-default', '默认收藏夹', isDefault: true, count: 1),
    ]);
    await _settle();

    expect(controller.state.isLoadingFolders, isFalse);
    expect(controller.state.folders.single.id, 'folder-default');
  });

  test('切换收藏夹清空旧游标并按 folderId 读取首屏', () async {
    final repository = _FakeRepository();
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    await controller.selectFolder('folder-custom');

    expect(controller.state.selectedFolderId, 'folder-custom');
    expect(repository.requests.last, (cursor: null, folderId: 'folder-custom'));
    expect(
      controller.state.items.every((item) => item.folderId == 'folder-custom'),
      isTrue,
    );
  });

  test('新建成功自动选中新分类并采用服务端分类顺序与空态', () async {
    final repository = _FakeRepository();
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    final folder = await controller.createFolder('  跑团资料  ');

    expect(folder?.name, '跑团资料');
    expect(repository.createdNames, ['跑团资料']);
    expect(controller.state.selectedFolderId, folder?.id);
    expect(controller.state.items, isEmpty);
    expect(controller.state.folders.first.isDefault, isTrue);
    expect(controller.state.folders.last.name, '跑团资料');
  });

  test('当前分类内移动成功后以首屏刷新移除条目并更新计数', () async {
    final repository = _FakeRepository();
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();
    await controller.selectFolder('folder-default');
    expect(controller.state.items, isNotEmpty);

    expect(
      await controller.moveBookmark('bookmark-1', 'folder-custom'),
      isTrue,
    );

    expect(repository.moves, [
      (bookmarkId: 'bookmark-1', folderId: 'folder-custom'),
    ]);
    expect(controller.state.items, isEmpty);
    expect(controller.state.folderById('folder-default')?.bookmarkCount, 0);
    expect(controller.state.folderById('folder-custom')?.bookmarkCount, 2);
  });

  test('移动后的列表刷新不等待较慢的分类计数请求', () async {
    final repository = _FakeRepository();
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();
    await controller.selectFolder('folder-default');
    final folders = Completer<List<BookmarkFolderItem>>();
    repository.folderCompleter = folders;

    final pending = controller.moveBookmark('bookmark-1', 'folder-custom');
    await _settle();

    expect(controller.state.items, isEmpty);
    expect(controller.state.pendingBookmarkId, isNull);
    expect(controller.state.isRefreshingList, isFalse);
    expect(controller.state.isLoadingFolders, isTrue);

    folders.complete(List.unmodifiable(repository._folders));
    expect(await pending, isTrue);
    expect(controller.state.isLoadingFolders, isFalse);
  });

  test('加载更多遇到失效游标时从当前分类首屏重载', () async {
    var invalidated = false;
    final repository = _FakeRepository(
      fetchHandler: ({cursor, folderId}) async {
        if (cursor == 'opaque-next' && !invalidated) {
          invalidated = true;
          throw const ApiFailure(userMessage: '游标失效', businessCode: 40007);
        }
        return CursorPage(
          items: [_item('bookmark-1', folderId: 'folder-default')],
          cursor: 'opaque-next',
          hasMore: true,
        );
      },
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    await controller.loadMore();

    expect(repository.requests, [
      (cursor: null, folderId: null),
      (cursor: 'opaque-next', folderId: null),
      (cursor: null, folderId: null),
    ]);
    expect(controller.state.isLoadingMore, isFalse);
    expect(controller.state.failure, isNull);
  });

  test('取消失败保留条目和不透明游标并显示请求 ID', () async {
    final repository = _FakeRepository(
      removeFailure: const ApiFailure(
        userMessage: '取消失败',
        requestId: 'bookmark-request-id',
      ),
    );
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();
    final oldCursor = controller.state.cursor;

    expect(await controller.removeBookmark('bookmark-1'), isFalse);

    expect(
      controller.state.items.map((item) => item.bookmarkId),
      contains('bookmark-1'),
    );
    expect(controller.state.cursor, oldCursor);
    expect(controller.state.actionFailure?.requestId, 'bookmark-request-id');
  });

  test('加载更多期间不并发移动或取消收藏', () async {
    final loadMore = Completer<CursorPage<BookmarkListItem>>();
    final repository = _FakeRepository(loadMoreCompleter: loadMore);
    final controller = BookmarkListController(repository);
    addTearDown(controller.dispose);
    await _settle();

    final pending = controller.loadMore();
    expect(
      await controller.moveBookmark('bookmark-1', 'folder-custom'),
      isFalse,
    );
    expect(await controller.removeBookmark('bookmark-1'), isFalse);
    loadMore.complete(CursorPage(items: const [], hasMore: false));
    await pending;

    expect(repository.moves, isEmpty);
    expect(repository.removedIds, isEmpty);
  });
}

typedef _FetchHandler =
    Future<CursorPage<BookmarkListItem>> Function({
      String? cursor,
      String? folderId,
    });

class _FakeRepository implements BookmarkListRepository {
  _FakeRepository({
    this.fetchHandler,
    this.folderFailure,
    this.removeFailure,
    this.loadMoreCompleter,
    this.folderCompleter,
  });

  final _FetchHandler? fetchHandler;
  final ApiFailure? folderFailure;
  final ApiFailure? removeFailure;
  final Completer<CursorPage<BookmarkListItem>>? loadMoreCompleter;
  Completer<List<BookmarkFolderItem>>? folderCompleter;
  final List<({String? cursor, String? folderId})> requests = [];
  final List<String> removedIds = [];
  final List<String> createdNames = [];
  final List<({String bookmarkId, String folderId})> moves = [];
  final List<BookmarkFolderItem> _folders = [
    _folder('folder-default', '默认收藏夹', isDefault: true, count: 1),
    _folder('folder-custom', '灵感', count: 1),
  ];
  final List<BookmarkListItem> _items = [
    _item('bookmark-1', folderId: 'folder-default'),
    _item('bookmark-2', folderId: 'folder-custom'),
  ];

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) async {
    requests.add((cursor: cursor, folderId: folderId));
    if (cursor != null && loadMoreCompleter != null) {
      return loadMoreCompleter!.future;
    }
    if (fetchHandler != null) {
      return fetchHandler!(cursor: cursor, folderId: folderId);
    }
    final items = folderId == null
        ? _items
        : _items.where((item) => item.folderId == folderId).toList();
    return CursorPage(
      items: List.unmodifiable(items),
      cursor: items.isEmpty ? null : 'opaque-next',
      hasMore: cursor == null && items.isNotEmpty,
    );
  }

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async {
    if (folderFailure != null) throw folderFailure!;
    if (folderCompleter != null) return folderCompleter!.future;
    return List.unmodifiable(_folders);
  }

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    createdNames.add(name);
    final folder = _folder('folder-created', name);
    _folders.add(folder);
    return folder;
  }

  @override
  Future<void> move(String bookmarkId, String folderId) async {
    moves.add((bookmarkId: bookmarkId, folderId: folderId));
    final index = _items.indexWhere((item) => item.bookmarkId == bookmarkId);
    if (index < 0) throw StateError('missing bookmark');
    final oldFolderId = _items[index].folderId;
    _items[index] = _items[index].copyWithFolderId(folderId);
    for (var index = 0; index < _folders.length; index++) {
      final folder = _folders[index];
      final delta = folder.id == oldFolderId
          ? -1
          : folder.id == folderId
          ? 1
          : 0;
      if (delta != 0) {
        _folders[index] = _folder(
          folder.id,
          folder.name,
          isDefault: folder.isDefault,
          count: folder.bookmarkCount + delta,
        );
      }
    }
  }

  @override
  Future<void> remove(String bookmarkId) async {
    if (removeFailure != null) throw removeFailure!;
    removedIds.add(bookmarkId);
    _items.removeWhere((item) => item.bookmarkId == bookmarkId);
  }
}

BookmarkFolderItem _folder(
  String id,
  String name, {
  bool isDefault = false,
  int count = 0,
}) {
  return BookmarkFolderItem(
    id: id,
    name: name,
    isDefault: isDefault,
    bookmarkCount: count,
    createdAt: DateTime.utc(2026, 8, 1),
  );
}

BookmarkListItem _item(String bookmarkId, {String? folderId}) {
  return BookmarkListItem(
    bookmarkId: bookmarkId,
    folderId: folderId,
    threadId: 'thread-$bookmarkId',
    title: '收藏 $bookmarkId',
    status: BookmarkedThreadStatus.recruiting,
    isPrivate: false,
    isPinned: false,
    ownerName: '骰子猫',
    ownerLevel: 3,
    createdAt: DateTime.utc(2026, 8, 1),
    memberCount: 4,
    postCount: 18,
    tipTotal: '9',
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

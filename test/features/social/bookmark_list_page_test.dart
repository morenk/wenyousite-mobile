import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/application/thread_category_catalog.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/bookmark_folder_catalog_page.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';

import '../../support/fake_thread_category_catalog.dart';

void main() {
  testWidgets('本人收藏展示摘要、进入主题并可原地取消', (tester) async {
    final repository = _FakeRepository(items: [_item('bookmark-1')]);
    final router = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    expect(find.text('稍后继续阅读或参与的内容。'), findsNothing);
    expect(find.text('雾港来信'), findsOneWidget);
    expect(find.textContaining('演绎'), findsOneWidget);
    expect(find.textContaining('DEDUCTION'), findsNothing);
    expect(find.text('骰子猫'), findsOneWidget);
    expect(find.text('Lv.3'), findsOneWidget);
    expect(find.byKey(const Key('home-thread-card-thread-1')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('打开主题：雾港来信，作者 骰子猫'));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1'), findsOneWidget);

    router.go('/bookmarks/threads/folders/folder-default');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-remove-bookmark-1')));
    await tester.pumpAndSettle();
    expect(find.text('雾港来信'), findsNothing);
    expect(find.text('已取消收藏。'), findsOneWidget);
    expect(repository.removedIds, ['bookmark-1']);
  });

  testWidgets('收藏页直接展示默认夹并可原地切换收藏夹', (tester) async {
    final repository = _FakeRepository(
      items: [
        _item('bookmark-1', folderId: 'folder-default'),
        _item('bookmark-2', folderId: 'folder-custom'),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byKey(const Key('bookmark-kind-tabs')), findsOneWidget);
    expect(find.byKey(const Key('bookmark-folder-menu')), findsOneWidget);
    expect(find.text('雾港来信'), findsOneWidget);
    expect(find.text('收藏 bookmark-2'), findsNothing);

    await tester.tap(find.byKey(const Key('bookmark-folder-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-folder-folder-custom')));
    await tester.pumpAndSettle();

    expect(repository.requestedFolders.last, 'folder-custom');
    expect(find.text('收藏 bookmark-2'), findsOneWidget);
    expect(find.text('雾港来信'), findsNothing);
    expect(find.text('灵感'), findsWidgets);
  });

  testWidgets('统一收藏页取消收藏后同步刷新外层计数', (tester) async {
    final repository = _FakeRepository(items: [_item('bookmark-1')]);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-remove-bookmark-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-folder-menu')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('bookmark-folder-folder-default')),
        matching: find.text('0 条收藏'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('统一收藏页刷新目录失败保留列表并显示局部错误', (tester) async {
    final repository = _FakeRepository(items: [_item('bookmark-1')]);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    repository.failFolders = true;
    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('bookmark-folder-refresh-failure')),
      findsOneWidget,
    );
    expect(find.text('问题编号：bookmark-folders-request'), findsWidgets);
    expect(find.text('雾港来信'), findsOneWidget);
  });

  testWidgets('收藏夹很多时选择器可滚动到最后一项', (tester) async {
    final folders = [
      for (var index = 0; index < 30; index++)
        _folder('folder-$index', '收藏夹 $index'),
    ];
    final repository = _FakeRepository(folders: folders);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-folder-menu')));
    await tester.pumpAndSettle();

    final last = find.byKey(const Key('bookmark-folder-folder-29'));
    await tester.ensureVisible(last);
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(repository.requestedFolders.last, 'folder-29');
  });

  testWidgets('新建收藏夹校验空名称并在成功后进入新收藏夹', (tester) async {
    final repository = _FakeRepository(items: [_item('bookmark-1')]);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-folder-create-thread')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-folder-submit')));
    await tester.pump();
    expect(find.text('请输入收藏夹名称。'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('bookmark-folder-name')),
      '  跑团资料  ',
    );
    await tester.tap(find.byKey(const Key('bookmark-folder-submit')));
    await tester.pumpAndSettle();

    expect(repository.createdNames, ['跑团资料']);
    expect(find.text('这个收藏夹还是空的'), findsOneWidget);
    expect(find.text('已新建“跑团资料”。'), findsOneWidget);
    expect(repository.requestedFolders.last, 'folder-created');
  });

  testWidgets('卡片移动使用底部收藏夹选择并刷新当前分类', (tester) async {
    final repository = _FakeRepository(
      items: [_item('bookmark-1', folderId: 'folder-default')],
    );
    final router = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-move-bookmark-1')));
    await tester.pumpAndSettle();
    expect(find.text('移动到收藏夹'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('bookmark-folder-picker-option-folder-custom')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();

    expect(repository.moves, [
      (bookmarkId: 'bookmark-1', folderId: 'folder-custom'),
    ]);
    expect(find.text('已移动到“灵感”。'), findsOneWidget);
  });

  testWidgets('目录、打开主题、移动和取消保持独立语义节点', (tester) async {
    final semantics = tester.ensureSemantics();
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(
        _FakeRepository(
          items: [_item('bookmark-1', folderId: 'folder-default')],
        ),
        router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('切换收藏夹'), findsOneWidget);
    expect(find.bySemanticsLabel('打开主题：雾港来信，作者 骰子猫'), findsOneWidget);
    expect(find.bySemanticsLabel('移动“雾港来信”到收藏夹'), findsOneWidget);
    expect(find.bySemanticsLabel('取消收藏“雾港来信”'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('收藏列表支持空态、加载失败重试与请求 ID', (tester) async {
    final emptyRouter = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(emptyRouter.dispose);
    await tester.pumpWidget(_app(_FakeRepository(), emptyRouter));
    await tester.pumpAndSettle();
    expect(find.text('这个收藏夹还是空的'), findsOneWidget);

    final failureRouter = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(failureRouter.dispose);
    await tester.pumpWidget(
      _app(_FakeRepository(failLoad: true), failureRouter),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookmark-list-retry')), findsOneWidget);
    expect(find.text('问题编号：bookmark-load-request'), findsOneWidget);
  });

  testWidgets('动态收藏在同一页面切换并直接选择默认夹', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_FakeRepository(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-kind-moment')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('moment-bookmarks-folder-default')),
      findsOneWidget,
    );
  });

  testWidgets('收藏夹分类失败不遮断收藏列表并提供独立重试', (tester) async {
    final router = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(
        _FakeRepository(items: [_item('bookmark-1')], failFolders: true),
        router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bookmark-folders-retry')), findsOneWidget);
    expect(find.text('问题编号：bookmark-folders-request'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('雾港来信'), findsOneWidget);
  });

  testWidgets('分页与取消失败保留列表并显示局部请求 ID', (tester) async {
    final repository = _FakeRepository(
      items: [_item('bookmark-1')],
      hasMore: true,
      failLoadMore: true,
      failRemove: true,
    );
    final router = _router(
      initialLocation: '/bookmarks/threads/folders/folder-default',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-list-load-more')));
    await tester.pumpAndSettle();
    expect(find.text('问题编号：bookmark-more-request'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bookmark-remove-bookmark-1')));
    await tester.pumpAndSettle();
    expect(find.text('雾港来信'), findsOneWidget);
    expect(find.text('问题编号：bookmark-remove-request'), findsOneWidget);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 收藏列表无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 620);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _app(_FakeRepository(items: [_item('bookmark-1')]), router),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      router.go('/bookmarks/threads/folders/folder-default');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

GoRouter _router({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => BookmarkFolderCatalogPage(
          contentBuilder: (context, kind, folder, refreshCatalog) =>
              switch (kind) {
                BookmarkFolderContentKind.thread => BookmarkListView(
                  key: ValueKey('thread-bookmarks-${folder.id}'),
                  folderId: folder.id,
                  additionalRefresh: refreshCatalog,
                  onCatalogChanged: refreshCatalog,
                ),
                BookmarkFolderContentKind.moment => SizedBox.expand(
                  key: ValueKey('moment-bookmarks-${folder.id}'),
                ),
              },
        ),
      ),
      GoRoute(
        path: '/bookmarks/threads',
        name: 'me-bookmark-threads',
        redirect: (_, _) => '/',
      ),
      GoRoute(
        path: '/bookmarks/threads/folders/:folderId',
        name: 'me-thread-bookmark-folder',
        builder: (_, state) => BookmarkListPage(
          folderId: state.pathParameters['folderId']!,
          initialFolderName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: '/bookmarks/moments',
        name: 'me-bookmark-moments',
        builder: (_, _) => const Scaffold(
          key: Key('moment-bookmarks-page'),
          body: Text('收藏动态内容'),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId',
        name: 'thread-detail',
        builder: (_, state) =>
            Scaffold(body: Text('主题=${state.pathParameters['threadId']}')),
      ),
    ],
  );
}

Widget _app(BookmarkListRepository repository, GoRouter router) {
  return ProviderScope(
    overrides: [
      bookmarkListRepositoryProvider.overrideWithValue(repository),
      bookmarkFolderCatalogProvider.overrideWith((ref, kind) => repository),
      threadCategoryCatalogRepositoryProvider.overrideWithValue(
        FakeThreadCategoryCatalogRepository(),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

class _FakeRepository implements BookmarkListRepository {
  _FakeRepository({
    List<BookmarkListItem> items = const [],
    List<BookmarkFolderItem>? folders,
    this.hasMore = false,
    this.failLoad = false,
    this.failLoadMore = false,
    this.failRemove = false,
    this.failFolders = false,
  }) : _items = List.of(items) {
    _folders = List.of(
      folders ??
          [
            _folder(
              'folder-default',
              '默认收藏夹',
              isDefault: true,
              count: _items
                  .where((item) => item.folderId == 'folder-default')
                  .length,
            ),
            _folder(
              'folder-custom',
              '灵感',
              count: _items
                  .where((item) => item.folderId == 'folder-custom')
                  .length,
            ),
          ],
    );
  }

  final List<BookmarkListItem> _items;
  final bool hasMore;
  final bool failLoad;
  final bool failLoadMore;
  final bool failRemove;
  bool failFolders;
  final List<String> removedIds = [];
  final List<String?> requestedFolders = [];
  final List<String> createdNames = [];
  final List<({String bookmarkId, String folderId})> moves = [];
  late final List<BookmarkFolderItem> _folders;

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) async {
    requestedFolders.add(folderId);
    if (cursor == null && failLoad) {
      throw const ApiFailure(
        userMessage: '收藏加载失败',
        requestId: 'bookmark-load-request',
      );
    }
    if (cursor != null && failLoadMore) {
      throw const ApiFailure(
        userMessage: '更多收藏加载失败',
        requestId: 'bookmark-more-request',
      );
    }
    final filtered = folderId == null
        ? _items
        : _items.where((item) => item.folderId == folderId).toList();
    return CursorPage(
      items: cursor == null ? List.unmodifiable(filtered) : const [],
      cursor: hasMore && filtered.isNotEmpty ? 'opaque-next' : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async {
    if (failFolders) {
      throw const ApiFailure(
        userMessage: '收藏夹分类加载失败',
        requestId: 'bookmark-folders-request',
      );
    }
    return _folders
        .map(
          (folder) => _folder(
            folder.id,
            folder.name,
            isDefault: folder.isDefault,
            count: _items.where((item) => item.folderId == folder.id).length,
          ),
        )
        .toList(growable: false);
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
    _items[index] = _items[index].copyWithFolderId(folderId);
  }

  @override
  Future<void> remove(String bookmarkId) async {
    if (failRemove) {
      throw const ApiFailure(
        userMessage: '取消收藏失败',
        requestId: 'bookmark-remove-request',
      );
    }
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

BookmarkListItem _item(
  String bookmarkId, {
  String? folderId = 'folder-default',
}) {
  return BookmarkListItem(
    bookmarkId: bookmarkId,
    folderId: folderId,
    threadId: bookmarkId == 'bookmark-1' ? 'thread-1' : 'thread-2',
    title: bookmarkId == 'bookmark-1' ? '雾港来信' : '收藏 $bookmarkId',
    categorySlug: 'DEDUCTION',
    status: BookmarkedThreadStatus.recruiting,
    isPrivate: false,
    isPinned: true,
    ownerName: '骰子猫',
    ownerLevel: 3,
    createdAt: DateTime.utc(2026, 8, 1),
    memberCount: 4,
    postCount: 18,
    tipTotal: '9',
  );
}

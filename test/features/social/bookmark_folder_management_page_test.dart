import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/bookmark_folder_catalog_page.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_repository_ports.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';
import 'package:wenyousite_mobile/features/thread_feed/thread_feed_catalog.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/fake_thread_category_catalog.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final width in [360.0, 400.0]) {
    for (final kind in [
      BookmarkFolderContentKind.thread,
      BookmarkFolderContentKind.moment,
    ]) {
      testWidgets('收藏夹顶栏在 ${width.toInt()}dp ${kind.name} 下保持紧凑', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 760);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        const longName = '收藏夹名称很长但仍应省略显示不挤压顶栏';
        final repository = _FolderManagementRepository(customName: longName);
        final router = _router(repository, initialKind: kind);
        addTearDown(router.dispose);
        await tester.pumpWidget(_app(repository, router));
        await tester.pumpAndSettle();

        expect(find.byTooltip('管理收藏夹'), findsNothing);
        await _selectCustomFolder(tester);
        final manage = find.byKey(Key('bookmark-folder-manage-${kind.name}'));
        final create = find.byKey(Key('bookmark-folder-create-${kind.name}'));
        expect(manage, findsOneWidget);
        expect(tester.getSize(manage), const Size(48, 48));
        expect(tester.getSize(create), const Size(48, 48));
        expect(
          tester.getRect(manage).right,
          lessThanOrEqualTo(tester.getRect(create).left),
        );
        expect(
          tester.widget<Text>(find.text(longName)).overflow,
          TextOverflow.ellipsis,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final kind in [
    BookmarkFolderContentKind.thread,
    BookmarkFolderContentKind.moment,
  ]) {
    testWidgets('${kind.name} 收藏夹可重命名并保留输入处理错误', (tester) async {
      final repository = _FolderManagementRepository();
      final router = _router(repository, initialKind: kind);
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(repository, router));
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key('bookmark-folder-manage-${kind.name}')),
        findsNothing,
      );
      await _selectCustomFolder(tester);
      final manage = find.byKey(Key('bookmark-folder-manage-${kind.name}'));
      expect(tester.getSize(manage), const Size(48, 48));
      expect(find.byTooltip('管理收藏夹'), findsOneWidget);
      await tester.tap(manage);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bookmark-folder-rename')));
      await tester.pumpAndSettle();

      final nameField = find.byKey(const Key('bookmark-folder-rename-name'));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '灵感');
      expect(field.controller!.selection.baseOffset, 0);
      expect(field.controller!.selection.extentOffset, '灵感'.length);
      await tester.enterText(nameField, '');
      await tester.tap(find.byKey(const Key('bookmark-folder-rename-submit')));
      await tester.pump();
      expect(find.text('请输入收藏夹名称。'), findsOneWidget);
      await tester.enterText(nameField, '1234567890123456789012345');
      await tester.tap(find.byKey(const Key('bookmark-folder-rename-submit')));
      await tester.pump();
      expect(find.text('名称不能超过 24 个字符。'), findsOneWidget);

      final emojiName = List.filled(24, '😀').join();
      repository.failRename = true;
      await tester.enterText(nameField, '  $emojiName  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('重命名暂时失败，请重试。'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '  $emojiName  ',
      );
      expect(repository.renamedFolders, [('folder-custom', emojiName)]);
      expect(manage, findsOneWidget);

      repository.failRename = false;
      await tester.tap(find.byKey(const Key('bookmark-folder-rename-submit')));
      await tester.pumpAndSettle();
      expect(repository.renamedFolders, [
        ('folder-custom', emojiName),
        ('folder-custom', emojiName),
      ]);
      expect(find.text(emojiName), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('${kind.name} 删除收藏夹迁移到响应指定的默认夹', (tester) async {
      const destinationId = 'folder-server-default';
      final routePrefix = kind == BookmarkFolderContentKind.thread
          ? 'thread-bookmarks'
          : 'moment-bookmarks';
      final repository = _FolderManagementRepository(
        destinationId: destinationId,
        items: [_bookmark('bookmark-custom', folderId: 'folder-custom')],
      );
      final router = _router(repository, initialKind: kind);
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(repository, router));
      await tester.pumpAndSettle();
      await _selectCustomFolder(tester);
      await tester.tap(find.byKey(Key('bookmark-folder-manage-${kind.name}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bookmark-folder-delete')));
      await tester.pumpAndSettle();
      expect(find.text('收藏夹内的收藏会移到默认收藏夹，收藏内容不会删除。'), findsOneWidget);
      final confirm = tester.widget<FilledButton>(
        find.byKey(const Key('bookmark-folder-delete-confirm')),
      );
      expect(confirm.style?.backgroundColor, isNotNull);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(repository.deletedFolders, isEmpty);

      repository.failDelete = true;
      await tester.tap(find.byKey(Key('bookmark-folder-manage-${kind.name}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bookmark-folder-delete')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bookmark-folder-delete-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('删除暂时失败，请重试。'), findsOneWidget);
      expect(
        find.byKey(ValueKey('$routePrefix-folder-custom')),
        findsOneWidget,
      );
      if (kind == BookmarkFolderContentKind.thread) {
        expect(find.text('收藏 bookmark-custom'), findsOneWidget);
      }
      expect(repository.deletedFolders, isEmpty);

      repository.failDelete = false;
      await tester.tap(find.byKey(const Key('bookmark-folder-delete-confirm')));
      await tester.pumpAndSettle();
      expect(repository.deletedFolders, ['folder-custom']);
      expect(
        find.byKey(ValueKey('$routePrefix-$destinationId')),
        findsOneWidget,
      );
      if (kind == BookmarkFolderContentKind.thread) {
        expect(repository.requestedFolders, contains(destinationId));
        expect(find.text('收藏 bookmark-custom'), findsOneWidget);
      }
      expect(find.text('收藏已移到默认收藏夹。'), findsOneWidget);
    });
  }
}

Future<void> _selectCustomFolder(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('bookmark-folder-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('bookmark-folder-folder-custom')));
  await tester.pumpAndSettle();
}

GoRouter _router(
  BookmarkListRepository repository, {
  required BookmarkFolderContentKind initialKind,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => BookmarkFolderCatalogPage(
          initialKind: initialKind,
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
                  child: const Text('收藏动态内容'),
                ),
              },
        ),
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

class _FolderManagementRepository implements BookmarkListRepository {
  _FolderManagementRepository({
    this.destinationId = 'folder-default',
    this.customName = '灵感',
    List<BookmarkListItem> items = const [],
  }) : _items = List.of(items) {
    _folders = [
      _folder(destinationId, '默认收藏夹', isDefault: true),
      _folder('folder-custom', customName),
    ];
  }

  final String destinationId;
  final String customName;
  final List<BookmarkListItem> _items;
  late final List<BookmarkFolderItem> _folders;
  final List<String?> requestedFolders = [];
  final List<(String, String)> renamedFolders = [];
  final List<String> deletedFolders = [];
  var failRename = false;
  var failDelete = false;

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    String? folderId,
    int limit = 20,
  }) async {
    requestedFolders.add(folderId);
    final items = _items.where((item) => item.folderId == folderId).toList();
    return CursorPage(items: items, cursor: null, hasMore: false);
  }

  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async => [
    for (final folder in _folders)
      folder.copyWith(
        bookmarkCount: _items
            .where((item) => item.folderId == folder.id)
            .length,
      ),
  ];

  @override
  Future<BookmarkFolderItem> createFolder(String name) async {
    final folder = _folder('folder-created', name);
    _folders.add(folder);
    return folder;
  }

  @override
  Future<BookmarkFolderItem> renameFolder(String folderId, String name) async {
    renamedFolders.add((folderId, name));
    if (failRename) {
      throw const ApiFailure(userMessage: '重命名暂时失败，请重试。');
    }
    final index = _folders.indexWhere((folder) => folder.id == folderId);
    final renamed = _folders[index].copyWith(name: name);
    _folders[index] = renamed;
    return renamed;
  }

  @override
  Future<BookmarkFolderDeleteResult> deleteFolder(String folderId) async {
    if (failDelete) {
      throw const ApiFailure(userMessage: '删除暂时失败，请重试。');
    }
    final index = _folders.indexWhere((folder) => folder.id == folderId);
    _folders.removeAt(index);
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].folderId == folderId) {
        _items[i] = _items[i].copyWithFolderId(destinationId);
      }
    }
    deletedFolders.add(folderId);
    return BookmarkFolderDeleteResult(
      deletedFolderId: folderId,
      destinationFolderId: destinationId,
    );
  }

  @override
  Future<void> move(String bookmarkId, String folderId) async {}

  @override
  Future<void> remove(String bookmarkId) async {
    _items.removeWhere((item) => item.bookmarkId == bookmarkId);
  }
}

BookmarkFolderItem _folder(String id, String name, {bool isDefault = false}) {
  return BookmarkFolderItem(
    id: id,
    name: name,
    isDefault: isDefault,
    bookmarkCount: 0,
    createdAt: DateTime.utc(2026, 9, 13),
  );
}

BookmarkListItem _bookmark(String bookmarkId, {required String folderId}) {
  return BookmarkListItem(
    bookmarkId: bookmarkId,
    folderId: folderId,
    threadId: 'thread-$bookmarkId',
    title: '收藏 $bookmarkId',
    status: BookmarkedThreadStatus.recruiting,
    isPrivate: false,
    isPinned: false,
    ownerName: '测试作者',
    ownerLevel: 1,
    createdAt: DateTime.utc(2026, 9, 13),
    memberCount: 1,
    postCount: 1,
    tipTotal: '0',
  );
}

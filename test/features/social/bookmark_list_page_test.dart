import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/bookmark_list_page.dart';

void main() {
  testWidgets('本人收藏展示摘要、进入主题并可原地取消', (tester) async {
    final repository = _FakeRepository(items: [_item('bookmark-1')]);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    expect(find.text('雾港来信'), findsOneWidget);
    expect(find.textContaining('骰子猫 · Lv.3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('bookmark-thread-thread-1')));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookmark-remove-bookmark-1')));
    await tester.pumpAndSettle();
    expect(find.text('雾港来信'), findsNothing);
    expect(find.text('已取消收藏。'), findsOneWidget);
    expect(repository.removedIds, ['bookmark-1']);
  });

  testWidgets('收藏列表支持空态、加载失败重试与请求 ID', (tester) async {
    final emptyRouter = _router();
    addTearDown(emptyRouter.dispose);
    await tester.pumpWidget(_app(_FakeRepository(), emptyRouter));
    await tester.pumpAndSettle();
    expect(find.text('还没有收藏'), findsOneWidget);

    final failureRouter = _router();
    addTearDown(failureRouter.dispose);
    await tester.pumpWidget(
      _app(_FakeRepository(failLoad: true), failureRouter),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bookmark-list-retry')), findsOneWidget);
    expect(find.text('请求 ID：bookmark-load-request'), findsOneWidget);
  });

  testWidgets('分页与取消失败保留列表并显示局部请求 ID', (tester) async {
    final repository = _FakeRepository(
      items: [_item('bookmark-1')],
      hasMore: true,
      failLoadMore: true,
      failRemove: true,
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bookmark-list-load-more')));
    await tester.pumpAndSettle();
    expect(find.text('请求 ID：bookmark-more-request'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bookmark-remove-bookmark-1')));
    await tester.pumpAndSettle();
    expect(find.text('雾港来信'), findsOneWidget);
    expect(find.text('请求 ID：bookmark-remove-request'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
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
    });
  }
}

GoRouter _router() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const BookmarkListPage()),
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
    overrides: [bookmarkListRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

class _FakeRepository implements BookmarkListRepository {
  _FakeRepository({
    this.items = const [],
    this.hasMore = false,
    this.failLoad = false,
    this.failLoadMore = false,
    this.failRemove = false,
  });

  final List<BookmarkListItem> items;
  final bool hasMore;
  final bool failLoad;
  final bool failLoadMore;
  final bool failRemove;
  final List<String> removedIds = [];

  @override
  Future<CursorPage<BookmarkListItem>> fetchPage({
    String? cursor,
    int limit = 20,
  }) async {
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
    return CursorPage(
      items: cursor == null ? items : const [],
      cursor: hasMore ? items.last.bookmarkId : null,
      hasMore: hasMore,
    );
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
  }
}

BookmarkListItem _item(String bookmarkId) {
  return BookmarkListItem(
    bookmarkId: bookmarkId,
    threadId: 'thread-1',
    title: '雾港来信',
    categorySlug: 'RPG',
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

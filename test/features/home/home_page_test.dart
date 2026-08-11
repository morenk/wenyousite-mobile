import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';

void main() {
  testWidgets('首页展示分类快捷项与紧凑主题卡片并可切换分类', (tester) async {
    final repository = _FakeHomeRepository();
    await tester.pumpWidget(_homeApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('发现主题'), findsNothing);
    expect(find.text('角色扮演'), findsNWidgets(2));
    expect(find.text('星海旅团'), findsOneWidget);
    expect(find.text('向星海出发'), findsOneWidget);
    expect(find.text('太空歌剧'), findsOneWidget);
    expect(find.text('8L 加油'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-category-RPG')));
    await tester.pumpAndSettle();
    expect(repository.lastQuery?.categorySlug, 'RPG');

    await tester.tap(find.byKey(const Key('home-status-menu')));
    await tester.pumpAndSettle();
    expect(find.text('主题状态'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(RadioListTile<HomeThreadStatusFilter>, '招募中'),
    );
    await tester.pumpAndSettle();
    expect(repository.lastQuery?.status, HomeThreadStatusFilter.recruiting);
  });

  testWidgets('首屏失败展示请求 ID 并可重试恢复', (tester) async {
    final repository = _FakeHomeRepository(failFirstRequest: true);
    await tester.pumpWidget(_homeApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('主题列表没有加载完成'), findsOneWidget);
    expect(find.text('请求 ID：home-request-id'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-retry')));
    await tester.pumpAndSettle();
    expect(find.text('星海旅团'), findsOneWidget);
  });

  testWidgets('首页不显示右上刷新按钮但仍可下拉刷新', (tester) async {
    final repository = _FakeHomeRepository();
    await tester.pumpWidget(_homeApp(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-refresh')), findsNothing);
    expect(find.byTooltip('刷新主题'), findsNothing);

    final callsBeforeRefresh = repository.threadCalls;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(repository.threadCalls, callsBeforeRefresh + 1);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 首页筛选与主题卡片无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_homeApp(_FakeHomeRepository()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('home-category-all'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('home-sort-menu'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}

Widget _homeApp(HomeRepository repository) {
  return ProviderScope(
    overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
  );
}

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.failFirstRequest = false});

  final bool failFirstRequest;
  int threadCalls = 0;
  HomeFeedQuery? lastQuery;

  @override
  Future<List<HomeCategory>> fetchCategories() async => const [
    HomeCategory(
      id: 'category-rpg',
      slug: 'RPG',
      name: '角色扮演',
      description: '角色扮演主题',
      sortOrder: 1,
    ),
  ];

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    threadCalls += 1;
    lastQuery = query;
    if (failFirstRequest && threadCalls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'home-request-id',
      );
    }
    return CursorPage(items: [_thread], hasMore: false);
  }
}

final _thread = HomeThreadCardModel(
  id: 'thread-1',
  title: '星海旅团',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: true,
  ownerId: 'user-1',
  ownerName: '温柔测试员',
  ownerLevel: 3,
  preview: '向星海出发',
  tags: const [HomeThreadTag(id: 'tag-1', name: '太空歌剧')],
  coverImageUrls: const [],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '8',
  lastActivityAt: DateTime.now().subtract(const Duration(minutes: 5)),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('首页展示分类快捷项与紧凑主题卡片并可切换分类', (tester) async {
    final repository = _FakeHomeRepository();
    await tester.pumpWidget(_homeApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('发现主题'), findsNothing);
    expect(find.text('角色扮演'), findsOneWidget);
    expect(find.text('星海旅团'), findsOneWidget);
    expect(find.text('向星海出发'), findsOneWidget);
    expect(find.text('#太空歌剧'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    final tag = find.byKey(const Key('home-thread-tag-thread-1-tag-1'));
    expect(
      find.descendant(of: tag, matching: find.byType(InputChip)),
      findsNothing,
    );
    expect(tester.getSize(tag).height, greaterThanOrEqualTo(48));
    expect(find.text('5 成员 · 2 玩家 · 12 回复 · 8L 加油'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('星海旅团')).dy,
      lessThan(tester.getTopLeft(find.text('温柔测试员')).dy),
    );
    expect(
      tester.getSize(find.byKey(const Key('home-thread-thread-1'))).height,
      lessThan(190),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('home-thread-thread-1')),
        matching: find.byType(Card),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('home-category-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, '角色扮演'));
    await tester.pumpAndSettle();
    expect(repository.lastQuery?.categorySlug, 'RPG');

    await tester.tap(find.byKey(const Key('home-status-menu')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(
      find.widgetWithText(PopupMenuItem<HomeThreadStatusFilter>, '招募中'),
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

  testWidgets('多主题以分隔线形成连续文章索引而不是逐张卡片', (tester) async {
    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_thread, _secondThread])),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('home-thread-divider-thread-2')),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('home-thread-thread-2')),
        matching: find.byType(Card),
      ),
      findsNothing,
    );
    expect(find.text('第二段接力'), findsOneWidget);
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
        tester.getSize(find.byKey(const Key('home-category-menu'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('home-sort-menu'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('home-status-menu'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('360dp 有封面主题使用右侧缩略图而不压过标题', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_threadWithCover])),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final cover = find.byKey(const Key('home-thread-cover-thumbnail'));
    expect(cover, findsOneWidget);
    expect(tester.getSize(cover), const Size(104, 88));
    expect(
      tester.getSize(find.byKey(const Key('home-thread-thread-cover'))).height,
      lessThan(190),
    );
    expect(find.text('带封面的长篇主题'), findsOneWidget);
    expect(find.text('正文摘要仍然先于图片建立阅读线索'), findsOneWidget);
  });

  testWidgets('360dp 首页保持标题与摘要优先的视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_homeApp(_FakeHomeRepository()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('home-text-first-visual')),
      matchesGoldenFile('goldens/home_text_first_360.png'),
    );
  });
}

Widget _homeApp(HomeRepository repository) {
  return ProviderScope(
    overrides: [homeRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const RepaintBoundary(
        key: Key('home-text-first-visual'),
        child: HomePage(),
      ),
    ),
  );
}

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.failFirstRequest = false, this.items});

  final bool failFirstRequest;
  final List<HomeThreadCardModel>? items;
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
    return CursorPage(items: items ?? [_thread], hasMore: false);
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

final _threadWithCover = HomeThreadCardModel(
  id: 'thread-cover',
  title: '带封面的长篇主题',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: false,
  ownerId: 'user-1',
  ownerName: '温柔测试员',
  ownerLevel: 3,
  preview: '正文摘要仍然先于图片建立阅读线索',
  tags: const [],
  coverImageUrls: const ['https://example.com/cover.jpg'],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '0',
  lastActivityAt: DateTime(2026, 8, 12),
);

final _secondThread = HomeThreadCardModel(
  id: 'thread-2',
  title: '第二段接力',
  categorySlug: 'RPG',
  status: HomeThreadStatus.finished,
  isPinned: false,
  ownerId: 'user-2',
  ownerName: '接力作者',
  ownerLevel: 2,
  preview: '新的一段故事从这里继续。',
  tags: const [],
  coverImageUrls: const [],
  memberCount: 3,
  playerCount: 2,
  postCount: 8,
  tipTotal: '0',
  lastActivityAt: DateTime(2026, 8, 12),
);

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';

import '../../support/foundation_icon_finder.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('首页展示独立主题卡片并可切换分类', (tester) async {
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
    expect(find.bySemanticsLabel(RegExp(r'2 玩家')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'12 回复')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'8 L 加油')), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.metricPlayers), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.metricReplies), findsOneWidget);
    expect(findFoundationIcon(WenyouIconIds.metricTips), findsOneWidget);
    expect(find.textContaining('成员'), findsNothing);
    expect(
      tester.getTopLeft(find.text('温柔测试员')).dy,
      lessThan(tester.getTopLeft(find.text('星海旅团')).dy),
    );
    expect(
      tester.getSize(find.byKey(const Key('home-thread-thread-1'))).height,
      lessThan(300),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('home-thread-card-thread-1')),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home-thread-cover-thread-1')), findsNothing);

    await tester.tap(find.byKey(const Key('home-category-RPG')));
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

    expect(find.text('主题列表加载失败'), findsOneWidget);
    expect(find.text('问题编号：home-request-id'), findsOneWidget);

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

  testWidgets('多主题使用独立卡片和卡片间留白', (tester) async {
    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_thread, _secondThread])),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-thread-divider-thread-2')), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const Key('home-thread-card-thread-2')),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
    final firstCard = find.byKey(const Key('home-thread-card-thread-1'));
    final secondCard = find.byKey(const Key('home-thread-card-thread-2'));
    expect(
      tester.getTopLeft(secondCard).dy - tester.getBottomLeft(firstCard).dy,
      greaterThanOrEqualTo(12),
    );
    expect(find.text('第二段接力'), findsOneWidget);
  });

  testWidgets('主题卡片展示作者头像且无头像时使用用户名首字符', (tester) async {
    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_threadWithAvatar, _secondThread])),
    );
    await tester.pump();

    final avatar = find.byKey(
      const Key('home-thread-author-avatar-thread-avatar'),
    );
    final fallback = find.byKey(
      const Key('home-thread-author-avatar-thread-2'),
    );
    expect(
      find.descendant(of: avatar, matching: find.byType(CachedNetworkImage)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: fallback, matching: find.text('接')),
      findsOneWidget,
    );
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 首页筛选与独立主题卡片无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _homeApp(
          _FakeHomeRepository(
            items: [_threadWithAvatar, _threadWithCover, _secondThread],
          ),
        ),
      );
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

  testWidgets('360dp 有封面主题使用正文整宽 16:9 单封面', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_threadWithCover])),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final cover = find.byKey(const Key('home-thread-cover-thread-cover'));
    final card = find.byKey(const Key('home-thread-card-thread-cover'));
    expect(cover, findsOneWidget);
    final coverSize = tester.getSize(cover);
    final cardSize = tester.getSize(card);
    expect(coverSize.width, greaterThan(cardSize.width * 0.9));
    expect(coverSize.width, cardSize.width - 24);
    expect(coverSize.width / coverSize.height, closeTo(16 / 9, 0.01));
    expect(tester.getTopLeft(cover).dx, tester.getTopLeft(card).dx + 12);
    expect(find.text('带封面的长篇主题'), findsOneWidget);
    expect(find.text('正文摘要在封面之后延续阅读线索'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(
      tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).fit,
      BoxFit.cover,
    );
  });

  for (final (width, visibleTags) in <(double, int)>[
    (320, 1),
    (360, 2),
    (600, 3),
  ]) {
    testWidgets('$width dp 底栏按可用宽度限制 $visibleTags 个标签并汇总剩余项', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        _homeApp(_FakeHomeRepository(items: [_threadWithManyTags])),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .getSize(
              find.byKey(const Key('home-thread-footer-thread-many-tags')),
            )
            .height,
        48,
      );
      for (var index = 1; index <= visibleTags; index++) {
        expect(
          find.byKey(Key('home-thread-tag-thread-many-tags-tag-$index')),
          findsOneWidget,
        );
      }
      for (var index = visibleTags + 1; index <= 4; index++) {
        expect(
          find.byKey(Key('home-thread-tag-thread-many-tags-tag-$index')),
          findsNothing,
        );
      }
      final more = find.byKey(
        const Key('home-thread-tags-more-thread-many-tags'),
      );
      expect(more, findsOneWidget);
      expect(tester.widget<Text>(more).data, '+${4 - visibleTags}');
      expect(
        find.ancestor(of: more, matching: find.byType(TextButton)),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

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

  testWidgets('360dp 首页卡片与整宽封面视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _homeApp(_FakeHomeRepository(items: [_threadWithCover])),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('home-text-first-visual')),
      matchesGoldenFile('goldens/home_card_cover_360.png'),
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
  preview: '正文摘要在封面之后延续阅读线索',
  tags: const [],
  coverImageUrls: const [
    'https://example.com/cover.jpg',
    'https://example.com/ignored-second-cover.jpg',
  ],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '0',
  lastActivityAt: DateTime.now().subtract(const Duration(hours: 10)),
);

final _threadWithAvatar = HomeThreadCardModel(
  id: 'thread-avatar',
  title: '有头像的主题',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: false,
  ownerId: 'user-avatar',
  ownerName: '一位名字很长但仍需完整保持卡片节奏的头像作者',
  ownerAvatarUrl: 'https://cdn.example.com/avatar.webp',
  ownerLevel: 4,
  preview: '头像与作者元信息保持同一阅读组。',
  tags: const [],
  coverImageUrls: const [],
  memberCount: 2,
  playerCount: 1,
  postCount: 3,
  tipTotal: '0',
  lastActivityAt: DateTime(2026, 8, 12),
);

final _threadWithManyTags = HomeThreadCardModel(
  id: 'thread-many-tags',
  title: '标签密度测试主题',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: true,
  ownerId: 'user-1',
  ownerName: '温柔测试员',
  ownerLevel: 3,
  preview: '标签只占固定底栏，不推动正文高度。',
  tags: const [
    HomeThreadTag(id: 'tag-1', name: '太空歌剧'),
    HomeThreadTag(id: 'tag-2', name: '长期演绎'),
    HomeThreadTag(id: 'tag-3', name: '角色招募'),
    HomeThreadTag(id: 'tag-4', name: '轻松日常'),
  ],
  coverImageUrls: const [],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '0',
  lastActivityAt: DateTime(2026, 8, 15),
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

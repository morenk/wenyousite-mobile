import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

void main() {
  testWidgets('公开主题详情展示默认子贴、Markdown、楼层与内嵌回复', (tester) async {
    await tester.pumpWidget(_detailApp(_FakeThreadDetailRepository()));
    await tester.pumpAndSettle();

    expect(find.text('星海旅团'), findsOneWidget);
    expect(find.text('角色扮演'), findsOneWidget);
    expect(find.text('主线正文'), findsOneWidget);
    expect(
      find.textContaining('🎲 1d20 = 16', findRichText: true),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const Key('thread-subthread-subthread-1')))
          .height,
      greaterThanOrEqualTo(48),
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -750));
    await tester.pumpAndSettle();
    expect(find.text('第一层内容'), findsOneWidget);
    expect(find.text('收到，准备出发。'), findsOneWidget);
  });

  testWidgets('切换子贴同步替换正文与楼层', (tester) async {
    final repository = _FakeThreadDetailRepository();
    await tester.pumpWidget(_detailApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subthread-subthread-2')));
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -750));
    await tester.pumpAndSettle();
    expect(find.text('支线楼层'), findsOneWidget);
    expect(find.text('第一层内容'), findsNothing);
    expect(repository.requestedSubthreads.last, 'subthread-2');
  });

  testWidgets('楼层首屏失败展示局部错误而不是空数据', (tester) async {
    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(
          floorFailure: const ApiFailure(
            userMessage: '楼层暂时无法加载。',
            requestId: 'floors-request-id',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('楼层暂时无法加载。'), findsOneWidget);
    expect(find.text('请求 ID：floors-request-id'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-detail-transient-retry')),
      findsOneWidget,
    );
    expect(find.text('还没有楼层'), findsNothing);
  });

  testWidgets('分页失败在楼层尾部展示请求 ID 与重试', (tester) async {
    final repository = _FakeThreadDetailRepository(
      loadMoreFailure: const ApiFailure(
        userMessage: '加载更多楼层失败。',
        requestId: 'load-more-request-id',
      ),
    );
    await tester.pumpWidget(_detailApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('加载更多楼层失败。'), findsOneWidget);
    expect(find.text('请求 ID：load-more-request-id'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-detail-transient-retry')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thread-floors-load-more')), findsNothing);
    expect(
      tester.getTopLeft(find.text('加载更多楼层失败。')).dy,
      greaterThan(tester.getTopLeft(find.text('第一层内容')).dy),
    );
  });

  testWidgets('404 使用不泄露私密信息的不可见状态', (tester) async {
    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(
          threadFailure: const ApiFailure(
            userMessage: '请求没有完成，请稍后重试。',
            httpStatus: 404,
            requestId: 'missing-request-id',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('这个主题暂时不可见'), findsOneWidget);
    expect(find.textContaining('删除、设为私密'), findsOneWidget);
    expect(find.text('请求 ID：missing-request-id'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 主题详情与楼层无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1100);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_detailApp(_FakeThreadDetailRepository()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('星海旅团'), findsOneWidget);
    });
  }

  testWidgets('首页整卡进入详情，返回后保留已加载首页', (tester) async {
    final homeRepository = _FakeHomeRepository();
    final detailRepository = _FakeThreadDetailRepository();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            categoryNameHint: state.extra as String?,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(homeRepository),
          threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-thread-thread-1')));
    await tester.pumpAndSettle();
    expect(find.text('主题详情'), findsOneWidget);
    expect(find.text('星海旅团'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('发现主题'), findsOneWidget);
    expect(homeRepository.threadCalls, 1);
  });
}

Widget _detailApp(ThreadDetailRepository repository) {
  return ProviderScope(
    overrides: [threadDetailRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const ThreadDetailPage(
        threadId: 'thread-1',
        categoryNameHint: '角色扮演',
      ),
    ),
  );
}

class _FakeThreadDetailRepository implements ThreadDetailRepository {
  _FakeThreadDetailRepository({
    this.threadFailure,
    this.floorFailure,
    this.loadMoreFailure,
  });

  final ApiFailure? threadFailure;
  final ApiFailure? floorFailure;
  final ApiFailure? loadMoreFailure;
  final List<String> requestedSubthreads = [];

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) async {
    if (threadFailure case final failure?) throw failure;
    return _detail;
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
  }) async {
    requestedSubthreads.add(subthreadId);
    if (cursor != null && loadMoreFailure != null) {
      throw loadMoreFailure!;
    }
    if (cursor == null && floorFailure != null) {
      throw floorFailure!;
    }
    if (cursor == null && loadMoreFailure != null) {
      return CursorPage(
        items: [subthreadId == 'subthread-1' ? _mainFloor : _sideFloor],
        cursor: 'next-cursor',
        hasMore: true,
      );
    }
    return CursorPage(
      items: [subthreadId == 'subthread-1' ? _mainFloor : _sideFloor],
      hasMore: false,
    );
  }
}

class _FakeHomeRepository implements HomeRepository {
  int threadCalls = 0;

  @override
  Future<List<HomeCategory>> fetchCategories() async => const [
    HomeCategory(id: 'category-rpg', slug: 'RPG', name: '角色扮演', sortOrder: 1),
  ];

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    threadCalls += 1;
    return CursorPage(items: [_homeThread], hasMore: false);
  }
}

final _detail = ThreadDetailModel(
  id: 'thread-1',
  title: '星海旅团',
  owner: _author,
  categorySlug: 'RPG',
  status: ThreadDetailStatus.recruiting,
  isPrivate: false,
  isPinned: true,
  viewCount: 128,
  likeCount: 12,
  tipTotal: '8',
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tags: const [ThreadTagModel(id: 'tag-1', name: '太空歌剧')],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 8,
      postingPolicyLabel: '参与者发言',
      body: ThreadBodyModel(
        markdown:
            '主线正文\n\n检定 [[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]',
        diceRolls: [
          ThreadDiceRollModel(
            nodeId: '550e8400-e29b-41d4-a716-446655440000',
            notation: '1d20',
            results: [16],
            total: 16,
          ),
        ],
      ),
    ),
    ThreadSubthreadModel(
      id: 'subthread-2',
      title: '支线',
      sortOrder: 2,
      postCount: 4,
      postingPolicyLabel: '玩家发言',
      body: ThreadBodyModel(markdown: '支线正文'),
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 9, 12),
);

const _author = ThreadAuthorModel(id: 'user-1', username: '温柔测试员', level: 3);

final _mainFloor = ThreadFloorModel(
  id: 'floor-1',
  floorNumber: 1,
  author: _author,
  body: const ThreadBodyModel(markdown: '第一层内容'),
  createdAt: DateTime.utc(2026, 8, 9, 12, 10),
  isDeleted: false,
  replyCount: 1,
  replies: [
    ThreadReplyModel(
      id: 'reply-1',
      author: _author,
      body: const ThreadBodyModel(markdown: '收到，准备出发。'),
      createdAt: DateTime.utc(2026, 8, 9, 12, 20),
      isDeleted: false,
      replyToUsername: '温柔测试员',
    ),
  ],
);

final _sideFloor = ThreadFloorModel(
  id: 'floor-2',
  floorNumber: 1,
  author: _author,
  body: const ThreadBodyModel(markdown: '支线楼层'),
  createdAt: DateTime.utc(2026, 8, 9, 13),
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final _homeThread = HomeThreadCardModel(
  id: 'thread-1',
  title: '星海旅团',
  categorySlug: 'RPG',
  status: HomeThreadStatus.recruiting,
  isPinned: false,
  ownerId: 'user-1',
  ownerName: '温柔测试员',
  ownerLevel: 3,
  tags: const [],
  coverImageUrls: const [],
  memberCount: 5,
  playerCount: 2,
  postCount: 12,
  tipTotal: '8',
  lastActivityAt: DateTime.utc(2026, 8, 9, 12),
);

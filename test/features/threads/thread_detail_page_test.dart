import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';

void main() {
  testWidgets('公开主题详情展示默认子贴、Markdown、楼层与内嵌回复', (tester) async {
    await tester.pumpWidget(_detailApp(_FakeThreadDetailRepository()));
    await tester.pumpAndSettle();

    expect(find.text('星海旅团'), findsOneWidget);
    expect(find.text('#太空歌剧'), findsOneWidget);
    final tag = find.byKey(const Key('thread-detail-tag-tag-1'));
    expect(
      find.descendant(of: tag, matching: find.byType(InputChip)),
      findsNothing,
    );
    expect(tester.getSize(tag).height, greaterThanOrEqualTo(48));
    expect(find.byKey(const Key('thread-detail-search')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-report')), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.text('登录后发表楼层'), findsOneWidget);
    expect(find.text('角色扮演'), findsOneWidget);
    expect(find.text('招募中'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('thread-subthread-menu'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const Key('thread-subthread-previous')),
          )
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('thread-subthread-next')))
          .onPressed,
      isNotNull,
    );
    final toolbarCenters = [
      const Key('thread-subthread-previous'),
      const Key('thread-subthread-menu'),
      const Key('thread-subthread-next'),
      const Key('thread-interaction-like'),
    ].map((key) => tester.getCenter(find.byKey(key)).dy).toList();
    expect(
      toolbarCenters.every(
        (center) => (center - toolbarCenters.first).abs() < 1,
      ),
      isTrue,
    );
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
      lessThan(230),
    );
    expect(find.text('参与者发言'), findsNothing);
    expect(find.text('8 条内容'), findsNothing);
    expect(find.text('12 楼层'), findsNothing);
    expect(find.text('128 浏览'), findsOneWidget);
    expect(find.text('2 位玩家'), findsOneWidget);
    expect(find.text('12 楼'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('主线正文'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('主线正文'), findsOneWidget);
    expect(
      find.textContaining('1d20 = 16', findRichText: true),
      findsOneWidget,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -750));
    await tester.pumpAndSettle();
    expect(find.text('第一层内容'), findsOneWidget);
    expect(find.text('收到，准备出发。'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('thread-body-subthread-1')),
        matching: find.byType(WenyouPanel),
      ),
      findsNothing,
    );
    expect(
      tester
          .getSize(find.byKey(const Key('thread-floor-author-floor-1')))
          .height,
      lessThanOrEqualTo(36),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('thread-floor-actions-floor-1')))
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('thread-floor-report-floor-1')), findsNothing);
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(find.byKey(const Key('thread-reply-level-reply-1')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('thread-reply-level-reply-1'))).width,
      lessThan(64),
    );

    await tester.tap(find.byKey(const Key('thread-floor-actions-floor-1')));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.text('复制楼层链接'), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(const Key('thread-inline-reply-reply-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('回复操作'), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
  });

  testWidgets('切换子贴同步替换正文与楼层', (tester) async {
    final repository = _FakeThreadDetailRepository();
    await tester.pumpWidget(_detailApp(repository));
    await tester.pumpAndSettle();

    final menu = find.byKey(const Key('thread-subthread-menu'));
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.text('主题目录'), findsOneWidget);
    expect(find.text('共 2 个子贴'), findsOneWidget);
    expect(find.text('8 楼'), findsWidgets);
    expect(find.text('4 楼'), findsOneWidget);
    expect(
      tester
          .widget<ListView>(find.byKey(const Key('thread-subthread-directory')))
          .scrollDirection,
      Axis.vertical,
    );
    expect(
      find.byKey(const Key('thread-subthread-subthread-1')),
      findsOneWidget,
    );
    final subthread = find.byKey(const Key('thread-subthread-subthread-2'));
    expect(subthread, findsOneWidget);
    await tester.tap(subthread);
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-2');

    await tester.tap(find.byKey(const Key('thread-subthread-previous')));
    await tester.pumpAndSettle();
    expect(find.text('主线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-1');

    await tester.tap(find.byKey(const Key('thread-subthread-previous')));
    await tester.pumpAndSettle();
    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-2');

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pumpAndSettle();
    expect(find.text('主线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-1');

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pumpAndSettle();
    expect(find.text('支线正文'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -750));
    await tester.pumpAndSettle();
    expect(find.text('支线楼层'), findsOneWidget);
    expect(find.text('第一层内容'), findsNothing);
    expect(repository.requestedSubthreads.last, 'subthread-2');
  });

  testWidgets('站内传送门的 subthread 坐标直接打开指定子贴', (tester) async {
    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(), subthreadIdHint: 'subthread-2'),
    );
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(find.text('主线正文'), findsNothing);
  });

  testWidgets('搜索结果中的帖子会切换所属子贴并展示目标上下文', (tester) async {
    final repository = _FakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: _targetFloor,
      ),
    );
    await tester.pumpWidget(
      _detailApp(repository, targetPostId: 'floor-target'),
    );
    await tester.pumpAndSettle();

    expect(find.text('目标楼层内容'), findsOneWidget);
    expect(repository.targetPostIds, ['floor-target']);
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

  testWidgets('360 dp 登录态子贴切换、喜欢、收藏和订阅保持同一工具栏', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(),
        ),
        threadInteractionRepositoryProvider.overrideWithValue(
          _FakeThreadInteractionRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('viewer-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(
            threadId: 'thread-1',
            categoryNameHint: '角色扮演',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final keys = [
      const Key('thread-subthread-previous'),
      const Key('thread-subthread-menu'),
      const Key('thread-subthread-next'),
      const Key('thread-interaction-like'),
      const Key('thread-interaction-bookmark'),
      const Key('thread-subscription-menu'),
    ];
    final centers = keys
        .map((key) => tester.getCenter(find.byKey(key)).dy)
        .toList();
    expect(
      centers.every((center) => (center - centers.first).abs() < 1),
      isTrue,
    );
  });

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

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(homeRepository.threadCalls, 1);
  });

  testWidgets('直接进入主题详情时系统返回回首页而不是退出应用', (tester) async {
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, _) => const Scaffold(
            body: Text('首页回退目标', key: Key('thread-back-home')),
          ),
        ),
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) =>
              ThreadDetailPage(threadId: state.pathParameters['threadId']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailRepositoryProvider.overrideWithValue(
            _FakeThreadDetailRepository(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('主题详情'), findsOneWidget);
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.byKey(const Key('thread-back-home')), findsOneWidget);
  });

  testWidgets('游客点赞先登录并保留主题帖子目标', (tester) async {
    final detailRepository = _FakeThreadDetailRepository();
    final router = GoRouter(
      initialLocation: '/threads/thread-1?post=floor-target',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            targetPostId: state.uri.queryParameters['post'],
          ),
        ),
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (_, state) => Scaffold(
            body: Text('登录回跳=${state.uri.queryParameters['returnTo']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-interaction-like')));
    await tester.pumpAndSettle();

    expect(
      find.text('登录回跳=/threads/thread-1?post=floor-target'),
      findsOneWidget,
    );
  });

  testWidgets('登录身份变化重新读取主题互动投影', (tester) async {
    final repository = _FakeThreadDetailRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(repository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.threadCalls, 1);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokens);
    await tester.pumpAndSettle();

    expect(repository.threadCalls, 2);
  });

  testWidgets('登录用户在零回复楼层仍看到可发现的回复入口', (tester) async {
    final repository = _FakeThreadDetailRepository(mainFloor: _sideFloor);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(repository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('viewer-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final discussion = find.byKey(const Key('thread-floor-discussion-floor-2'));
    await tester.scrollUntilVisible(
      discussion,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: discussion, matching: find.text('回复')),
      findsOneWidget,
    );
  });

  testWidgets('管理者从主题详情编辑正文并按作者与管理权限操作楼层', (tester) async {
    final detailRepository = _FakeThreadDetailRepository(
      detail: _managerDetail,
    );
    final postRepository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(postRepository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('user-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-detail-manage')), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.text('发表楼层…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-composer-close')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('thread-body-edit')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('thread-body-edit')), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-body-edit')));
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴正文'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-composer-close')));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-edit-floor-1')), findsNothing);
    expect(find.byKey(const Key('thread-floor-delete-floor-1')), findsNothing);
    expect(
      find.byKey(const Key('thread-floor-discussion-floor-1')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('thread-floor-actions-floor-1')));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    await tester.ensureVisible(find.text('删除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这个楼层？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(postRepository.removedIds, ['floor-1']);
  });
}

Widget _detailApp(
  ThreadDetailRepository repository, {
  String? targetPostId,
  String? subthreadIdHint,
}) {
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: ThreadDetailPage(
        threadId: 'thread-1',
        categoryNameHint: '角色扮演',
        targetPostId: targetPostId,
        subthreadIdHint: subthreadIdHint,
      ),
    ),
  );
}

class _FakeThreadDetailRepository implements ThreadDetailRepository {
  _FakeThreadDetailRepository({
    this.threadFailure,
    this.floorFailure,
    this.loadMoreFailure,
    this.postTarget,
    ThreadDetailModel? detail,
    ThreadFloorModel? mainFloor,
  }) : detail = detail ?? _detail,
       mainFloor = mainFloor ?? _mainFloor;

  final ApiFailure? threadFailure;
  final ApiFailure? floorFailure;
  final ApiFailure? loadMoreFailure;
  final ThreadPostTargetModel? postTarget;
  final ThreadDetailModel detail;
  final ThreadFloorModel mainFloor;
  final List<String> requestedSubthreads = [];
  final List<String> targetPostIds = [];
  int threadCalls = 0;

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) async {
    threadCalls += 1;
    if (threadFailure case final failure?) throw failure;
    return detail;
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) async {
    targetPostIds.add(postId);
    return postTarget!;
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
        items: [subthreadId == 'subthread-1' ? mainFloor : _sideFloor],
        cursor: 'next-cursor',
        hasMore: true,
      );
    }
    return CursorPage(
      items: [subthreadId == 'subthread-1' ? mainFloor : _sideFloor],
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

final _managerDetail = ThreadDetailModel(
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
  tags: const [],
  subthreads: const [
    ThreadSubthreadModel(
      id: 'subthread-1',
      title: '主线',
      sortOrder: 1,
      postCount: 8,
      postingPolicyLabel: '参与者发言',
      body: ThreadBodyModel(markdown: '主线正文', postId: 'body-1', version: 5),
    ),
  ],
  defaultSubthreadId: 'subthread-1',
  canManageThread: true,
  hasAutomaticUpdates: true,
  currentUserId: 'user-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 9, 12),
);

const _author = ThreadAuthorModel(id: 'user-1', username: '温柔测试员', level: 3);

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

SessionTokens _tokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}

class _FakeThreadSubscriptionRepository
    implements ThreadSubscriptionRepository {
  @override
  Future<List<ThreadSubscriptionRecord>> fetchSubscriptions(
    String threadId,
  ) async => const [];

  @override
  Future<List<ThreadSubscriptionCandidate>> fetchCandidates(
    String threadId, {
    String? viewerUserId,
  }) async => const [];

  @override
  Future<ThreadSubscriptionRecord> create({
    required String threadId,
    required ThreadSubscriptionType type,
    String? targetUserId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String subscriptionId) {
    throw UnimplementedError();
  }
}

class _FakeThreadInteractionRepository implements ThreadInteractionRepository {
  @override
  Future<String> createBookmark(String threadId) async => 'bookmark-1';

  @override
  Future<int> like(String threadId) async => 13;

  @override
  Future<void> removeBookmark(String bookmarkId) async {}

  @override
  Future<int> unlike(String threadId) async => 12;
}

class _FakePostRepository implements PostRepository {
  final List<String> removedIds = [];

  @override
  Future<void> remove(String postId) async => removedIds.add(postId);

  @override
  Future<PostItem> fetchPost(String postId) => throw UnsupportedError('unused');

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) => throw UnsupportedError('unused');

  @override
  Future<PostItem> create(PostCreateInput input) =>
      throw UnsupportedError('unused');

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) => throw UnsupportedError('unused');

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) => throw UnsupportedError('unused');
}

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

final _targetFloor = ThreadFloorModel(
  id: 'floor-target',
  floorNumber: 9,
  author: _author,
  body: const ThreadBodyModel(markdown: '目标楼层内容'),
  createdAt: DateTime.utc(2026, 8, 10, 8),
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

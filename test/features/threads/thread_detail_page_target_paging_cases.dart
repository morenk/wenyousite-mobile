import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageTargetPagingCases() {
  testWidgets('帖子入口尚在定位时用户切换子贴，迟到结果不再覆盖用户选择', (tester) async {
    final completer = Completer<ThreadPostTargetModel>();
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTargetFuture: completer.future,
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(repository, targetPostId: 'floor-target'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('主线正文'), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pump();
    await tester.pump();
    expect(find.text('支线正文'), findsOneWidget);

    completer.complete(
      ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-2');
    expect(find.text('目标楼层内容'), findsNothing);
  });

  testWidgets('同一主题压入两个详情页时各自保留独立子贴状态', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository();
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          builder: (context, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            entryTarget: ThreadDetailEntryTarget.fromQuery(
              postId: state.uri.queryParameters['post'],
              subthreadId: state.uri.queryParameters['subthread'],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          threadDetailRepositoryProvider.overrideWithValue(repository),
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pumpAndSettle();
    expect(find.text('支线正文'), findsOneWidget);

    unawaited(router.push<void>('/threads/thread-1'));
    await tester.pumpAndSettle();
    expect(find.text('主线正文'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.threadCalls, 2);
  });

  testWidgets('搜索结果中的帖子会切换所属子贴并展示目标上下文', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(repository, targetPostId: 'floor-target'),
    );
    await tester.pumpAndSettle();

    expect(find.text('目标楼层内容'), findsOneWidget);
    expect(find.textContaining('已定位到'), findsNothing);
    expect(find.textContaining('强调底色'), findsNothing);
    expect(find.byType(AnimatedContainer), findsOneWidget);
    expect(repository.targetPostIds, ['floor-target']);
    expect(repository.requestedSubthreads.last, 'subthread-2');
    expect(
      tester
          .getTopLeft(find.byKey(const Key('thread-floor-card-floor-target')))
          .dy,
      greaterThan(
        tester
            .getTopLeft(find.byKey(const Key('thread-floor-card-floor-2')))
            .dy,
      ),
    );
  });

  testWidgets('目标主楼被发言者筛选排除时恢复全部楼层后再定位', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(repository, targetPostId: 'floor-target'),
    );
    await tester.pumpAndSettle();

    final authorFilter = find.byKey(const Key('thread-floors-author'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 80));
    await tester.pumpAndSettle();
    await tester.tap(authorFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一位接力者').last);
    await tester.pumpAndSettle();

    expect(repository.requestedAuthors, contains('user-2'));
    expect(repository.requestedAuthors.last, isNull);
    expect(find.text('已取消发言者筛选，以显示目标楼层。'), findsOneWidget);
    expect(find.text('目标楼层内容'), findsOneWidget);
  });

  testWidgets('首屏外目标楼层定位后会释放用户滚动', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final floors = [
      for (var index = 1; index <= 20; index += 1)
        ThreadFloorModel(
          id: 'long-floor-$index',
          floorNumber: index,
          author: threadDetailPageTestAuthor,
          body: ThreadBodyModel(
            markdown: '第 $index 层的较长正文，用来确保目标一开始不在 Sliver 构建范围内。\n\n补充内容。',
          ),
          createdAt: threadDetailPageTestRecentFixtureTime,
          isDeleted: false,
          replyCount: 0,
          replies: const [],
        ),
    ];
    final targetFloor = ThreadFloorModel(
      id: 'far-target',
      floorNumber: 1000,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '远端目标楼层'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      mainFloors: floors,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'far-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: targetFloor,
      ),
    );

    await tester.pumpWidget(
      threadDetailPageTestDetailApp(repository, targetPostId: 'far-target'),
    );
    await tester.pumpAndSettle();

    final targetFinder = find.byKey(const Key('thread-floor-card-far-target'));
    expect(targetFinder, findsOneWidget);
    final targetRect = tester.getRect(targetFinder);
    expect(targetRect.bottom, greaterThan(0));
    expect(targetRect.top, lessThan(640));

    final scrollView = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView),
    );
    final scrollController = scrollView.controller!;
    final locatedOffset = scrollController.offset;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 240));
    await tester.pumpAndSettle();
    final userOffset = scrollController.offset;
    expect(userOffset, lessThan(locatedOffset - 100));

    final scrollContext = tester.element(find.byType(CustomScrollView));
    ScrollMetricsNotification(
      metrics: scrollController.position,
      context: scrollContext,
    ).dispatch(scrollContext);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(scrollController.offset, closeTo(userOffset, 1));
  });

  testWidgets('发表楼层后保留已加载窗口并定位到新楼层', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final createdFloor = ThreadFloorModel(
      id: 'floor-created',
      floorNumber: 2,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '刚发表的楼层'),
      createdAt: DateTime.utc(2026, 8, 10, 9),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    final detailRepository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-created',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: createdFloor,
      ),
    );
    final postRepository = ThreadDetailPageTestCreatingPostRepository();
    final authorDirectory =
        ThreadDetailPageTestMutablePostDiscussionAuthorDirectory();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(postRepository),
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          authorDirectory,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('user-1'));
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (context, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            entryTarget: ThreadDetailEntryTarget.fromQuery(
              postId: state.uri.queryParameters['post'],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(authorDirectory.floorCalls, 1);

    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    await threadDetailPageTestReplacePostComposerText(tester, '刚发表的楼层');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();

    expect(postRepository.createInputs, hasLength(1));
    expect(postRepository.createInputs.single.parentPostId, isNull);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['post'],
      'floor-created',
    );
    expect(detailRepository.targetPostIds, ['floor-created']);
    expect(detailRepository.requestedSubthreads, ['subthread-1']);
    expect(authorDirectory.floorCalls, 2);
    expect(find.text('刚发表的楼层'), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const Key('thread-floor-card-floor-created')))
          .dy,
      greaterThan(
        tester
            .getTopLeft(find.byKey(const Key('thread-floor-card-floor-1')))
            .dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('楼层首屏失败展示局部错误而不是空数据', (tester) async {
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
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
    expect(find.textContaining('问题编号：floors-request-id'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-detail-transient-retry')),
      findsOneWidget,
    );
    expect(find.text('还没有楼层'), findsNothing);
  });

  testWidgets('分页失败在楼层尾部展示请求 ID 与重试', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      loadMoreFailure: const ApiFailure(
        userMessage: '加载更多楼层失败。',
        requestId: 'load-more-request-id',
      ),
    );
    await tester.pumpWidget(threadDetailPageTestDetailApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text('加载更多楼层失败。'), findsOneWidget);
    expect(find.textContaining('问题编号：load-more-request-id'), findsOneWidget);
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

  testWidgets('分页新增楼层首帧直接进入最终位置且 200ms 后不再变化', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      mainFloors: [threadDetailPageTestMainFloor],
      nextFloors: [threadDetailPageTestPaginatedFloor],
    );
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        threadDetailRepositoryProvider.overrideWithValue(repository),
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

    final addedFloor = find.byKey(const Key('thread-floor-card-floor-page'));
    await tester.scrollUntilVisible(
      addedFloor,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(addedFloor, findsOneWidget);
    final firstFrameTop = tester.getTopLeft(addedFloor).dy;
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getTopLeft(addedFloor).dy, firstFrameTop);
  });

  testWidgets('404 使用不泄露私密信息的不可见状态', (tester) async {
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
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
    expect(find.textContaining('问题编号：missing-request-id'), findsNothing);
  });

  for (final fixture in threadDetailPageTestThreadDetailViewportFixtures) {
    testWidgets('${fixture.name} 主题详情保持正文视口和贴底操作栏', (tester) async {
      threadDetailPageTestConfigureThreadDetailViewport(tester, fixture);

      await tester.pumpWidget(
        threadDetailPageTestDetailApp(
          ThreadDetailPageTestFakeThreadDetailRepository(),
          textScale: fixture.textScale,
        ),
      );
      await tester.pumpAndSettle();

      final screenSize = fixture.logicalSize;
      final bottomBar = find.byKey(const Key('thread-detail-bottom-bar'));
      final bottomBarRect = tester.getRect(bottomBar);
      final scrollRect = tester.getRect(find.byType(CustomScrollView));
      expect(tester.takeException(), isNull);
      expect(find.text('星海旅团'), findsOneWidget);
      expect(bottomBarRect.height, greaterThanOrEqualTo(48));
      expect(bottomBarRect.height, lessThan(160));
      expect(bottomBarRect.height, lessThan(screenSize.height * 0.35));
      expect(bottomBarRect.bottom, closeTo(screenSize.height, 0.2));
      expect(scrollRect.width, greaterThan(0));
      expect(scrollRect.height, greaterThan(screenSize.height * 0.3));
      expect(scrollRect.bottom, closeTo(bottomBarRect.top, 0.2));
      for (final actionKey in const [
        Key('thread-interaction-like'),
        Key('thread-floor-compose'),
      ]) {
        expect(
          bottomBarRect.contains(tester.getCenter(find.byKey(actionKey))),
          isTrue,
        );
      }
    });
  }

  for (final fixture in threadDetailPageTestThreadDetailViewportFixtures.where(
    (fixture) => threadDetailPageTestAuthenticatedViewportFixtureNames.contains(
      fixture.name,
    ),
  )) {
    testWidgets('${fixture.name} 登录态完整底栏保持全部操作可见', (tester) async {
      threadDetailPageTestConfigureThreadDetailViewport(tester, fixture);
      await tester.pumpWidget(
        await threadDetailPageTestAuthenticatedDetailApp(
          ThreadDetailPageTestFakeThreadDetailRepository(),
          userId: 'viewer-1',
          textScale: fixture.textScale,
        ),
      );
      await tester.pumpAndSettle();

      final screenSize = fixture.logicalSize;
      final bottomBarRect = tester.getRect(
        find.byKey(const Key('thread-detail-bottom-bar')),
      );
      final scrollRect = tester.getRect(find.byType(CustomScrollView));
      expect(tester.takeException(), isNull);
      expect(bottomBarRect.height, lessThan(160));
      expect(bottomBarRect.height, lessThan(screenSize.height * 0.35));
      expect(bottomBarRect.bottom, closeTo(screenSize.height, 0.2));
      expect(scrollRect.height, greaterThan(screenSize.height * 0.3));
      expect(scrollRect.bottom, closeTo(bottomBarRect.top, 0.2));
      for (final actionKey in const [
        Key('thread-interaction-like'),
        Key('thread-interaction-bookmark'),
        Key('thread-subscription-menu'),
        Key('thread-floor-compose'),
      ]) {
        expect(find.byKey(actionKey), findsOneWidget);
        expect(
          bottomBarRect.contains(tester.getCenter(find.byKey(actionKey))),
          isTrue,
        );
      }
    });
  }
}

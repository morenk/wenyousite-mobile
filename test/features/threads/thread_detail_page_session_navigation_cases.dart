import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageSessionNavigationCases() {
  testWidgets('360 dp 子贴导航独占题头行，互动与发表固定在底部拇指栏', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(),
        ),
        threadInteractionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadInteractionRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));

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

    expect(tester.takeException(), isNull);
    final navigatorKeys = [
      const Key('thread-subthread-previous'),
      const Key('thread-subthread-menu'),
      const Key('thread-subthread-next'),
    ];
    final navigatorCenters = navigatorKeys
        .map((key) => tester.getCenter(find.byKey(key)).dy)
        .toList();
    expect(
      navigatorCenters.every(
        (center) => (center - navigatorCenters.first).abs() < 1,
      ),
      isTrue,
    );
    final bottomKeys = [
      const Key('thread-interaction-like'),
      const Key('thread-interaction-bookmark'),
      const Key('thread-subscription-menu'),
      const Key('thread-floor-compose'),
    ];
    final bottomCenters = bottomKeys
        .map((key) => tester.getCenter(find.byKey(key)).dy)
        .toList();
    expect(
      bottomCenters.every((center) => (center - bottomCenters.first).abs() < 1),
      isTrue,
    );
    expect(bottomCenters.first, greaterThan(navigatorCenters.first));
    final bottomBar = find.byKey(const Key('thread-detail-bottom-bar'));
    expect(bottomBar, findsOneWidget);
    expect(tester.getSize(bottomBar).height, lessThan(120));
    expect(tester.getBottomLeft(bottomBar).dy, closeTo(900, 0.1));
    expect(
      tester.getSize(find.byType(CustomScrollView)).height,
      greaterThan(600),
    );
  });

  testWidgets('320dp 与两倍字号下底栏把发表收为可读图标且保持可操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(
            detail: threadDetailPageTestCopyThreadDetail(
              threadDetailPageTestDetail,
              subthreads: threadDetailPageTestDetail.subthreads,
              likeCount: 1000000,
            ),
          ),
        ),
        threadInteractionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadInteractionRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final navigatorFrame = find.byKey(
      const Key('thread-subthread-navigator-frame'),
    );
    expect(tester.getSize(navigatorFrame).width, closeTo(296, 0.1));
    expect(tester.getCenter(navigatorFrame).dx, closeTo(160, 0.1));
    final compose = find.byKey(const Key('thread-floor-compose'));
    expect(compose, findsOneWidget);
    expect(find.text('发表楼层'), findsNothing);
    expect(find.text('100万'), findsOneWidget);
    expect(tester.getSemantics(compose).getSemanticsData().tooltip, '发表楼层');

    await tester.tap(compose);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
  });

  testWidgets('玩家退出入口只在更多操作的身份面板中出现', (tester) async {
    final playerDetail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestDetail,
      subthreads: threadDetailPageTestDetail.subthreads,
      isCurrentUserPlayer: true,
      currentUserId: 'viewer-1',
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(detail: playerDetail),
        ),
        threadInteractionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadInteractionRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));
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

    expect(find.byKey(const Key('thread-player-exit')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-exit-player')), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-detail-exit-player')));
    await tester.pumpAndSettle();

    expect(find.text('玩家身份'), findsOneWidget);
    expect(find.byKey(const Key('thread-player-exit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('首页整卡进入详情，返回后保留已加载首页', (tester) async {
    final homeRepository = ThreadDetailPageTestFakeHomeRepository();
    final detailRepository = ThreadDetailPageTestFakeThreadDetailRepository();
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
          builder: (_, state) =>
              ThreadDetailPage(threadId: state.pathParameters['threadId']!),
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
    expect(find.text('主题详情'), findsNothing);
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
            ThreadDetailPageTestFakeThreadDetailRepository(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('主题详情'), findsNothing);
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.byKey(const Key('thread-back-home')), findsOneWidget);
  });

  testWidgets('游客点赞先登录并保留主题帖子目标', (tester) async {
    final detailRepository = ThreadDetailPageTestFakeThreadDetailRepository();
    final router = GoRouter(
      initialLocation: '/threads/thread-1?post=floor-target',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            entryTarget: ThreadDetailEntryTarget.fromQuery(
              postId: state.uri.queryParameters['post'],
            ),
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
    final repository = ThreadDetailPageTestFakeThreadDetailRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(repository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
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
        .authenticate(threadDetailPageTestTokens);
    await tester.pumpAndSettle();

    expect(repository.threadCalls, 2);
  });

  testWidgets('登录身份变化重新读取目标楼层而不复用旧账号投影', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: threadDetailPageTestMainFloor,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(repository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(
            threadId: 'thread-1',
            entryTarget: ThreadDetailEntryTarget.post('floor-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.targetPostIds, ['floor-1']);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokens);
    await tester.pumpAndSettle();

    expect(repository.targetPostIds, ['floor-1', 'floor-1']);
  });

  testWidgets('切号关闭主题详情旧编辑器并清空账号内存草稿', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('account-a'));
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
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    await threadDetailPageTestReplacePostComposerText(tester, '账号 A 的未发布楼层');

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('account-b'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller
          .document
          .toPlainText()
          .trim(),
      isEmpty,
    );
  });

  testWidgets('登录用户点击零回复楼层正文直接回复且不显示回复按钮', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      mainFloor: threadDetailPageTestSideFloor,
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(repository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));
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

    final floor = find.byKey(const Key('thread-floor-card-floor-2'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('thread-floor-discussion-floor-2')),
      findsNothing,
    );

    final semantics = tester.getSemantics(floor);
    expect(semantics.label, contains('回复第 1 楼'));
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.text('支线楼层'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    expect(find.text('回复 @温柔测试员'), findsOneWidget);
  });
}

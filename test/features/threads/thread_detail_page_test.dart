import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('公开主题详情连续展示正文，并由克制入口进入楼中楼', (tester) async {
    await tester.pumpWidget(_detailRouterApp(_FakeThreadDetailRepository()));
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
    expect(find.byKey(const Key('thread-detail-more')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-tip')), findsNothing);
    expect(find.byKey(const Key('thread-detail-report')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-tip')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-report')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-manage')), findsNothing);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
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
      lessThan(190),
    );
    expect(find.text('参与者发言'), findsNothing);
    expect(find.text('8 条内容'), findsNothing);
    expect(find.text('12 楼层'), findsNothing);
    expect(find.text('128 浏览 · 2 玩家 · 12 楼 · 8 升温油'), findsOneWidget);
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
    expect(
      find.byKey(const Key('thread-floor-reply-floor-1-reply-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-collapsed-floor-1')),
      findsNothing,
    );
    expect(find.byKey(const Key('thread-reply-level-reply-1')), findsNothing);
    final discussion = find.byKey(const Key('thread-floor-discussion-floor-1'));
    expect(discussion, findsOneWidget);
    expect(tester.getSize(discussion).height, greaterThanOrEqualTo(48));
    final discussionSemantics = tester.getSemantics(discussion);
    expect(discussionSemantics.label, contains('1 条回复'));
    expect(tester.widget<TextButton>(discussion).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('thread-floor-actions-floor-1')));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.text('复制楼层链接'), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.ensureVisible(discussion);
    await tester.pumpAndSettle();
    await tester.tap(discussion);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsOneWidget,
    );
    expect(find.text('thread-1/floor-1'), findsOneWidget);
  });

  testWidgets('楼中楼回复深链直接定位独立讨论，返回后不重复打开', (tester) async {
    final repository = _FakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'reply-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: _mainFloor,
        focusedReplyId: 'reply-1',
      ),
    );
    await tester.pumpWidget(
      _detailRouterApp(
        repository,
        initialLocation: '/threads/thread-1?post=reply-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsOneWidget,
    );
    expect(find.text('thread-1/floor-1/reply-1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('test-post-replies-back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsNothing,
    );
    expect(find.text('主题详情'), findsOneWidget);
  });

  testWidgets('楼层只预览前五条回复且合计正文超过 500 字时折叠', (tester) async {
    final replies = [
      for (var index = 1; index <= 6; index++)
        ThreadReplyModel(
          id: 'preview-$index',
          author: _author,
          body: ThreadBodyModel(
            markdown: index == 1
                ? List.filled(501, '长').join()
                : '第 $index 条简短回复',
          ),
          createdAt: DateTime.utc(2026, 8, 9, 12, 20 + index),
          isDeleted: false,
        ),
    ];
    final floor = ThreadFloorModel(
      id: 'floor-preview',
      floorNumber: 1,
      author: _author,
      body: const ThreadBodyModel(markdown: '带有较长讨论的楼层'),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: replies.length,
      replies: replies,
    );
    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(mainFloor: floor)),
    );
    await tester.pumpAndSettle();

    final collapsed = find.byKey(
      const Key('thread-floor-reply-preview-collapsed-floor-preview'),
    );
    await tester.scrollUntilVisible(
      collapsed,
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(collapsed, findsOneWidget);
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-preview')),
      findsOneWidget,
    );
    for (var index = 1; index <= 5; index++) {
      expect(
        find.byKey(Key('thread-floor-reply-floor-preview-preview-$index')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const Key('thread-floor-reply-floor-preview-preview-6')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp 长文阅读滚动时顶栏和发表入口保持固定', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const visualKey = Key('thread-detail-text-first-visual');

    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(
          mainFloors: [_longMainFloor, _longSecondFloor],
        ),
        visualKey: visualKey,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('thread-detail-reading-app-bar')),
      findsNothing,
    );
    expect(find.text('主题详情').hitTestable(), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('主题详情').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/thread_detail_text_first_360.png'),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(find.text('主题详情').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
  });

  testWidgets('360dp 主题首屏优先呈现标题与正文', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const visualKey = Key('thread-detail-overview-visual');

    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(), visualKey: visualKey),
    );
    await tester.pumpAndSettle();

    final overview = find.byKey(const Key('thread-detail-overview'));
    expect(tester.getSize(overview).height, lessThan(190));
    expect(
      find.ancestor(of: overview, matching: find.byType(Card)),
      findsNothing,
    );
    expect(find.text('主线正文'), findsOneWidget);

    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/thread_detail_overview_360.png'),
    );
  });

  for (final size in [const Size(400, 900), const Size(600, 1000)]) {
    testWidgets('${size.width.toInt()}dp 主题首屏保持文字优先响应式基线', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final visualKey = Key(
        'thread-detail-overview-${size.width.toInt()}-visual',
      );

      await tester.pumpWidget(
        _detailApp(_FakeThreadDetailRepository(), visualKey: visualKey),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
        lessThan(190),
      );
      expect(find.text('主线正文'), findsOneWidget);
      expect(find.text('第一层内容'), findsOneWidget);
      await expectLater(
        find.byKey(visualKey),
        matchesGoldenFile(
          'goldens/thread_detail_overview_${size.width.toInt()}.png',
        ),
      );
    });
  }

  testWidgets('360dp 五标签语境保持单行横滑且不撑高题头', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final manyTagsDetail = _detailWithTags(const [
      ThreadTagModel(id: 'tag-1', name: '太空歌剧'),
      ThreadTagModel(id: 'tag-2', name: '群像叙事'),
      ThreadTagModel(id: 'tag-3', name: '星际远航'),
      ThreadTagModel(id: 'tag-4', name: '长期接力'),
      ThreadTagModel(id: 'tag-5', name: '硬科幻'),
    ]);

    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(detail: manyTagsDetail)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<SingleChildScrollView>(
            find.byKey(const Key('thread-detail-context-row')),
          )
          .scrollDirection,
      Axis.horizontal,
    );
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
      lessThan(190),
    );
    expect(find.text('主线正文'), findsOneWidget);
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

  testWidgets('发表楼层后保留已加载窗口并定位到新楼层', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final createdFloor = ThreadFloorModel(
      id: 'floor-created',
      floorNumber: 2,
      author: _author,
      body: const ThreadBodyModel(markdown: '刚发表的楼层'),
      createdAt: DateTime.utc(2026, 8, 10, 9),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    final detailRepository = _FakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-created',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: createdFloor,
      ),
    );
    final postRepository = _CreatingPostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
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
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (context, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            targetPostId: state.uri.queryParameters['post'],
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

    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    await _replacePostComposerText(tester, '刚发表的楼层');
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

  testWidgets('分页新增楼层首帧直接进入最终位置且 200ms 后不再变化', (tester) async {
    final repository = _FakeThreadDetailRepository(
      mainFloors: [_mainFloor],
      nextFloors: [_paginatedFloor],
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

    final loadMore = container
        .read(threadDetailControllerProvider('thread-1').notifier)
        .loadMore();
    await tester.pump();
    await loadMore;

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

  testWidgets('登录用户点击零回复楼层正文直接回复且不显示回复按钮', (tester) async {
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

  testWidgets('楼层回复数与更多菜单保留独立点击行为', (tester) async {
    final repository = _FakeThreadDetailRepository();
    await tester.pumpWidget(_detailRouterApp(repository));
    await tester.pumpAndSettle();

    final discussion = find.byKey(const Key('thread-floor-discussion-floor-1'));
    await tester.scrollUntilVisible(
      discussion,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(discussion);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('post-composer-body')), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    final floor = find.byKey(const Key('thread-floor-card-floor-1'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPressAt(tester.getTopLeft(floor) + const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-body')), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('thread-floor-actions-floor-1')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('thread-floor-actions-floor-1')));
    await tester.pumpAndSettle();
    expect(find.text('楼层操作'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-body')), findsNothing);
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

    expect(find.byKey(const Key('thread-detail-more')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-manage')), findsNothing);
    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    expect(find.byKey(const Key('thread-detail-edit-body')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-manage')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-edit-body')), findsOneWidget);
    expect(find.text('编辑当前子贴正文'), findsOneWidget);
    expect(find.text('主线'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('thread-detail-tip')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-report')), findsOneWidget);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.text('发表楼层…'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-composer-close')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-edit-body')));
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

  for (final width in const [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 管理者阅读区不常驻正文编辑控件', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
          threadDetailRepositoryProvider.overrideWithValue(
            _FakeThreadDetailRepository(detail: _managerDetail),
          ),
          threadSubscriptionRepositoryProvider.overrideWithValue(
            _FakeThreadSubscriptionRepository(),
          ),
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

      expect(find.byKey(const Key('thread-body-edit')), findsNothing);
      expect(find.text('主线正文'), findsOneWidget);
      expect(tester.getTopLeft(find.text('主线正文')).dy, lessThan(400));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('thread-detail-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thread-detail-edit-body')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('thread-detail-edit-body'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('360dp 管理者首屏同样保持正文优先视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(detail: _managerDetail),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('user-1'));
    const visualKey = Key('thread-detail-manager-text-first-visual');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: visualKey,
            child: ThreadDetailPage(threadId: 'thread-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    expect(find.text('主线正文'), findsOneWidget);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/thread_detail_manager_text_first_360.png'),
    );
  });

  testWidgets('管理者在空子贴从主题操作添加正文', (tester) async {
    final emptyBodyDetail = _copyThreadDetail(
      _managerDetail,
      subthreads: const [
        ThreadSubthreadModel(
          id: 'subthread-1',
          title: '尚未开篇',
          sortOrder: 1,
          postCount: 0,
          postingPolicyLabel: '参与者发言',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(detail: emptyBodyDetail),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
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

    expect(find.text('这个子贴还没有正文。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.text('添加当前子贴正文'), findsOneWidget);
    expect(find.text('尚未开篇'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('thread-detail-edit-body')));
    await tester.pumpAndSettle();
    expect(find.text('添加子贴正文'), findsOneWidget);
  });
}

Future<void> _replacePostComposerText(WidgetTester tester, String text) async {
  final editor = find.byKey(const Key('post-composer-body'));
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
  final rawEditor = tester.state<QuillRawEditorState>(
    find.descendant(of: editor, matching: find.byType(QuillRawEditor)),
  );
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(
        offset: rawEditor.textEditingValue.text.length,
      ),
    ),
  );
  await tester.idle();
}

Widget _detailApp(
  ThreadDetailRepository repository, {
  String? targetPostId,
  String? subthreadIdHint,
  Key? visualKey,
}) {
  final page = ThreadDetailPage(
    threadId: 'thread-1',
    categoryNameHint: '角色扮演',
    targetPostId: targetPostId,
    subthreadIdHint: subthreadIdHint,
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: visualKey == null
          ? page
          : RepaintBoundary(key: visualKey, child: page),
    ),
  );
}

Widget _detailRouterApp(
  ThreadDetailRepository repository, {
  String initialLocation = '/threads/thread-1',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        builder: (context, state) => ThreadDetailPage(
          threadId: state.pathParameters['threadId']!,
          categoryNameHint: '角色扮演',
          targetPostId: state.uri.queryParameters['post'],
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/posts/:postId/replies',
        name: 'post-replies',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          final postId = state.pathParameters['postId']!;
          final replyId = state.uri.queryParameters['post'];
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(key: Key('test-post-replies-back')),
              title: const Text('楼中楼讨论'),
            ),
            body: Center(
              child: Text(
                [threadId, postId, ?replyId].join('/'),
                key: const Key('test-post-replies-destination'),
              ),
            ),
          );
        },
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
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
    List<ThreadFloorModel>? mainFloors,
    this.nextFloors,
  }) : detail = detail ?? _detail,
       mainFloors = mainFloors ?? [mainFloor ?? _mainFloor];

  final ApiFailure? threadFailure;
  final ApiFailure? floorFailure;
  final ApiFailure? loadMoreFailure;
  final ThreadPostTargetModel? postTarget;
  final ThreadDetailModel detail;
  final List<ThreadFloorModel> mainFloors;
  final List<ThreadFloorModel>? nextFloors;
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
    if (cursor != null) {
      return CursorPage(items: nextFloors ?? const [], hasMore: false);
    }
    if (cursor == null && floorFailure != null) {
      throw floorFailure!;
    }
    if (cursor == null && (loadMoreFailure != null || nextFloors != null)) {
      return CursorPage(
        items: subthreadId == 'subthread-1' ? mainFloors : [_sideFloor],
        cursor: 'next-cursor',
        hasMore: true,
      );
    }
    return CursorPage(
      items: subthreadId == 'subthread-1' ? mainFloors : [_sideFloor],
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

final _recentFixtureTime = DateTime.now().subtract(
  const Duration(days: 5, hours: 1),
);

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
  updatedAt: _recentFixtureTime,
);

ThreadDetailModel _detailWithTags(List<ThreadTagModel> tags) {
  return ThreadDetailModel(
    id: _detail.id,
    title: _detail.title,
    owner: _detail.owner,
    categorySlug: _detail.categorySlug,
    status: _detail.status,
    isPrivate: _detail.isPrivate,
    isPinned: _detail.isPinned,
    viewCount: _detail.viewCount,
    likeCount: _detail.likeCount,
    tipTotal: _detail.tipTotal,
    memberCount: _detail.memberCount,
    playerCount: _detail.playerCount,
    postCount: _detail.postCount,
    tags: tags,
    subthreads: _detail.subthreads,
    defaultSubthreadId: _detail.defaultSubthreadId,
    createdAt: _detail.createdAt,
    updatedAt: _detail.updatedAt,
  );
}

ThreadDetailModel _copyThreadDetail(
  ThreadDetailModel source, {
  required List<ThreadSubthreadModel> subthreads,
}) {
  return ThreadDetailModel(
    id: source.id,
    title: source.title,
    owner: source.owner,
    categorySlug: source.categorySlug,
    status: source.status,
    isPrivate: source.isPrivate,
    isPinned: source.isPinned,
    viewCount: source.viewCount,
    likeCount: source.likeCount,
    isLiked: source.isLiked,
    isBookmarked: source.isBookmarked,
    bookmarkId: source.bookmarkId,
    hasAutomaticUpdates: source.hasAutomaticUpdates,
    canManageThread: source.canManageThread,
    isCurrentUserPlayer: source.isCurrentUserPlayer,
    isCurrentUserOwner: source.isCurrentUserOwner,
    currentUserId: source.currentUserId,
    tipTotal: source.tipTotal,
    memberCount: source.memberCount,
    playerCount: source.playerCount,
    postCount: source.postCount,
    tags: source.tags,
    subthreads: subthreads,
    defaultSubthreadId: subthreads.firstOrNull?.id,
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
  );
}

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
  updatedAt: _recentFixtureTime,
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

class _CreatingPostRepository implements PostRepository {
  final List<PostCreateInput> createInputs = [];

  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    final createdAt = DateTime.utc(2026, 8, 10, 9);
    return PostItem(
      id: 'floor-created',
      threadId: 'thread-1',
      subthreadId: input.subthreadId,
      author: const PostAuthor(id: 'user-1', username: '温柔测试员', level: 3),
      content: input.content,
      version: 1,
      createdAt: createdAt,
      updatedAt: createdAt,
      isBody: false,
      isDeleted: false,
      floorNumber: 2,
      parentPostId: input.parentPostId,
      replyToPostId: input.replyToPostId,
    );
  }

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
  Future<void> remove(String postId) => throw UnsupportedError('unused');

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
  createdAt: _recentFixtureTime,
  isDeleted: false,
  replyCount: 1,
  replies: [
    ThreadReplyModel(
      id: 'reply-1',
      author: _author,
      body: const ThreadBodyModel(markdown: '收到，准备出发。'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyToUsername: '温柔测试员',
    ),
  ],
);

final _longMainFloor = ThreadFloorModel(
  id: 'floor-long',
  floorNumber: 1,
  author: _author,
  body: const ThreadBodyModel(
    markdown: '''第一层内容

舷窗外的群星缓慢后退。温柔测试员把航线重新标在纸图上，让后来者不必猜测故事从哪里继续。

引擎发出低沉而均匀的嗡鸣，甲板上的每个人都在等待下一位接力者写下选择。

远处的信标终于亮起，新的章节也在这一刻展开。''',
  ),
  createdAt: _recentFixtureTime,
  isDeleted: false,
  replyCount: 1,
  replies: [
    ThreadReplyModel(
      id: 'reply-long',
      author: _author,
      body: const ThreadBodyModel(markdown: '收到，准备出发。'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyToUsername: '温柔测试员',
    ),
  ],
);

final _longSecondFloor = ThreadFloorModel(
  id: 'floor-long-2',
  floorNumber: 2,
  author: const ThreadAuthorModel(id: 'user-2', username: '下一位接力者', level: 5),
  body: const ThreadBodyModel(
    markdown: '''第二层内容

舱门在身后合拢。下一位接力者没有解释来意，只把一页写满坐标的纸放在桌上。''',
  ),
  createdAt: _recentFixtureTime,
  isDeleted: false,
  replyCount: 2,
  replies: [
    ThreadReplyModel(
      id: 'reply-long-2',
      author: _author,
      body: const ThreadBodyModel(markdown: '这条讨论不应插进接力正文。'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyToUsername: '下一位接力者',
    ),
  ],
);

final _sideFloor = ThreadFloorModel(
  id: 'floor-2',
  floorNumber: 1,
  author: _author,
  body: const ThreadBodyModel(markdown: '支线楼层'),
  createdAt: _recentFixtureTime,
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final _paginatedFloor = ThreadFloorModel(
  id: 'floor-page',
  floorNumber: 2,
  author: _author,
  body: const ThreadBodyModel(markdown: '分页新增内容'),
  createdAt: _recentFixtureTime,
  isDeleted: false,
  replyCount: 0,
  replies: const [],
);

final _targetFloor = ThreadFloorModel(
  id: 'floor-target',
  floorNumber: 9,
  author: _author,
  body: const ThreadBodyModel(markdown: '目标楼层内容'),
  createdAt: _recentFixtureTime,
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_subthread_navigator.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageSubthreadNavigationCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('切换子贴同步替换正文与楼层', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository();
    await tester.pumpWidget(threadDetailPageTestDetailApp(repository));
    await tester.pumpAndSettle();

    final menu = find.byKey(const Key('thread-subthread-menu'));
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.text('主题目录'), findsNothing);
    expect(find.text('共 2 个子贴'), findsOneWidget);
    expect(find.text('8 楼'), findsWidgets);
    expect(find.text('4 楼'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    final selectedRow = find.descendant(
      of: find.byKey(const Key('thread-subthread-subthread-1')),
      matching: find.byType(WenyouSelectionRow),
    );
    expect(tester.widget<WenyouSelectionRow>(selectedRow).selected, isTrue);
    expect(
      tester.getTopLeft(selectedRow).dy,
      greaterThan(tester.getBottomLeft(menu).dy),
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

  for (final dark in [false, true]) {
    testWidgets('子贴长目录右侧常显滚动条并可滚动选择末项 $dark', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(dark ? 2 : 1)),
            child: child!,
          ),
          home: Scaffold(
            body: SafeArea(
              child: ThreadSubthreadNavigator(
                subthreads: [
                  for (var i = 0; i < 24; i++)
                    ThreadSubthreadModel(
                      id: 'chapter-$i',
                      title: '第 ${i + 1} 幕：星海旅途',
                      sortOrder: i,
                      postCount: i + 1,
                      postingPolicyLabel: '所有玩家',
                    ),
                ],
                selectedSubthreadId: 'chapter-0',
                onSelected: (value) => selected = value,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('thread-subthread-menu')));
      await tester.pumpAndSettle();
      final scrollbarFinder = find.byType(Scrollbar);
      expect(scrollbarFinder, findsOneWidget);
      final scrollbar = tester.widget<Scrollbar>(scrollbarFinder);
      expect(scrollbar.thumbVisibility, isTrue);
      expect(scrollbar.scrollbarOrientation, ScrollbarOrientation.right);
      expect(scrollbar.controller!.position.maxScrollExtent, greaterThan(0));
      await tester.pump(const Duration(seconds: 3));
      await expectLater(
        find.byType(Overlay).first,
        matchesGoldenFile(
          'goldens/thread_subthread_scrollbar_${dark ? 'dark_2x' : 'light'}.png',
        ),
      );
      await tester.drag(
        find.descendant(
          of: scrollbarFinder,
          matching: find.byType(SingleChildScrollView),
        ),
        const Offset(0, -280),
      );
      await tester.pumpAndSettle();
      expect(scrollbar.controller!.offset, greaterThan(0));
      final last = find.byKey(const Key('thread-subthread-chapter-23'));
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(selected, 'chapter-23');
      expect(find.byType(Scrollbar), findsNothing);
      await tester.tap(find.byKey(const Key('thread-subthread-menu')));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('360dp 子贴目录使用锚点菜单与轻量选中高亮', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
      ),
    );
    await tester.pumpAndSettle();
    final menu = find.byKey(const Key('thread-subthread-menu'));
    final capsule = find.byKey(const Key('thread-subthread-menu-capsule'));
    final title = find.descendant(of: capsule, matching: find.byType(Text));
    expect(tester.widget<Text>(title).textAlign, TextAlign.center);
    expect(tester.getCenter(title).dx, closeTo(tester.getCenter(menu).dx, 0.1));
    final closedDecoration = tester.widget<Container>(capsule).decoration;
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(tester.widget<Container>(capsule).decoration, closedDecoration);
    expect(find.text('主题目录'), findsNothing);

    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/thread_subthread_directory_360.png'),
    );
  });

  testWidgets('多子贴切换栏滚动后冻结并在切换时回到新正文开头', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      mainFloors: [
        threadDetailPageTestLongMainFloor,
        threadDetailPageTestLongSecondFloor,
      ],
    );
    await tester.pumpWidget(threadDetailPageTestDetailApp(repository));
    await tester.pumpAndSettle();

    final scrollView = find.byType(CustomScrollView);
    final stickyHeader = find.byKey(
      const Key('thread-subthread-sticky-header'),
    );
    final navigatorFrame = find.byKey(
      const Key('thread-subthread-navigator-frame'),
    );
    expect(tester.getSize(stickyHeader).height, closeTo(56, 0.1));
    expect(tester.getSize(navigatorFrame).width, closeTo(336, 0.1));
    expect(tester.getCenter(navigatorFrame).dx, closeTo(180, 0.1));
    expect(
      tester.getSize(find.byKey(const Key('thread-subthread-menu'))).width,
      closeTo(240, 0.1),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('thread-subthread-menu-capsule')))
          .height,
      closeTo(36, 0.1),
    );
    await tester.drag(scrollView, const Offset(0, -650));
    await tester.pumpAndSettle();

    final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    expect(tester.getTopLeft(stickyHeader).dy, closeTo(appBarBottom, 1));
    expect(tester.getSize(stickyHeader).height, closeTo(48, 0.1));
    expect(find.byKey(const Key('thread-subthread-menu')), findsOneWidget);
    final scrollController = tester
        .widget<CustomScrollView>(scrollView)
        .controller!;
    final previousOffset = scrollController.offset;

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(find.text('主线正文'), findsNothing);
    expect(repository.requestedSubthreads.last, 'subthread-2');
    expect(scrollController.offset, lessThan(previousOffset));
    expect(
      tester.getTopLeft(find.text('支线正文')).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(stickyHeader).dy),
    );
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 子贴导航填满内容行且浮标保持可操作', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouContentFrame(
              child: ThreadSubthreadNavigator(
                subthreads: threadDetailPageTestDetail.subthreads,
                selectedSubthreadId:
                    threadDetailPageTestDetail.subthreads.first.id,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frame = find.byKey(const Key('thread-subthread-navigator-frame'));
      final previous = find.byKey(const Key('thread-subthread-previous'));
      final next = find.byKey(const Key('thread-subthread-next'));
      final menu = find.byKey(const Key('thread-subthread-menu'));
      final context = tester.element(frame);
      final expectedWidth =
          width -
          wenyouHorizontalPagePadding(context, availableWidth: width) * 2;
      final previousWidth = tester.getSize(previous).width;
      final nextWidth = tester.getSize(next).width;

      expect(tester.takeException(), isNull);
      expect(tester.getSize(frame).width, closeTo(expectedWidth, 0.1));
      expect(tester.getCenter(frame).dx, closeTo(width / 2, 0.1));
      expect(previousWidth, greaterThanOrEqualTo(48));
      expect(nextWidth, greaterThanOrEqualTo(48));
      expect(
        tester.getSize(menu).width,
        closeTo(expectedWidth - previousWidth - nextWidth, 0.1),
      );
    });
  }

  testWidgets('360dp 两倍字号下冻结栏保持双行标题与 48dp 操作区', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final coordinator = ThreadDetailSubthreadScrollCoordinator();
    addTearDown(coordinator.dispose);
    const longTitle = '第一幕：穿过漫长星海之后所有玩家终于抵达共同约定的远方';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: CustomScrollView(
          controller: coordinator.controller,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ThreadDetailSubthreadHeaderSliver(
              subthreads: [
                const ThreadSubthreadModel(
                  id: 'subthread-1',
                  title: longTitle,
                  sortOrder: 1,
                  postCount: 8,
                  postingPolicyLabel: '参与者发言',
                  body: ThreadBodyModel(markdown: '主线正文'),
                ),
                threadDetailPageTestDetail.subthreads.last,
              ],
              selectedSubthreadId: 'subthread-1',
              onSelected: (_) async {},
              scrollCoordinator: coordinator,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final navigatorFrame = find.byKey(
      const Key('thread-subthread-navigator-frame'),
    );
    expect(tester.getSize(navigatorFrame).width, closeTo(336, 0.1));
    expect(tester.getCenter(navigatorFrame).dx, closeTo(180, 0.1));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.widget<Text>(find.text(longTitle)).maxLines, 2);
    expect(
      tester.getSize(find.byKey(const Key('thread-subthread-previous'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const Key('thread-subthread-sticky-header')))
          .dy,
      closeTo(0, 1),
    );
  });

  testWidgets('单子贴的目录栏随正文滚走而不冻结', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final detail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestDetail,
      subthreads: [threadDetailPageTestDetail.subthreads.first],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          detail: detail,
          mainFloors: [
            threadDetailPageTestLongMainFloor,
            threadDetailPageTestLongSecondFloor,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('thread-subthread-sticky-header')).hitTestable(),
      findsNothing,
    );
  });

  testWidgets('站内传送门的 subthread 坐标直接打开指定子贴', (tester) async {
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
        subthreadIdHint: 'subthread-2',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(find.text('主线正文'), findsNothing);
  });

  for (final targetKind in ['subthread']) {
    for (final surface
        in ThreadDetailPageTestSubthreadSelectionSurface.values) {
      testWidgets('$targetKind 入口定位后可通过 ${surface.label} 切换子贴', (tester) async {
        final repository = ThreadDetailPageTestFakeThreadDetailRepository(
          postTarget: targetKind == 'post'
              ? ThreadPostTargetModel(
                  requestedPostId: 'floor-target',
                  threadId: 'thread-1',
                  subthreadId: 'subthread-2',
                  floor: threadDetailPageTestTargetFloor,
                )
              : null,
        );
        await tester.pumpWidget(
          targetKind == 'post'
              ? threadDetailPageTestDetailRouterApp(
                  repository,
                  initialLocation: '/threads/thread-1?post=floor-target',
                )
              : threadDetailPageTestDetailApp(
                  repository,
                  subthreadIdHint: 'subthread-2',
                ),
        );
        await tester.pumpAndSettle();
        if (targetKind == 'post') {
          expect(find.text('目标楼层内容'), findsOneWidget);
        }
        expect(find.text('支线正文'), findsOneWidget);

        await threadDetailPageTestSelectMainSubthread(tester, surface);
        await tester.pumpAndSettle();

        expect(find.text('主线正文'), findsOneWidget);
        expect(find.text('支线正文'), findsNothing);
        expect(repository.requestedSubthreads.last, 'subthread-1');
      });
    }
  }

  testWidgets('入口目标已是当前子贴时仍直接显示聚焦楼层', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: threadDetailPageTestMainFloor,
      ),
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(repository, targetPostId: 'floor-1'),
    );
    await tester.pumpAndSettle();

    expect(find.text('第一层内容'), findsOneWidget);
    // 正文可保留在滚动缓存中，但定位后不能占据目标阅读视口。
    expect(find.text('主线正文').hitTestable(), findsNothing);
    expect(repository.requestedSubthreads, ['subthread-1']);
  });

  testWidgets('最新发言按钮位于搜索与更多之间并可重复定位主楼层', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      latestPost: threadDetailPageTestLatestFloorPost,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpWidget(threadDetailPageTestDetailRouterApp(repository));
    await tester.pumpAndSettle();

    final search = find.byKey(const Key('thread-detail-search'));
    final latest = find.byKey(const Key('thread-detail-latest'));
    final more = find.byKey(const Key('thread-detail-more'));
    expect(latest, findsOneWidget);
    expect(tester.getCenter(search).dx, lessThan(tester.getCenter(latest).dx));
    expect(tester.getCenter(latest).dx, lessThan(tester.getCenter(more).dx));

    await tester.tap(latest);
    await tester.pumpAndSettle();

    expect(repository.latestThreadIds, ['thread-1']);
    expect(repository.targetPostIds, ['floor-target']);
    expect(find.text('目标楼层内容'), findsOneWidget);
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);

    await tester.tap(find.byKey(const Key('thread-detail-latest')));
    await tester.pumpAndSettle();

    expect(repository.latestThreadIds, ['thread-1', 'thread-1']);
    expect(repository.targetPostIds, ['floor-target', 'floor-target']);
  });

  testWidgets('最新发言为楼中楼时直接进入父楼层讨论并聚焦回复', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      latestPost: ThreadLatestPostModel(
        id: 'reply-latest',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        parentPostId: 'floor-1',
        createdAt: threadDetailPageTestRecentFixtureTime,
      ),
    );
    await tester.pumpWidget(threadDetailPageTestDetailRouterApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-detail-latest')));
    await tester.pumpAndSettle();

    expect(find.text('thread-1/floor-1/reply-latest'), findsOneWidget);
    expect(repository.latestThreadIds, ['thread-1']);
    expect(repository.targetPostIds, isEmpty);
  });

  testWidgets('最新发言定位期间禁用重复请求', (tester) async {
    final completer = Completer<ThreadLatestPostModel>();
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      latestPostFuture: completer.future,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-2',
        floor: threadDetailPageTestTargetFloor,
      ),
    );
    await tester.pumpWidget(threadDetailPageTestDetailRouterApp(repository));
    await tester.pumpAndSettle();

    final latest = find.byKey(const Key('thread-detail-latest'));
    await tester.tap(latest);
    await tester.pump();
    final iconButton = tester.widget<IconButton>(
      find.descendant(of: latest, matching: find.byType(IconButton)),
    );
    expect(iconButton.onPressed, isNull);
    await tester.tap(latest);
    expect(repository.latestThreadIds, ['thread-1']);

    completer.complete(threadDetailPageTestLatestFloorPost);
    await tester.pumpAndSettle();
    expect(repository.latestThreadIds, ['thread-1']);
  });

  testWidgets('空主题禁用最新发言且删除竞态显示明确提示', (tester) async {
    final emptyRepository = ThreadDetailPageTestFakeThreadDetailRepository(
      detail: threadDetailPageTestCopyThreadDetail(
        threadDetailPageTestDetail,
        subthreads: threadDetailPageTestDetail.subthreads,
        postCount: 0,
      ),
      mainFloors: const [],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(emptyRepository),
    );
    await tester.pumpAndSettle();

    final emptyButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('thread-detail-latest')),
        matching: find.byType(IconButton),
      ),
    );
    expect(emptyButton.onPressed, isNull);

    final raceRepository = ThreadDetailPageTestFakeThreadDetailRepository(
      latestFailure: const ApiFailure(
        userMessage: '目标不存在',
        reason: FailureReason.notFound,
        businessCode: 40403,
      ),
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(raceRepository),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-latest')));
    await tester.pumpAndSettle();

    expect(find.text('当前主题还没有楼层或回复。'), findsOneWidget);
  });
}

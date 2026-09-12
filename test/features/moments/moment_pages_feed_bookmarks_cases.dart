import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_draft_store_ports.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import '../../support/deterministic_test_fonts.dart';
import 'moment_pages_test_support.dart';

void registerMomentPagesFeedBookmarksCases() {
  setUpAll(loadDeterministicTestFonts);
  for (final deleting in [false, true]) {
    testWidgets('动态${deleting ? '删除' : '保存'}成功后本机清理失败只重试清理', (tester) async {
      final repository = MomentPagesTestCleanupPageRepository();
      final store = MomentPagesTestFlakyDeleteStore();
      final router = GoRouter(
        initialLocation: '/moments',
        routes: [
          GoRoute(
            path: '/moments',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/edit'),
                child: const Text('进入编辑'),
              ),
            ),
          ),
          GoRoute(
            path: '/edit',
            builder: (_, _) => const MomentComposePage(momentId: 'moment-1'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentComposerOwnerResolverProvider.overrideWithValue(
              () async => 'user-1',
            ),
            momentDraftStoreProvider.overrideWithValue(store),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('进入编辑'));
      await tester.pumpAndSettle();
      if (deleting) {
        await tester.tap(find.byKey(const Key('moment-compose-delete')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('moment-compose-delete-confirm')),
        );
      } else {
        await tester.tap(find.byKey(const Key('moment-compose-submit')));
      }
      await tester.pumpAndSettle();
      expect(find.text('重试清理'), findsOneWidget);
      expect(find.text('草稿清理失败，请重试。'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('重试清理'));
      await tester.pumpAndSettle();
      expect(find.text('进入编辑'), findsOneWidget);
      expect(repository.updateCalls, deleting ? 0 : 1);
      expect(repository.removeCalls, deleting ? 1 : 0);
    });
  }

  testWidgets('发现信息流展示文本封面，游客左右滑动切换关注栏目', (tester) async {
    final repository = MomentPagesTestPageRepository();
    await tester.pumpWidget(momentPagesTestFeedApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('今日微光'), findsWidgets);
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    expect(find.byKey(const Key('moment-open-search')), findsOneWidget);
    expect(find.byKey(const Key('moment-open-bookmarks')), findsNothing);
    expect(repository.feedModes, [MomentFeedMode.discover]);

    await tester.drag(
      find.byKey(const Key('moment-feed-swipe')),
      const Offset(-100, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('登录后查看关注动态'), findsOneWidget);
    expect(find.textContaining('这里会按时间展示'), findsNothing);
    expect(repository.feedModes, [MomentFeedMode.discover]);

    await tester.drag(
      find.byKey(const Key('moment-feed-swipe')),
      const Offset(100, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    expect(repository.feedModes, [MomentFeedMode.discover]);
  });

  testWidgets('动态信息流通过滚动通知在接近底部时继续分页', (tester) async {
    final repository = MomentPagesTestPagingPageRepository();
    await tester.pumpWidget(momentPagesTestFeedApp(repository));
    await tester.pumpAndSettle();

    final scrollableFinder = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    final scrollable = tester.state<ScrollableState>(scrollableFinder);
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(repository.cursors, [null, 'next']);
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-card-moment-next')), findsOneWidget);
    expect(find.byKey(const Key('moment-feed-footer')), findsOneWidget);
    expect(find.text('已经看到这里了'), findsOneWidget);
    expect(tester.takeException(), isNull);

    scrollable.position.jumpTo(0);
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets('360dp 动态瀑布流反复滚动回收后仍保持双列和完整滚动范围', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      momentPagesTestFeedApp(MomentPagesTestWaterfallRegressionRepository()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final scrollableFinder = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    );
    final scrollable = tester.state<ScrollableState>(scrollableFinder);
    expect(
      scrollable.position.maxScrollExtent,
      greaterThan(scrollable.position.viewportDimension),
    );

    for (var cycle = 0; cycle < 3; cycle++) {
      await tester.scrollUntilVisible(
        find.byKey(const Key('moment-feed-footer')),
        500,
        scrollable: scrollableFinder,
        maxScrolls: 50,
      );
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pump();

      final lastCard = find.byKey(
        const Key('moment-card-waterfall-regression-23'),
      );
      final footer = find.byKey(const Key('moment-feed-footer'));
      expect(lastCard, findsOneWidget);
      expect(footer, findsOneWidget);
      expect(
        tester.getSize(footer).width,
        closeTo(tester.getSize(lastCard).width * 2 + 12, 0.1),
      );
      expect(tester.takeException(), isNull);

      scrollable.position.jumpTo(0);
      await tester.pump();

      final first = find.byKey(const Key('moment-card-waterfall-regression-0'));
      final second = find.byKey(
        const Key('moment-card-waterfall-regression-1'),
      );
      expect(
        tester.getTopLeft(first).dx,
        lessThan(tester.getTopLeft(second).dx),
      );
      expect(
        tester.getTopLeft(first).dy,
        closeTo(tester.getTopLeft(second).dy, 0.1),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();
      expect(scrollable.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('360dp 动态信息流使用双列瀑布布局并保留 48dp 点赞目标', (tester) async {
    expect(
      WenyouCollectionContract.mobileDomainLayoutExceptions['moments-feed'],
      'two-column-waterfall',
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      momentPagesTestFeedApp(MomentPagesTestPageRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('动态瀑布流'), findsOneWidget);
    expect(find.bySemanticsLabel('查看动态：今日微光'), findsOneWidget);
    expect(find.text('动态正文是纯文本'), findsNothing);
    expect(find.byKey(const Key('moment-bookmark-moment-1')), findsNothing);

    final first = find.byKey(const Key('moment-card-moment-1'));
    final second = find.byKey(const Key('moment-card-moment-2'));
    final third = find.byKey(const Key('moment-card-moment-3'));
    final firstTopLeft = tester.getTopLeft(first);
    final secondTopLeft = tester.getTopLeft(second);
    final thirdTopLeft = tester.getTopLeft(third);
    expect(firstTopLeft.dx, lessThan(secondTopLeft.dx));
    expect(thirdTopLeft.dx, closeTo(firstTopLeft.dx, 0.1));
    expect(thirdTopLeft.dy, greaterThan(firstTopLeft.dy));
    expect(thirdTopLeft.dy, closeTo(tester.getBottomRight(first).dy + 12, 0.1));

    final likeSize = tester.getSize(
      find.byKey(const Key('moment-like-moment-1')),
    );
    expect(likeSize.width, greaterThanOrEqualTo(48));
    expect(likeSize.height, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  testWidgets('动态首屏加载态使用双列瀑布骨架', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = MomentPagesTestPendingPageRepository();
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(momentPagesTestFeedApp(repository));
    await tester.pump();

    expect(find.bySemanticsLabel('正在加载动态'), findsNWidgets(4));
    final skeletons = find.bySemanticsLabel('正在加载动态');
    expect(
      tester.getTopLeft(skeletons.at(0)).dx,
      lessThan(tester.getTopLeft(skeletons.at(1)).dx),
    );

    repository.feed.complete(
      CursorPage(items: [momentPagesTestCard()], cursor: null, hasMore: false),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('360dp 动态瀑布流保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      momentPagesTestFeedApp(MomentPagesTestPageRepository()),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('moment-feed-visual')),
      matchesGoldenFile('goldens/moment_waterfall_360.png'),
    );
  });

  testWidgets('他人动态的紧凑加油项继续打开原有加油流程', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MomentPagesTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          MomentPagesTestFakeSessionRemote(),
        ),
        momentRepositoryProvider.overrideWithValue(
          MomentPagesTestPageRepository(),
        ),
        walletRepositoryProvider.overrideWithValue(
          MomentPagesTestMomentPageWalletRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(momentPagesTestTokensFor('viewer-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-detail-tip')));
    await tester.pumpAndSettle();
    expect(find.text('为温柔测试员加油'), findsOneWidget);
    expect(find.byKey(const Key('tip-amount-2')), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });

  testWidgets('动态详情直接切换评论顺序且不请求作者候选', (tester) async {
    final repository = MomentPagesTestPageRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-detail-report')), findsOneWidget);
    expect(find.text('动态正文是纯文本'), findsOneWidget);
    expect(find.text('主评论'), findsOneWidget);
    expect(
      find.byKey(const Key('moment-comment-card-comment-root')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('moment-comment-report-comment-root')),
      findsNothing,
    );
    expect(find.text('回复'), findsNothing);
    expect(find.text('倒序'), findsOneWidget);
    expect(find.byKey(const Key('moment-comments-order')), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-settings')), findsNothing);
    expect(find.text('只看作者'), findsNothing);
    expect(repository.commentOrders, [MomentCommentOrder.newest]);
    expect(repository.commentAuthorCalls, 0);
    expect(
      tester.getSize(find.byKey(const Key('moment-comments-order'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);
    expect(find.text('登录后发表评论'), findsOneWidget);
    expect(find.byKey(const Key('moment-detail-login')), findsNothing);

    await tester.tap(find.byKey(const Key('moment-comments-order')));
    await tester.pumpAndSettle();
    expect(find.text('正序'), findsOneWidget);
    expect(repository.commentOrders, [
      MomentCommentOrder.newest,
      MomentCommentOrder.oldest,
    ]);
    expect(repository.commentAuthorCalls, 0);

    final commentParagraph = tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == '主评论',
      ),
    );
    final commentGlyphCenter = commentParagraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 1, extentOffset: 2),
        )
        .first
        .toRect()
        .center;
    await tester.longPressAt(
      commentParagraph.localToGlobal(commentGlyphCenter),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('moment-comment-action-comment-root-report')),
      findsNothing,
    );
    await tester.tapAt(commentParagraph.localToGlobal(commentGlyphCenter));
    await tester.pump();

    final commentCard = find.byKey(
      const Key('moment-comment-card-comment-root'),
    );
    final commentRect = tester.getRect(commentCard);
    await tester.longPressAt(
      Offset(
        commentRect.right - 12,
        commentParagraph.localToGlobal(Offset.zero).dy +
            commentParagraph.preferredLineHeight / 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('moment-comment-action-comment-root-report')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('moment-comment-action-comment-root-reply')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();
  });

  testWidgets('动态首次收藏先选夹并只提交一次写入', (tester) async {
    final repository = MomentPagesTestPageRepository();
    final folderRepository = MomentPagesTestMomentFolderRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(MomentPagesTestMemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(
          MomentPagesTestFakeSessionRemote(),
        ),
        momentRepositoryProvider.overrideWithValue(repository),
        bookmarkFolderCatalogProvider.overrideWith(
          (ref, kind) => folderRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(momentPagesTestTokensFor('user-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-detail-bookmark')));
    await tester.pumpAndSettle();
    expect(find.text('收藏到收藏夹'), findsOneWidget);
    expect(find.text('1 条收藏'), findsOneWidget);
    expect(find.text('3 条收藏'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('bookmark-folder-picker-option-folder-later')),
    );
    await tester.tap(find.byKey(const Key('bookmark-folder-picker-confirm')));
    await tester.pumpAndSettle();

    expect(repository.bookmarkWrites, [
      (momentId: 'moment-1', active: true, folderId: 'folder-later'),
    ]);
    expect(repository.bookmarkMoves, isEmpty);
    expect(find.text('已收藏到“稍后阅读”。'), findsOneWidget);
  });

  testWidgets('canInteract false 时动态详情禁止新增收藏', (tester) async {
    final repository = MomentPagesTestPageRepository(
      detail: MomentDetail(
        card: momentPagesTestCard(canInteract: false),
        content: '动态正文是纯文本',
        images: const [],
        version: 3,
        canEdit: false,
        canDelete: false,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = tester.widget<WenyouInteractionToggle>(
      find.descendant(
        of: find.byKey(const Key('moment-detail-bookmark')),
        matching: find.byType(WenyouInteractionToggle),
      ),
    );
    expect(toggle.onPressed, isNull);
    expect(repository.bookmarkWrites, isEmpty);
  });
}

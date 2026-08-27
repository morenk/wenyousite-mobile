import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_composer_dock.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_draft_store.dart';
import 'package:wenyousite_mobile/features/moments/data/moment_repository.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_compose_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_page.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_feed_page.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => Directory.systemTemp.path,
        );
  });
  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  testWidgets('发现信息流展示文本封面，游客切到关注只发起登录引导', (tester) async {
    final repository = _PageRepository();
    await tester.pumpWidget(_feedApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('今日微光'), findsWidgets);
    expect(find.byKey(const Key('moment-card-moment-1')), findsOneWidget);
    expect(find.byKey(const Key('moment-open-search')), findsOneWidget);
    expect(find.byKey(const Key('moment-open-bookmarks')), findsNothing);
    expect(repository.feedModes, [MomentFeedMode.discover]);

    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();
    expect(find.text('登录后查看关注动态'), findsOneWidget);
    expect(find.textContaining('这里会按时间展示'), findsNothing);
    expect(repository.feedModes, [MomentFeedMode.discover]);
  });

  testWidgets('动态信息流通过滚动通知在接近底部时继续分页', (tester) async {
    final repository = _PagingPageRepository();
    await tester.pumpWidget(_feedApp(repository));
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

    await tester.pumpWidget(_feedApp(_WaterfallRegressionRepository()));
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

    await tester.pumpWidget(_feedApp(_PageRepository()));
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
    final repository = _PendingPageRepository();
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(_feedApp(repository));
    await tester.pump();

    expect(find.bySemanticsLabel('正在加载动态'), findsNWidgets(4));
    final skeletons = find.bySemanticsLabel('正在加载动态');
    expect(
      tester.getTopLeft(skeletons.at(0)).dx,
      lessThan(tester.getTopLeft(skeletons.at(1)).dx),
    );

    repository.feed.complete(
      CursorPage(items: [_card()], cursor: null, hasMore: false),
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

    await tester.pumpWidget(_feedApp(_PageRepository()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('moment-feed-visual')),
      matchesGoldenFile('goldens/moment_waterfall_360.png'),
    );
  });

  testWidgets('动态详情直接切换评论顺序且不请求作者候选', (tester) async {
    final repository = _PageRepository();
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
    final repository = _PageRepository();
    final folderRepository = _MomentFolderRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        momentRepositoryProvider.overrideWithValue(repository),
        bookmarkFolderCatalogProvider.overrideWith(
          (ref, kind) => folderRepository,
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
    final repository = _PageRepository(
      detail: MomentDetail(
        card: _card(canInteract: false),
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

  testWidgets('动态详情按来源返回且直接进入时回到动态列表', (tester) async {
    final router = GoRouter(
      initialLocation: '/moments/moment-1',
      routes: [
        GoRoute(
          path: '/moments',
          name: 'moments',
          builder: (_, _) => const Scaffold(
            body: Text('动态列表返回目标', key: Key('moment-back-target')),
          ),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              MomentDetailPage(momentId: state.pathParameters['momentId']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-detail-back')), findsOneWidget);
    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(find.byKey(const Key('moment-back-target')), findsOneWidget);

    unawaited(
      router.pushNamed(
        'moment-detail',
        pathParameters: const {'momentId': 'moment-1'},
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-detail-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-back-target')), findsOneWidget);
  });

  testWidgets('动态详情滚动时顶栏和评论入口保持固定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('动态').hitTestable(), findsOneWidget);
    await tester.drag(
      find.byKey(const PageStorageKey('moment-detail-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('动态').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);

    await tester.drag(
      find.byKey(const PageStorageKey('moment-detail-scroll')),
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();
    expect(find.text('动态').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-dock')), findsOneWidget);
  });

  testWidgets('动态评论入口悬浮首屏并从评论动作带入回复对象', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PageRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        momentRepositoryProvider.overrideWithValue(repository),
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
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dock = find.byKey(const Key('moment-comment-dock'));
    expect(dock, findsOneWidget);
    expect(find.text('发表评论…'), findsOneWidget);
    expect(tester.getBottomRight(dock).dy, lessThanOrEqualTo(760));

    await tester.tap(dock);
    await tester.pumpAndSettle();
    expect(find.byType(DraggableScrollableSheet), findsNothing);
    expect(find.byKey(const Key('moment-comment-dock')), findsNothing);
    expect(find.byKey(const Key('moment-comment-editor-dock')), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-close')), findsNothing);
    expect(find.byType(QuillEditor), findsOneWidget);
    expect(find.text('0/500'), findsNothing);
    final editorDock = find.byKey(const Key('moment-comment-editor-dock'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();
    final opaqueSurface = find
        .descendant(
          of: find.byType(WenyouInlineComposerDock),
          matching: find.byType(Material),
        )
        .first;
    expect(tester.getSize(opaqueSurface).height, lessThan(180));
    expect(
      tester.getSize(find.byKey(const Key('moment-comment-input'))).width,
      closeTo(tester.getSize(editorDock).width, 0.01),
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('moment-comment-input'))).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('moment-comment-image'))).dy,
      ),
    );
    final firstInsetFrameBottom = tester
        .getBottomRight(find.byKey(const Key('moment-comment-send')))
        .dy;
    expect(firstInsetFrameBottom, lessThanOrEqualTo(480));
    expect(
      find.descendant(of: editorDock, matching: find.byType(AnimatedPadding)),
      findsNothing,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      tester.getBottomRight(find.byKey(const Key('moment-comment-send'))).dy,
      firstInsetFrameBottom,
    );
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    const inviteUrl = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    _replaceAtomicEditor(tester, const Key('moment-comment-input'), inviteUrl);
    await tester.pump();
    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-comment-send')));
    await tester.pumpAndSettle();

    expect(repository.commentInputs, hasLength(1));
    expect(
      repository.commentInputs.single.content,
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
    expect(repository.commentInputs.single.replyToCommentId, isNull);
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);

    final rootCommentText = find.text('主评论');
    await tester.ensureVisible(rootCommentText);
    await tester.tap(rootCommentText);
    await tester.pumpAndSettle();
    expect(find.text('回复 @温柔测试员'), findsOneWidget);
    expect(find.byKey(const Key('moment-comment-input')), findsOneWidget);
    _replaceAtomicEditor(tester, const Key('moment-comment-input'), '暂时不发送的草稿');
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
    expect(find.text('放弃这条评论？'), findsNothing);

    await tester.ensureVisible(rootCommentText);
    await tester.tap(rootCommentText);
    await tester.pumpAndSettle();
    expect(
      _atomicEditorPlainText(tester, const Key('moment-comment-input')),
      '暂时不发送的草稿',
    );
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
  });

  testWidgets('360dp 键盘态动态评论输入 dock 保持整行输入视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final repository = _PageRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        momentRepositoryProvider.overrideWithValue(repository),
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
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-dock')));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();

    await expectLater(
      find.byKey(const Key('moment-comment-editor-dock')),
      matchesGoldenFile('goldens/moment_comment_composer_keyboard_360.png'),
    );
  });

  testWidgets('动态发布在单页展示图片区与正文且只保留底部主操作', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _PageRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = find.byKey(const Key('moment-compose-content'));
    final images = find.byKey(const Key('moment-compose-images'));
    final addImage = find.byKey(const Key('moment-compose-add-image'));
    final submit = find.byKey(const Key('moment-compose-submit'));
    expect(tester.getSize(content).height, greaterThan(300));
    expect(
      tester.getBottomRight(images).dy,
      lessThan(tester.getTopLeft(content).dy),
    );
    expect(tester.getSize(addImage).width, greaterThanOrEqualTo(48));
    expect(tester.getSize(addImage).height, greaterThanOrEqualTo(48));
    expect(tester.getBottomRight(submit).dy, lessThanOrEqualTo(760));
    expect(find.text('纯文本，不解析 Markdown'), findsNothing);
    expect(find.text('封面仅影响信息流展示'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('动态发布上传失败后复用原图重试并只加入一次', (tester) async {
    final gateway = _FailingThenSuccessfulUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(_FakeImagePicker()),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();

    expect(find.text('图片处理失败'), findsOneWidget);
    expect(find.text('问题编号：moment-upload-one'), findsOneWidget);
    expect(
      find.byKey(const Key('moment-compose-retry-upload')),
      findsOneWidget,
    );
    expect(find.text('取消上传'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-submit')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('moment-compose-retry-upload')));
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(2));
    expect(gateway.inputs[1], same(gateway.inputs[0]));
    expect(find.byKey(const ValueKey('moment-image')), findsOneWidget);
    expect(find.text('1/9'), findsOneWidget);
    expect(find.byKey(const Key('moment-compose-retry-upload')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('moment-compose-submit')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('动态发布多选图片后不经裁剪并按原顺序完成', (tester) async {
    final picker = _FakeMultiImagePicker();
    final gateway = _SuccessfulBatchUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(picker),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pumpAndSettle();

    expect(picker.lastLimit, 9);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(gateway.inputs, hasLength(3));
    expect(
      gateway.inputs.map((input) => input.purpose),
      everyElement(MediaUploadPurpose.moment),
    );
    expect(gateway.inputs.map((input) => input.filename), [
      'moment-0.png',
      'moment-1.png',
      'moment-2.png',
    ]);
    for (var index = 1; index <= 3; index++) {
      expect(find.byKey(ValueKey('moment-image-$index')), findsOneWidget);
    }
    expect(find.text('3/9'), findsOneWidget);
  });

  testWidgets('动态多选立即展示本地缩略图且后台最多同时处理两张', (tester) async {
    final gateway = _ControlledBatchUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(
            _FakeMultiImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pump();
    await tester.pump();

    expect(find.text('3/9'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('moment-local-thumbnail-0')),
      findsOneWidget,
    );
    expect(gateway.operations, hasLength(2));

    gateway.complete(0);
    await tester.pump();
    await tester.pump();
    expect(gateway.operations, hasLength(3));

    gateway.complete(1);
    gateway.complete(2);
    await tester.pumpAndSettle();
    expect(gateway.inputs.map((input) => input.filename), [
      'moment-0.png',
      'moment-1.png',
      'moment-2.png',
    ]);
    for (var index = 1; index <= 3; index++) {
      expect(find.byKey(ValueKey('moment-image-$index')), findsOneWidget);
    }
  });

  testWidgets('动态编辑新增图片同样不打开裁剪流程', (tester) async {
    final picker = _FakeMultiImagePicker();
    final gateway = _SuccessfulBatchUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            _PageRepository(detail: _editableDetail(title: '原动态', version: 3)),
          ),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(picker),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(gateway.inputs, hasLength(3));
    expect(
      gateway.inputs.map((input) => input.purpose),
      everyElement(MediaUploadPurpose.moment),
    );
  });

  testWidgets('动态评论上传中系统返回会取消任务并忽略迟到图片', (tester) async {
    final gateway = _LateCompletingUploadGateway();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        momentRepositoryProvider.overrideWithValue(_PageRepository()),
        editorImagePickerPortProvider.overrideWithValue(_FakeImagePicker()),
        mediaUploadGatewayPortProvider.overrideWithValue(gateway),
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
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-dock')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-comment-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(find.textContaining('正在上传'), findsOneWidget);
    expect(gateway.input?.purpose, MediaUploadPurpose.momentComment);
    await tester.binding.handlePopRoute();
    expect(gateway.operation.cancelled, isTrue);
    gateway.operation.complete(
      const UploadedEditorImage(
        mediaId: 'late-moment-image',
        url: 'https://cdn.example.com/late-moment.png',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moment-comment-input')), findsNothing);
    expect(find.byKey(const ValueKey('late-moment-image')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('动态详情多图使用固定舞台横滑并从当前图片进入原图', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final semantics = tester.ensureSemantics();
    final repository = _PageRepository(detail: _detailWithImages());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [momentRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentDetailPage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final gallery = find.byKey(const Key('moment-detail-gallery'));
    final carousel = find.byKey(const Key('moment-detail-carousel'));
    expect(gallery, findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('动态图片轮播，共 3 张，左右滑动切换')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(GridView)),
      findsNothing,
    );
    expect(
      find.descendant(of: gallery, matching: find.byType(PageView)),
      findsOneWidget,
    );
    expect(find.text('1 / 3'), findsOneWidget);
    final firstImage = tester.widget<WenyouCachedImage>(
      find.byKey(const Key('moment-content-image-0')),
    );
    expect(firstImage.imageUrl, 'https://cdn.example.com/1-md.webp');
    expect(firstImage.fit, BoxFit.contain);
    expect(
      tester.getBottomRight(find.text('今日微光')).dy,
      lessThan(tester.getTopLeft(gallery).dy),
    );
    expect(
      tester.getTopLeft(find.text('动态正文是纯文本')).dy,
      greaterThan(tester.getBottomRight(gallery).dy),
    );
    final initialStageSize = tester.getSize(gallery);
    expect(initialStageSize.width, 336);
    expect(initialStageSize.aspectRatio, closeTo(1, 0.01));

    await tester.drag(carousel, const Offset(-320, 0));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2 / 3'), findsOneWidget);
    expect(tester.getSize(gallery), initialStageSize);
    final secondImage = tester.widget<WenyouCachedImage>(
      find.byKey(const Key('moment-content-image-1')),
    );
    expect(secondImage.imageUrl, 'https://cdn.example.com/2-md.webp');
    expect(secondImage.fit, BoxFit.contain);

    await tester.tap(find.byKey(const Key('moment-detail-image')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('moment-gallery-close')), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('纯文字动态可完成发布且保留稳定详情目标', (tester) async {
    final repository = _PageRepository();
    final draftStore = _MemoryMomentDraftStore();
    final router = GoRouter(
      initialLocation: '/compose/moment',
      routes: [
        GoRoute(
          path: '/compose/moment',
          builder: (_, _) => const MomentComposePage(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              Scaffold(body: Text('动态=${state.pathParameters['momentId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '新的动态',
    );
    _replaceAtomicEditor(
      tester,
      const Key('moment-compose-content'),
      '纯文字也可以发布',
    );
    await tester.ensureVisible(find.byKey(const Key('moment-compose-submit')));
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(repository.createdInputs.single.mediaIds, isEmpty);
    expect(repository.createdInputs.single.title, '新的动态');
    expect(draftStore.draft, isNull);
    expect(find.text('动态=moment-1'), findsOneWidget);
  });

  testWidgets('动态邀请链接发布前成为可混排原子且保存规范正文', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final repository = _PageRepository();
    final router = GoRouter(
      initialLocation: '/compose/moment',
      routes: [
        GoRoute(
          path: '/compose/moment',
          builder: (_, _) => const MomentComposePage(),
        ),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) =>
              Scaffold(body: Text('动态=${state.pathParameters['momentId']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '私密入口',
    );
    _replaceAtomicEditor(tester, const Key('moment-compose-content'), url);
    await tester.pump();

    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('moment-compose-submit')));
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(
      repository.createdInputs.single.content,
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
    expect(find.text('动态=moment-1'), findsOneWidget);
  });

  testWidgets('动态草稿恢复文字与图片顺序并在离开前确认', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final draftStore = _MemoryMomentDraftStore()
      ..draft = MomentLocalDraft(
        title: '未完成的标题',
        content: '未完成的正文',
        images: const [
          UploadedEditorImage(
            mediaId: 'media-2',
            url: 'https://cdn.example.com/2.webp',
          ),
          UploadedEditorImage(
            mediaId: 'media-1',
            url: 'https://cdn.example.com/1.webp',
          ),
        ],
        coverMediaId: 'media-2',
        updatedAt: DateTime.utc(2026, 8, 11, 8),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已恢复上次的草稿'), findsOneWidget);
    expect(find.text('重新开始'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '未完成的标题',
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('media-2'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('media-1'))).dx),
    );
    final publish = find.byKey(const Key('moment-compose-submit'));
    expect(publish, findsOneWidget);
    expect(tester.getBottomRight(publish).dy, lessThanOrEqualTo(752));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('已恢复上次的草稿'), findsNothing);
    expect(find.text('重新开始'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '未完成的标题',
    );

    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '自动保存后的标题',
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(draftStore.draft?.title, '自动保存后的标题');
    expect(draftStore.draft?.images.map((image) => image.mediaId), [
      'media-2',
      'media-1',
    ]);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('要保存这次编辑吗？'), findsOneWidget);
    expect(find.text('保存草稿并退出'), findsOneWidget);
    expect(find.text('不保存'), findsOneWidget);
    expect(find.byKey(const Key('moment-leave-save')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('要保存这次编辑吗？'), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '自动保存后的标题',
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-leave-save')));
    await tester.pumpAndSettle();
    expect(draftStore.draft?.title, '自动保存后的标题');
  });

  testWidgets('取消失败的图片批次会保留已经上传完成的图片', (tester) async {
    final gateway = _FirstSuccessfulThenFailingUploadGateway();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
          editorImagePickerPortProvider.overrideWithValue(
            _FakeMultiImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('moment-compose-add-image')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(
      find.byKey(const ValueKey('moment-local-thumbnail-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('moment-compose-upload-failure')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('moment-compose-cancel-upload')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('moment-image-1')), findsOneWidget);
    expect(
      find.byKey(const Key('moment-compose-upload-failure')),
      findsNothing,
    );
    expect(find.text('1/9'), findsOneWidget);
  });

  testWidgets('动态图片可点按选封面、长按排序并在移除封面后自动回退', (tester) async {
    final semantics = tester.ensureSemantics();
    final draftStore = _MemoryMomentDraftStore()
      ..draft = MomentLocalDraft(
        title: '图片动态',
        content: '',
        images: const [
          UploadedEditorImage(
            mediaId: 'media-2',
            url: 'https://cdn.example.com/2.webp',
          ),
          UploadedEditorImage(
            mediaId: 'media-1',
            url: 'https://cdn.example.com/1.webp',
          ),
        ],
        coverMediaId: 'media-2',
        updatedAt: DateTime.utc(2026, 8, 11, 8),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('图片 2，点按设为封面')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('media-1')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('media-1')),
        matching: find.text('封面'),
      ),
      findsOneWidget,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('media-2'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(180, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('media-1'))).dx,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('media-2'))).dx),
    );

    await tester.tap(find.byTooltip('移除图片 1'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('media-1')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('media-2')),
        matching: find.text('封面'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('动态编辑冲突明确提供保留本机内容或使用最新内容', (tester) async {
    final repository = _ConflictPageRepository();
    final draftStore = _MemoryMomentDraftStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(repository),
          momentDraftStoreProvider.overrideWithValue(draftStore),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(momentId: 'moment-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('moment-compose-title')),
      '保留在本机的标题',
    );
    await tester.tap(find.byKey(const Key('moment-compose-submit')));
    await tester.pumpAndSettle();

    expect(find.text('这条动态刚刚更新了。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('moment-compose-resolve-conflict')));
    await tester.pumpAndSettle();
    expect(find.text('保留我的内容'), findsOneWidget);
    expect(find.text('使用最新内容'), findsOneWidget);

    await tester.tap(find.byKey(const Key('moment-conflict-use-latest')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('moment-compose-title')))
          .controller!
          .text,
      '服务端最新标题',
    );
    expect(draftStore.draft, isNull);
  });

  testWidgets('360dp 键盘态动态发布页保持主操作可见且语义明确', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MomentComposePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('标题（必填）')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('正文（选填）')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('moment-compose-submit'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('360dp 纯文字动态发布页保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(_PageRepository()),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('moment-compose-text-visual'),
            child: MomentComposePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('moment-compose-text-visual')),
      matchesGoldenFile('goldens/moment_compose_text_360.png'),
    );
  });

  testWidgets('360dp 多图动态编辑页保持 Foundation 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          momentRepositoryProvider.overrideWithValue(
            _PageRepository(detail: _editableDetailWithImages()),
          ),
          momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('moment-compose-images-visual'),
            child: MomentComposePage(momentId: 'moment-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getBottomRight(find.byKey(const Key('moment-compose-submit'))).dy,
      lessThanOrEqualTo(760),
    );
    await expectLater(
      find.byKey(const Key('moment-compose-images-visual')),
      matchesGoldenFile('goldens/moment_compose_images_360.png'),
    );
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 动态信息流、详情与发布页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _PageRepository();

      await tester.pumpWidget(_feedApp(repository));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentDraftStoreProvider.overrideWithValue(
              _MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentDetailPage(momentId: 'moment-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            momentRepositoryProvider.overrideWithValue(repository),
            momentDraftStoreProvider.overrideWithValue(
              _MemoryMomentDraftStore(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MomentComposePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _feedApp(MomentRepository repository) {
  return ProviderScope(
    overrides: [
      momentRepositoryProvider.overrideWithValue(repository),
      momentDraftStoreProvider.overrideWithValue(_MemoryMomentDraftStore()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const RepaintBoundary(
        key: Key('moment-feed-visual'),
        child: MomentFeedPage(),
      ),
    ),
  );
}

void _replaceAtomicEditor(WidgetTester tester, Key key, String value) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  final length = editor.controller.document.length - 1;
  editor.controller.replaceText(
    0,
    length,
    value,
    TextSelection.collapsed(offset: value.length),
  );
  editor.focusNode.requestFocus();
}

String _atomicEditorPlainText(WidgetTester tester, Key key) {
  final editor = tester.widget<QuillEditor>(find.byKey(key));
  return editor.controller.document.toPlainText().trimRight();
}

class _PageRepository extends Fake implements MomentRepository {
  _PageRepository({MomentDetail? detail}) : _detailValue = detail ?? _detail();

  final feedModes = <MomentFeedMode>[];
  final createdInputs = <MomentDraftInput>[];
  final commentInputs = <MomentCommentInput>[];
  final bookmarkMoves = <(String, String)>[];
  final bookmarkWrites = <({String momentId, bool active, String? folderId})>[];
  final commentOrders = <MomentCommentOrder>[];
  final MomentDetail _detailValue;
  var commentAuthorCalls = 0;

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(
      items: [
        _card(),
        _card(
          id: 'moment-2',
          title: '这是一个足够长并且会占据两行空间的动态标题',
          theme: MomentTextCoverTheme.rose,
        ),
        _card(
          id: 'moment-3',
          title: '第三条动态',
          theme: MomentTextCoverTheme.amber,
        ),
      ],
      cursor: null,
      hasMore: false,
    );
  }

  @override
  Future<MomentDetail> fetchDetail(String momentId) async => _detailValue;

  @override
  Future<MomentActionResult> setBookmark(
    String momentId, {
    required bool active,
    String? folderId,
  }) async {
    bookmarkWrites.add((
      momentId: momentId,
      active: active,
      folderId: folderId,
    ));
    return MomentActionResult(
      momentId: momentId,
      count: active ? 2 : 1,
      active: active,
    );
  }

  @override
  Future<void> moveBookmark(String momentId, String folderId) async {
    bookmarkMoves.add((momentId, folderId));
  }

  @override
  Future<CursorPage<MomentRootComment>> fetchComments({
    required String momentId,
    required MomentCommentOrder order,
    String? authorId,
    String? cursor,
    int limit = 20,
  }) async {
    commentOrders.add(order);
    return CursorPage(items: [_rootComment()], cursor: null, hasMore: false);
  }

  @override
  Future<List<MomentAuthor>> fetchCommentAuthors(String momentId) async {
    commentAuthorCalls += 1;
    return [_author()];
  }

  @override
  Future<MomentComment> createComment(
    String momentId,
    MomentCommentInput input, {
    required String clientRequestId,
  }) async {
    commentInputs.add(input);
    return MomentComment(
      id: 'comment-created',
      momentId: momentId,
      author: _author(),
      content: input.content,
      parentCommentId: input.replyToCommentId == null ? null : 'comment-root',
      deleted: false,
      canDelete: true,
      createdAt: DateTime.utc(2026, 8, 10, 14),
    );
  }

  @override
  Future<MomentDetail> create(
    MomentDraftInput input, {
    required String clientRequestId,
  }) async {
    createdInputs.add(input.normalized());
    return _detail();
  }
}

class _MomentFolderRepository extends Fake implements BookmarkFolderCatalog {
  @override
  Future<List<BookmarkFolderItem>> fetchFolders() async => [
    BookmarkFolderItem(
      id: 'folder-default',
      name: '默认收藏夹',
      isDefault: true,
      bookmarkCount: 1,
      createdAt: DateTime.utc(2026, 8, 19),
    ),
    BookmarkFolderItem(
      id: 'folder-later',
      name: '稍后阅读',
      isDefault: false,
      bookmarkCount: 3,
      createdAt: DateTime.utc(2026, 8, 19),
    ),
  ];
}

class _PendingPageRepository extends _PageRepository {
  final feed = Completer<CursorPage<MomentCard>>();

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) {
    feedModes.add(mode);
    return feed.future;
  }
}

class _PagingPageRepository extends _PageRepository {
  final cursors = <String?>[];

  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    cursors.add(cursor);
    if (cursor == 'next') {
      return CursorPage(
        items: [_card(id: 'moment-next', title: '分页动态')],
        hasMore: false,
      );
    }
    return CursorPage(
      items: [
        for (var index = 0; index < 30; index++)
          _card(id: 'moment-$index', title: '动态 $index'),
      ],
      cursor: 'next',
      hasMore: true,
    );
  }
}

class _WaterfallRegressionRepository extends _PageRepository {
  @override
  Future<CursorPage<MomentCard>> fetchFeed({
    required MomentFeedMode mode,
    String? cursor,
    int limit = 20,
  }) async {
    feedModes.add(mode);
    return CursorPage(
      items: [
        for (var index = 0; index < 24; index++)
          _card(
            id: 'waterfall-regression-$index',
            title: index.isEven
                ? '动态 $index'
                : '这是第 $index 条用于验证双列滚动稳定性的较长动态标题',
            coverMedia: switch (index % 3) {
              0 => _waterfallMedia(index, width: 900, height: 1600),
              1 => _waterfallMedia(index, width: 1600, height: 900),
              _ => null,
            },
            imageCount: index % 3 == 2 ? 0 : 1,
          ),
      ],
      hasMore: false,
    );
  }
}

MomentMedia _waterfallMedia(
  int index, {
  required int width,
  required int height,
}) {
  return MomentMedia(
    id: 'waterfall-image-$index',
    url: 'https://cdn.example.com/waterfall-feed.webp',
    width: width,
    height: height,
  );
}

class _ConflictPageRepository extends _PageRepository {
  _ConflictPageRepository()
    : super(detail: _editableDetail(title: '原来的标题', version: 3));

  var fetchCalls = 0;

  @override
  Future<MomentDetail> fetchDetail(String momentId) async {
    fetchCalls += 1;
    return fetchCalls == 1
        ? _editableDetail(title: '原来的标题', version: 3)
        : _editableDetail(title: '服务端最新标题', version: 4);
  }

  @override
  Future<MomentDetail> update(
    String momentId,
    MomentDraftInput input, {
    required int version,
  }) async {
    throw const ApiFailure(businessCode: 40002, userMessage: '这条动态刚刚更新了。');
  }
}

class _MemoryMomentDraftStore implements MomentDraftStore {
  MomentLocalDraft? draft;

  @override
  Future<void> delete(String? momentId) async => draft = null;

  @override
  Future<MomentLocalDraft?> read(String? momentId) async => draft;

  @override
  Future<void> write(String? momentId, MomentLocalDraft value) async {
    draft = value;
  }
}

class _FakeImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'moment.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class _FakeMultiImagePicker
    implements EditorImagePicker, MultiEditorImagePicker {
  int? lastLimit;

  @override
  Future<MediaUploadInput?> pickFromGallery() async => null;

  @override
  Future<List<MediaUploadInput>> pickManyFromGallery({
    required int limit,
  }) async {
    lastLimit = limit;
    return [
      for (var index = 0; index < 3; index++)
        MediaUploadInput(
          filename: 'moment-$index.png',
          declaredContentType: 'image/png',
          bytes: Uint8List.fromList([index + 1]),
        ),
    ];
  }
}

class _SuccessfulBatchUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    return _ImmediateUploadOperation(
      Future.value(
        UploadedEditorImage(
          mediaId: 'moment-image-${inputs.length}',
          url: 'https://cdn.example.com/moment-${inputs.length}.png',
        ),
      ),
    );
  }
}

class _ControlledBatchUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];
  final operations = <Completer<UploadedEditorImage>>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    final completion = Completer<UploadedEditorImage>();
    operations.add(completion);
    return _ImmediateUploadOperation(completion.future);
  }

  void complete(int index) {
    operations[index].complete(
      UploadedEditorImage(
        mediaId: 'moment-image-${index + 1}',
        url: 'https://cdn.example.com/moment-${index + 1}.png',
      ),
    );
  }
}

class _FailingThenSuccessfulUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    if (inputs.length == 1) {
      return _ImmediateUploadOperation(
        Future<UploadedEditorImage>.error(
          const ApiFailure(
            userMessage: '图片处理失败',
            requestId: 'moment-upload-one',
          ),
        ),
      );
    }
    return _ImmediateUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'moment-image',
          url: 'https://cdn.example.com/moment.png',
        ),
      ),
    );
  }
}

class _FirstSuccessfulThenFailingUploadGateway implements MediaUploadGateway {
  var calls = 0;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    calls += 1;
    if (calls == 1) {
      return _ImmediateUploadOperation(
        Future.value(
          const UploadedEditorImage(
            mediaId: 'moment-image-1',
            url: 'https://cdn.example.com/moment-1.png',
          ),
        ),
      );
    }
    return _ImmediateUploadOperation(
      Future<UploadedEditorImage>.error(
        const ApiFailure(userMessage: '第二张图片上传失败'),
      ),
    );
  }
}

class _ImmediateUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _ImmediateUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

class _LateCompletingUploadGateway implements MediaUploadGateway {
  final operation = _LateCompletingUploadOperation();
  MediaUploadInput? input;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    this.input = input;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class _LateCompletingUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final _completer = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _completer.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) => _completer.complete(image);
}

MomentAuthor _author() =>
    const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 4);

MomentCard _card({
  String id = 'moment-1',
  String title = '今日微光',
  MomentTextCoverTheme theme = MomentTextCoverTheme.mint,
  MomentMedia? coverMedia,
  int imageCount = 0,
  bool canInteract = true,
}) {
  final now = DateTime.utc(2026, 8, 10, 12);
  return MomentCard(
    id: id,
    author: _author(),
    title: title,
    contentExcerpt: '动态正文是纯文本',
    coverType: coverMedia == null
        ? MomentCoverType.text
        : MomentCoverType.image,
    textCoverTheme: theme,
    coverMedia: coverMedia,
    imageCount: imageCount,
    likeCount: 2,
    commentCount: 1,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    canInteract: canInteract,
    createdAt: now,
    updatedAt: now,
  );
}

MomentDetail _detail() => MomentDetail(
  card: _card(),
  content: '动态正文是纯文本',
  images: const [],
  version: 3,
  canEdit: false,
  canDelete: false,
);

MomentDetail _detailWithImages() {
  const images = [
    MomentMedia(
      id: 'image-1',
      url: 'https://cdn.example.com/1.webp',
      mediumUrl: 'https://cdn.example.com/1-md.webp',
      width: 1200,
      height: 1600,
    ),
    MomentMedia(
      id: 'image-2',
      url: 'https://cdn.example.com/2.webp',
      mediumUrl: 'https://cdn.example.com/2-md.webp',
      width: 1600,
      height: 1000,
    ),
    MomentMedia(
      id: 'image-3',
      url: 'https://cdn.example.com/3.webp',
      mediumUrl: 'https://cdn.example.com/3-md.webp',
      width: 1000,
      height: 1000,
    ),
  ];
  return MomentDetail(
    card: _card(coverMedia: images[2], imageCount: images.length),
    content: '动态正文是纯文本',
    images: images,
    version: 3,
    canEdit: false,
    canDelete: false,
  );
}

MomentDetail _editableDetail({required String title, required int version}) =>
    MomentDetail(
      card: _card(title: title),
      content: '这是可以继续编辑的正文',
      images: const [],
      version: version,
      canEdit: true,
      canDelete: true,
    );

MomentDetail _editableDetailWithImages() {
  final detail = _detailWithImages();
  return MomentDetail(
    card: detail.card,
    content: '带着图片继续分享此刻。',
    images: detail.images,
    version: detail.version,
    canEdit: true,
    canDelete: true,
  );
}

MomentRootComment _rootComment() => MomentRootComment(
  id: 'comment-root',
  momentId: 'moment-1',
  author: _author(),
  content: '主评论',
  deleted: false,
  canDelete: false,
  createdAt: DateTime.utc(2026, 8, 10, 13),
  replyCount: 0,
  replies: const [],
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
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokensFor('user-1');
}

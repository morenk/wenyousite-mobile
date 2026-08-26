import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/home/presentation/home_page.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('公开主题详情连续展示正文且短楼中楼保留独立讨论入口', (tester) async {
    DebugDiagnosticBuffer.instance.clear();
    final repository = _FakeThreadDetailRepository();
    await tester.pumpWidget(
      _detailRouterApp(repository, enableRenderDiagnostics: true),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    final geometryDiagnostics = DebugDiagnosticBuffer.instance.exportText();
    expect(geometryDiagnostics, contains('thread_render_geometry'));
    expect(geometryDiagnostics, contains('after_2500ms'));
    expect(geometryDiagnostics, contains('"markdown"'));
    expect(geometryDiagnostics, contains('visibleFraction'));
    expect(find.text('星海旅团'), findsOneWidget);
    expect(find.text('#太空歌剧'), findsOneWidget);
    final tag = find.byKey(const Key('thread-detail-tag-tag-1'));
    expect(tag, findsOneWidget);
    expect(
      find.descendant(of: tag, matching: find.byType(InputChip)),
      findsNothing,
    );
    expect(
      find.descendant(of: tag, matching: find.byType(OutlinedButton)),
      findsNothing,
    );
    expect(
      find.descendant(of: tag, matching: find.byType(TextButton)),
      findsOneWidget,
    );
    expect(tester.getSize(tag).height, greaterThanOrEqualTo(48));
    await tester.tap(tag);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('test-tag-destination')), findsOneWidget);
    expect(find.text('tag-1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('test-tag-back')));
    await tester.pumpAndSettle();
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
    expect(find.text('登录后发表'), findsOneWidget);
    expect(find.text('角色扮演'), findsNothing);
    expect(find.text('招募中'), findsNothing);
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
    final navigatorCenters = [
      const Key('thread-subthread-previous'),
      const Key('thread-subthread-menu'),
      const Key('thread-subthread-next'),
    ].map((key) => tester.getCenter(find.byKey(key)).dy).toList();
    expect(
      navigatorCenters.every(
        (center) => (center - navigatorCenters.first).abs() < 1,
      ),
      isTrue,
    );
    expect(find.byKey(const Key('thread-detail-bottom-bar')), findsOneWidget);
    expect(
      tester.getCenter(find.byKey(const Key('thread-interaction-like'))).dy,
      greaterThan(navigatorCenters.first),
    );
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
      lessThan(140),
    );
    expect(find.text('参与者发言'), findsNothing);
    expect(find.text('8 条内容'), findsNothing);
    expect(find.text('12 楼层'), findsNothing);
    expect(find.byKey(const Key('thread-floor-controls')), findsOneWidget);
    expect(find.byKey(const Key('thread-floors-count')), findsOneWidget);
    expect(find.text('8 层'), findsOneWidget);
    expect(find.byKey(const Key('thread-floors-author')), findsOneWidget);
    expect(find.byKey(const Key('thread-floors-order')), findsOneWidget);
    expect(find.byKey(const Key('thread-floors-settings')), findsNothing);
    expect(find.text('楼层'), findsNothing);
    expect(find.text('最早在前'), findsOneWidget);
    expect(find.text('最新在前'), findsNothing);
    final bodyBottom = tester
        .getBottomLeft(find.byType(ThreadSubthreadBody))
        .dy;
    final controlsTop = tester
        .getTopLeft(find.byKey(const Key('thread-floor-controls')))
        .dy;
    expect(controlsTop - bodyBottom, closeTo(12, 0.1));
    await tester.tap(find.byKey(const Key('thread-floors-order')));
    await tester.pumpAndSettle();
    expect(repository.requestedOrders.last, ThreadFloorOrder.newest);
    expect(find.text('最新在前'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-floors-order')));
    await tester.pumpAndSettle();
    expect(repository.requestedOrders.last, ThreadFloorOrder.oldest);
    expect(find.text('128 浏览 · 2 玩家 · 12 楼 · 8 升温油'), findsNothing);
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
    const bodyDiceId = '550e8400-e29b-41d4-a716-446655440000';
    await tester.tap(find.byKey(const ValueKey('wenyou-dice-$bodyDiceId')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('wenyou-dice-detail-sheet')), findsOneWidget);
    expect(find.bySemanticsLabel('第 1 枚，16 点'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wenyou-dice-detail-close')));
    await tester.pumpAndSettle();
    await tester.longPress(
      find.byKey(const ValueKey('wenyou-dice-$bodyDiceId')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-copy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-link')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-edit')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-reply')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();
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
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('thread-floor-actions-floor-1')), findsNothing);
    expect(
      find.byKey(const Key('thread-floor-number-floor-1')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('thread-floor-report-floor-1')), findsNothing);
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(
      find.byKey(const Key('thread-floor-reply-floor-1-reply-1')),
      findsOneWidget,
    );
    final replyMarkdown = find.descendant(
      of: find.byKey(const Key('thread-floor-reply-floor-1-reply-1')),
      matching: find.byType(WenyouMarkdown),
    );
    expect(replyMarkdown, findsOneWidget);
    for (final markdown in tester.widgetList<WenyouMarkdown>(replyMarkdown)) {
      expect(markdown.bodyFontSize, 17);
      expect(markdown.bodyHeight, 1.8);
    }
    expect(
      find.byKey(const Key('thread-floor-reply-preview-collapsed-floor-1')),
      findsNothing,
    );
    expect(find.byKey(const Key('thread-reply-level-reply-1')), findsNothing);
    expect(
      find.byKey(const Key('thread-floor-discussion-floor-1')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-1')),
      findsOneWidget,
    );
    expect(find.text('展开楼中楼（1 条）'), findsOneWidget);

    final floorAvatar = find.byKey(
      const Key('thread-floor-author-avatar-floor-1'),
    );
    expect(tester.getSize(floorAvatar).height, greaterThanOrEqualTo(48));
    await tester.tap(floorAvatar);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('test-user-destination')), findsOneWidget);
    expect(find.text('user-1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('test-user-back')));
    await tester.pumpAndSettle();

    final replyAvatar = find.byKey(
      const Key('thread-floor-reply-author-avatar-reply-1'),
    );
    await tester.ensureVisible(replyAvatar);
    await tester.tap(replyAvatar);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('test-user-destination')), findsOneWidget);
    await tester.tap(find.byKey(const Key('test-user-back')));
    await tester.pumpAndSettle();

    final floorParagraph = tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == '第一层内容',
      ),
    );
    final floorCardRect = tester.getRect(
      find.byKey(const Key('thread-floor-card-floor-1')),
    );
    await tester.longPressAt(
      Offset(
        floorCardRect.right - 12,
        floorParagraph.localToGlobal(Offset.zero).dy +
            floorParagraph.preferredLineHeight / 2,
      ),
    );
    await tester.pumpAndSettle();
    final modalMenu = find.byKey(const Key('wenyou-modal-action-menu'));
    expect(modalMenu, findsOneWidget);
    expect(tester.getCenter(modalMenu), const Offset(400, 300));
    expect(
      tester
          .widgetList<ModalBarrier>(find.byType(ModalBarrier))
          .any((barrier) => (barrier.color?.a ?? 0) > 0),
      isTrue,
    );
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-link')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-reply')),
      findsNothing,
    );
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsNothing,
    );
  });

  testWidgets('用户构建关闭帖子现场诊断后不采集渲染事件或几何', (tester) async {
    DebugDiagnosticBuffer.instance.clear();
    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(), enableRenderDiagnostics: false),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('星海旅团'), findsOneWidget);
    expect(DebugDiagnosticBuffer.instance.exportText(), contains('暂无诊断记录。'));
  });

  testWidgets('举报入口对楼主、私密主题、本人楼层和已删除楼层安全隐藏', (tester) async {
    final ownerDetail = _copyThreadDetail(
      _managerDetail,
      subthreads: _managerDetail.subthreads,
      isCurrentUserOwner: true,
      currentUserId: 'user-1',
    );
    await tester.pumpWidget(
      await _authenticatedDetailApp(
        _FakeThreadDetailRepository(detail: ownerDetail),
        userId: 'user-1',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-report')), findsNothing);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    const ownFloorAuthor = ThreadAuthorModel(
      id: 'collaborator-1',
      username: '协作者',
      level: 4,
    );
    final ownFloor = ThreadFloorModel(
      id: 'floor-own',
      floorNumber: 1,
      author: ownFloorAuthor,
      body: const ThreadBodyModel(markdown: '本人楼层'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      await _authenticatedDetailApp(
        _FakeThreadDetailRepository(
          detail: _managerDetail,
          mainFloors: [ownFloor],
        ),
        userId: 'collaborator-1',
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('thread-floor-card-floor-own')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-own')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-own-report')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    final privateDetail = _copyThreadDetail(
      _managerDetail,
      subthreads: _managerDetail.subthreads,
      isPrivate: true,
      currentUserId: 'collaborator-1',
    );
    await tester.pumpWidget(
      await _authenticatedDetailApp(
        _FakeThreadDetailRepository(detail: privateDetail),
        userId: 'collaborator-1',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-report')), findsNothing);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('thread-floor-card-floor-1')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-report')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    final deletedFloor = ThreadFloorModel(
      id: 'floor-deleted',
      floorNumber: 2,
      author: _playerAuthor,
      body: const ThreadBodyModel(markdown: '已删除楼层'),
      createdAt: _recentFixtureTime,
      isDeleted: true,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(mainFloors: [deletedFloor])),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('thread-floor-card-floor-deleted')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-deleted')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-deleted-report')),
      findsNothing,
    );
  });

  testWidgets('主楼排序和发言者直接生效，筛选空态可恢复全部楼层', (tester) async {
    final repository = _FakeThreadDetailRepository();
    final authorDirectory = _MutablePostDiscussionAuthorDirectory();
    await tester.pumpWidget(
      _detailApp(repository, authorDirectory: authorDirectory),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedSubthreads, ['subthread-1']);
    await tester.tap(find.byKey(const Key('thread-floors-order')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floors-author')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一位接力者').last);
    await tester.pumpAndSettle();

    expect(repository.requestedSubthreads, [
      'subthread-1',
      'subthread-1',
      'subthread-1',
    ]);
    expect(repository.requestedOrders.last, ThreadFloorOrder.newest);
    expect(repository.requestedAuthors.last, 'user-2');
    expect(find.text('最新在前'), findsOneWidget);
    expect(find.text('下一位接力者'), findsOneWidget);
    expect(find.text('没有符合条件的楼层'), findsOneWidget);
    expect(find.text('查看全部楼层'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('thread-floors-clear-author')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floors-clear-author')));
    await tester.pumpAndSettle();

    expect(repository.requestedAuthors.last, isNull);
    expect(repository.requestedOrders.last, ThreadFloorOrder.newest);
    expect(find.text('第一层内容'), findsOneWidget);
    expect(find.text('没有符合条件的楼层'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('thread-floors-author')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floors-author')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('下一位接力者').last);
    await tester.pumpAndSettle();
    authorDirectory.floorAuthors = const [];
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ThreadDetailPage)),
    );
    container.invalidate(postFloorDiscussionAuthorsProvider('subthread-1'));
    await tester.pumpAndSettle();

    expect(repository.requestedAuthors.last, isNull);
    expect(find.text('第一层内容'), findsOneWidget);
    expect(find.text('暂无可筛选作者'), findsOneWidget);
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
    expect(find.text('主题详情'), findsNothing);
  });

  testWidgets('楼中楼最多预览前三条并提供独立讨论入口', (tester) async {
    final replies = [
      for (var index = 1; index <= 6; index++)
        ThreadReplyModel(
          id: 'preview-$index',
          author: _author,
          body: ThreadBodyModel(markdown: '第 $index 条简短回复'),
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
      _detailRouterApp(_FakeThreadDetailRepository(mainFloor: floor)),
    );
    await tester.pumpAndSettle();

    final previewGroup = find.byKey(
      const Key('thread-floor-reply-preview-floor-preview'),
    );
    await tester.scrollUntilVisible(
      previewGroup,
      180,
      scrollable: find.byType(Scrollable).first,
    );

    expect(previewGroup, findsOneWidget);
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-preview')),
      findsOneWidget,
    );
    for (var index = 1; index <= 3; index++) {
      expect(
        find.byKey(Key('thread-floor-reply-floor-preview-preview-$index')),
        findsOneWidget,
      );
    }
    for (var index = 4; index <= 6; index++) {
      expect(
        find.byKey(Key('thread-floor-reply-floor-preview-preview-$index')),
        findsNothing,
      );
    }
    final expand = find.byKey(
      const Key('thread-floor-reply-preview-expand-floor-preview'),
    );
    await tester.ensureVisible(expand);
    await tester.pumpAndSettle();
    await tester.tap(expand);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsOneWidget,
    );
    expect(find.text('thread-1/floor-preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('单条超高楼中楼完整展示且仍可进入独立讨论', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final reply = ThreadReplyModel(
      id: 'preview-tall',
      author: _author,
      body: ThreadBodyModel(
        markdown: List.filled(14, '这是一段用于验证真实排版高度的楼中楼回复。').join('\n\n'),
      ),
      createdAt: DateTime.utc(2026, 8, 9, 12, 21),
      isDeleted: false,
    );
    final floor = ThreadFloorModel(
      id: 'floor-tall-preview',
      floorNumber: 1,
      author: _author,
      body: const ThreadBodyModel(markdown: '带有超高讨论的楼层'),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: 1,
      replies: [reply],
    );
    await tester.pumpWidget(
      _detailRouterApp(_FakeThreadDetailRepository(mainFloor: floor)),
    );
    await tester.pumpAndSettle();

    final collapsed = find.byKey(
      const Key('thread-floor-reply-preview-collapsed-floor-tall-preview'),
    );
    final replyPreview = find.byKey(
      const Key('thread-floor-reply-floor-tall-preview-preview-tall'),
    );
    final expand = find.byKey(
      const Key('thread-floor-reply-preview-expand-floor-tall-preview'),
    );
    await tester.scrollUntilVisible(
      replyPreview,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(expand);
    await tester.pumpAndSettle();

    expect(collapsed, findsNothing);
    expect(tester.getSize(replyPreview).height, greaterThan(320));
    expect(expand, findsOneWidget);
    await tester.tap(expand);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test-post-replies-destination')),
      findsOneWidget,
    );
    expect(find.text('thread-1/floor-tall-preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('相邻楼层使用结构线且楼中楼形成明确层级缩进', (tester) async {
    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(mainFloors: [_mainFloor, _longSecondFloor]),
      ),
    );
    await tester.pumpAndSettle();

    final floor = find.byKey(const Key('thread-floor-card-floor-1'));
    final reply = find.byKey(const Key('thread-floor-reply-floor-1-reply-1'));
    await tester.scrollUntilVisible(
      reply,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.getTopLeft(reply).dx - tester.getTopLeft(floor).dx,
      greaterThanOrEqualTo(24),
    );

    final floorDivider = find.byKey(
      const ValueKey('thread-floor-divider-floor-long-2'),
    );
    await tester.scrollUntilVisible(
      floorDivider,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    final divider = tester.widget<Divider>(
      find.descendant(of: floorDivider, matching: find.byType(Divider)),
    );
    expect(divider.thickness, 1);
    expect(divider.height, 24);
    expect(tester.takeException(), isNull);
  });

  testWidgets('楼层正文按真实视口高度折叠且展开后可从正文区域滚动', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final floor = ThreadFloorModel(
      id: 'floor-tall-body',
      floorNumber: 1,
      author: _author,
      body: ThreadBodyModel(
        markdown: List.filled(36, '这是用于验证楼层正文真实布局高度的一段文字。').join('\n\n'),
      ),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(mainFloor: floor)),
    );
    await tester.pumpAndSettle();

    final collapsed = find.byKey(
      const Key('thread-floor-body-collapsed-floor-tall-body'),
    );
    final toggle = find.byKey(
      const Key('thread-floor-body-toggle-floor-tall-body'),
    );
    await tester.scrollUntilVisible(
      toggle,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(collapsed, findsOneWidget);
    expect(tester.getSize(collapsed).height, 640);
    expect(find.text('展开全文'), findsOneWidget);

    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(collapsed, findsNothing);
    expect(find.text('收起'), findsOneWidget);

    final scrollController = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    final offsetBeforeBodyDrag = scrollController.offset;
    final visibleBodyText = find.text('这是用于验证楼层正文真实布局高度的一段文字。').hitTestable();
    expect(visibleBodyText, findsWidgets);
    await tester.drag(visibleBodyText.first, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(scrollController.offset, greaterThan(offsetBeforeBodyDrag));

    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(collapsed, findsOneWidget);
    expect(find.text('展开全文'), findsOneWidget);
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
    expect(find.text('主题详情'), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('主题详情'), findsNothing);
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/thread_detail_text_first_360.png'),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(find.text('主题详情'), findsNothing);
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
    expect(tester.getSize(overview).height, lessThan(140));
    expect(
      find.ancestor(of: overview, matching: find.byType(Card)),
      findsNothing,
    );
    expect(find.text('主线正文'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
    expect(find.text('主题详情'), findsNothing);
    final threadTitle = find.text('星海旅团');
    expect(
      tester.getTopLeft(threadTitle).dy,
      greaterThan(tester.getBottomLeft(find.byType(AppBar)).dy),
    );
    expect(tester.getCenter(threadTitle).dx, closeTo(180, 1));

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
        lessThan(140),
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

  testWidgets('360dp 五标签在题头单行横滑且不换行', (tester) async {
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
    expect(find.byKey(const Key('thread-detail-context-row')), findsNothing);
    final tags = find.byKey(const Key('thread-detail-tags'));
    expect(tags, findsOneWidget);
    expect(
      tester.widget<SingleChildScrollView>(tags).scrollDirection,
      Axis.horizontal,
    );
    for (final name in ['太空歌剧', '群像叙事', '星际远航', '长期接力', '硬科幻']) {
      expect(find.text('#$name'), findsOneWidget);
    }
    final tagCenters = List.generate(
      5,
      (index) => tester
          .getCenter(find.byKey(Key('thread-detail-tag-tag-${index + 1}')))
          .dy,
    );
    expect(
      tagCenters.every((center) => (center - tagCenters.first).abs() < 1),
      isTrue,
    );
    final tagScrollable = tester.state<ScrollableState>(
      find.descendant(of: tags, matching: find.byType(Scrollable)),
    );
    expect(tagScrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(tags, const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(tagScrollable.position.pixels, greaterThan(0));
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
      lessThan(140),
    );
    expect(find.text('主线正文'), findsOneWidget);
  });

  testWidgets('无标签主题不保留标签栏或空白', (tester) async {
    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(detail: _detailWithTags(const [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-detail-tags')), findsNothing);
    expect(find.byType(ThreadDetailOverview), findsOneWidget);
    expect(find.text('主线正文'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp 长主题与子贴标题各自最多显示两行', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const threadTitle = '这是一个用于验证移动端题头双行截断且不会挤占操作区域的很长主题标题';
    const subthreadTitle = '第一幕：穿过漫长星海之后所有玩家终于抵达共同约定的远方';
    final detail = _copyThreadDetail(
      _detail,
      title: threadTitle,
      subthreads: const [
        ThreadSubthreadModel(
          id: 'subthread-long',
          title: subthreadTitle,
          sortOrder: 1,
          postCount: 8,
          postingPolicyLabel: '参与者发言',
          body: ThreadBodyModel(markdown: '长标题子贴正文'),
        ),
      ],
    );

    await tester.pumpWidget(
      _detailApp(_FakeThreadDetailRepository(detail: detail)),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(find.text(threadTitle)).maxLines, 2);
    expect(tester.widget<Text>(find.text(subthreadTitle)).maxLines, 2);
    expect(
      tester.getTopLeft(find.text(subthreadTitle)).dy,
      greaterThan(tester.getBottomLeft(find.text(threadTitle)).dy),
    );
    expect(
      tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
      lessThan(190),
    );
    expect(tester.takeException(), isNull);
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
    final directoryDivider = find.byKey(
      const Key('thread-subthread-directory-divider-0'),
    );
    expect(directoryDivider, findsOneWidget);
    expect(tester.widget<Divider>(directoryDivider).height, 1);
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

  testWidgets('多子贴切换栏滚动后冻结并在切换时回到新正文开头', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _FakeThreadDetailRepository(
      mainFloors: [_longMainFloor, _longSecondFloor],
    );
    await tester.pumpWidget(_detailApp(repository));
    await tester.pumpAndSettle();

    final scrollView = find.byType(CustomScrollView);
    await tester.drag(scrollView, const Offset(0, -650));
    await tester.pumpAndSettle();

    final appBarBottom = tester.getBottomLeft(find.byType(AppBar)).dy;
    final stickyHeader = find.byKey(
      const Key('thread-subthread-sticky-header'),
    );
    expect(tester.getTopLeft(stickyHeader).dy, closeTo(appBarBottom, 1));
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
                _detail.subthreads.last,
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
    final detail = _copyThreadDetail(
      _detail,
      subthreads: [_detail.subthreads.first],
    );
    await tester.pumpWidget(
      _detailApp(
        _FakeThreadDetailRepository(
          detail: detail,
          mainFloors: [_longMainFloor, _longSecondFloor],
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
      _detailApp(_FakeThreadDetailRepository(), subthreadIdHint: 'subthread-2'),
    );
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(find.text('主线正文'), findsNothing);
  });

  for (final targetKind in ['subthread', 'post']) {
    for (final surface in _SubthreadSelectionSurface.values) {
      testWidgets('$targetKind 入口定位后可通过 ${surface.label} 切换子贴', (tester) async {
        final repository = _FakeThreadDetailRepository(
          postTarget: targetKind == 'post'
              ? ThreadPostTargetModel(
                  requestedPostId: 'floor-target',
                  threadId: 'thread-1',
                  subthreadId: 'subthread-2',
                  floor: _targetFloor,
                )
              : null,
        );
        await tester.pumpWidget(
          _detailApp(
            repository,
            targetPostId: targetKind == 'post' ? 'floor-target' : null,
            subthreadIdHint: targetKind == 'subthread' ? 'subthread-2' : null,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('支线正文'), findsOneWidget);

        await _selectMainSubthread(tester, surface);
        await tester.pumpAndSettle();

        expect(find.text('主线正文'), findsOneWidget);
        expect(find.text('支线正文'), findsNothing);
        expect(repository.requestedSubthreads.last, 'subthread-1');
      });
    }
  }

  testWidgets('入口目标已是当前子贴时仍完成一次性消费', (tester) async {
    final repository = _FakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: _mainFloor,
      ),
    );
    await tester.pumpWidget(_detailApp(repository, targetPostId: 'floor-1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('thread-subthread-next')));
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-2');
  });

  testWidgets('帖子入口尚在定位时用户切换子贴，迟到结果不再覆盖用户选择', (tester) async {
    final completer = Completer<ThreadPostTargetModel>();
    final repository = _FakeThreadDetailRepository(
      postTargetFuture: completer.future,
    );
    await tester.pumpWidget(
      _detailApp(repository, targetPostId: 'floor-target'),
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
        floor: _targetFloor,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('支线正文'), findsOneWidget);
    expect(repository.requestedSubthreads.last, 'subthread-2');
    expect(find.text('目标楼层内容'), findsNothing);
  });

  testWidgets('同一主题压入两个详情页时各自保留独立子贴状态', (tester) async {
    final repository = _FakeThreadDetailRepository();
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
            _FakePostDiscussionAuthorDirectory(),
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

  testWidgets('目标主楼被发言者筛选排除时恢复全部楼层后再定位', (tester) async {
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
          author: _author,
          body: ThreadBodyModel(
            markdown: '第 $index 层的较长正文，用来确保目标一开始不在 Sliver 构建范围内。\n\n补充内容。',
          ),
          createdAt: _recentFixtureTime,
          isDeleted: false,
          replyCount: 0,
          replies: const [],
        ),
    ];
    final targetFloor = ThreadFloorModel(
      id: 'far-target',
      floorNumber: 1000,
      author: _author,
      body: const ThreadBodyModel(markdown: '远端目标楼层'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    final repository = _FakeThreadDetailRepository(
      mainFloors: floors,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'far-target',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: targetFloor,
      ),
    );

    await tester.pumpWidget(_detailApp(repository, targetPostId: 'far-target'));
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
    final authorDirectory = _MutablePostDiscussionAuthorDirectory();
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
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          authorDirectory,
        ),
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
    expect(find.text('问题编号：floors-request-id'), findsOneWidget);
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
    expect(find.text('问题编号：load-more-request-id'), findsOneWidget);
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
    expect(find.text('问题编号：missing-request-id'), findsOneWidget);
  });

  for (final fixture in _threadDetailViewportFixtures) {
    testWidgets('${fixture.name} 主题详情保持正文视口和贴底操作栏', (tester) async {
      _configureThreadDetailViewport(tester, fixture);

      await tester.pumpWidget(
        _detailApp(_FakeThreadDetailRepository(), textScale: fixture.textScale),
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

  for (final fixture in _threadDetailViewportFixtures.where(
    (fixture) => _authenticatedViewportFixtureNames.contains(fixture.name),
  )) {
    testWidgets('${fixture.name} 登录态完整底栏保持全部操作可见', (tester) async {
      _configureThreadDetailViewport(tester, fixture);
      await tester.pumpWidget(
        await _authenticatedDetailApp(
          _FakeThreadDetailRepository(),
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

  testWidgets('360 dp 子贴导航独占题头行，互动与发表固定在底部拇指栏', (tester) async {
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
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(
            detail: _copyThreadDetail(
              _detail,
              subthreads: _detail.subthreads,
              likeCount: 1000000,
            ),
          ),
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
    final playerDetail = _copyThreadDetail(
      _detail,
      subthreads: _detail.subthreads,
      isCurrentUserPlayer: true,
      currentUserId: 'viewer-1',
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(detail: playerDetail),
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
            _FakeThreadDetailRepository(),
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
    final detailRepository = _FakeThreadDetailRepository();
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

  testWidgets('登录身份变化重新读取目标楼层而不复用旧账号投影', (tester) async {
    final repository = _FakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: _mainFloor,
      ),
    );
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
        .authenticate(_tokens);
    await tester.pumpAndSettle();

    expect(repository.targetPostIds, ['floor-1', 'floor-1']);
  });

  testWidgets('切号关闭主题详情旧编辑器并清空账号内存草稿', (tester) async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        threadDetailRepositoryProvider.overrideWithValue(
          _FakeThreadDetailRepository(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-a'));
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
    await _replacePostComposerText(tester, '账号 A 的未发布楼层');

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('account-b'));
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

  testWidgets('点击短楼中楼预览直接精确回复且楼层长按菜单保持独立', (tester) async {
    final reply = ThreadReplyModel(
      id: 'reply-direct',
      author: const ThreadAuthorModel(
        id: 'user-2',
        username: '楼中楼作者',
        level: 4,
      ),
      body: const ThreadBodyModel(markdown: '点击这条短回复'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
    );
    final floorModel = ThreadFloorModel(
      id: 'floor-direct',
      floorNumber: 1,
      author: _author,
      body: const ThreadBodyModel(markdown: '可直接回复的楼层'),
      createdAt: _recentFixtureTime,
      isDeleted: false,
      replyCount: 1,
      replies: [reply],
    );
    final detailRepository = _FakeThreadDetailRepository(
      mainFloor: floorModel,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-created',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: floorModel,
      ),
    );
    final postRepository = _CreatingPostRepository();
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
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
        .authenticate(_tokensFor('viewer-1'));
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
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

    final floor = find.byKey(const Key('thread-floor-card-floor-direct'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPressAt(tester.getTopLeft(floor) + const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-direct-copy')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('post-composer-body')), findsNothing);
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    final preview = find.byKey(
      const Key('thread-floor-reply-floor-direct-reply-direct'),
    );
    await tester.scrollUntilVisible(
      preview,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-direct')),
      findsOneWidget,
    );
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    expect(find.text('回复 @楼中楼作者'), findsOneWidget);

    await _replacePostComposerText(tester, '精确回复内容');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(postRepository.createInputs, hasLength(1));
    expect(postRepository.createInputs.single.parentPostId, 'floor-direct');
    expect(postRepository.createInputs.single.replyToPostId, 'reply-direct');
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
        .authenticate(_tokensFor('collaborator-1'));
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
    final bodyRect = tester.getRect(
      find.byKey(const Key('thread-body-container-subthread-1')),
    );
    await tester.longPressAt(Offset(bodyRect.right - 12, bodyRect.top + 12));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-copy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-link')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-edit')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('thread-body-action-subthread-1-edit')),
    );
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴正文'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-composer-close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-manage')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-edit-body')), findsOneWidget);
    expect(find.text('编辑正文'), findsOneWidget);
    expect(find.text('主线'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('thread-detail-tip')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-report')), findsOneWidget);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.text('发表楼层'), findsOneWidget);
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
      findsNothing,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-1')),
      findsOneWidget,
    );

    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-delete')),
      findsOneWidget,
    );
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
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            _FakePostDiscussionAuthorDirectory(),
          ),
          threadSubscriptionRepositoryProvider.overrideWithValue(
            _FakeThreadSubscriptionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(sessionControllerProvider.notifier)
          .authenticate(_tokensFor('collaborator-1'));
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
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          _FakePostDiscussionAuthorDirectory(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          _FakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('collaborator-1'));
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
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          _FakePostDiscussionAuthorDirectory(),
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
        .authenticate(_tokensFor('collaborator-1'));
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
    expect(
      find.byKey(const Key('thread-body-add-subthread-1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.text('添加正文'), findsAtLeastNWidgets(1));
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

enum _SubthreadSelectionSurface {
  previous('上一个按钮'),
  next('下一个按钮'),
  directory('目录');

  const _SubthreadSelectionSurface(this.label);

  final String label;
}

Future<void> _selectMainSubthread(
  WidgetTester tester,
  _SubthreadSelectionSurface surface,
) async {
  switch (surface) {
    case _SubthreadSelectionSurface.previous:
      await tester.tap(find.byKey(const Key('thread-subthread-previous')));
      return;
    case _SubthreadSelectionSurface.next:
      await tester.tap(find.byKey(const Key('thread-subthread-next')));
      return;
    case _SubthreadSelectionSurface.directory:
      await tester.tap(find.byKey(const Key('thread-subthread-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-subthread-subthread-1')));
      return;
  }
}

const _threadDetailViewportFixtures = <_ThreadDetailViewportFixture>[
  _ThreadDetailViewportFixture(
    name: '小屏三键 320x568@2x',
    physicalSize: Size(640, 1136),
    devicePixelRatio: 2,
    padding: FakeViewPadding(top: 48, bottom: 96),
  ),
  _ThreadDetailViewportFixture(
    name: '小屏手势 320x800@3x 双倍字体',
    physicalSize: Size(960, 2400),
    devicePixelRatio: 3,
    padding: FakeViewPadding(top: 90, bottom: 72),
    systemGestures: FakeViewPadding(left: 54, top: 90, right: 54, bottom: 120),
    textScale: 2,
  ),
  _ThreadDetailViewportFixture(
    name: '折叠屏窄幅 347x945@2.4x',
    physicalSize: Size(832, 2268),
    devicePixelRatio: 2.4,
    padding: FakeViewPadding(top: 84, bottom: 60),
    systemGestures: FakeViewPadding(left: 48, top: 84, right: 48, bottom: 120),
    textScale: 1.3,
  ),
  _ThreadDetailViewportFixture(
    name: '短窗口 360x480@2x',
    physicalSize: Size(720, 960),
    devicePixelRatio: 2,
    padding: FakeViewPadding(top: 48, bottom: 48),
    systemGestures: FakeViewPadding(left: 32, top: 48, right: 32, bottom: 64),
    textScale: 1.3,
  ),
  _ThreadDetailViewportFixture(
    name: '标准三键 360x640@3x',
    physicalSize: Size(1080, 1920),
    devicePixelRatio: 3,
    padding: FakeViewPadding(top: 72, bottom: 144),
  ),
  _ThreadDetailViewportFixture(
    name: '标准手势 360x800@3x',
    physicalSize: Size(1080, 2400),
    devicePixelRatio: 3,
    padding: FakeViewPadding(top: 90, bottom: 72),
    systemGestures: FakeViewPadding(left: 48, top: 90, right: 48, bottom: 120),
    textScale: 1.3,
  ),
  _ThreadDetailViewportFixture(
    name: '高密度 360x800@4x',
    physicalSize: Size(1440, 3200),
    devicePixelRatio: 4,
    padding: FakeViewPadding(top: 128, bottom: 96),
    systemGestures: FakeViewPadding(left: 64, top: 128, right: 64, bottom: 160),
  ),
  _ThreadDetailViewportFixture(
    name: '荣耀 Magic8 359x789@3.5x',
    physicalSize: Size(1256, 2760),
    devicePixelRatio: 3.5,
    padding: FakeViewPadding(top: 119, bottom: 78),
    systemGestures: FakeViewPadding(left: 53, top: 119, right: 53, bottom: 140),
  ),
  _ThreadDetailViewportFixture(
    name: '主流长屏 393x851@2.75x',
    physicalSize: Size(1080, 2340),
    devicePixelRatio: 2.75,
    padding: FakeViewPadding(top: 93, bottom: 66),
    systemGestures: FakeViewPadding(left: 48, top: 93, right: 48, bottom: 110),
  ),
  _ThreadDetailViewportFixture(
    name: '主流大屏 411x914@2.625x',
    physicalSize: Size(1080, 2400),
    devicePixelRatio: 2.625,
    padding: FakeViewPadding(top: 84, bottom: 63),
    systemGestures: FakeViewPadding(left: 44, top: 84, right: 44, bottom: 105),
    textScale: 1.3,
  ),
  _ThreadDetailViewportFixture(
    name: '大号手机 480x960@2.5x 双倍字体',
    physicalSize: Size(1200, 2400),
    devicePixelRatio: 2.5,
    padding: FakeViewPadding(top: 75, bottom: 60),
    systemGestures: FakeViewPadding(left: 45, top: 75, right: 45, bottom: 100),
    textScale: 2,
  ),
  _ThreadDetailViewportFixture(
    name: '小平板 600x960@2x',
    physicalSize: Size(1200, 1920),
    devicePixelRatio: 2,
    padding: FakeViewPadding(top: 48, bottom: 48),
    systemGestures: FakeViewPadding(left: 32, top: 48, right: 32, bottom: 80),
  ),
  _ThreadDetailViewportFixture(
    name: '平板 800x1280@2x 放大字体',
    physicalSize: Size(1600, 2560),
    devicePixelRatio: 2,
    padding: FakeViewPadding(top: 48, bottom: 48),
    systemGestures: FakeViewPadding(left: 32, top: 48, right: 32, bottom: 80),
    textScale: 1.3,
  ),
];

const _authenticatedViewportFixtureNames = <String>{
  '小屏手势 320x800@3x 双倍字体',
  '荣耀 Magic8 359x789@3.5x',
  '主流长屏 393x851@2.75x',
  '大号手机 480x960@2.5x 双倍字体',
  '平板 800x1280@2x 放大字体',
};

class _ThreadDetailViewportFixture {
  const _ThreadDetailViewportFixture({
    required this.name,
    required this.physicalSize,
    required this.devicePixelRatio,
    this.padding = FakeViewPadding.zero,
    this.systemGestures = FakeViewPadding.zero,
    this.textScale = 1,
  });

  final String name;
  final Size physicalSize;
  final double devicePixelRatio;
  final FakeViewPadding padding;
  final FakeViewPadding systemGestures;
  final double textScale;

  Size get logicalSize => physicalSize / devicePixelRatio;
}

void _configureThreadDetailViewport(
  WidgetTester tester,
  _ThreadDetailViewportFixture fixture,
) {
  tester.view.devicePixelRatio = fixture.devicePixelRatio;
  tester.view.physicalSize = fixture.physicalSize;
  tester.view.padding = fixture.padding;
  tester.view.viewPadding = fixture.padding;
  tester.view.viewInsets = FakeViewPadding.zero;
  tester.view.systemGestureInsets = fixture.systemGestures;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetViewInsets);
  addTearDown(tester.view.resetSystemGestureInsets);
}

Widget _detailApp(
  ThreadDetailRepository repository, {
  String? targetPostId,
  String? subthreadIdHint,
  Key? visualKey,
  PostDiscussionAuthorDirectory? authorDirectory,
  double? textScale,
  bool enableRenderDiagnostics = false,
}) {
  final page = ThreadDetailPage(
    threadId: 'thread-1',
    enableRenderDiagnostics: enableRenderDiagnostics,
    entryTarget: ThreadDetailEntryTarget.fromQuery(
      postId: targetPostId,
      subthreadId: subthreadIdHint,
    ),
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        authorDirectory ?? _FakePostDiscussionAuthorDirectory(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: textScale == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
      home: visualKey == null
          ? page
          : RepaintBoundary(key: visualKey, child: page),
    ),
  );
}

Future<Widget> _authenticatedDetailApp(
  ThreadDetailRepository repository, {
  required String userId,
  double? textScale,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        _FakePostDiscussionAuthorDirectory(),
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
      .authenticate(_tokensFor(userId));
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      builder: textScale == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
      home: const ThreadDetailPage(threadId: 'thread-1'),
    ),
  );
}

Widget _detailRouterApp(
  ThreadDetailRepository repository, {
  String initialLocation = '/threads/thread-1',
  bool enableRenderDiagnostics = false,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        builder: (context, state) => ThreadDetailPage(
          threadId: state.pathParameters['threadId']!,
          enableRenderDiagnostics: enableRenderDiagnostics,
          entryTarget: ThreadDetailEntryTarget.fromQuery(
            postId: state.uri.queryParameters['post'],
          ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    [threadId, postId, ?replyId].join('/'),
                    key: const Key('test-post-replies-destination'),
                  ),
                  if (!state.uri.queryParameters.containsKey('reports'))
                    const SizedBox.shrink(
                      key: Key('test-post-replies-reports-absent'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/tags/:tagId',
        name: 'tag-threads',
        builder: (context, state) => Scaffold(
          appBar: AppBar(leading: const BackButton(key: Key('test-tag-back'))),
          body: Center(
            child: Text(
              state.pathParameters['tagId']!,
              key: const Key('test-tag-destination'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) => Scaffold(
          appBar: AppBar(leading: const BackButton(key: Key('test-user-back'))),
          body: Center(
            child: Text(
              state.pathParameters['userId']!,
              key: const Key('test-user-destination'),
            ),
          ),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        _FakePostDiscussionAuthorDirectory(),
      ),
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
    this.postTargetFuture,
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
  final Future<ThreadPostTargetModel>? postTargetFuture;
  final ThreadDetailModel detail;
  final List<ThreadFloorModel> mainFloors;
  final List<ThreadFloorModel>? nextFloors;
  final List<String> requestedSubthreads = [];
  final List<ThreadFloorOrder> requestedOrders = [];
  final List<String?> requestedAuthors = [];
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
    if (postTargetFuture case final future?) return future;
    return postTarget!;
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    requestedSubthreads.add(subthreadId);
    requestedOrders.add(order);
    requestedAuthors.add(authorId);
    if (cursor != null && loadMoreFailure != null) {
      throw loadMoreFailure!;
    }
    if (cursor != null) {
      final floors = nextFloors ?? const <ThreadFloorModel>[];
      return CursorPage(
        items: authorId == null
            ? floors
            : floors.where((floor) => floor.author.id == authorId).toList(),
        hasMore: false,
      );
    }
    if (cursor == null && floorFailure != null) {
      throw floorFailure!;
    }
    if (cursor == null && (loadMoreFailure != null || nextFloors != null)) {
      final floors = subthreadId == 'subthread-1' ? mainFloors : [_sideFloor];
      return CursorPage(
        items: authorId == null
            ? floors
            : floors.where((floor) => floor.author.id == authorId).toList(),
        cursor: 'next-cursor',
        hasMore: true,
      );
    }
    final floors = subthreadId == 'subthread-1' ? mainFloors : [_sideFloor];
    return CursorPage(
      items: authorId == null
          ? floors
          : floors.where((floor) => floor.author.id == authorId).toList(),
      hasMore: false,
    );
  }
}

class _FakePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    return [
      PostDiscussionAuthor(
        userId: _author.id,
        username: _author.username,
        role: PostDiscussionAuthorRole.owner,
      ),
      PostDiscussionAuthor(
        userId: _playerAuthor.id,
        username: _playerAuthor.username,
        role: PostDiscussionAuthorRole.player,
      ),
    ];
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async => const [];
}

class _MutablePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  int floorCalls = 0;
  List<PostDiscussionAuthor> floorAuthors = [
    PostDiscussionAuthor(
      userId: _author.id,
      username: _author.username,
      role: PostDiscussionAuthorRole.owner,
    ),
    PostDiscussionAuthor(
      userId: _playerAuthor.id,
      username: _playerAuthor.username,
      role: PostDiscussionAuthorRole.player,
    ),
  ];

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    floorCalls += 1;
    return floorAuthors;
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async => const [];
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

final _recentFixtureTime = DateTime.utc(2026, 8, 1, 5, 23);

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
  String? title,
  bool? isPrivate,
  bool? isCurrentUserPlayer,
  bool? isCurrentUserOwner,
  String? currentUserId,
  int? likeCount,
}) {
  return ThreadDetailModel(
    id: source.id,
    title: title ?? source.title,
    owner: source.owner,
    categorySlug: source.categorySlug,
    status: source.status,
    isPrivate: isPrivate ?? source.isPrivate,
    isPinned: source.isPinned,
    viewCount: source.viewCount,
    likeCount: likeCount ?? source.likeCount,
    isLiked: source.isLiked,
    isBookmarked: source.isBookmarked,
    bookmarkId: source.bookmarkId,
    hasAutomaticUpdates: source.hasAutomaticUpdates,
    canManageThread: source.canManageThread,
    isCurrentUserPlayer: isCurrentUserPlayer ?? source.isCurrentUserPlayer,
    isCurrentUserOwner: isCurrentUserOwner ?? source.isCurrentUserOwner,
    currentUserId: currentUserId ?? source.currentUserId,
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
  currentUserId: 'collaborator-1',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: _recentFixtureTime,
);

const _author = ThreadAuthorModel(id: 'user-1', username: '温柔测试员', level: 3);
const _playerAuthor = ThreadAuthorModel(
  id: 'user-2',
  username: '下一位接力者',
  level: 5,
);

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
  Future<String> createBookmark(String threadId, String folderId) async =>
      'bookmark-1';

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
  Future<PostItem> fetchPost(String postId) async {
    if (postId != 'body-1') throw UnsupportedError('unused');
    final timestamp = DateTime.utc(2026, 8, 10, 9);
    return PostItem(
      id: postId,
      threadId: 'thread-1',
      subthreadId: 'subthread-1',
      author: const PostAuthor(id: 'collaborator-1', username: '协作者', level: 4),
      content: '主线正文',
      version: 5,
      createdAt: timestamp,
      updatedAt: timestamp,
      isBody: true,
      isDeleted: false,
    );
  }

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
  author: _playerAuthor,
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

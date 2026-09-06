import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageReadingFiltersCases() {
  testWidgets('公开主题详情连续展示正文且短楼中楼保留独立讨论入口', (tester) async {
    DebugDiagnosticBuffer.instance.clear();
    final repository = ThreadDetailPageTestFakeThreadDetailRepository();
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(
        repository,
        enableRenderDiagnostics: true,
      ),
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
    expect(find.text('正序'), findsOneWidget);
    expect(find.text('倒序'), findsNothing);
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
    expect(find.text('倒序'), findsOneWidget);
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
    final expandAction = tester.widget<TextButton>(
      find.ancestor(
        of: find.text('展开楼中楼（1 条）'),
        matching: find.byType(TextButton),
      ),
    );
    expect(
      expandAction.style?.textStyle?.resolve(const <WidgetState>{})?.fontWeight,
      FontWeight.w400,
    );

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
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
        enableRenderDiagnostics: false,
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('星海旅团'), findsOneWidget);
    expect(DebugDiagnosticBuffer.instance.exportText(), contains('暂无诊断记录。'));
  });

  testWidgets('举报入口对楼主、私密主题、本人楼层和已删除楼层安全隐藏', (tester) async {
    final ownerDetail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestManagerDetail,
      subthreads: threadDetailPageTestManagerDetail.subthreads,
      isCurrentUserOwner: true,
      currentUserId: 'user-1',
    );
    await tester.pumpWidget(
      await threadDetailPageTestAuthenticatedDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(detail: ownerDetail),
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
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      await threadDetailPageTestAuthenticatedDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          detail: threadDetailPageTestManagerDetail,
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

    final privateDetail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestManagerDetail,
      subthreads: threadDetailPageTestManagerDetail.subthreads,
      isPrivate: true,
      currentUserId: 'collaborator-1',
    );
    await tester.pumpWidget(
      await threadDetailPageTestAuthenticatedDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(detail: privateDetail),
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
      author: threadDetailPageTestPlayerAuthor,
      body: const ThreadBodyModel(markdown: '已删除楼层'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: true,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          mainFloors: [deletedFloor],
        ),
      ),
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
    final repository = ThreadDetailPageTestFakeThreadDetailRepository();
    final authorDirectory =
        ThreadDetailPageTestMutablePostDiscussionAuthorDirectory();
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        repository,
        authorDirectory: authorDirectory,
      ),
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
    expect(find.text('倒序'), findsOneWidget);
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
}

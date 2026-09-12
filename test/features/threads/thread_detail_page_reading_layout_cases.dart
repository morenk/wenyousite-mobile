import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageReadingLayoutCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('楼中楼回复深链直接定位独立讨论，返回后不重复打开', (tester) async {
    final repository = ThreadDetailPageTestFakeThreadDetailRepository(
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'reply-1',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: threadDetailPageTestMainFloor,
        focusedReplyId: 'reply-1',
      ),
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(
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
          author: threadDetailPageTestAuthor,
          body: ThreadBodyModel(markdown: '第 $index 条简短回复'),
          createdAt: DateTime.utc(2026, 8, 9, 12, 20 + index),
          isDeleted: false,
        ),
    ];
    final floor = ThreadFloorModel(
      id: 'floor-preview',
      floorNumber: 1,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '带有较长讨论的楼层'),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: replies.length,
      replies: replies,
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(
        ThreadDetailPageTestFakeThreadDetailRepository(mainFloor: floor),
      ),
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
      author: threadDetailPageTestAuthor,
      body: ThreadBodyModel(
        markdown: List.filled(14, '这是一段用于验证真实排版高度的楼中楼回复。').join('\n\n'),
      ),
      createdAt: DateTime.utc(2026, 8, 9, 12, 21),
      isDeleted: false,
    );
    final floor = ThreadFloorModel(
      id: 'floor-tall-preview',
      floorNumber: 1,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '带有超高讨论的楼层'),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: 1,
      replies: [reply],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailRouterApp(
        ThreadDetailPageTestFakeThreadDetailRepository(mainFloor: floor),
      ),
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
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          mainFloors: [
            threadDetailPageTestMainFloor,
            threadDetailPageTestLongSecondFloor,
          ],
        ),
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

  testWidgets('楼层长正文不按视口高度折叠并可直接读到末段', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final paragraphs = List.generate(
      36,
      (index) => '第 ${index + 1} 段，这是用于验证楼层正文完整排版的文字。',
    );
    final floor = ThreadFloorModel(
      id: 'floor-tall-body',
      floorNumber: 1,
      author: threadDetailPageTestAuthor,
      body: ThreadBodyModel(markdown: paragraphs.join('\n\n')),
      createdAt: DateTime.utc(2026, 8, 9, 12, 10),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(mainFloor: floor),
      ),
    );
    await tester.pumpAndSettle();

    final floorCard = find.byKey(
      const Key('thread-floor-card-floor-tall-body'),
    );
    final markdown = find.descendant(
      of: floorCard,
      matching: find.byType(WenyouMarkdown),
    );
    expect(markdown, findsOneWidget);
    expect(tester.getSize(markdown).height, greaterThan(800 * 1.2));
    expect(
      find.byKey(const Key('thread-floor-body-collapsed-floor-tall-body')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('thread-floor-body-toggle-floor-tall-body')),
      findsNothing,
    );
    expect(find.text('展开全文'), findsNothing);
    expect(find.text('收起'), findsNothing);

    final lastParagraph = find.text(paragraphs.last, findRichText: true);
    expect(lastParagraph, findsOneWidget);
    await tester.scrollUntilVisible(
      lastParagraph,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(lastParagraph.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp 长文阅读滚动时顶栏和发表入口保持固定', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const visualKey = Key('thread-detail-text-first-visual');

    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          mainFloors: [
            threadDetailPageTestLongMainFloor,
            threadDetailPageTestLongSecondFloor,
          ],
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
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
        visualKey: visualKey,
      ),
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
        threadDetailPageTestDetailApp(
          ThreadDetailPageTestFakeThreadDetailRepository(),
          visualKey: visualKey,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('thread-detail-overview'))).height,
        lessThan(140),
      );
      expect(find.text('主线正文'), findsOneWidget);
      expect(find.text('第一层内容'), findsOneWidget);
      final navigatorFrame = find.byKey(
        const Key('thread-subthread-navigator-frame'),
      );
      final navigatorContext = tester.element(navigatorFrame);
      expect(
        tester.getSize(navigatorFrame).width,
        closeTo(
          size.width -
              wenyouHorizontalPagePadding(
                    navigatorContext,
                    availableWidth: size.width,
                  ) *
                  2,
          0.1,
        ),
      );
      expect(tester.getCenter(navigatorFrame).dx, closeTo(size.width / 2, 0.1));
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
    final manyTagsDetail = threadDetailPageTestDetailWithTags(const [
      ThreadTagModel(id: 'tag-1', name: '太空歌剧'),
      ThreadTagModel(id: 'tag-2', name: '群像叙事'),
      ThreadTagModel(id: 'tag-3', name: '星际远航'),
      ThreadTagModel(id: 'tag-4', name: '长期接力'),
      ThreadTagModel(id: 'tag-5', name: '硬科幻'),
    ]);

    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(detail: manyTagsDetail),
      ),
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
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(
          detail: threadDetailPageTestDetailWithTags(const []),
        ),
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
    final detail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestDetail,
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
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(detail: detail),
      ),
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
}

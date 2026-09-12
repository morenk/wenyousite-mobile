import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/drafts/application/content_drafts_controller.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_compose_page.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_compose_page_test_support.dart';

void registerThreadComposePageLayoutDraftsCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('创作首屏固定标题、发布元信息和正文', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );

    await threadComposePageTestPumpPage(tester, controller);

    final title = find.byKey(const Key('compose-title'));
    final body = find.byKey(const Key('compose-body'));
    final settings = find.byKey(const Key('compose-publish-settings'));
    expect(tester.getTopLeft(title).dy, lessThan(tester.getTopLeft(body).dy));
    expect(tester.getSize(body).height, greaterThanOrEqualTo(300));
    expect(find.byKey(const Key('compose-category')), findsOneWidget);
    expect(find.byKey(const Key('compose-visibility')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('compose-remote-drafts'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('compose-publish'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('compose-save-draft')), findsNothing);

    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('compose-save-draft'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getSize(find.byKey(const Key('compose-open-remote-drafts')))
          .height,
      greaterThanOrEqualTo(48),
    );
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();

    await tester.ensureVisible(settings);
    await tester.tap(find.byKey(const Key('compose-category')));
    await tester.pump();
    expect(find.byKey(const Key('compose-metadata-panel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('compose-visibility')));
    await tester.pump();
    expect(find.text('公开'), findsOneWidget);
    await tester.tap(find.byTooltip('标签'));
    await tester.pump();
    expect(find.byKey(const Key('compose-tags')), findsOneWidget);
  });

  testWidgets('360dp 创作首屏保持标题与正文优先的视觉基线', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );

    await threadComposePageTestPumpPage(tester, controller);

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_text_first_360.png'),
    );

    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    expect(editor.config.customStyles?.paragraph?.style.fontSize, 17);
    expect(editor.config.customStyles?.paragraph?.style.height, 1.8);
    editor.focusNode.requestFocus();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_keyboard_360.png'),
    );
  });

  testWidgets('360dp 长文编辑态与成稿保持舒展文字节奏', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );
    controller
      ..updateTitle('雾港接力稿')
      ..updateBody(
        '钟声从雾里传来，守夜人把最后一盏灯留在码头。\n'
        '她没有回头，只把写了一半的航海日志推给下一位旅人。\n\n'
        '接下来的人需要沿着潮痕继续，并保留上一段留下的人物动机。',
      );

    await threadComposePageTestPumpPage(tester, controller);

    await expectLater(
      find.byKey(const Key('compose-text-first-visual')),
      matchesGoldenFile('goldens/thread_compose_longform_360.png'),
    );
  });

  testWidgets('工具栏正文草稿与顶栏云端主题草稿保持独立入口', (tester) async {
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );
    controller.updateBody('当前主题正文');
    final contentDraftRepository =
        ThreadComposePageTestFakeContentDraftRepository();
    final contentDraftsController = ContentDraftsController(
      contentDraftRepository,
      autoStart: false,
      autoSaveDebounce: Duration.zero,
    );
    await contentDraftsController.load();
    await threadComposePageTestPumpPage(
      tester,
      controller,
      contentDraftsController: contentDraftsController,
    );
    final draftsButton = find.byKey(const Key('editor-content-drafts'));
    await tester.scrollUntilVisible(
      draftsButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(draftsButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('content-drafts-list')), findsOneWidget);
    expect(find.text('只保存当前正文 · 已用 1/5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('content-drafts-auto-save-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开启'));
    await tester.pumpAndSettle();
    expect(contentDraftRepository.updatedContents, isEmpty);

    await tester.tap(find.byTooltip('关闭正文草稿'));
    await tester.pumpAndSettle();
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    const automaticContent = '关闭面板后继续自动保存';
    editor.controller.replaceText(
      0,
      editor.controller.document.length - 1,
      automaticContent,
      const TextSelection.collapsed(offset: automaticContent.length),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(contentDraftRepository.updatedContents, [automaticContent]);

    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('compose-save-draft')), findsOneWidget);
    expect(find.byKey(const Key('compose-open-remote-drafts')), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
  });

  testWidgets('离页强制落盘失败时要求用户明确选择而不静默退出', (tester) async {
    final store = ThreadComposePageTestMemorySnapshotStore(failSaves: true);
    final controller = await threadComposePageTestReadyController(store);
    await threadComposePageTestPumpPage(tester, controller);
    await tester.enterText(find.byKey(const Key('compose-title')), '尚未保存的标题');

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('本地内容尚未保存'), findsOneWidget);
    await tester.tap(find.text('留下'));
    await tester.pumpAndSettle();
    expect(find.byType(ThreadComposePage), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';

void main() {
  for (final width in const [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 工具栏使用固定核心栏和内部更多托盘', (tester) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final document = Document()..insert(0, '第一段正文');
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 2),
      );
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: WenyouEditorToolbar(
                controller: controller,
                editorFocusNode: focusNode,
                enabled: true,
                onInsertImage: () async {},
                onSaveDraft: () async {},
                onSubmit: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('editor-toolbar-dock'))).width,
        width,
      );
      expect(find.byKey(const Key('editor-heading')), findsOneWidget);
      expect(find.byKey(const Key('editor-submit')), findsOneWidget);
      final controlKeys = <String>[
        'editor-heading',
        'editor-bold',
        'editor-italic',
        'editor-image',
        if (find
            .byKey(const Key('editor-content-drafts'))
            .evaluate()
            .isNotEmpty)
          'editor-content-drafts',
        'editor-more',
        'editor-submit',
      ];
      final centers = controlKeys
          .map((key) => tester.getCenter(find.byKey(Key(key))).dx)
          .toList();
      final gaps = <double>[
        for (var index = 1; index < centers.length; index++)
          centers[index] - centers[index - 1],
      ];
      expect(gaps.every((gap) => gap >= 48), isTrue);
      final widestGap = gaps.reduce((a, b) => a > b ? a : b);
      final narrowestGap = gaps.reduce((a, b) => a < b ? a : b);
      expect(widestGap - narrowestGap, lessThan(0.1));

      await tester.tap(find.byKey(const Key('editor-heading')));
      await tester.pump();
      expect(find.byKey(const Key('editor-heading-tray')), findsOneWidget);
      expect(find.byType(AnimatedSize), findsNothing);
      await tester.tap(find.text('H2'));
      await tester.pumpAndSettle();
      expect(controller.getSelectionStyle().attributes['header']?.value, 2);
      expect(find.byKey(const Key('editor-heading-tray')), findsNothing);

      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('链接和骰子在编辑器内部输入并保持 Markdown 往返', (tester) async {
    final document = Document()..insert(0, '查看资料');
    final controller = QuillController(
      document: document,
      selection: const TextSelection(baseOffset: 0, extentOffset: 4),
    );
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              editorFocusNode: focusNode,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('链接'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-link-tray')), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, '查看资料'), '查看资料');
    await tester.enterText(
      find.widgetWithText(TextField, 'https://…'),
      'https://wenyou.site/help',
    );
    await tester.tap(find.byTooltip('确认插入'));
    await tester.pumpAndSettle();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      contains('[查看资料](https://wenyou.site/help)'),
    );

    controller.updateSelection(
      TextSelection.collapsed(offset: controller.document.length - 1),
      ChangeSource.local,
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('骰子'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '2d6+3');
    await tester.tap(find.byTooltip('确认插入'));
    await tester.pumpAndSettle();
    final markdown = MarkdownDeltaCodec.encode(controller.document.toDelta());
    expect(markdown, contains('2d6+3'));
    expect(
      MarkdownDeltaCodec.encode(MarkdownDeltaCodec.decode(markdown).delta),
      markdown,
    );
  });

  testWidgets('可扩展面板在键盘收起时为系统导航区保留空间', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: WenyouEditorToolbar(
              controller: controller,
              surface: WenyouComposerSurface.expandableSheet,
              enabled: true,
              onInsertImage: () async {},
              onSaveDraft: () async {},
              onSubmit: () {},
            ),
          ),
        ),
      ),
    );

    final dock = find.byKey(const Key('editor-toolbar-dock'));
    expect(tester.getSize(dock).height, 80);
    expect(
      tester.getBottomRight(find.byKey(const Key('editor-submit'))).dy,
      lessThanOrEqualTo(616),
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getSize(dock).height, 56);
  });
}

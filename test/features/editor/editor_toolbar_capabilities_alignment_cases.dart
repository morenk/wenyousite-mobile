import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import '../../support/deterministic_test_fonts.dart';

void registerEditorToolbarCapabilitiesAlignmentCases() {
  setUpAll(loadDeterministicTestFonts);
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

  testWidgets('工具栏按能力集合隐藏业务上下文不支持的命令', (tester) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouEditorToolbar(
            controller: controller,
            enabled: true,
            capabilities: const WenyouEditorCapabilities(
              headings: false,
              inlineStyles: false,
              images: false,
              links: false,
              blockStyles: false,
              dice: false,
              stickers: false,
              drafts: false,
            ),
            onInsertImage: () async {},
            onSaveDraft: () async {},
            onSubmit: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('editor-heading')), findsNothing);
    expect(find.byKey(const Key('editor-image')), findsNothing);
    expect(find.byKey(const Key('editor-more')), findsNothing);
    expect(find.byKey(const Key('editor-submit')), findsOneWidget);
  });

  testWidgets('更多面板使用中性表面并直接设置左、居中和右对齐', (tester) async {
    final controller = QuillController(
      document: Document()..insert(0, '正文'),
      selection: const TextSelection.collapsed(offset: 1),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouEditorToolbar(
            controller: controller,
            enabled: true,
            capabilities: const WenyouEditorCapabilities(
              headings: false,
              inlineStyles: false,
              images: false,
              links: false,
              blockStyles: false,
              alignment: true,
              dice: false,
              stickers: false,
              drafts: false,
            ),
            onInsertImage: () async {},
            onSaveDraft: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedButton<WenyouTextAlignment>), findsNothing);
    expect(find.byKey(const Key('editor-align-left')), findsOneWidget);
    expect(find.byKey(const Key('editor-align-center')), findsOneWidget);
    expect(find.byKey(const Key('editor-align-right')), findsOneWidget);
    final tray = tester.widget<Container>(
      find.byKey(const Key('editor-more-tray')),
    );
    final tokens = AppTheme.light.extension<WenyouThemeTokens>()!;
    expect((tray.decoration! as BoxDecoration).color, tokens.panel);

    await tester.tap(find.byTooltip('居中'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-center]: #\n正文',
    );
    var alignment = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('editor-align-center')),
        matching: find.byType(IconButton),
      ),
    );
    expect(alignment.isSelected, isTrue);
    expect(
      alignment.style!.backgroundColor!.resolve({WidgetState.selected}),
      Colors.transparent,
    );
    expect((alignment.selectedIcon! as WenyouIcon).color, tokens.like);

    await tester.tap(find.byTooltip('右对齐'));
    await tester.pumpAndSettle();
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '[wenyousite-align-v1-right]: #\n正文',
    );
    await tester.tap(find.byTooltip('左对齐'));
    await tester.pumpAndSettle();
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), '正文');
    alignment = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('editor-align-left')),
        matching: find.byType(IconButton),
      ),
    );
    expect(alignment.isSelected, isTrue);
  });

  testWidgets('Markdown v5 独立图片可从更多面板设置对齐', (tester) async {
    final controller = QuillController(
      document: Document.fromDelta(
        MarkdownDeltaCodec.decode(
          '![图片](https://cdn.example.com/image.webp)',
          imageAlignment: true,
        ).delta,
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouEditorToolbar(
            controller: controller,
            enabled: true,
            capabilities:
                WenyouEditorCapabilities.richMarkdownWithImageAlignment,
            onInsertImage: () async {},
            onSaveDraft: () async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('居中'));
    await tester.pumpAndSettle();

    expect(
      MarkdownDeltaCodec.encode(
        controller.document.toDelta(),
        imageAlignment: true,
      ),
      '[wenyousite-align-v1-center]: #\n'
      '![图片](https://cdn.example.com/image.webp)',
    );
  });

  for (final scenario in [
    (name: 'light', theme: AppTheme.light),
    (name: 'dark', theme: AppTheme.dark),
  ]) {
    testWidgets('360dp ${scenario.name} 更多纯图标托盘保持视觉基线', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 320);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = QuillController(
        document: Document()..insert(0, '正文'),
        selection: const TextSelection.collapsed(offset: 1),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: scenario.theme,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: WenyouEditorToolbar(
                controller: controller,
                enabled: true,
                capabilities:
                    WenyouEditorCapabilities.richMarkdownWithAlignment,
                onInsertImage: () async {},
                onSaveDraft: () async {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();

      final firstRow = find.byKey(const Key('editor-more-row-0'));
      final secondRow = find.byKey(const Key('editor-more-row-1'));
      expect(firstRow, findsOneWidget);
      expect(secondRow, findsOneWidget);
      for (final key in const [
        Key('editor-align-left'),
        Key('editor-align-center'),
        Key('editor-align-right'),
      ]) {
        expect(
          find.descendant(of: firstRow, matching: find.byKey(key)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: firstRow, matching: find.byType(IconButton)),
        findsNWidgets(5),
      );
      expect(
        find.descendant(of: secondRow, matching: find.byType(IconButton)),
        findsNWidgets(5),
      );

      await expectLater(
        find.byKey(const Key('editor-more-tray')),
        matchesGoldenFile('goldens/editor_more_tray_360_${scenario.name}.png'),
      );
    });
  }
}

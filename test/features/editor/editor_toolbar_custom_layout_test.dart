import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/editor_toolbar_store.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final layout = customEditorToolbarTestLayout();

  for (final width in [320.0, 360.0]) {
    for (final dark in [false, true]) {
      testWidgets('自定义布局 $width ${dark ? 'dark' : 'light'} 顺序和窄屏画面', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 360);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final controller = QuillController.basic();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _app(controller, layout, dark: dark, scale: width == 320 ? 2 : 1),
        );
        final primary = find.byKey(const Key('editor-toolbar-primary'));
        final expected = width == 320
            ? layout.primary.take(4)
            : layout.primary.take(5);
        final centers = [
          for (final tool in expected)
            tester
                .getCenter(
                  find.descendant(
                    of: primary,
                    matching: find.byTooltip(tool.label),
                  ),
                )
                .dx,
        ];
        for (var index = 1; index < centers.length; index++) {
          expect(centers[index] - centers[index - 1], greaterThanOrEqualTo(48));
        }
        await tester.tap(find.byKey(const Key('editor-more')));
        await tester.pumpAndSettle();
        for (final tool in EditorTool.values) {
          expect(find.byTooltip(tool.label), findsOneWidget);
        }
        expect(find.byTooltip('表情包').hitTestable(), findsOneWidget);
        expect(find.byTooltip('有序列表'), findsNothing);
        expect(find.byTooltip('无序列表'), findsNothing);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/editor_custom_toolbar_${width.toInt()}_${dark ? 'dark' : 'light'}.png',
          ),
        );
      });
    }
  }

  testWidgets('无原更多能力仍可访问自定义展开栏，缺表情回调不显示按钮', (tester) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        controller,
        EditorToolbarLayout.custom(primary: [], expanded: [EditorTool.heading]),
        stickers: false,
        capabilities: const WenyouEditorCapabilities(
          headings: true,
          inlineStyles: false,
          images: false,
          links: false,
          blockStyles: false,
          dice: false,
          stickers: false,
          drafts: false,
        ),
      ),
    );
    expect(find.byKey(const Key('editor-more')), findsOneWidget);
    expect(find.byTooltip('正文样式'), findsNothing);
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('正文样式'), findsOneWidget);
    await tester.tap(find.byTooltip('正文样式'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('H2'));
    await tester.pumpAndSettle();
    expect(
      controller.getSelectionStyle().attributes[Attribute.header.key]?.value,
      2,
    );

    await tester.pumpWidget(_app(controller, layout, stickers: false));
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('表情包'), findsNothing);
    expect(find.byTooltip('粗体'), findsOneWidget);
  });

  testWidgets('展开栏的粗体保留选区，主栏链接任务仍可插入并返回', (tester) async {
    final controller = QuillController(
      document: Document()..insert(0, '正文'),
      selection: const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        controller,
        EditorToolbarLayout.custom(
          primary: [EditorTool.link],
          expanded: [EditorTool.bold],
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('粗体'));
    await tester.pumpAndSettle();
    expect(
      controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 2),
    );
    expect(controller.getSelectionStyle().attributes['bold']?.value, true);
    await tester.tap(find.byTooltip('链接'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-link-tray')), findsOneWidget);
    expect(find.byKey(const Key('editor-toolbar-primary')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(
  QuillController controller,
  EditorToolbarLayout layout, {
  bool dark = false,
  double scale = 1,
  bool stickers = true,
  WenyouEditorCapabilities capabilities =
      WenyouEditorCapabilities.richMarkdownWithImageAlignment,
}) => MaterialApp(
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: WenyouEditorToolbar(
        controller: controller,
        enabled: true,
        layout: layout,
        capabilities: capabilities,
        onInsertImage: () async {},
        onSaveDraft: () async {},
        onInsertSticker: stickers ? (_) async {} : null,
        onSubmit: () {},
      ),
    ),
  ),
);

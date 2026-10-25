import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final scenarios = [
    for (final prefix in ['', '## ', '### '])
      (name: '$prefix 单段', source: '前文\n\n$prefix标题文字\n\n后文', all: false),
    (name: '相邻 H2/H3/P', source: '## 二级标题\n### 三级标题\n正文', all: true),
    (name: '相邻 P/H2/H3', source: '正文\n## 二级标题\n### 三级标题', all: true),
    (name: '相邻 H3/P/H2', source: '### 三级标题\n正文\n## 二级标题', all: true),
    (name: '多行及显式空段', source: '## 二级标题\n<br />\n第一行\n第二行\n### 三级标题', all: true),
    (
      name: '混合行内样式',
      source:
          '## 标题 **粗体** *斜体* `代码`\n### 标题 <span data-wenyou-color-v1="#D14343">颜色</span>',
      all: true,
    ),
    (
      name: '自动折行',
      source: '## 这是很长的二级标题，需要在手机窄屏上自动折行显示\n### 这是很长的三级标题，需要在手机窄屏上自动折行显示',
      all: true,
    ),
    (name: '引用和列表邻接', source: '> 引用\n\n## 标题文字\n\n- 列表项', all: false),
  ];
  final cases = [
    for (final scenario in scenarios)
      (
        name: scenario.name,
        source: scenario.source,
        all: scenario.all,
        nativeHeader: null,
      ),
    // 产品 Markdown 仅支持 H2/H3；直接构造原生属性验证补丁其他分支。
    for (final level in [1, 4, 5, 6])
      (
        name: '原生 Quill H$level',
        source: '前文\n\n## 标题文字\n\n后文',
        all: false,
        nativeHeader: level,
      ),
  ];
  for (final scenario in cases) {
    testWidgets('${scenario.name} 仅切换对齐保留原有文字与段落垂直位置', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final source = scenario.source;
      final controller = QuillController(
        document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
        selection: const TextSelection.collapsed(offset: 3),
      );
      final focus = FocusNode();
      controller.updateSelection(
        scenario.all
            ? TextSelection(
                baseOffset: 0,
                extentOffset: controller.document.length - 1,
              )
            : TextSelection.collapsed(
                offset: controller.document.toPlainText().indexOf('标题'),
              ),
        ChangeSource.local,
      );
      final scroll = ScrollController();
      if (scenario.nativeHeader != null) {
        controller.formatSelection(
          Attribute.clone(Attribute.header, scenario.nativeHeader),
        );
      }
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => QuillEditor(
                controller: controller,
                focusNode: focus,
                scrollController: scroll,
                config: QuillEditorConfig(
                  scrollable: false,
                  padding: EdgeInsets.zero,
                  customStyles: wenyouEditorTextStyles(context),
                  showCursor: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      List<(double, double)> geometry() => tester
          .widgetList<RichText>(
            find.descendant(
              of: find.byType(QuillEditor),
              matching: find.byType(RichText),
            ),
          )
          .map((text) {
            final rect = tester.getRect(find.byWidget(text));
            return (rect.top, rect.height);
          })
          .toList();
      final initial = geometry();
      final initialText = controller.document.toPlainText();
      for (final alignment in [
        Attribute.centerAlignment,
        Attribute.rightAlignment,
        Attribute.leftAlignment,
        Attribute.clone(Attribute.align, null),
      ]) {
        controller.formatSelection(alignment);
        await tester.pumpAndSettle();
        expect(
          geometry(),
          initial,
          reason: '${alignment.value}: ${controller.document.toDelta()}',
        );
        expect(controller.document.toPlainText(), initialText);
      }
      controller.document.history.clear();
      controller.formatSelection(Attribute.centerAlignment);
      await tester.pumpAndSettle();
      controller.undo();
      await tester.pumpAndSettle();
      expect(geometry(), initial);
      controller.redo();
      await tester.pumpAndSettle();
      expect(geometry(), initial);
      if (scenario.name == '相邻 H2/H3/P') {
        controller.formatSelection(Attribute.h3);
        await tester.pumpAndSettle();
        final alignedHeading = geometry();
        controller.formatSelection(Attribute.clone(Attribute.align, null));
        await tester.pumpAndSettle();
        expect(geometry(), alignedHeading, reason: '对齐后再设标题仍保持间距');
      }
    });
  }
}

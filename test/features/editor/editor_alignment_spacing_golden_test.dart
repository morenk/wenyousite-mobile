import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    testWidgets('320 ${dark ? 'dark' : 'light'} 标题对齐垂直间距', (tester) async {
      tester.view.devicePixelRatio = 1;
      // 三列各为手机 320dp 视口，从同一纵向起点比较对齐前后间距。
      tester.view.physicalSize = const Size(960, 500);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final theme = dark ? AppTheme.dark : AppTheme.light;
      final sections = <Widget>[];
      for (final alignment in ['left', 'center', 'right']) {
        final marker = alignment == 'left'
            ? ''
            : '[wenyousite-align-v1-$alignment]: #\n';
        final source =
            '$marker## 二级标题\n'
            '$marker### 三级标题\n'
            '$marker正文第一行\n正文第二行';
        final controller = QuillController(
          document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
        final focus = FocusNode();
        final scroll = ScrollController();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        addTearDown(scroll.dispose);
        sections.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('编辑 · $alignment'),
                  Builder(
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
                  const SizedBox(height: 12),
                  Text('阅读 · $alignment'),
                  WenyouMarkdown(data: source),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('alignment-spacing'),
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('alignment-spacing')),
        matchesGoldenFile(
          'goldens/editor_alignment_spacing_320_${dark ? 'dark' : 'light'}.png',
        ),
      );
    });
  }
}

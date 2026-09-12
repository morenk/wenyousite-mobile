import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final sample in [
    (name: 'paragraphs', separator: '>'),
    (name: 'invisible_content', separator: '>\u200b'),
    (name: 'explicit_empty', separator: '> <br />'),
  ]) {
    testWidgets('${sample.name} 阅读与编辑引用背景连续且保留外部空段', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 620);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final source =
          '> hh\n${sample.separator}\n'
          '> **阿三大苏打**  *~~撒大苏打~~*\n\n<br />';
      final emitted = <String>[];
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: emitted.add,
      );
      addTearDown(session.dispose);
      final document = session.controller.document;
      final editorKey = GlobalKey<EditorState>();
      expect(document.root.children, hasLength(2));
      final quote = document.root.children.first as Block;
      expect(quote.style.attributes['blockquote']?.value, isTrue);
      expect(quote.childCount, sample.name == 'paragraphs' ? 2 : 3);
      expect(document.root.children.last, isA<Line>());
      expect(document.toPlainText(), isNot(contains('>')));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('quote-parity'),
              child: Builder(
                builder: (context) => Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('显示态'),
                      const SizedBox(height: 12),
                      WenyouMarkdown(data: source),
                      const SizedBox(height: 24),
                      const Text('编辑态'),
                      const SizedBox(height: 12),
                      QuillEditor(
                        controller: session.controller,
                        focusNode: session.focusNode,
                        scrollController: session.scrollController,
                        config: QuillEditorConfig(
                          editorKey: editorKey,
                          scrollable: false,
                          showCursor: false,
                          padding: EdgeInsets.zero,
                          customStyles: wenyouEditorTextStyles(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final renderEditor = editorKey.currentState!.renderEditor;
      final firstCaret = renderEditor.getLocalRectForCaret(
        const TextPosition(offset: 0),
      );
      final lastCaret = renderEditor.getLocalRectForCaret(
        TextPosition(offset: document.toPlainText().indexOf('阿')),
      );
      final expectedRows = sample.name == 'paragraphs' ? 1 : 2;
      var rowsHeight = 0.0;
      final renderedRows = find
          .descendant(
            of: find.byType(QuillEditor),
            matching: find.byType(RichText),
          )
          .evaluate()
          .toList();
      // Empty text uses the font's strut metrics; measure text boxes directly
      // and assert that Quill adds no paragraph padding between those boxes.
      for (var row = 0; row < expectedRows; row++) {
        rowsHeight += tester
            .getSize(find.byWidget(renderedRows[row].widget))
            .height;
      }
      expect(lastCaret.top - firstCaret.top, closeTo(rowsHeight, 1));
      expect(emitted, isEmpty);
      expect(await session.flush(), isTrue);
      expect(
        md.markdownToHtml(
          emitted.last,
          extensionSet: md.ExtensionSet.gitHubFlavored,
        ),
        md.markdownToHtml(source, extensionSet: md.ExtensionSet.gitHubFlavored),
      );
      await expectLater(
        find.byKey(const Key('quote-parity')),
        matchesGoldenFile('goldens/editor_quote_${sample.name}_360.png'),
      );

      final offset = document.toPlainText().indexOf('阿');
      session.controller.replaceText(
        offset,
        0,
        '新',
        TextSelection.collapsed(offset: offset + 1),
      );
      expect(await session.flush(), isTrue);
      final reopened = Document.fromDelta(
        MarkdownDeltaCodec.decode(emitted.last).delta,
      );
      addTearDown(reopened.close);
      expect(reopened.root.children.whereType<Block>(), hasLength(1));
      expect(reopened.toPlainText(), document.toPlainText());
      expect(
        reopened.collectStyle(offset, 6).attributes['bold']?.value,
        isTrue,
      );
      final strikeOffset = reopened.toPlainText().indexOf('撒');
      final strike = reopened.collectStyle(strikeOffset, 4).attributes;
      expect(strike['italic']?.value, isTrue);
      expect(strike['strike']?.value, isTrue);
      expect(MarkdownDeltaCodec.encode(reopened.toDelta()), emitted.last);
    });
  }
}

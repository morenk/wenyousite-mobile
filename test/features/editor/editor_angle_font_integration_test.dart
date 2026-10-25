import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  RichEditorSession open(String source) {
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    return session;
  }

  for (final (version, font) in [
    (1, 'wenkai'),
    (2, 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
  ]) {
    test('纯字体 v$version 保留规范 span，不因尖括号保护改写为字符实体', () async {
      final source = '<span data-wenyou-font-v$version="$font">正文</span>';
      final session = open(source);
      expect(session.isSourceProtected, isFalse);
      expect(session.controller.document.toPlainText(), '正文\n');
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      expect(session.localMarkdown, source);
    });

    for (final color in [false, true]) {
      test('字体 v$version 的实体标签编辑、撤销、保存和重开：颜色=$color', () async {
        final marks = <String, Object>{
          'font': font,
          if (color) 'color': '#D14343',
          'bold': true,
        };
        final source =
            '<span data-wenyou-font-v$version="$font"'
            '${color ? ' data-wenyou-color-v1="#D14343"' : ''}>'
            '**&lt;tag&gt;**</span>';
        final session = open(source);
        expect(session.isSourceProtected, isFalse);
        expect(session.controller.document.toPlainText(), '<tag>\n');
        expect(
          colorDeltaUnits(session.controller.document.toDelta()),
          colorExpectedUnits([('<tag>', marks)]),
        );
        session.controller.document.history.clear();
        session.controller.replaceText(
          1,
          0,
          '新',
          const TextSelection.collapsed(offset: 2),
        );
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        final expected = colorExpectedUnits([('<新tag>', marks)]);
        expect(
          colorReaderUnits(colorReaderNodes(session.localMarkdown)),
          expected,
        );
        expect(
          colorDeltaUnits(
            open(session.localMarkdown).controller.document.toDelta(),
          ),
          expected,
        );
        session.controller.undo();
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        expect(session.controller.document.toPlainText(), '<tag>\n');
        expect(
          MarkdownContent.toPlainTextPreview(session.localMarkdown),
          '<tag>',
        );
      });
    }

    test('实体字体标签在真实字体旁仍为字面正文 v$version', () async {
      final literal = '<span data-wenyou-font-v$version="$font">原文</span>';
      final source =
          '<span data-wenyou-font-v$version="$font">字体</span> '
          '&lt;span data-wenyou-font-v$version="$font"&gt;原文&lt;/span&gt;';
      final session = open(source);
      expect(session.isSourceProtected, isFalse);
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final expected = colorExpectedUnits([
        ('字体', {'font': font}),
        (' $literal', {}),
      ]);
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        expected,
      );
      final reopened = open(session.localMarkdown);
      expect(reopened.isSourceProtected, isFalse);
      expect(colorDeltaUnits(reopened.controller.document.toDelta()), expected);
      expect(reopened.controller.document.toPlainText(), '字体 $literal\n');
    });
  }
}

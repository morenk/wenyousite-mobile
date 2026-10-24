import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('实际会话打开、输入、保存、重开保留字体、文字、空段和样式', () async {
    const initial =
        '<span data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#D14343">**甲乙**</span>\n\n<br />\n\n第二段';
    var saved = initial;
    final session = RichEditorSession(
      initialMarkdown: initial,
      onMarkdownChanged: (value) => saved = value,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    session.controller.replaceText(
      1,
      0,
      '中',
      const TextSelection.collapsed(offset: 2),
    );
    expect(await session.flush(), isTrue);
    final opened = RichEditorSession(
      initialMarkdown: saved,
      onMarkdownChanged: (_) {},
    );
    addTearDown(opened.dispose);
    expect(
      opened.controller.document.toPlainText(),
      session.controller.document.toPlainText(),
    );
    expect(opened.controller.document.toPlainText(), contains('甲中乙'));
    expect(
      colorDeltaUnits(opened.controller.document.toDelta()).take(3),
      colorExpectedUnits([
        ('甲中乙', {'font': 'wenkai', 'color': '#D14343', 'bold': true}),
      ]),
    );
    expect(saved, contains('<br />'));
    expect(
      colorReaderUnits(colorReaderNodes(saved)).take(3),
      colorExpectedUnits([
        ('甲中乙', {'font': 'wenkai', 'color': '#D14343', 'bold': true}),
      ]),
    );
  });
  test('恢复默认后 # 开头仍是正文，清除操作可重开且不遗留字体标签', () async {
    var saved = '';
    final session = RichEditorSession(
      initialMarkdown: '<span data-wenyou-font-v1="wenkai"># 标题</span>',
      onMarkdownChanged: (value) => saved = value,
    );
    addTearDown(session.dispose);
    expect(
      EditorTextFontPolicy.apply(
        session.controller,
        const TextSelection(baseOffset: 0, extentOffset: 4),
        null,
      ),
      isTrue,
    );
    expect(await session.flush(), isTrue);
    expect(saved, isNot(contains('data-wenyou-font')));
    expect(
      colorReaderUnits(colorReaderNodes(saved)),
      colorExpectedUnits([('# 标题', <String, Object>{})]),
    );
  });
  test('站内剪贴板 v2 保留同 span 字体与颜色，外部 CSS 不当作字体', () {
    final delta = const WenyouSiteClipboardParser().parse(
      '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor"><p><span data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#d14343"><strong>甲乙</strong></span></p></div>',
    );
    expect(delta, isNotNull);
    expect(
      colorDeltaUnits(delta!),
      colorExpectedUnits([
        ('甲乙', {'font': 'wenkai', 'color': '#D14343', 'bold': true}),
      ]),
    );
    expect(
      MarkdownDeltaCodec.encode(delta),
      contains('data-wenyou-font-v1="wenkai" data-wenyou-color-v1="#D14343"'),
    );
    final foreign = const WenyouSiteClipboardParser().parse(
      '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor"><p><span style="font-family:Arial">甲乙</span></p></div>',
    );
    expect(
      foreign!.operations.every((op) => op.attributes?['font'] == null),
      isTrue,
    );
  });
}

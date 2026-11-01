import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/reading_text_style_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('只改变字体保留外链颜色与字重', (tester) async {
    await pump(tester, const [
      Text('上：普通链接；下：只增加字体'),
      SizedBox(height: 12),
      WenyouMarkdown(data: '[普通链接](https://example.com)'),
      SizedBox(height: 12),
      WenyouMarkdown(
        data:
            '<span data-wenyou-font-v1="wenkai">[字体链接](https://example.com)</span>',
        enableTextFonts: true,
      ),
    ]);
    final plain = leafStyle(tester, '普通链接');
    final font = leafStyle(tester, '字体链接');

    expect(font.color, plain.color);
    expect(font.fontWeight, plain.fontWeight);
  });
  testWidgets('只改变颜色保留行内代码字号与行高', (tester) async {
    await pump(tester, const [
      Text('上：普通代码；下：只增加颜色'),
      SizedBox(height: 12),
      WenyouMarkdown(data: '前文 `codeA` 后文'),
      SizedBox(height: 12),
      WenyouMarkdown(
        data: '前文 <span data-wenyou-color-v1="#D14343">`codeB`</span> 后文',
      ),
    ]);
    final normal = leafStyle(tester, 'codeA');
    final colored = leafStyle(tester, 'codeB');

    expect(colored.fontSize, normal.fontSize);
    expect(colored.height, normal.height);
  });
  testWidgets('独立空段与普通正文空行同步缩放', (tester) async {
    await pump(tester, const [
      WenyouMarkdown(data: '## 甲\n<br />\n## 乙'),
      WenyouMarkdown(data: '正文\n<br />\n末行', enablePlainTextFastPath: false),
    ], scale: 2);
    final blank = find.byKey(
      const ValueKey('wenyou-markdown-empty-paragraph-0'),
    );
    expect(blank, findsOneWidget);
    final actual = tester.getSize(blank).height;
    final rich = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText() == '正文\n\n末行',
    );
    final paragraph = tester.renderObject<RenderParagraph>(rich);
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
    );
    final last = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 4, extentOffset: 5),
    );
    final line = (last.single.top - boxes.single.top) / 2;

    expect(actual, closeTo(line, 1));
  });
  testWidgets('传送门在 Markdown 与纯文本阅读入口缩放一致', (tester) async {
    const source = '[入口](/threads/cmsewdo0h000x7qv6aa77ll1v)';
    await pump(tester, const [
      Text('主题正文'),
      WenyouMarkdown(key: Key('markdown'), data: source),
      SizedBox(height: 20),
      Text('动态 / 私聊正文'),
      WenyouInternalReferenceText(
        key: Key('plain'),
        content: source,
        style: TextStyle(fontSize: 17, height: 1.8),
      ),
    ], scale: 2);
    RenderParagraph label(String key) => tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == '入口',
        ),
      ),
    );
    double glyphHeight(RenderParagraph p) {
      final box = p
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 1),
          )
          .single
          .toRect();
      return p.localToGlobal(box.bottomRight).dy -
          p.localToGlobal(box.topLeft).dy;
    }

    final markdown = glyphHeight(label('markdown'));
    final plain = glyphHeight(label('plain'));

    expect(plain, closeTo(markdown, 1));
  });
}

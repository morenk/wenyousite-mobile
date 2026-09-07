import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_quote_line_syntax.dart';

void main() {
  test('显式空行周围的多行行内样式保持原语义', () {
    final nodes = md.Document(
      blockSyntaxes: [const MarkdownLiteralRowsSyntax()],
    ).parseLines('**甲\n乙**\n<br />\n丙'.split('\n'));
    final paragraph = nodes.single as md.Element;
    final strong = paragraph.children!.whereType<md.Element>().first;
    expect(strong.tag, 'strong');
    expect(strong.textContent, '甲\n乙');
    expect(
      paragraph.children!.whereType<md.Element>().where(
        (node) => node.tag == 'br',
      ),
      hasLength(2),
    );
  });

  test('空行排版不吞并标题、列表和分隔线', () {
    final nodes = md.Document(
      blockSyntaxes: [const MarkdownLiteralRowsSyntax()],
    ).parseLines('甲\n<br />\n乙\n\n## 标题\n\n- 项目\n\n---'.split('\n'));
    expect(nodes.whereType<md.Element>().map((node) => node.tag), [
      'p',
      'h2',
      'ul',
      'hr',
    ]);
  });
}

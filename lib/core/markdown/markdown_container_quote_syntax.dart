import 'package:markdown/markdown.dart' as md;

/// Dart 7.3.1 的引用收集器把链接定义当作段落中断；这里依据实际块判断 lazy 行。
class MarkdownContainerQuoteSyntax extends md.BlockquoteSyntax {
  const MarkdownContainerQuoteSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    final children = <md.Line>[];
    var lazy = false;
    while (!parser.isDone) {
      final line = parser.current;
      final match = pattern.firstMatch(line.content);
      if (match != null) {
        final marker = line.content.indexOf('>');
        var end = marker + 1;
        if (end < line.content.length &&
            (line.content[end] == ' ' || line.content[end] == '\t')) {
          end++;
        }
        children.add(md.Line(line.content.substring(end)));
        parser.advance();
        lazy = false;
        continue;
      }
      if (children.isEmpty ||
          children.last.isBlankLine ||
          md.BlockSyntax.isAtBlockEnd(parser) ||
          !_endsInParagraph(children)) {
        break;
      }
      children.add(line);
      parser.advance();
      lazy = true;
    }
    collectedLines(parser, children);
    return md.Element(
      'blockquote',
      md.BlockParser(
        children,
        parser.document,
      ).parseLines(disabledSetextHeading: lazy, parentSyntax: this),
    );
  }

  /// 供来源分析记录原生容器去前缀后的逐行对应，不参与节点语义。
  void collectedLines(md.BlockParser parser, List<md.Line> children) {}

  static bool _endsInParagraph(List<md.Line> lines) {
    final blocks = md.BlockParser(
      lines,
      md.Document(extensionSet: md.ExtensionSet.gitHubFlavored),
    ).parseLines();
    if (blocks.isEmpty) return false;
    md.Node last = blocks.last;
    while (last is md.Element &&
        const {'blockquote', 'ul', 'ol', 'li'}.contains(last.tag) &&
        last.children?.isNotEmpty == true) {
      last = last.children!.last;
    }
    return last is md.UnparsedContent || last is md.Element && last.tag == 'p';
  }
}

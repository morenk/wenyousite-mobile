import 'package:markdown/markdown.dart' as md;

/// markdown 7.3.1 的段尾 trimRight 会删除可见的 NBSP。
/// 复用原段落解析，仅在原源码确有 NBSP 的尾部恢复被裁掉的内容。
class MarkdownReaderParagraphSyntax extends md.ParagraphSyntax {
  const MarkdownReaderParagraphSyntax();

  @override
  bool canParse(md.BlockParser parser) {
    // 自定义语法先于内置语法运行；不得抢占标题、列表或其他结构。
    for (final syntax in parser.blockSyntaxes) {
      if (identical(syntax, this)) continue;
      if (syntax.canParse(parser)) return syntax is md.ParagraphSyntax;
    }
    return false;
  }

  @override
  md.Node? parse(md.BlockParser parser) {
    final start = parser.lines.indexOf(parser.current);
    final node = super.parse(parser);
    if (node is! md.Element || node.tag != 'p') return node;
    final end = parser.isDone
        ? parser.lines.length
        : parser.lines.indexOf(parser.current);
    final source = parser.lines
        .sublist(start, end)
        .map((line) => line.content)
        .join('\n');
    final suffix = source.substring(source.trimRight().length);
    if (suffix.contains('\u00a0')) {
      node.children!.add(md.Text(suffix));
    }
    return node;
  }
}

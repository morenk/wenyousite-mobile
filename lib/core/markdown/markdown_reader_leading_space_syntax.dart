import 'package:markdown/markdown.dart' as md;

/// 保留段首真实空格，避免阅读组件在实体解码后再次按 Markdown 缩进裁剪。
class MarkdownReaderLeadingSpaceSyntax extends md.InlineSyntax {
  MarkdownReaderLeadingSpaceSyntax()
    : super(r'^(?: |&#(?:0{0,5}32|[xX]0{0,4}20);)+');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final spaces = match[0]!.replaceAll(RegExp(r'&#[^;]+;'), ' ');
    // 中性行内节点沿用父级样式；字符仍是原始 U+0020，不用 NBSP 或隐藏字符代替。
    // 块级缩进已由原解析器处理；代码和反斜杠转义不会匹配此段首语法。
    parser.addNode(md.Element.text('span', spaces));
    return true;
  }
}

import 'package:markdown/markdown.dart' as md;

/// 跨行 code span 在编辑器中显示 CommonMark 可见文字；未修改时保留原始换行。
abstract final class MarkdownInlineCodeSource {
  static const key = 'wenyou_inline_code_source';

  static md.InlineSyntax syntax() => _SourceCode();

  static String? preserved(String text, String? source) {
    if (source == null || !source.contains('\n')) return null;
    final nodes = md.Document(encodeHtml: false).parseInline(source);
    if (nodes.length != 1 || nodes.single is! md.Element) return null;
    final node = nodes.single as md.Element;
    return node.tag == 'code' && node.textContent == text ? source : null;
  }
}

class _SourceCode extends md.CodeSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final raw = match.group(0)!;
    if (!raw.contains('\n')) return super.onMatch(parser, match);
    final nodes = md.Document(encodeHtml: parser.encodeHtml).parseInline(raw);
    final node = nodes.single as md.Element;
    node.attributes[MarkdownInlineCodeSource.key] = raw;
    parser.addNode(node);
    return true;
  }
}

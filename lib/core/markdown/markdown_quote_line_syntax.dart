import 'package:markdown/markdown.dart' as md;

/// Plain text and explicit empty rows form one line layout. Stop before any
/// structural block so heading/list/image semantics stay with their parsers.
class MarkdownLiteralRowsSyntax extends md.BlockSyntax {
  const MarkdownLiteralRowsSyntax({this.isAtomicLine});

  final bool Function(String)? isAtomicLine;

  static final _empty = RegExp(r'^<br />$');
  static final _boundary = RegExp(
    r'^(?:\s*$|\t| {4}| {0,3}(?:#{1,6}(?: |$)|>|[-+*](?: |$)|\d+[.)] |`{3}|~{3}|!\[|\[[^\]]*\]:|---|___))',
  );

  @override
  RegExp get pattern => RegExp(r'.*');

  @override
  bool canEndBlock(md.BlockParser parser) => false;

  List<String> _rows(md.BlockParser parser) {
    final rows = <String>[];
    for (var offset = 0; ; offset++) {
      final line = parser.peek(offset)?.content;
      if (line == null || _boundary.hasMatch(line)) break;
      rows.add(line);
    }
    // 空段行与普通文字共用行布局；独立媒体需保留块身份，空段仍由
    // 既有空段 builder 按行高显示。邻接普通文字的链接不因此被拆开。
    final atomic = isAtomicLine;
    if (atomic != null && parser.parentSyntax == null) {
      for (var index = 0; index < rows.length; index++) {
        if ((index == 0 || _empty.hasMatch(rows[index - 1])) &&
            (index + 1 == rows.length || _empty.hasMatch(rows[index + 1])) &&
            atomic(rows[index])) {
          return rows.sublist(0, index);
        }
      }
    }
    return rows;
  }

  @override
  bool canParse(md.BlockParser parser) {
    final rows = _rows(parser);
    return rows.any(_empty.hasMatch) &&
        rows.any((line) => !_empty.hasMatch(line));
  }

  @override
  md.Node parse(md.BlockParser parser) {
    final rows = _rows(parser);
    final children = <md.Node>[];
    final textRows = <String>[];
    void flushText() {
      if (textRows.isEmpty) return;
      children.add(md.UnparsedContent(textRows.join('\n')));
      textRows.clear();
    }

    for (var index = 0; index < rows.length; index++) {
      if (_empty.hasMatch(rows[index])) {
        flushText();
        if (index > 0) children.add(md.Element.empty('br'));
      } else {
        if (textRows.isEmpty && index > 0) children.add(md.Element.empty('br'));
        textRows.add(rows[index]);
      }
      parser.advance();
    }
    flushText();
    return md.Element('p', children);
  }
}

/// Explicit quoted empty rows share one text layout, so the Markdown widget
/// does not add paragraph spacing on both sides of every empty row.
class MarkdownQuoteLineSyntax extends md.BlockquoteSyntax {
  const MarkdownQuoteLineSyntax(this.emptyParagraphTag);

  final String emptyParagraphTag;

  @override
  md.Node parse(md.BlockParser parser) {
    final node = super.parse(parser);
    if (node is! md.Element) return node;
    final children = node.children;
    if (children == null ||
        !children.any(
          (child) => child is md.Element && child.tag == emptyParagraphTag,
        ) ||
        !children.every(
          (child) =>
              child is md.Element &&
              (child.tag == 'p' || child.tag == emptyParagraphTag),
        )) {
      return node;
    }
    final inline = <md.Node>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) inline.add(md.Element.empty('br'));
      final child = children[index] as md.Element;
      if (child.tag == 'p') inline.addAll(child.children ?? const []);
    }
    return md.Element('blockquote', [md.Element('p', inline)]);
  }
}

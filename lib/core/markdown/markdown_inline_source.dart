import 'package:markdown/markdown.dart' as md;

typedef MarkdownSourceRange = ({int start, int end});

/// 与阅读解析器共享词法规则，不把任意一对尖括号当作 HTML。
/// 转义、代码、自动链接和链接目标／标题由解析器实际消费顺序决定。
final class MarkdownInlineSource {
  MarkdownInlineSource._();

  final code = <MarkdownSourceRange>[];
  final metadata = <MarkdownSourceRange>[];
  final html = <MarkdownSourceRange>[];

  static MarkdownInlineSource analyze(String source) {
    final result = MarkdownInlineSource._();
    md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        _Code(result.code.add),
        _Html(result.html.add),
        _Link(result.metadata.add),
        _Image(result.metadata.add),
        _Autolink(result.metadata.add),
        _ExtendedAutolink(result.metadata.add),
      ],
    ).parseInline(source);
    return result;
  }

  static String maskProtected(String source) {
    final parsed = analyze(source);
    return _replace(source, [...parsed.code, ...parsed.metadata], mask: true);
  }

  static String stripHtml(String source) =>
      source.contains('<') ? _replace(source, analyze(source).html) : source;

  /// 编辑器中的可见文字（如由 `&lt;` 解码的 `<tag>`）写回时不能变成 HTML。
  static String escapeHtml(String source) {
    if (!source.contains('<')) return source;
    var result = source;
    for (final range in analyze(source).html.reversed) {
      result = result.replaceRange(
        range.start,
        range.end,
        source.substring(range.start, range.end).replaceAll('<', r'\<'),
      );
    }
    return result;
  }

  static String _replace(
    String source,
    List<MarkdownSourceRange> ranges, {
    bool mask = false,
  }) {
    var result = source;
    for (final range in ranges..sort((a, b) => b.start.compareTo(a.start))) {
      result = result.replaceRange(
        range.start,
        range.end,
        mask ? 'x' * (range.end - range.start) : ' ',
      );
    }
    return result;
  }
}

class _Code extends md.CodeSyntax {
  _Code(this.onRange);
  final void Function(MarkdownSourceRange) onRange;
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    onRange((start: match.start, end: match.end));
    return super.onMatch(parser, match);
  }
}

class _Html extends md.InlineHtmlSyntax {
  _Html(this.onRange);
  final void Function(MarkdownSourceRange) onRange;
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    onRange((start: match.start, end: match.end));
    return super.onMatch(parser, match);
  }
}

mixin _Metadata on md.LinkSyntax {
  void Function(MarkdownSourceRange) get onRange;
  @override
  Iterable<md.Node>? close(
    md.InlineParser parser,
    covariant md.SimpleDelimiter opener,
    md.Delimiter? closer, {
    String? tag,
    required List<md.Node> Function() getChildren,
  }) {
    final start = parser.pos + 1;
    final nodes = super.close(
      parser,
      opener,
      closer,
      tag: tag,
      getChildren: getChildren,
    );
    if (nodes != null && parser.pos >= start) {
      onRange((start: start, end: parser.pos + 1));
    }
    return nodes;
  }
}

class _Link extends md.LinkSyntax with _Metadata {
  _Link(this.onRange);
  @override
  final void Function(MarkdownSourceRange) onRange;
}

class _Image extends md.ImageSyntax with _Metadata {
  _Image(this.onRange);
  @override
  final void Function(MarkdownSourceRange) onRange;
}

// 自动链接的可见 URL 同样是一个已消费的原子，路径内的协议示例不生效。
mixin _AutolinkRange on md.InlineSyntax {
  void Function(MarkdownSourceRange) get onRange;
  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final start = parser.pos;
    final matched = super.tryMatch(parser, startMatchPos);
    if (matched) onRange((start: start, end: parser.pos));
    return matched;
  }
}

class _Autolink extends md.AutolinkSyntax with _AutolinkRange {
  _Autolink(this.onRange);
  @override
  final void Function(MarkdownSourceRange) onRange;
}

class _ExtendedAutolink extends md.AutolinkExtensionSyntax with _AutolinkRange {
  _ExtendedAutolink(this.onRange);
  @override
  final void Function(MarkdownSourceRange) onRange;
}

import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';

/// 局部适配 markdown 7.3.1 的两个已复现阅读差异；代码内部仍由 CodeSyntax 消费。
abstract final class MarkdownInlineCompatibilitySyntax {
  static List<md.InlineSyntax> create() => [
    _EntityAfterBacktick(),
    _StruckCode(),
    _PlainFormatting('**', 'strong', md.EmphasisSyntax.asterisk()),
    _PlainFormatting('~~', 'del', md.StrikethroughSyntax()),
  ];
}

class _EntityAfterBacktick extends md.InlineSyntax {
  _EntityAfterBacktick()
    : super(
        md.DecodeHtmlSyntax().pattern.pattern,
        startCharacter: 38,
        caseSensitive: false,
      );

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    if (parser.pos == 0 || parser.source[parser.pos - 1] != '`') return false;
    return super.tryMatch(parser, startMatchPos);
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    // 隔离到实体自身后仍由原解析器校验命名实体、数值范围及 HTML 转义，
    // 只避开其无条件的“前一个源码字符是反引号”拒绝分支。
    for (final node in md.Document(
      encodeHtml: parser.encodeHtml,
    ).parseInline(match[0]!)) {
      parser.addNode(node);
    }
    return true;
  }
}

class _StruckCode extends md.InlineSyntax {
  _StruckCode() : super(r'~~(?=`)', startCharacter: 126);
  static final _code = md.CodeSyntax().pattern;

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final start = startMatchPos ?? parser.pos;
    if (!parser.source.startsWith('~~`', start) ||
        (start > 0 && parser.source[start - 1] == '~')) {
      return false;
    }
    // 首个完整 code span 之后必须立即闭合；不能回溯寻找更远的反引号。
    final code = _code.matchAsPrefix(parser.source, start + 2);
    if (code == null ||
        !parser.source.startsWith('~~', code.end) ||
        (code.end + 2 < parser.source.length &&
            parser.source[code.end + 2] == '~')) {
      return false;
    }
    final syntax = md.StrikethroughSyntax();
    md.DelimiterRun? delimiter(int offset) => md.DelimiterRun.tryParse(
      parser,
      offset,
      offset + 2,
      syntax: syntax,
      tags: [md.DelimiterTag('del', 2)],
      node: md.Text('~~'),
      allowIntraWord: true,
    );
    final opener = delimiter(start);
    if (opener?.canOpen != true ||
        opener!.canClose ||
        delimiter(code.end)?.canClose != true) {
      return false;
    }
    parser.writeText();
    onMatch(parser, code);
    parser.consume(code.end + 2 - start);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    // 只提前消费完整“删除线包住一个 code span”。其余嵌套仍交给原
    // delimiter stack，避免其前一个格式消耗后 openersBottom 索引残留。
    final nodes = md.Document(
      inlineSyntaxes: [MarkdownInlineCodeSource.syntax()],
      encodeHtml: parser.encodeHtml,
    ).parseInline(match[0]!);
    parser.addNode(md.Element('del', nodes));
    return true;
  }
}

/// 无嵌套的双定界符纯文字可独立证明语义，避开相邻格式的索引缓存缺陷。
class _PlainFormatting extends md.InlineSyntax {
  _PlainFormatting(this.marker, this.tag, this.syntax)
    : super(
        '${RegExp.escape(marker)}'
        r'([^*_~`\\\[\]<\r\n]+)'
        '${RegExp.escape(marker)}',
        startCharacter: marker.codeUnitAt(0),
      );
  final String marker;
  final String tag;
  final md.DelimiterSyntax syntax;

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final start = startMatchPos ?? parser.pos;
    if (!parser.source.startsWith(marker, start) ||
        (start > 0 && parser.source[start - 1] == marker[0])) {
      return false;
    }
    final match = pattern.matchAsPrefix(parser.source, start);
    if (match == null ||
        (match.end < parser.source.length &&
            parser.source[match.end] == marker[0])) {
      return false;
    }
    md.DelimiterRun? delimiter(int offset) => md.DelimiterRun.tryParse(
      parser,
      offset,
      offset + 2,
      syntax: syntax,
      tags: [md.DelimiterTag(tag, 2)],
      node: md.Text(marker),
      allowIntraWord: true,
    );
    final opener = delimiter(start);
    if (opener?.canOpen != true ||
        opener!.canClose ||
        delimiter(match.end - 2)?.canClose != true) {
      return false;
    }
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: parser.encodeHtml,
    ).parseInline(match[0]!);
    if (nodes.length != 1 || nodes.single is! md.Element) return false;
    final element = nodes.single as md.Element;
    if (element.tag != tag ||
        element.children == null ||
        !element.children!.every((node) => node is md.Text)) {
      return false;
    }
    parser.writeText();
    parser.addNode(element);
    parser.consume(match.end - start);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) => false;
}

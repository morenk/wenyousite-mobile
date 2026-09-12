import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_container_quote_syntax.dart';

/// 保护区来自实际块和行内解析消费范围，URL/title 内的反引号不参与配对。
final class MarkdownSourceProtection {
  MarkdownSourceProtection._(this.lines) : maskedLines = List.of(lines);

  final List<String> lines;
  final List<String> maskedLines;
  final Set<int> blockLines = {};
  final Set<int> indentedCodeLines = {};
  final Set<int> codeLines = {};
  final Map<int, int> multilineCodeRanges = {};
  final Map<int, String> multilineCodeSources = {};
  final _codeSpans =
      <({int first, int column, int last, int end, String raw})>[];
  final Map<md.Line, int> _positions = {};
  final _localPositions = Expando<Map<md.Line, int>>();
  final _sourcePositions = Expando<List<int>>();
  final _listScopes = <_ListScope>[];
  late final List<String> _parseLines;

  static MarkdownSourceProtection analyze(List<String> lines) {
    final raw = _analyze(lines);
    return _analyze(lines, protectedCode: raw.codeLines);
  }

  /// 仅阅读投影：真实 code span 中的 LF 在 CommonMark 中就是空格。
  /// 先投影可避免自定义空段语法在代码内部打断原生段落；不改持久化源码。
  static String prepareForReader(String markdown) {
    final source = markdown.replaceAll(RegExp(r'\r\n?'), '\n');
    if (!source.contains('\n') || !source.contains('`')) return source;
    final lines = source.split('\n');
    final protection = analyze(lines);
    final offsets = <int>[];
    var offset = 0;
    for (final line in lines) {
      offsets.add(offset);
      offset += line.length + 1;
    }
    var result = source;
    for (final span in protection._codeSpans.reversed) {
      result = result.replaceRange(
        offsets[span.first] + span.column,
        offsets[span.last] + span.end,
        span.raw.replaceAll('\n', ' '),
      );
    }
    return result;
  }

  static MarkdownSourceProtection _analyze(
    List<String> lines, {
    Set<int>? protectedCode,
  }) {
    final result = MarkdownSourceProtection._(lines);
    if (lines.isEmpty) return result;
    result._parseLines = lines;
    final template = md.BlockParser(
      const [],
      md.Document(extensionSet: md.ExtensionSet.gitHubFlavored),
    );
    final syntaxes = <md.BlockSyntax>[
      if (protectedCode != null) _ProtocolEmpty(result, protectedCode),
      for (final syntax in template.blockSyntaxes)
        switch (syntax) {
          md.FencedCodeBlockSyntax() => _Fence(result),
          md.HtmlBlockSyntax() => _Html(result),
          md.CodeBlockSyntax() => _Indent(result),
          md.BlockquoteSyntax() => _Quote(result),
          md.ListSyntax() => _List(result, syntax),
          md.ParagraphSyntax() => _Paragraph(result),
          _ => syntax,
        },
    ];
    final document = md.Document(
      blockSyntaxes: syntaxes,
      withDefaultBlockSyntaxes: false,
    );
    final parser = md.BlockParser(
      result._parseLines.map(md.Line.new).toList(),
      document,
    );
    result._positions.addAll({
      for (var i = 0; i < parser.lines.length; i++) parser.lines[i]: i,
    });
    parser.parseLines();
    return result;
  }

  int position(md.BlockParser parser) => parser.isDone
      ? parser.lines.length
      : (_localPositions[parser] ??= {
          for (var i = 0; i < parser.lines.length; i++) parser.lines[i]: i,
        })[parser.current]!;

  List<int>? sourcePositions(md.BlockParser parser) {
    final cached = _sourcePositions[parser];
    if (cached != null) return cached;
    final anchor = parser.lines.indexWhere(_positions.containsKey);
    if (anchor < 0) return _listSourcePositions(parser);
    final offset = _positions[parser.lines[anchor]]! - anchor;
    final result = <int>[];
    for (var i = 0; i < parser.lines.length; i++) {
      final row = offset + i;
      if (row < 0 ||
          row >= lines.length ||
          !_parseLines[row].endsWith(parser.lines[i].content)) {
        return null;
      }
      result.add(row);
      _positions[parser.lines[i]] = row;
    }
    return _sourcePositions[parser] = result;
  }

  List<int>? _listSourcePositions(md.BlockParser parser) {
    if (_listScopes.isEmpty || parser.parentSyntax is! md.ListSyntax) {
      return null;
    }
    final scope = _listScopes.last;
    if (identical(scope.parser, parser)) return null;
    final parent = sourcePositions(scope.parser);
    if (parent == null) return null;
    // ListSyntax 逐项按原顺序消费，只在已消费的容器范围匹配完整去缩进子行。
    // 游标单向前进，不按全文相同文字猜测来源，也不越过当前容器。
    final end = position(scope.parser);
    for (
      var start = scope.cursor;
      start + parser.lines.length <= end;
      start++
    ) {
      var matches = true;
      for (var i = 0; i < parser.lines.length; i++) {
        if (!lines[parent[start + i]].endsWith(parser.lines[i].content)) {
          matches = false;
          break;
        }
      }
      if (!matches) continue;
      final positions = parent.sublist(start, start + parser.lines.length);
      for (var i = 0; i < positions.length; i++) {
        _positions[parser.lines[i]] = positions[i];
      }
      scope.cursor = start + parser.lines.length;
      return _sourcePositions[parser] = positions;
    }
    return null;
  }

  void protectBlock(md.BlockParser parser, int start, {bool indented = false}) {
    final positions = sourcePositions(parser);
    if (positions == null) return;
    blockLines.addAll(positions.sublist(start, position(parser)));
    if (indented) {
      indentedCodeLines.addAll(positions.sublist(start, position(parser)));
    }
  }

  void inspectInline(md.BlockParser parser, int start, int end) {
    final positions = sourcePositions(parser);
    if (positions == null) return;
    final content = <String>[];
    final prefixes = <int>[];
    for (var i = start; i < end; i++) {
      final row = positions[i];
      final prefix = _parseLines[row].length - parser.lines[i].content.length;
      prefixes.add(prefix);
      content.add(lines[row].substring(prefix));
    }
    final source = content.join('\n');
    md.Document(
      encodeHtml: false,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        _Code((offset, raw) {
          final firstLine = '\n'.allMatches(source.substring(0, offset)).length;
          final firstColumn =
              offset - source.substring(0, offset).lastIndexOf('\n') - 1;
          final parts = raw.split('\n');
          if (parts.length > 1) {
            final codeStart = positions[start + firstLine];
            final codeEnd = positions[start + firstLine + parts.length - 1];
            _codeSpans.add((
              first: codeStart,
              column: prefixes[firstLine] + firstColumn,
              last: codeEnd,
              end: prefixes[firstLine + parts.length - 1] + parts.last.length,
              raw: raw,
            ));
            final previous = multilineCodeRanges.entries.lastOrNull;
            // 同一行结束并再次开始的 code span 需要一起解析；范围外段落独立。
            if (previous != null && previous.value >= codeStart) {
              multilineCodeRanges[previous.key] = codeEnd;
            } else {
              multilineCodeRanges[codeStart] = codeEnd;
            }
            final rangeStart = previous != null && previous.value >= codeStart
                ? previous.key
                : codeStart;
            final localStart = positions.indexOf(rangeStart) - start;
            final localEnd = firstLine + parts.length;
            multilineCodeSources[rangeStart] = [
              lines[rangeStart],
              ...content.sublist(localStart + 1, localEnd),
            ].join('\n');
          }
          for (var i = 0; i < parts.length; i++) {
            final line = positions[start + firstLine + i];
            final column = prefixes[firstLine + i] + (i == 0 ? firstColumn : 0);
            final original = maskedLines[line];
            maskedLines[line] = original.replaceRange(
              column,
              column + parts[i].length,
              'x' * parts[i].length,
            );
            codeLines.add(line);
          }
        }),
      ],
    ).parseInline(source);
  }
}

class _Quote extends MarkdownContainerQuoteSyntax {
  _Quote(this.result);
  final MarkdownSourceProtection result;
  @override
  void collectedLines(md.BlockParser parser, List<md.Line> children) {
    final positions = result.sourcePositions(parser);
    if (positions == null) return;
    final start = result.position(parser) - children.length;
    for (var i = 0; i < children.length; i++) {
      final source = positions[start + i];
      if (!result.lines[source].endsWith(children[i].content)) return;
    }
    for (var i = 0; i < children.length; i++) {
      result._positions[children[i]] = positions[start + i];
    }
  }
}

class _List extends md.ListSyntax {
  _List(this.result, this.delegate);
  final MarkdownSourceProtection result;
  final md.ListSyntax delegate;
  @override
  RegExp get pattern => delegate.pattern;
  @override
  md.Node parse(md.BlockParser parser) {
    result.sourcePositions(parser);
    result._listScopes.add(_ListScope(parser, result.position(parser)));
    try {
      return delegate.parse(parser);
    } finally {
      result._listScopes.removeLast();
    }
  }
}

class _ListScope {
  _ListScope(this.parser, this.cursor);
  final md.BlockParser parser;
  int cursor;
}

class _Fence extends md.FencedCodeBlockSyntax {
  _Fence(this.result);
  final MarkdownSourceProtection result;
  @override
  md.Node parse(md.BlockParser parser) {
    final start = result.position(parser);
    final node = super.parse(parser);
    result.protectBlock(parser, start);
    return node;
  }
}

class _Html extends md.HtmlBlockSyntax {
  _Html(this.result);
  final MarkdownSourceProtection result;
  @override
  md.Node parse(md.BlockParser parser) {
    final start = result.position(parser);
    final node = super.parse(parser);
    result.protectBlock(parser, start);
    return node;
  }
}

class _Indent extends md.CodeBlockSyntax {
  _Indent(this.result);
  final MarkdownSourceProtection result;
  @override
  md.Node parse(md.BlockParser parser) {
    final start = result.position(parser);
    final node = super.parse(parser);
    result.protectBlock(parser, start, indented: true);
    return node;
  }
}

class _Paragraph extends md.ParagraphSyntax {
  _Paragraph(this.result);
  final MarkdownSourceProtection result;
  @override
  md.Node? parse(md.BlockParser parser) {
    final start = result.position(parser);
    final node = super.parse(parser);
    if (node != null) {
      result.inspectInline(parser, start, result.position(parser));
    }
    return node;
  }
}

class _Code extends md.CodeSyntax {
  _Code(this.onCode);
  final void Function(int offset, String source) onCode;
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    onCode(parser.pos, match.group(0)!);
    return super.onMatch(parser, match);
  }
}

class _ProtocolEmpty extends md.BlockSyntax {
  const _ProtocolEmpty(this.result, this.protectedCode);
  final MarkdownSourceProtection result;
  final Set<int> protectedCode;
  @override
  bool canParse(md.BlockParser parser) {
    if (!super.canParse(parser)) return false;
    final positions = result.sourcePositions(parser);
    return positions == null ||
        !protectedCode.contains(positions[result.position(parser)]);
  }

  @override
  RegExp get pattern =>
      RegExp(r'^ {0,3}<br\s*/?>[\t ]*$', caseSensitive: false);
  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();
    return md.Element.empty('wenyou-empty');
  }
}

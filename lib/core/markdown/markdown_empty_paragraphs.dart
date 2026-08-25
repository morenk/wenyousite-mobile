import 'package:markdown/markdown.dart' as md;

/// Compatibility rules for Markdown v3 empty paragraphs.
///
/// A standalone `<br />` is the canonical empty-paragraph marker. Historical
/// clients stored repeated blank lines instead, but CommonMark collapses those
/// lines while rendering. Recovery therefore happens only while reading old
/// content; the editor writes canonical markers on its next save.
class MarkdownEmptyParagraphs {
  MarkdownEmptyParagraphs._();

  static final _blankLine = RegExp(r'^[\t ]*$');
  static final _emptyParagraph = RegExp(
    r'^ {0,3}<br\s*/?>[\t ]*$',
    caseSensitive: false,
  );

  /// Recovers historical top-level blank paragraphs without touching literal
  /// fenced code, indented code, or raw HTML blocks.
  static String recoverLegacy(String markdown) {
    final normalized = markdown.replaceAll(RegExp(r'\r\n?'), '\n');
    if (!normalized.contains('\n')) return normalized;

    final lines = normalized.split('\n');
    if (lines.every(_blankLine.hasMatch)) return normalized;
    if (!_hasRecoverableRun(lines)) return normalized;
    final protectedLines = _protectedLineIndexes(lines);

    final output = <String>[];
    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      if (!_blankLine.hasMatch(line) || protectedLines.contains(index)) {
        output.add(line);
        index += 1;
        continue;
      }

      final start = index;
      while (index < lines.length &&
          _blankLine.hasMatch(lines[index]) &&
          !protectedLines.contains(index)) {
        index += 1;
      }
      final runLength = index - start;
      final atStart = start == 0;
      final atEnd = index == lines.length;

      if (atStart) {
        for (var count = 0; count < runLength; count++) {
          output
            ..add('<br />')
            ..add('');
        }
        continue;
      }

      // One line is the normal paragraph boundary (or the trailing source
      // newline). Only the remaining lines represented historical empties.
      output.add('');
      for (var count = 1; count < runLength; count++) {
        output.add('<br />');
        if (!atEnd || count < runLength - 1) output.add('');
      }
    }

    return output.join('\n');
  }

  /// Prepares Markdown for the line-based Quill codec.
  ///
  /// Markdown parsers require blank separators around raw `<br />` blocks,
  /// while Quill would interpret those separators as additional editable
  /// paragraphs. This removes only separators adjacent to a protocol marker;
  /// ordinary paragraph boundaries remain unchanged.
  static String prepareForLineEditor(String markdown) {
    final lines = recoverLegacy(markdown).split('\n');
    for (var index = 0; index < lines.length; index++) {
      if (_emptyParagraph.hasMatch(lines[index])) lines[index] = '<br />';
    }

    final output = <String>[];
    var index = 0;
    while (index < lines.length) {
      if (!_blankLine.hasMatch(lines[index])) {
        output.add(lines[index]);
        index += 1;
        continue;
      }

      final start = index;
      while (index < lines.length && _blankLine.hasMatch(lines[index])) {
        index += 1;
      }
      final previousIsMarker =
          start > 0 && _emptyParagraph.hasMatch(lines[start - 1]);
      final nextIsMarker =
          index < lines.length && _emptyParagraph.hasMatch(lines[index]);
      if (!previousIsMarker && !nextIsMarker) {
        output.addAll(lines.getRange(start, index));
      }
    }
    return output.join('\n');
  }

  static bool _hasRecoverableRun(List<String> lines) {
    var index = 0;
    while (index < lines.length) {
      if (!_blankLine.hasMatch(lines[index])) {
        index += 1;
        continue;
      }
      final start = index;
      while (index < lines.length && _blankLine.hasMatch(lines[index])) {
        index += 1;
      }
      if (start == 0 || index - start > 1) return true;
    }
    return false;
  }

  static Set<int> _protectedLineIndexes(List<String> lines) {
    final collector = _ProtectedLineCollector(lines);
    md.Document(
      blockSyntaxes: [
        _RecordingFencedCodeSyntax(collector),
        _RecordingIndentedCodeSyntax(collector),
        _RecordingHtmlBlockSyntax(collector),
      ],
    ).parseLines(lines);
    return collector.indexes;
  }
}

class _ProtectedLineCollector {
  _ProtectedLineCollector(this.sourceLines);

  final List<String> sourceLines;
  final indexes = <int>{};

  int? begin(md.BlockParser parser) {
    if (!_isTopLevel(parser)) return null;
    return parser.lines.indexOf(parser.current);
  }

  void finish(md.BlockParser parser, int? start) {
    if (start == null) return;
    final end = parser.isDone
        ? sourceLines.length
        : parser.lines.indexOf(parser.current);
    for (var index = start; index < end; index++) {
      indexes.add(index);
    }
  }

  bool _isTopLevel(md.BlockParser parser) {
    if (parser.lines.length != sourceLines.length) return false;
    for (var index = 0; index < sourceLines.length; index++) {
      if (parser.lines[index].content != sourceLines[index]) return false;
    }
    return true;
  }
}

class _RecordingFencedCodeSyntax extends md.FencedCodeBlockSyntax {
  _RecordingFencedCodeSyntax(this.collector);

  final _ProtectedLineCollector collector;

  @override
  md.Node parse(md.BlockParser parser) {
    final start = collector.begin(parser);
    final node = super.parse(parser);
    collector.finish(parser, start);
    return node;
  }
}

class _RecordingIndentedCodeSyntax extends md.CodeBlockSyntax {
  _RecordingIndentedCodeSyntax(this.collector);

  final _ProtectedLineCollector collector;

  @override
  md.Node parse(md.BlockParser parser) {
    final start = collector.begin(parser);
    final node = super.parse(parser);
    collector.finish(parser, start);
    return node;
  }
}

class _RecordingHtmlBlockSyntax extends md.HtmlBlockSyntax {
  _RecordingHtmlBlockSyntax(this.collector);

  final _ProtectedLineCollector collector;

  @override
  md.Node parse(md.BlockParser parser) {
    final start = collector.begin(parser);
    final node = super.parse(parser);
    collector.finish(parser, start);
    return node;
  }
}

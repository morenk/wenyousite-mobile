import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';

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
    final protectedLines = _protectedLineIndexes(lines);
    for (var index = 0; index < lines.length; index++) {
      if (protectedLines.contains(index)) continue;
      if (_emptyParagraph.hasMatch(lines[index])) lines[index] = '<br />';
      if (MarkdownContent.isQuotedEmptyParagraphLine(lines[index])) {
        lines[index] = '> <br />';
      }
    }

    final output = <String>[];
    var index = 0;
    while (index < lines.length) {
      if (protectedLines.contains(index)) {
        output.add(lines[index++]);
        continue;
      }
      if (MarkdownContent.isEmptyQuoteLine(lines[index])) {
        final start = index;
        while (index < lines.length &&
            MarkdownContent.isEmptyQuoteLine(lines[index])) {
          index += 1;
        }
        final adjacentMarker =
            (start > 0 && lines[start - 1] == '> <br />') ||
            (index < lines.length && lines[index] == '> <br />');
        if (!adjacentMarker) output.addAll(lines.getRange(start, index));
        continue;
      }
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
    final protection = MarkdownSourceProtection.analyze(lines);
    return {...protection.blockLines, ...protection.codeLines};
  }
}

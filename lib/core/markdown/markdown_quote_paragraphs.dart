import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

/// An empty `>` between quoted paragraphs is Markdown syntax, not a blank
/// editor paragraph. Keep its source count on the preceding newline so soft
/// breaks, paragraph boundaries and quoted characters survive serialization.
abstract final class MarkdownQuoteParagraphs {
  static const separatorCountKey = 'wenyou_quote_separators';

  static Delta collapse(Delta source) {
    final lines = _QuoteLine.split(source);
    final output = <_QuoteLine>[];
    for (var index = 0; index < lines.length;) {
      final line = lines[index];
      if (!line.isEmptyQuote) {
        output.add(line);
        index += 1;
        continue;
      }
      var end = index + 1;
      while (end < lines.length && lines[end].isEmptyQuote) {
        end += 1;
      }
      if (output.isNotEmpty &&
          output.last.isQuoteContent &&
          end < lines.length &&
          lines[end].isQuoteContent) {
        output.last.attributes[separatorCountKey] = end - index;
      } else {
        // A standalone/leading/trailing empty quote has no two paragraphs
        // to join. Keep it editable, as well as all literal/code lines.
        output.addAll(lines.sublist(index, end));
      }
      index = end;
    }
    return _join(output);
  }

  static Delta expand(Delta source) {
    final lines = _QuoteLine.split(source);
    final output = <_QuoteLine>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final count = line.attributes.remove(separatorCountKey);
      output.add(line);
      if (count == null ||
          !line.isQuoteContent ||
          index + 1 == lines.length ||
          !lines[index + 1].isQuoteContent) {
        continue;
      }
      if (count is! int || count < 1 || count > 10000) {
        throw const MarkdownCodecException('引用段落无法安全保存');
      }
      for (var separator = 0; separator < count; separator++) {
        output.add(_QuoteLine(Delta(), {'blockquote': true}));
      }
    }
    return _join(output);
  }

  static Delta _join(List<_QuoteLine> lines) {
    final output = Delta();
    for (final line in lines) {
      for (final op in line.content.operations) {
        output.insert(op.data, op.attributes);
      }
      if (line.terminated) {
        output.insert('\n', line.attributes.isEmpty ? null : line.attributes);
      }
    }
    return output;
  }
}

final class _QuoteLine {
  _QuoteLine(this.content, this.attributes, {this.terminated = true});

  final Delta content;
  final Map<String, dynamic> attributes;
  final bool terminated;

  bool get isQuote =>
      terminated &&
      attributes['blockquote'] == true &&
      attributes['wenyou_literal_line'] != true;
  bool get isEmptyQuote => isQuote && content.isEmpty;
  bool get isQuoteContent => isQuote && content.isNotEmpty;

  static List<_QuoteLine> split(Delta source) {
    final lines = <_QuoteLine>[];
    var content = Delta();
    for (final op in source.operations) {
      final data = op.data;
      if (data is! String) {
        content.insert(data, op.attributes);
        continue;
      }
      final parts = data.split('\n');
      for (var index = 0; index < parts.length; index++) {
        if (parts[index].isNotEmpty) {
          final attributes = Map<String, dynamic>.from(op.attributes ?? {})
            ..remove(MarkdownQuoteParagraphs.separatorCountKey);
          content.insert(parts[index], attributes.isEmpty ? null : attributes);
        }
        if (index < parts.length - 1) {
          lines.add(_QuoteLine(content, Map.of(op.attributes ?? {})));
          content = Delta();
        }
      }
    }
    if (content.isNotEmpty) {
      lines.add(_QuoteLine(content, {}, terminated: false));
    }
    return lines;
  }
}

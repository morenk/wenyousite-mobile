import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';

/// 正文段落边界只占一行高度；持久化时仍使用既有 Markdown 空行语法。
/// 单 LF 不带此属性，因此旧内容及 Shift+Enter 仍属于同一个排版段。
abstract final class MarkdownParagraphBoundaries {
  static const key = 'wenyou_paragraph_separators';

  static Delta collapse(Delta source) {
    final lines = _ParagraphLine.split(source);
    final output = <_ParagraphLine>[];
    for (var index = 0; index < lines.length;) {
      final line = lines[index];
      if (!line.isSourceSeparator) {
        output.add(line);
        index++;
        continue;
      }
      var end = index + 1;
      while (end < lines.length && lines[end].isSourceSeparator) {
        end++;
      }
      if (output.isNotEmpty &&
          output.last.isBody &&
          end < lines.length &&
          lines[end].isBody) {
        output.last.attributes[key] = end - index;
      } else {
        output.addAll(lines.sublist(index, end));
      }
      index = end;
    }
    for (var index = 0; index + 1 < output.length; index++) {
      final line = output[index];
      final next = output[index + 1];
      // 真空行本身就是独立段落；重开后填写它也不能合并前后排版。
      if (line.isBody &&
          next.isBody &&
          ((line.isEmpty &&
                  line.attributes['wenyou_empty_paragraph'] == true) ||
              (next.isEmpty &&
                  next.attributes['wenyou_empty_paragraph'] == true))) {
        line.attributes[key] = 1;
      }
    }
    return _join(output);
  }

  static Delta expand(Delta source) {
    final lines = _ParagraphLine.split(source);
    final output = <_ParagraphLine>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final count = line.attributes.remove(key);
      output.add(line);
      if (count == null) continue;
      if (count is! int || count < 1 || count > 10000) {
        throw const MarkdownCodecException('正文段落无法安全保存');
      }
      if (!line.isBody ||
          line.isEmpty ||
          index + 1 == lines.length ||
          !lines[index + 1].isBody ||
          lines[index + 1].isEmpty) {
        continue;
      }
      for (var separator = 0; separator < count; separator++) {
        output.add(_ParagraphLine(Delta(), {'wenyou_source_separator': true}));
      }
    }
    return _join(output);
  }

  /// 返回光标所在正文段的范围，包含旧软换行，排除相邻独立段。
  static ({int start, int end})? range(Delta source, int position) {
    final lines = _ParagraphLine.split(source);
    final starts = <int>[];
    var offset = 0;
    var selected = -1;
    for (var index = 0; index < lines.length; index++) {
      starts.add(offset);
      offset += lines[index].length;
      if (position >= starts.last && position < offset) selected = index;
    }
    if (selected < 0 || !lines[selected].isBody) return null;
    var first = selected;
    var last = selected;
    while (first > 0 && _joins(lines[first - 1], lines[first])) {
      first--;
    }
    while (last + 1 < lines.length && _joins(lines[last], lines[last + 1])) {
      last++;
    }
    return (start: starts[first], end: starts[last] + lines[last].length);
  }

  static bool _joins(_ParagraphLine left, _ParagraphLine right) =>
      left.isBody &&
      right.isBody &&
      !left.isEmpty &&
      !right.isEmpty &&
      left.attributes[key] == null;

  static Delta _join(List<_ParagraphLine> lines) {
    final output = Delta();
    for (final line in lines) {
      for (final operation in line.content.operations) {
        output.insert(operation.data, operation.attributes);
      }
      if (line.terminated) {
        output.insert('\n', line.attributes.isEmpty ? null : line.attributes);
      }
    }
    return output;
  }
}

final class _ParagraphLine {
  _ParagraphLine(this.content, this.attributes, {this.terminated = true});

  final Delta content;
  final Map<String, dynamic> attributes;
  final bool terminated;

  int get length =>
      content.operations.fold(0, (sum, op) => sum + op.length!) +
      (terminated ? 1 : 0);
  bool get isEmpty => content.isEmpty;
  bool get isSourceSeparator =>
      isEmpty && attributes['wenyou_source_separator'] == true && isBodyStyle;
  bool get isBodyStyle => ![
    'header',
    'list',
    'blockquote',
    'indent',
    'code-block',
    'wenyou_literal_line',
  ].any((key) => attributes[key] != null && attributes[key] != false);
  bool get isBody =>
      terminated &&
      isBodyStyle &&
      !isSourceSeparator &&
      !content.operations.any((operation) {
        final data = operation.data;
        return data is Map &&
            (data.containsKey('wenyou_image') ||
                data.containsKey('wenyou_horizontal_rule'));
      });

  static List<_ParagraphLine> split(Delta source) {
    final lines = <_ParagraphLine>[];
    var content = Delta();
    for (final operation in source.operations) {
      final data = operation.data;
      final textAttributes = Map<String, dynamic>.from(
        operation.attributes ?? {},
      )..remove(MarkdownParagraphBoundaries.key);
      if (data is! String) {
        content.insert(data, textAttributes.isEmpty ? null : textAttributes);
        continue;
      }
      final parts = data.split('\n');
      for (var index = 0; index < parts.length; index++) {
        if (parts[index].isNotEmpty) {
          content.insert(
            parts[index],
            textAttributes.isEmpty ? null : textAttributes,
          );
        }
        if (index + 1 < parts.length) {
          lines.add(
            _ParagraphLine(content, Map.of(operation.attributes ?? {})),
          );
          content = Delta();
        }
      }
    }
    if (content.isNotEmpty) {
      lines.add(_ParagraphLine(content, {}, terminated: false));
    }
    return lines;
  }
}

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';

/// Input provenance controls escaping inside a run, never its style boundary.
final class MarkdownDeltaInlineEncoder {
  MarkdownDeltaInlineEncoder(this.output);

  static const literalTextKey = 'wenyou_literal_text';
  static const markKeys = {'bold', 'italic', 'strike', 'code', 'link'};

  final StringBuffer output;
  final _pieces = <({String text, bool literal})>[];
  Map<String, dynamic> _marks = const {};
  String? _codeSource;

  static Map<String, dynamic> visibleMarks(Map<String, dynamic>? attributes) =>
      {
        for (final key in markKeys)
          if (attributes?[key] != null && attributes?[key] != false)
            key: attributes![key],
      };

  void add(String text, Map<String, dynamic>? attributes) {
    final marks = visibleMarks(attributes);
    final source = attributes?[MarkdownInlineCodeSource.key] as String?;
    if (!mapEquals(marks, _marks)) flush();
    _marks = marks;
    // Quill 插字会拆分来源属性；同样式代码仍必须只输出一对分隔符。
    _codeSource = _pieces.isEmpty || source == _codeSource ? source : null;
    _pieces.add((text: text, literal: attributes?[literalTextKey] == true));
  }

  void flush() {
    if (_pieces.isEmpty) return;
    final value = _pieces.map((piece) => piece.text).join();
    final code = _marks['code'] == true;
    if (code && _marks.length != 1) {
      throw const MarkdownCodecException('行内代码不能与其他行内格式组合');
    }
    if (code) {
      output.write(
        MarkdownInlineCodeSource.preserved(value, _codeSource) ??
            _inlineCode(value),
      );
    } else {
      final core = value.trim();
      final leading = value.length - value.trimLeft().length;
      final coreEnd = leading + core.length;
      final escaped = StringBuffer();
      var offset = 0;
      for (final piece in _pieces) {
        final start = (leading - offset).clamp(0, piece.text.length);
        final end = (coreEnd - offset).clamp(start, piece.text.length);
        final text = piece.text.substring(start, end);
        escaped.write(
          piece.literal ? MarkdownContent.literalizeInlineText(text) : text,
        );
        offset += piece.text.length;
      }
      var encoded = escaped.toString();
      final link = _marks['link'];
      if (link != null) {
        final uri = link is String ? Uri.tryParse(link) : null;
        if (uri == null ||
            !uri.hasScheme ||
            !MarkdownContent.isSafeLink(uri) ||
            RegExp(r'[\s)]').hasMatch(link as String)) {
          throw const MarkdownCodecException('这个链接暂时无法安全编辑');
        }
      }
      if (core.isNotEmpty) {
        // Shared v7 nesting: bold → italic → link → strike.
        if (_marks['strike'] == true) encoded = '~~$encoded~~';
        if (link != null) encoded = '[$encoded]($link)';
        if (_marks['italic'] == true) encoded = '*$encoded*';
        if (_marks['bold'] == true) encoded = '**$encoded**';
      }
      output
        ..write(value.substring(0, leading))
        ..write(encoded)
        ..write(value.substring(coreEnd));
    }
    _pieces.clear();
    _marks = const {};
    _codeSource = null;
  }

  static String _inlineCode(String value) {
    var longestRun = 0;
    var currentRun = 0;
    for (final unit in value.codeUnits) {
      if (unit == 0x60) {
        currentRun += 1;
        if (currentRun > longestRun) longestRun = currentRun;
      } else {
        currentRun = 0;
      }
    }
    final delimiter = '`' * (longestRun + 1);
    final padding =
        value.startsWith('`') ||
        value.endsWith('`') ||
        (value.startsWith(' ') &&
            value.endsWith(' ') &&
            value.trim().isNotEmpty);
    return '$delimiter${padding ? ' ' : ''}$value${padding ? ' ' : ''}$delimiter';
  }
}

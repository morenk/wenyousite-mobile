import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_boundary.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_code_source.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_inline_runs.dart';

/// Input provenance controls escaping inside a run, never its style boundary.
final class MarkdownDeltaInlineEncoder {
  MarkdownDeltaInlineEncoder(this.output);

  static const literalTextKey = 'wenyou_literal_text';
  static const markKeys = {'bold', 'italic', 'strike', 'code', 'link'};

  final StringBuffer output;
  final _pieces = <({String text, bool literal})>[];
  final _runs = <MarkdownInlineRun>[];
  final _legacy = StringBuffer();
  bool _hasLiteralInput = false;
  Map<String, dynamic> _marks = const {};
  String? _codeSource;

  static Map<String, dynamic> visibleMarks(Map<String, dynamic>? attributes) =>
      {
        for (final key in markKeys)
          if (attributes?[key] != null && attributes?[key] != false)
            key: attributes![key],
      };

  void add(String text, Map<String, dynamic>? attributes) {
    _hasLiteralInput |= attributes?[literalTextKey] == true;
    final marks = visibleMarks(attributes);
    final source = attributes?[MarkdownInlineCodeSource.key] as String?;
    if (!mapEquals(marks, _marks)) _finishRun();
    _marks = marks;
    // Quill 插字会拆分来源属性；同样式代码仍必须只输出一对分隔符。
    _codeSource = _pieces.isEmpty || source == _codeSource ? source : null;
    _pieces.add((text: text, literal: attributes?[literalTextKey] == true));
  }

  void flush({bool preserveSourceWhitespace = false}) {
    _finishRun();
    if (_runs.isEmpty) return;
    final normalized = MarkdownInlineRuns.normalizeEdges(_runs);
    final legacy = MarkdownInlineBoundary.canonicalize(_legacy.toString());
    if (normalized.every((run) => run.marks.isEmpty)) {
      // 兼容原文和块级空白由外层编码器及最终语义门禁处理。
      // 无样式源码不能被此处行内回退猜测为用户新输入。
      output.write(
        _hasLiteralInput && !preserveSourceWhitespace
            ? _protectWhitespace(legacy)
            : legacy,
      );
      _legacy.clear();
      _runs.clear();
      _hasLiteralInput = false;
      return;
    }
    var encoded =
        !RegExp(r'\*{4,}|_{4,}|~{4,}').hasMatch(legacy) &&
            MarkdownInlineRuns.matches(legacy, normalized)
        ? legacy
        : MarkdownInlineRuns.write(normalized);
    for (final markers in [('**', '*'), ('__', '*'), ('__', '_')]) {
      if (MarkdownInlineRuns.matches(encoded, normalized)) break;
      encoded = MarkdownInlineRuns.write(
        normalized,
        bold: markers.$1,
        italic: markers.$2,
      );
    }
    if (!MarkdownInlineRuns.matches(encoded, normalized)) {
      throw const MarkdownCodecException('行内格式无法安全保存');
    }
    output.write(
      preserveSourceWhitespace ? encoded : _protectWhitespace(encoded),
    );
    _legacy.clear();
    _runs.clear();
    _hasLiteralInput = false;
  }

  // 新输入与格式区间的危险块级空白使用等价实体，不加入可见字符。
  // 原始无属性兼容源码仍由既有块级保护处理。
  static String _protectWhitespace(String source) {
    final leading = source.replaceFirstMapped(
      RegExp(r'^ +'),
      (match) => '&#32;' * match[0]!.length,
    );
    return leading.replaceFirstMapped(
      RegExp(r' {2,}$'),
      (match) => match.start > 0 && leading[match.start - 1] == '`'
          ? ' ${'&#32;' * (match[0]!.length - 1)}'
          : '&#32;' * match[0]!.length,
    );
  }

  void _finishRun() {
    if (_pieces.isEmpty) return;
    _validateLink();
    final value = _pieces.map((piece) => piece.text).join();
    final code = _marks['code'] == true;
    if (code) {
      final source =
          MarkdownInlineCodeSource.preserved(value, _codeSource) ??
          _inlineCode(value);
      _runs.add(MarkdownInlineRun(value, _marks, codeSource: source));
      _legacy.write(_wrap(source));
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
      if (core.isNotEmpty) {
        encoded = _wrap(encoded);
      }
      _runs.add(MarkdownInlineRun(value, _marks));
      _legacy
        ..write(value.substring(0, leading))
        ..write(encoded)
        ..write(value.substring(coreEnd));
    }
    _pieces.clear();
    _marks = const {};
    _codeSource = null;
  }

  void _validateLink() {
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
  }

  String _wrap(String encoded) {
    final link = _marks['link'];
    if (_marks['strike'] == true) encoded = '~~$encoded~~';
    if (link != null) encoded = '[$encoded]($link)';
    if (_marks['italic'] == true) encoded = '*$encoded*';
    if (_marks['bold'] == true) encoded = '**$encoded**';
    return encoded;
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

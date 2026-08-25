import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

class MarkdownContent {
  MarkdownContent._();

  static final _emptyImage = RegExp(r'!\[[^\]]*\]\(\s*\)');
  static final _emptyLink = RegExp(r'\[[^\]]*\]\(\s*\)');
  static final _image = RegExp(r'!\[[^\]]*\]\(\s*[^)\s]+[^)]*\)');
  static final _link = RegExp(r'\[([^\]]+)\]\(\s*[^)\s]+[^)]*\)');
  static final _httpAutolink = RegExp(
    r'<https?://[^\s<>]+>',
    caseSensitive: false,
    unicode: true,
  );
  static final _html = RegExp(r'<[^>]*>');
  static final _emptyParagraph = RegExp(
    r'^ {0,3}<br\s*/?>[\t ]*$',
    caseSensitive: false,
  );
  static final _thematicBreak = RegExp(
    r'^ {0,3}(?:(?:\*\s*){3,}|(?:-\s*){3,}|(?:_\s*){3,})$',
  );
  static final _defaultIgnorable = RegExp(
    r'[\u00AD\u034F\u061C\u115F\u1160\u17B4\u17B5\u180B-\u180F'
    r'\u200B-\u200F\u202A-\u202E\u2060-\u206F\u3164\uFE00-\uFE0F'
    r'\uFEFF\uFFA0]',
    unicode: true,
  );
  static final _diceNode = RegExp(
    r'^\[\[dice:v1:([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}):([^\]\r\n]+)\]\]',
    caseSensitive: false,
  );
  static final _previewImage = RegExp(
    r'!\[([^\]]*)\]\(\s*[^)\s]+[^)]*\)',
    unicode: true,
  );
  static final _previewUrl = RegExp(
    r'https?://[^\s<>()]+',
    caseSensitive: false,
    unicode: true,
  );
  static final _previewDice = RegExp(
    r'\[\[dice:v1:[0-9a-f-]+:([^\]\r\n]+)\]\]',
    caseSensitive: false,
  );
  static final _taskList = RegExp(
    r'^(?: {0,3}>[\t ]*)*[\t ]*(?:[-+*]|\d+[.)])[\t ]+\[[ xX]\](?:[\t ]|$)',
    unicode: true,
  );
  static final _atxHeading = RegExp(r'^ {0,3}(#{1,6})(?:[\t ]|$)');
  static final _fenceStart = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  static final _tableDelimiter = RegExp(
    r'^\s*\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$',
  );
  static final _listItem = RegExp(r'^(\s*)(?:[-+*]|\d+[.)])[\t ]+');
  static final _unknownProtocol = RegExp(
    r'\[\[([a-z][a-z0-9_-]*):v(\d+):',
    caseSensitive: false,
  );
  static final _htmlToken = RegExp(r'<[^>]*>');
  static final _literalPunctuation = RegExp(
    r'''[!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]''',
  );
  static const _wordJoiner = '\u2060';

  /// Escapes untrusted editor text without adding block separators.
  ///
  /// Formatting syntax emitted by the Delta codec is added after this step,
  /// so text entered through an IME or clipboard can never create Markdown
  /// nodes merely by containing punctuation.
  static String literalizeInlineText(String value) => value.replaceAllMapped(
    _literalPunctuation,
    (match) => '\\${match.group(0)}',
  );

  /// Returns whether [line] contains the canonical safety encoding produced
  /// by [literalizeLine]. This is used only while reopening saved drafts so
  /// escape slashes and whitespace guards are not exposed in the editor.
  static bool hasCanonicalLiteralEncoding(String line) =>
      decodeLiteralSpans(line) != null;

  /// Replaces decoded literal characters with a private-use placeholder so a
  /// rich-line parser can still recognize supported formatting around them.
  /// The placeholder is never persisted and the method declines the rare
  /// source line that already contains it.
  static ({String source, String placeholder, List<String> literals})?
  maskCanonicalLiteralLine(String line) {
    const placeholder = '\uE000';
    if (line.contains(placeholder)) return null;
    final spans = decodeLiteralSpans(line);
    if (spans == null) return null;
    final source = StringBuffer();
    final literals = <String>[];
    for (final span in spans) {
      if (!span.literal) {
        source.write(span.text);
        continue;
      }
      for (var index = 0; index < span.text.length; index++) {
        source.write(placeholder);
        literals.add(span.text[index]);
      }
    }
    return (
      source: source.toString(),
      placeholder: placeholder,
      literals: List.unmodifiable(literals),
    );
  }

  /// Decodes saved safety escapes while retaining which visible characters
  /// must be escaped again. Unmarked text can still be decoded as supported
  /// rich Markdown by the caller without turning an escaped character back
  /// into syntax.
  static List<({String text, bool literal})>? decodeLiteralSpans(String line) {
    var source = line;
    var foundEncoding = false;
    if (source.startsWith(_wordJoiner) &&
        (source.substring(1).startsWith('    ') ||
            source.substring(1).startsWith('\t'))) {
      source = source.substring(1);
      foundEncoding = true;
    }
    if (source.endsWith(_wordJoiner) &&
        RegExp(r' {2,}\u2060$').hasMatch(source)) {
      source = source.substring(0, source.length - 1);
      foundEncoding = true;
    }

    final spans = <({String text, bool literal})>[];
    final plain = StringBuffer();
    void flushPlain() {
      if (plain.isEmpty) return;
      spans.add((text: plain.toString(), literal: false));
      plain.clear();
    }

    var index = 0;
    while (index < source.length) {
      if (source[index] != r'\') {
        plain.write(source[index]);
        index += 1;
        continue;
      }
      var end = index;
      while (end < source.length && source[end] == r'\') {
        end += 1;
      }
      final count = end - index;
      final escapedBackslashes = count ~/ 2;
      final escapedPunctuation =
          count.isOdd &&
          end < source.length &&
          _literalPunctuation.hasMatch(source[end]);
      if (escapedBackslashes > 0 || escapedPunctuation) {
        flushPlain();
        spans.add((
          text:
              '${r'\' * escapedBackslashes}'
              '${escapedPunctuation ? source[end] : ''}',
          literal: true,
        ));
        foundEncoding = true;
        index = escapedPunctuation ? end + 1 : end;
        continue;
      }
      plain.write(r'\');
      index = end;
    }
    flushPlain();
    return foundEncoding ? List.unmodifiable(spans) : null;
  }

  /// Reverses only the canonical safety encoding used by this client.
  /// Legitimate word joiners elsewhere in the line are preserved.
  static String decodeLiteralLine(String line) {
    final spans = decodeLiteralSpans(line);
    return spans == null ? line : spans.map((span) => span.text).join();
  }

  /// Prevents plain leading indentation and trailing spaces from becoming
  /// code blocks or hard breaks. The guards are removed again by
  /// [decodeLiteralLine].
  static String protectUnsafeWhitespace(String line) {
    var protected = line;
    if (protected.startsWith('    ') || protected.startsWith('\t')) {
      protected = '$_wordJoiner$protected';
    }
    if (RegExp(r' {2,}$').hasMatch(protected)) {
      protected = '$protected$_wordJoiner';
    }
    return protected;
  }

  static String normalize(String markdown) {
    final lines = markdown.replaceAll(RegExp(r'\r\n?'), '\n').split('\n');
    _Fence? fence;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final fenceToken = _openingFence(line);
      if (fence != null) {
        final closing = _closingFence(line);
        if (closing != null &&
            closing.marker == fence.marker &&
            closing.length >= fence.length) {
          fence = null;
        }
        continue;
      }
      if (fenceToken != null) {
        fence = fenceToken;
        continue;
      }
      if (RegExp(
        r'^ {0,3}<br\s*/?>[\t ]*$',
        caseSensitive: false,
      ).hasMatch(line)) {
        lines[index] = '<br />';
        continue;
      }
      lines[index] = line.replaceAll(_emptyImage, '');
    }
    return lines.join('\n');
  }

  /// Converts Markdown v3 structures outside the product capability whitelist
  /// into visible literal text. This mirrors the backend migration contract:
  /// unsupported source remains readable but cannot be reinterpreted as an
  /// unsupported node when the editor serializes it again.
  static String literalizeUnsupported(String markdown) {
    final normalized = normalize(markdown);
    final lines = normalized.split('\n');
    final affected = _unsupportedLines(lines);
    if (affected.isEmpty) return normalized;

    final output = <String>[];
    for (var index = 0; index < lines.length; index++) {
      if (!affected.contains(index)) {
        output.add(lines[index]);
        continue;
      }
      if (output.isNotEmpty && output.last.isNotEmpty) output.add('');
      output.add(_escapeLiteralLine(lines[index]));
      if (index < lines.length - 1 && lines[index + 1].isNotEmpty) {
        output.add('');
      }
    }
    return output.join('\n');
  }

  static Set<int> unsupportedLineIndexes(String markdown) {
    final lines = normalize(markdown).split('\n');
    return Set<int>.unmodifiable(_unsupportedLines(lines));
  }

  static String literalizeLine(String line) => _escapeLiteralLine(line);

  static Set<int> _unsupportedLines(List<String> lines) {
    final affected = <int>{};
    _markFencedCode(lines, affected);
    _markTables(lines, affected);

    for (var index = 0; index < lines.length; index++) {
      if (affected.contains(index)) continue;
      final line = lines[index];
      final heading = _atxHeading.firstMatch(line)?.group(1);
      if (heading != null && (heading.length == 1 || heading.length >= 4)) {
        affected.add(index);
      }
      if (_taskList.hasMatch(line) || _isIndentedCode(line)) {
        affected.add(index);
      }
      final listIndent = _listItem.firstMatch(line)?.group(1);
      if (listIndent != null && _indentWidth(listIndent) >= 6) {
        affected.add(index);
      }
      if (_hasHardBreak(line) ||
          _hasRawHtml(line) ||
          _hasUnknownProtocol(line)) {
        affected.add(index);
      }
      if (index > 0 &&
          RegExp(r'^ {0,3}=+[\t ]*$').hasMatch(line) &&
          lines[index - 1].trim().isNotEmpty) {
        affected
          ..add(index - 1)
          ..add(index);
      }
    }
    return affected;
  }

  static void _markFencedCode(List<String> lines, Set<int> affected) {
    String? marker;
    var markerLength = 0;
    for (var index = 0; index < lines.length; index++) {
      final token = _fenceStart.firstMatch(lines[index])?.group(1);
      if (marker == null) {
        if (token == null) continue;
        marker = token[0];
        markerLength = token.length;
        affected.add(index);
        continue;
      }
      // Empty source lines need no escaping once the fence markers are
      // literal. Leaving them empty also keeps repeated sanitation stable.
      if (lines[index].isNotEmpty) affected.add(index);
      final closing = RegExp(
        '^ {0,3}${RegExp.escape(marker)}{$markerLength,}[\\t ]*\$',
      );
      if (closing.hasMatch(lines[index])) {
        marker = null;
        markerLength = 0;
      }
    }
  }

  static void _markTables(List<String> lines, Set<int> affected) {
    for (var index = 1; index < lines.length; index++) {
      if (!_tableDelimiter.hasMatch(lines[index]) ||
          !_hasUnescapedPipe(lines[index - 1])) {
        continue;
      }
      affected
        ..add(index - 1)
        ..add(index);
      var cursor = index + 1;
      while (cursor < lines.length && _hasUnescapedPipe(lines[cursor])) {
        affected.add(cursor);
        cursor += 1;
      }
    }
  }

  static bool _hasUnescapedPipe(String line) {
    for (var index = 0; index < line.length; index++) {
      if (line[index] == '|' && !_isEscaped(line, index)) return true;
    }
    return false;
  }

  static bool _isIndentedCode(String line) {
    if (line.trim().isEmpty || _listItem.hasMatch(line)) return false;
    return line.startsWith('    ') || line.startsWith('\t');
  }

  static int _indentWidth(String value) {
    var width = 0;
    for (final unit in value.codeUnits) {
      width += unit == 0x09 ? 4 : 1;
    }
    return width;
  }

  static bool _hasHardBreak(String line) {
    final spaces = RegExp(r' +$').firstMatch(line)?.group(0)?.length ?? 0;
    final slashes = RegExp(r'\\+$').firstMatch(line)?.group(0)?.length ?? 0;
    return spaces >= 2 || slashes.isOdd;
  }

  static bool _hasRawHtml(String line) {
    if (_emptyParagraph.hasMatch(line)) return false;
    for (final match in _htmlToken.allMatches(line)) {
      if (_isEscaped(line, match.start)) continue;
      final token = match.group(0)!;
      if (RegExp(
        r'^<https?://[^\s<>]+>$',
        caseSensitive: false,
      ).hasMatch(token)) {
        continue;
      }
      return true;
    }
    return false;
  }

  static bool _hasUnknownProtocol(String line) {
    final masked = _maskInlineCode(line);
    for (final match in _unknownProtocol.allMatches(masked)) {
      if (_isEscaped(line, match.start)) continue;
      if (match.group(1)!.toLowerCase() == 'dice' && match.group(2) == '1') {
        continue;
      }
      return true;
    }
    return false;
  }

  static String _maskInlineCode(String line) {
    final chars = List<String>.generate(
      line.length,
      (index) => line.substring(index, index + 1),
    );
    var index = 0;
    while (index < line.length) {
      if (line[index] != '`' || _isEscaped(line, index)) {
        index += 1;
        continue;
      }
      var length = 1;
      while (index + length < line.length && line[index + length] == '`') {
        length += 1;
      }
      final delimiter = '`' * length;
      final closing = line.indexOf(delimiter, index + length);
      if (closing < 0) {
        index += length;
        continue;
      }
      for (var cursor = index; cursor < closing + length; cursor++) {
        chars[cursor] = ' ';
      }
      index = closing + length;
    }
    return chars.join();
  }

  static bool _isEscaped(String value, int index) {
    var slashes = 0;
    for (
      var cursor = index - 1;
      cursor >= 0 && value[cursor] == r'\';
      cursor--
    ) {
      slashes += 1;
    }
    return slashes.isOdd;
  }

  static String _escapeLiteralLine(String line) {
    final escaped = protectUnsafeWhitespace(literalizeInlineText(line));
    return escaped.isEmpty ? _wordJoiner : escaped;
  }

  static bool hasVisibleContent(String markdown) {
    final lines = normalize(markdown).split('\n');
    _Fence? fence;
    for (final rawLine in lines) {
      final line = rawLine.trim();
      final fenceToken = _openingFence(rawLine);
      if (fence != null) {
        final closing = _closingFence(rawLine);
        if (closing != null &&
            closing.marker == fence.marker &&
            closing.length >= fence.length) {
          fence = null;
        } else if (_hasNonIgnorableText(line)) {
          return true;
        }
        continue;
      }
      if (fenceToken != null) {
        fence = fenceToken;
        continue;
      }
      if (line.isEmpty || _thematicBreak.hasMatch(rawLine)) continue;
      if (_image.hasMatch(line) || _httpAutolink.hasMatch(line)) return true;

      final visible = line
          .replaceAll(_emptyImage, '')
          .replaceAll(_emptyLink, '')
          .replaceAllMapped(_link, (match) => match.group(1) ?? '')
          .replaceAll(_html, '')
          .replaceFirst(RegExp(r'^[#>+\-\s]+', unicode: true), '')
          .replaceFirst(RegExp(r'^\d+[.)]\s*', unicode: true), '')
          .replaceAll(RegExp(r'[*_~`]'), '')
          .replaceAll(_defaultIgnorable, '')
          .trim();
      if (visible.isNotEmpty) return true;
    }
    return false;
  }

  static bool hasVisibleNonDiceContent(String markdown) =>
      hasVisibleContent(MarkdownDiceContract.removeMarkdownNodes(markdown));

  static bool isSafeLink(Uri uri) {
    return uri.scheme == 'https' ||
        uri.scheme == 'http' ||
        uri.scheme == 'mailto';
  }

  static bool isSafeImage(Uri uri) =>
      uri.scheme == 'https' || uri.scheme == 'http';

  static String toPlainTextPreview(String markdown, {int maxLength = 180}) {
    if (maxLength <= 0) return '';
    final visible = normalize(markdown)
        .replaceAllMapped(
          _previewDice,
          (match) => '[${match.group(1)!.trim()}]',
        )
        .replaceAll(_previewImage, '[图片]')
        .replaceAllMapped(_link, (match) => match.group(1) ?? '[链接]')
        .replaceAll(_httpAutolink, '[链接]')
        .replaceAll(_previewUrl, '[链接]')
        .replaceAll(_html, ' ')
        .replaceAll(RegExp(r'(^|\n)\s{0,3}(?:[#>+\-]|\d+[.)])\s*'), ' ')
        .replaceAll(RegExp(r'[`*_~|]'), '')
        .replaceAll(RegExp(r'\s+', unicode: true), ' ')
        .trim();
    final runes = visible.runes.toList(growable: false);
    if (runes.length <= maxLength) return visible;
    return '${String.fromCharCodes(runes.take(maxLength - 1))}…';
  }

  static String renderDiceForDisplay(
    String markdown,
    Map<String, String> labelsByNodeId,
  ) {
    return _renderDice(markdown, labelsByNodeId);
  }

  static String _renderDice(
    String markdown,
    Map<String, String> labelsByNodeId,
  ) {
    final lines = normalize(markdown).split('\n');
    _Fence? fence;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final opening = _openingFence(line);
      if (fence != null) {
        final closing = _closingFence(line);
        if (closing != null &&
            closing.marker == fence.marker &&
            closing.length >= fence.length) {
          fence = null;
        }
        continue;
      }
      if (opening != null) {
        fence = opening;
        continue;
      }
      lines[index] = _renderLineDice(line, labelsByNodeId);
    }
    return lines.join('\n');
  }

  static String _renderLineDice(
    String line,
    Map<String, String> labelsByNodeId,
  ) {
    final output = StringBuffer();
    var index = 0;
    while (index < line.length) {
      if (line[index] == r'\' && index + 1 < line.length) {
        output.write(line.substring(index, index + 2));
        index += 2;
        continue;
      }
      if (line[index] == '`') {
        var runLength = 1;
        while (index + runLength < line.length &&
            line[index + runLength] == '`') {
          runLength += 1;
        }
        final delimiter = '`' * runLength;
        final closing = line.indexOf(delimiter, index + runLength);
        if (closing == -1) {
          output.write(line.substring(index));
          break;
        }
        output.write(line.substring(index, closing + runLength));
        index = closing + runLength;
        continue;
      }
      final match = _diceNode.firstMatch(line.substring(index));
      if (match != null) {
        final nodeId = match.group(1)!.toLowerCase();
        final notation = match.group(2)!.trim();
        final label = labelsByNodeId[nodeId] ?? '$notation = ?';
        output.write(label);
        index += match.group(0)!.length;
        continue;
      }
      output.write(line[index]);
      index += 1;
    }
    return output.toString();
  }

  static bool _hasNonIgnorableText(String value) {
    return value.replaceAll(_defaultIgnorable, '').trim().isNotEmpty;
  }

  static _Fence? _openingFence(String line) {
    final match = RegExp(r'^ {0,3}(`{3,}|~{3,})').firstMatch(line);
    final token = match?.group(1);
    return token == null ? null : _Fence(token[0], token.length);
  }

  static _Fence? _closingFence(String line) {
    final match = RegExp(r'^ {0,3}(`{3,}|~{3,})[\t ]*$').firstMatch(line);
    final token = match?.group(1);
    return token == null ? null : _Fence(token[0], token.length);
  }
}

class _Fence {
  const _Fence(this.marker, this.length);

  final String marker;
  final int length;
}

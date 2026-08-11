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
        .replaceAllMapped(_previewImage, (match) {
          final alt = match.group(1)?.trim() ?? '';
          return alt.isEmpty ? '[图片]' : '[图片：$alt]';
        })
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
    return _renderDice(markdown, labelsByNodeId, markup: false);
  }

  /// Renders dice as inline elements so the reader can match Web's compact
  /// result/pending chips instead of seeing a standalone dice emoji.
  static String renderDiceMarkupForDisplay(
    String markdown,
    Map<String, String> labelsByNodeId,
  ) {
    return _renderDice(markdown, labelsByNodeId, markup: true);
  }

  static String _renderDice(
    String markdown,
    Map<String, String> labelsByNodeId, {
    required bool markup,
  }) {
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
      lines[index] = _renderLineDice(line, labelsByNodeId, markup: markup);
    }
    return lines.join('\n');
  }

  static String _renderLineDice(
    String line,
    Map<String, String> labelsByNodeId, {
    required bool markup,
  }) {
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
        if (markup) {
          final state = labelsByNodeId.containsKey(nodeId)
              ? 'result'
              : 'pending';
          output
            ..write('<wenyou-dice data-state="')
            ..write(state)
            ..write('">')
            ..write(_escapeHtml(label))
            ..write('</wenyou-dice>');
        } else {
          output.write(label);
        }
        index += match.group(0)!.length;
        continue;
      }
      output.write(line[index]);
      index += 1;
    }
    return output.toString();
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
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

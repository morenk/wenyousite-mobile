/// Restores supported emphasis syntax when strict CommonMark flanking rules
/// leave a delimiter literal beside punctuation.
///
/// The canonical form protects adjacent punctuation with a numeric character
/// reference and moves one known legacy separator outside bold. It changes no
/// rendered text or whitespace and keeps saved Markdown unambiguous.
abstract final class MarkdownInlineBoundary {
  static const _tokens = <String>['***', '___', '**', '__', '~~', '*', '_'];

  static final _definition = RegExp(r'^ {0,3}\[([^\]\r\n]+)\]:');
  static final _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  static final _closingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})[\t ]*\r?$');

  /// Canonicalizes one inline-capable source fragment.
  static String canonicalize(String source) =>
      _canonicalizeInline(source, shortcutReferences: const <String>{});

  /// Canonicalizes renderable text without entering protected Markdown nodes.
  ///
  /// Fenced/indented code and definitions are block-level protection. Inline
  /// code, links, images, autolinks and HTML tags are handled by the shared
  /// inline scanner. The returned value is a render-only equivalent: numeric
  /// references decode to the original visible characters.
  static String canonicalizeDocument(String source) {
    if (!_hasCandidateMarker(source)) return source;

    final lines = source.split('\n');
    final shortcutReferences = <String>{};
    for (final line in lines) {
      final definition = _definition.firstMatch(line);
      if (definition != null) {
        shortcutReferences.add(_normalizeReference(definition.group(1)!));
      }
    }

    String? fenceMarker;
    var fenceLength = 0;
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (fenceMarker != null) {
        final closing = _closingFence.firstMatch(line)?.group(1);
        if (closing != null &&
            closing[0] == fenceMarker &&
            closing.length >= fenceLength) {
          fenceMarker = null;
          fenceLength = 0;
        }
        continue;
      }

      final opening = _openingFence.firstMatch(line)?.group(1);
      if (opening != null) {
        fenceMarker = opening[0];
        fenceLength = opening.length;
        continue;
      }
      if (_definition.hasMatch(line) ||
          line.startsWith('    ') ||
          line.startsWith('\t')) {
        continue;
      }
      lines[index] = _canonicalizeInline(
        line,
        shortcutReferences: shortcutReferences,
      );
    }
    return lines.join('\n');
  }

  static String _canonicalizeInline(
    String source, {
    required Set<String> shortcutReferences,
  }) {
    if (!_hasCandidateMarker(source)) return source;

    final output = StringBuffer();
    var unchangedStart = 0;
    var index = 0;
    var changed = false;
    while (index < source.length) {
      // Inspect the escaped character on the next iteration. That lets an
      // escaped opening delimiter consume its own closing delimiter before a
      // later, independent candidate is considered.
      if (source[index] == r'\') {
        index += 1;
        continue;
      }
      final protectedEnd = _protectedInlineEnd(
        source,
        index,
        shortcutReferences: shortcutReferences,
      );
      if (protectedEnd != null) {
        index = protectedEnd;
        continue;
      }

      final token = _tokenAt(source, index);
      if (token == null) {
        index += 1;
        continue;
      }
      final closingMatch = _findClosing(
        source,
        token,
        index + token.length,
        shortcutReferences: shortcutReferences,
      );
      if (closingMatch == null) {
        index += token.length;
        continue;
      }

      final closing = closingMatch.index;
      final content = source.substring(index + token.length, closing);
      final previousStart = _previousRuneStart(source, index);
      final previous = previousStart == null
          ? null
          : _runeAt(source, previousStart);
      final nextIndex = closing + token.length;
      final next = nextIndex >= source.length
          ? null
          : _runeAt(source, nextIndex);
      final moveTrailingSpace = _hasTrailingSpaceBeforeCode(
        source,
        token: token,
        content: content,
        nextIndex: nextIndex,
      );
      if (closingMatch.containsProtected ||
          _isEscapedAt(source, index) ||
          _isEscapedAt(source, closing) ||
          (!moveTrailingSpace &&
              !_isRecoverable(content, previous: previous, next: next))) {
        index = nextIndex;
        continue;
      }

      final protectPrevious = _needsProtection(previous);
      final replacementStart = protectPrevious ? previousStart! : index;
      output.write(source.substring(unchangedStart, replacementStart));
      if (protectPrevious) output.write(_entity(previous!));

      final canonicalToken = switch (token.length) {
        1 => '*',
        2 when token != '~~' => '**',
        3 => '***',
        _ => token,
      };
      output
        ..write(canonicalToken)
        ..write(
          moveTrailingSpace
              ? content.substring(0, content.length - 1)
              : content,
        )
        ..write(canonicalToken);
      if (moveTrailingSpace) output.write(' ');

      var replacementEnd = nextIndex;
      if (_needsProtection(next)) {
        output.write(_entity(next!));
        replacementEnd += _runeLength(next);
      }
      unchangedStart = replacementEnd;
      index = replacementEnd;
      changed = true;
    }

    if (!changed) return source;
    output.write(source.substring(unchangedStart));
    return output.toString();
  }

  static bool _hasCandidateMarker(String source) =>
      source.contains('*') || source.contains('_') || source.contains('~~');

  static String? _tokenAt(String source, int index) {
    final marker = source[index];
    if (index > 0 && source[index - 1] == marker) return null;
    for (final token in _tokens) {
      if (!source.startsWith(token, index)) continue;
      if (_runLength(source, index, token[0]) != token.length) continue;
      return token;
    }
    return null;
  }

  static ({int index, bool containsProtected})? _findClosing(
    String source,
    String token,
    int start, {
    required Set<String> shortcutReferences,
  }) {
    var index = start;
    var containsProtected = false;
    while (index < source.length) {
      if (source[index] == r'\') {
        index += index + 1 < source.length ? 2 : 1;
        continue;
      }
      final protectedEnd = _protectedInlineEnd(
        source,
        index,
        shortcutReferences: shortcutReferences,
      );
      if (protectedEnd != null) {
        containsProtected = true;
        index = protectedEnd;
        continue;
      }
      if (source.startsWith(token, index) &&
          _runLength(source, index, token[0]) == token.length &&
          (index == 0 || source[index - 1] != token[0])) {
        return (index: index, containsProtected: containsProtected);
      }
      index += 1;
    }
    return null;
  }

  static int? _protectedInlineEnd(
    String source,
    int index, {
    required Set<String> shortcutReferences,
  }) {
    final character = source[index];
    if (character == '`') return _codeSpanEnd(source, index);
    if (character == '<') {
      final closing = source.indexOf('>', index + 1);
      return closing < 0 ? null : closing + 1;
    }
    if (character == '[' ||
        (character == '!' &&
            index + 1 < source.length &&
            source[index + 1] == '[')) {
      return _linkLikeEnd(
        source,
        index,
        shortcutReferences: shortcutReferences,
      );
    }
    return null;
  }

  static int? _codeSpanEnd(String source, int index) {
    final runLength = _runLength(source, index, '`');
    final delimiter = '`' * runLength;
    final closing = source.indexOf(delimiter, index + runLength);
    return closing < 0 ? null : closing + runLength;
  }

  static int? _linkLikeEnd(
    String source,
    int index, {
    required Set<String> shortcutReferences,
  }) {
    final bracketStart = source[index] == '!' ? index + 1 : index;
    if (bracketStart >= source.length || source[bracketStart] != '[') {
      return null;
    }
    final bracketEnd = _matchingDelimiter(source, bracketStart, '[', ']');
    if (bracketEnd == null) return null;

    final suffixStart = bracketEnd + 1;
    if (suffixStart < source.length && source[suffixStart] == '(') {
      final destinationEnd = _matchingDelimiter(source, suffixStart, '(', ')');
      return destinationEnd == null ? null : destinationEnd + 1;
    }
    if (suffixStart < source.length && source[suffixStart] == '[') {
      final referenceEnd = _matchingDelimiter(source, suffixStart, '[', ']');
      return referenceEnd == null ? null : referenceEnd + 1;
    }

    final label = source.substring(bracketStart + 1, bracketEnd);
    return shortcutReferences.contains(_normalizeReference(label))
        ? bracketEnd + 1
        : null;
  }

  static int? _matchingDelimiter(
    String source,
    int opening,
    String opener,
    String closer,
  ) {
    var depth = 1;
    var index = opening + 1;
    while (index < source.length) {
      if (source[index] == r'\') {
        index += index + 1 < source.length ? 2 : 1;
        continue;
      }
      if (source[index] == opener) {
        depth += 1;
      } else if (source[index] == closer) {
        depth -= 1;
        if (depth == 0) return index;
      }
      index += 1;
    }
    return null;
  }

  static String _normalizeReference(String value) =>
      value.trim().replaceAll(RegExp(r'[\t\r\n ]+'), ' ').toLowerCase();

  static bool _isEscapedAt(String source, int index) {
    var slashCount = 0;
    for (
      var cursor = index - 1;
      cursor >= 0 && source[cursor] == r'\';
      cursor--
    ) {
      slashCount += 1;
    }
    return slashCount.isOdd;
  }

  static bool _isRecoverable(
    String content, {
    required int? previous,
    required int? next,
  }) {
    if (content.isEmpty) return false;
    final first = content.runes.first;
    final last = content.runes.last;
    if (_isWhitespace(first) || _isWhitespace(last)) return false;
    final hasTightOutside =
        (previous != null && !_isWhitespace(previous)) ||
        (next != null && !_isWhitespace(next));
    return hasTightOutside &&
        (_isPunctuationOrSymbol(first) || _isPunctuationOrSymbol(last));
  }

  static bool _hasTrailingSpaceBeforeCode(
    String source, {
    required String token,
    required String content,
    required int nextIndex,
  }) {
    if (token != '**' ||
        !content.endsWith(' ') ||
        content.endsWith('  ') ||
        nextIndex >= source.length ||
        source[nextIndex] != '`') {
      return false;
    }
    final core = content.substring(0, content.length - 1);
    return core.isNotEmpty &&
        !_isWhitespace(core.runes.first) &&
        !_isWhitespace(core.runes.last) &&
        _codeSpanEnd(source, nextIndex) != null;
  }

  static bool _needsProtection(int? rune) =>
      rune != null && !_isWhitespace(rune) && !_isPunctuationOrSymbol(rune);

  static bool _isWhitespace(int rune) =>
      RegExp(r'^\s$', unicode: true).hasMatch(String.fromCharCode(rune));

  static bool _isPunctuationOrSymbol(int rune) =>
      (rune >= 0x21 && rune <= 0x2f) ||
      (rune >= 0x3a && rune <= 0x40) ||
      (rune >= 0x5b && rune <= 0x60) ||
      (rune >= 0x7b && rune <= 0x7e) ||
      (rune >= 0xa1 && rune <= 0xbf) ||
      (rune >= 0x2000 && rune <= 0x206f) ||
      (rune >= 0x2070 && rune <= 0x2bff) ||
      (rune >= 0x2e00 && rune <= 0x303f) ||
      (rune >= 0xfe10 && rune <= 0xfe6f) ||
      (rune >= 0xff01 && rune <= 0xff65) ||
      (rune >= 0x1f000 && rune <= 0x1fbff);

  static int _runLength(String source, int index, String marker) {
    var length = 0;
    while (index + length < source.length && source[index + length] == marker) {
      length += 1;
    }
    return length;
  }

  static int? _previousRuneStart(String source, int index) {
    if (index == 0) return null;
    final previous = source.codeUnitAt(index - 1);
    if (previous >= 0xdc00 &&
        previous <= 0xdfff &&
        index >= 2 &&
        source.codeUnitAt(index - 2) >= 0xd800 &&
        source.codeUnitAt(index - 2) <= 0xdbff) {
      return index - 2;
    }
    return index - 1;
  }

  static int _runeAt(String source, int index) {
    final first = source.codeUnitAt(index);
    if (first >= 0xd800 && first <= 0xdbff && index + 1 < source.length) {
      final second = source.codeUnitAt(index + 1);
      if (second >= 0xdc00 && second <= 0xdfff) {
        return 0x10000 + ((first - 0xd800) << 10) + second - 0xdc00;
      }
    }
    return first;
  }

  static int _runeLength(int rune) => rune > 0xffff ? 2 : 1;

  static String _entity(int rune) =>
      '&#x${rune.toRadixString(16).toUpperCase()};';
}

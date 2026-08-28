/// Restores supported emphasis syntax when strict CommonMark flanking rules
/// leave a delimiter literal beside punctuation.
///
/// The canonical form protects only an adjacent visible character with a
/// numeric character reference. It changes no rendered text, adds no spaces,
/// and keeps saved Markdown unambiguous across clients.
abstract final class MarkdownInlineBoundary {
  static const _tokens = <String>['***', '___', '**', '__', '~~', '*', '_'];

  static String canonicalize(String source) {
    if (!source.contains('*') &&
        !source.contains('_') &&
        !source.contains('~~')) {
      return source;
    }

    final output = StringBuffer();
    var index = 0;
    while (index < source.length) {
      if (source[index] == r'\') {
        final end = index + (index + 1 < source.length ? 2 : 1);
        output.write(source.substring(index, end));
        index = end;
        continue;
      }
      if (source[index] == '`') {
        final runLength = _runLength(source, index, '`');
        final delimiter = '`' * runLength;
        final closing = source.indexOf(delimiter, index + runLength);
        if (closing >= 0) {
          final end = closing + runLength;
          output.write(source.substring(index, end));
          index = end;
          continue;
        }
      }

      final token = _tokenAt(source, index);
      if (token == null) {
        output.write(source[index]);
        index += 1;
        continue;
      }
      final closing = _findClosing(source, token, index + token.length);
      if (closing == null) {
        output.write(source[index]);
        index += 1;
        continue;
      }
      final content = source.substring(index + token.length, closing);
      final previous = _previousRune(source, index);
      final next = _nextRune(source, closing + token.length);
      if (!_isRecoverable(content, previous: previous, next: next)) {
        output.write(source.substring(index, closing + token.length));
        index = closing + token.length;
        continue;
      }

      if (_needsProtection(previous)) {
        final previousText = String.fromCharCode(previous!);
        final current = output.toString();
        if (current.endsWith(previousText)) {
          final retained = current.substring(
            0,
            current.length - previousText.length,
          );
          output
            ..clear()
            ..write(retained)
            ..write(_entity(previous));
        }
      }
      final canonicalToken = switch (token.length) {
        1 => '*',
        2 when token != '~~' => '**',
        3 => '***',
        _ => token,
      };
      output
        ..write(canonicalToken)
        ..write(content)
        ..write(canonicalToken);
      index = closing + token.length;
      if (_needsProtection(next)) {
        output.write(_entity(next!));
        index += _runeLength(next);
      }
    }
    return output.toString();
  }

  static String? _tokenAt(String source, int index) {
    for (final token in _tokens) {
      if (!source.startsWith(token, index)) continue;
      if (_runLength(source, index, token[0]) != token.length) continue;
      return token;
    }
    return null;
  }

  static int? _findClosing(String source, String token, int start) {
    var index = start;
    while (index < source.length) {
      if (source[index] == r'\') {
        index += index + 1 < source.length ? 2 : 1;
        continue;
      }
      if (source.startsWith(token, index) &&
          _runLength(source, index, token[0]) == token.length) {
        return index;
      }
      index += 1;
    }
    return null;
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

  static bool _needsProtection(int? rune) =>
      rune != null && !_isWhitespace(rune) && !_isPunctuationOrSymbol(rune);

  static bool _isWhitespace(int rune) =>
      RegExp(r'^\s$', unicode: true).hasMatch(String.fromCharCode(rune));

  static bool _isPunctuationOrSymbol(int rune) =>
      (rune >= 0x21 && rune <= 0x2f) ||
      (rune >= 0x3a && rune <= 0x40) ||
      (rune >= 0x5b && rune <= 0x60) ||
      (rune >= 0x7b && rune <= 0x7e) ||
      (rune >= 0x2000 && rune <= 0x206f) ||
      (rune >= 0x2190 && rune <= 0x2bff) ||
      (rune >= 0x3000 && rune <= 0x303f) ||
      (rune >= 0xfe10 && rune <= 0xfe6f) ||
      (rune >= 0xff01 && rune <= 0xff65);

  static int _runLength(String source, int index, String marker) {
    var length = 0;
    while (index + length < source.length && source[index + length] == marker) {
      length += 1;
    }
    return length;
  }

  static int? _previousRune(String source, int index) =>
      index == 0 ? null : source.substring(0, index).runes.last;

  static int? _nextRune(String source, int index) =>
      index >= source.length ? null : source.substring(index).runes.first;

  static int _runeLength(int rune) => rune > 0xffff ? 2 : 1;

  static String _entity(int rune) =>
      '&#x${rune.toRadixString(16).toUpperCase()};';
}

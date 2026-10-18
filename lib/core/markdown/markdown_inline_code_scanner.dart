/// 只识别行内代码定界符，不解释块、链接或 HTML，不改变 UTF-16 偏移。
abstract final class MarkdownInlineCodeScanner {
  static int? endAt(String source, int start) {
    if (start < 0 || start >= source.length || source[start] != '`')
      return null;
    if (start > 0 &&
        source[start - 1] == '`' &&
        !_isEscaped(source, start - 1)) {
      return null;
    }
    if (_isEscaped(source, start)) return null;
    final length = _runLength(source, start);
    var search = start + length;
    while (search < source.length) {
      final next = source.indexOf('`', search);
      if (next < 0) return null;
      final closingLength = _runLength(source, next);
      // 代码区内反斜杠是字面字符；闭合串必须与开头长度完全相同。
      if (closingLength == length) return next + closingLength;
      search = next + closingLength;
    }
    return null;
  }

  static String mask(String source) {
    final output = StringBuffer();
    var index = 0;
    while (index < source.length) {
      final end = endAt(source, index);
      if (end == null) {
        output.write(source[index++]);
      } else {
        output.write(' ' * (end - index));
        index = end;
      }
    }
    return output.toString();
  }

  static int _runLength(String source, int start) {
    var end = start;
    while (end < source.length && source[end] == '`') {
      end++;
    }
    return end - start;
  }

  static bool _isEscaped(String source, int start) {
    var slashes = 0;
    for (var i = start - 1; i >= 0 && source[i] == r'\'; i--) {
      slashes++;
    }
    return slashes.isOdd;
  }
}

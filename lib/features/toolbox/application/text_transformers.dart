import 'package:flutter/widgets.dart' show StringCharacters;

import 'emoji_width.dart';

const toolTextLimit = 10000;

void assertToolTextLimit(String text) {
  if (text.length > toolTextLimit) {
    throw const FormatException('输入最多 10,000 个字符');
  }
}

enum ReadingDirection { right, left }

class VerticalOptions {
  const VerticalOptions({
    this.width = 10,
    this.height = 20,
    this.gap = 2,
    this.direction = ReadingDirection.right,
    this.separator,
  });

  final int width;
  final int height;
  final int gap;
  final ReadingDirection direction;
  final String? separator;
}

final _controlSeparator = RegExp(r'[\x00-\x1f\x7f-\x9f\u2028\u2029]');

/// 与 Web 固定页格规则一致；先按完整 grapheme 分段，再计算中英文补位。
int verticalCellWidth(String grapheme) {
  if (containsDoubleCellEmoji(grapheme)) return 2;
  final code = grapheme.runes.firstOrNull ?? 0;
  return code >= 0x1100 &&
          (code <= 0x115f ||
              code == 0x2329 ||
              code == 0x232a ||
              (code >= 0x2e80 && code <= 0xa4cf) ||
              (code >= 0xac00 && code <= 0xd7a3) ||
              (code >= 0xf900 && code <= 0xfaff) ||
              (code >= 0xfe10 && code <= 0xfe6f) ||
              (code >= 0xff01 && code <= 0xff60) ||
              (code >= 0xffe0 && code <= 0xffe6) ||
              (code >= 0x20000 && code <= 0x3fffd))
      ? 2
      : 1;
}

String verticalText(String text, VerticalOptions options) {
  registerEmojiWidthLicense();
  assertToolTextLimit(text);
  final VerticalOptions(:width, :height, :gap, :direction) = options;
  if (width < 1 || width > 100) {
    throw const FormatException('页宽须为 1–100 的整数');
  }
  if (height < 1 || height > 100) {
    throw const FormatException('页高须为 1–100 的整数');
  }
  if (gap < 0 || gap > 10) {
    throw const FormatException('列间空格须为 0–10 的整数');
  }
  final separator = options.separator ?? ' ' * gap;
  if (separator.length > 20 || _controlSeparator.hasMatch(separator)) {
    throw const FormatException('分隔符最多 20 个字符，不能包含换行或控制字符');
  }
  if (text.isEmpty) return '';
  final columns = <List<String>>[];
  var characterUnits = 0;
  for (final line in _normalizeNewlines(text).split('\n')) {
    final chars = line.replaceAll('\t', '    ').characters.toList();
    for (final char in chars) {
      characterUnits += char.length - verticalCellWidth(char);
    }
    if (chars.isEmpty) {
      columns.add([]);
    } else {
      for (var i = 0; i < chars.length; i += height) {
        columns.add(chars.sublist(i, (i + height).clamp(0, chars.length)));
      }
    }
  }
  final pageCount = (columns.length / width).ceil();
  final cells = pageCount * width * height;
  final outputUnits =
      cells * 2 +
      characterUnits +
      pageCount * height * (width - 1) * separator.length +
      pageCount * (height - 1) +
      (pageCount - 1) * 2;
  if (cells > 100000 || outputUnits > 500000) {
    throw const FormatException(
      '排版结果过大（最多 100,000 格、500,000 个字符），请减少输入空行、页宽或页高',
    );
  }
  final pages = <String>[];
  for (var start = 0; start < columns.length; start += width) {
    var page = List<List<String>>.generate(
      width,
      (column) =>
          start + column < columns.length ? columns[start + column] : [],
    );
    if (direction == ReadingDirection.right) page = page.reversed.toList();
    pages.add(
      List.generate(height, (row) {
        return page
            .map((column) {
              final char = row < column.length ? column[row] : '';
              return char +
                  ' ' * (char.isEmpty ? 2 : 2 - verticalCellWidth(char));
            })
            .join(separator);
      }).join('\n'),
    );
  }
  return pages.join('\n\n');
}

const morseCodes = <String, String>{
  'A': '.-',
  'B': '-...',
  'C': '-.-.',
  'D': '-..',
  'E': '.',
  'F': '..-.',
  'G': '--.',
  'H': '....',
  'I': '..',
  'J': '.---',
  'K': '-.-',
  'L': '.-..',
  'M': '--',
  'N': '-.',
  'O': '---',
  'P': '.--.',
  'Q': '--.-',
  'R': '.-.',
  'S': '...',
  'T': '-',
  'U': '..-',
  'V': '...-',
  'W': '.--',
  'X': '-..-',
  'Y': '-.--',
  'Z': '--..',
  '0': '-----',
  '1': '.----',
  '2': '..---',
  '3': '...--',
  '4': '....-',
  '5': '.....',
  '6': '-....',
  '7': '--...',
  '8': '---..',
  '9': '----.',
  '.': '.-.-.-',
  ',': '--..--',
  '?': '..--..',
  "'": '.----.',
  '/': '-..-.',
  '(': '-.--.',
  ')': '-.--.-',
  ':': '---...',
  '=': '-...-',
  '+': '.-.-.',
  '-': '-....-',
  '"': '.-..-.',
  '@': '.--.-.',
  'É': '..-..',
};

String _normalizeNewlines(String text) =>
    text.replaceAll(RegExp(r'\r\n?'), '\n');
final _whitespace = RegExp(r'\s', unicode: true);
final _whitespaces = RegExp(r'\s+', unicode: true);

String encodeMorse(String text) {
  assertToolTextLimit(text);
  final normalized = _normalizeNewlines(
    text,
  ).replaceAllMapped(RegExp('[a-zé]'), (match) => match[0]!.toUpperCase());
  final unknown = normalized.runes
      .map(String.fromCharCode)
      .where(
        (char) => !_whitespace.hasMatch(char) && !morseCodes.containsKey(char),
      )
      .toSet();
  if (unknown.isNotEmpty) {
    throw FormatException(
      '国际摩斯不支持这些字符：${unknown.take(12).join(' ')}${unknown.length > 12 ? '…' : ''}',
    );
  }
  return normalized
      .split('\n')
      .map((line) {
        return line
            .trim()
            .split(_whitespaces)
            .map((word) {
              return word.runes
                  .map((code) => morseCodes[String.fromCharCode(code)])
                  .join(' ');
            })
            .join(' / ');
      })
      .join('\n');
}

String decodeMorse(String text) {
  assertToolTextLimit(text);
  final reverse = {for (final item in morseCodes.entries) item.value: item.key};
  return _normalizeNewlines(text)
      .split('\n')
      .map((line) {
        return line
            .trim()
            .split(RegExp(r'\s*/\s*'))
            .map((word) {
              if (word.isEmpty) return '';
              return word.trim().split(_whitespaces).map((code) {
                final decoded = reverse[code];
                if (decoded == null) {
                  throw FormatException(
                    '无法识别码组：${code.substring(0, code.length.clamp(0, 20))}。请用空格分隔字符，用 / 分隔单词',
                  );
                }
                return decoded;
              }).join();
            })
            .join(' ');
      })
      .join('\n');
}

enum FancyStyle {
  bold('粗体', 0x1d400, 0x1d41a, 0x1d7ce),
  italic('斜体', 0x1d434, 0x1d44e),
  script('花体', 0x1d49c, 0x1d4b6),
  fraktur('哥特体', 0x1d504, 0x1d51e),
  doubleLine('双线体', 0x1d538, 0x1d552, 0x1d7d8),
  mono('等宽体', 0x1d670, 0x1d68a, 0x1d7f6),
  full('全角', 0xff21, 0xff41, 0xff10);

  const FancyStyle(this.label, this.upper, this.lower, [this.digit]);
  final String label;
  final int upper;
  final int lower;
  final int? digit;
}

const _fancyExceptions = <FancyStyle, Map<String, String>>{
  FancyStyle.italic: {'h': 'ℎ'},
  FancyStyle.script: {
    'B': 'ℬ',
    'E': 'ℰ',
    'F': 'ℱ',
    'H': 'ℋ',
    'I': 'ℐ',
    'L': 'ℒ',
    'M': 'ℳ',
    'R': 'ℛ',
    'e': 'ℯ',
    'g': 'ℊ',
    'o': 'ℴ',
  },
  FancyStyle.fraktur: {'C': 'ℭ', 'H': 'ℌ', 'I': 'ℑ', 'R': 'ℜ', 'Z': 'ℨ'},
  FancyStyle.doubleLine: {
    'C': 'ℂ',
    'H': 'ℍ',
    'N': 'ℕ',
    'P': 'ℙ',
    'Q': 'ℚ',
    'R': 'ℝ',
    'Z': 'ℤ',
  },
};

String fancyText(String text, FancyStyle style) {
  assertToolTextLimit(text);
  return text.runes.map((code) {
    final char = String.fromCharCode(code);
    final exception = _fancyExceptions[style]?[char];
    if (exception != null) return exception;
    if (code >= 65 && code <= 90) {
      return String.fromCharCode(style.upper + code - 65);
    }
    if (code >= 97 && code <= 122) {
      return String.fromCharCode(style.lower + code - 97);
    }
    if (code >= 48 && code <= 57 && style.digit != null) {
      return String.fromCharCode(style.digit! + code - 48);
    }
    return char;
  }).join();
}

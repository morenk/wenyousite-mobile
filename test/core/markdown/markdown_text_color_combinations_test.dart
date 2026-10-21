import 'package:flutter_test/flutter_test.dart';
import '../../support/text_color_assertions.dart';

void main() {
  test('32 种行内样式各自与颜色组合，逐字核对阅读和重开', () {
    for (var mask = 0; mask < 32; mask++) {
      verifyColorSegments([('如何呢👩🏽‍💻e\u0301', textColorMarks(mask))]);
    }
  });

  for (final colors in [
    ('#D14343', '#D14343'),
    ('#D14343', '#2563EB'),
    ('#D14343', null),
    (null, '#D14343'),
  ]) {
    test('1024 种相邻行内样式，颜色 ${colors.$1} → ${colors.$2}', () {
      final failures = <String>[];
      for (var left = 0; left < 32; left++) {
        for (var right = 0; right < 32; right++) {
          try {
            verifyColorSegments([
              ('如', textColorMarks(left, colors.$1)),
              ('何呢', textColorMarks(right, colors.$2)),
            ]);
          } on Object catch (error) {
            failures.add('$left/$right: $error');
          }
        }
      }
      expect(failures.take(12), isEmpty, reason: '${failures.length} 个失败组合');
    });
  }

  test('部分上色、不同链接、符号字面与 emoji 组合保持文字和范围', () {
    final failures = <String>[];
    for (var mask = 0; mask < 32; mask++) {
      for (final text in [
        'culti',
        '*[_]~\\',
        '`code`',
        '&amp;&#42;',
        '👩🏽‍💻',
      ]) {
        try {
          verifyColorSegments([
            ('a', textColorMarks(mask, null)),
            (text, textColorMarks(mask)),
            ('b', textColorMarks(mask, null)),
          ]);
          verifyColorSegments([
            ('甲', {...textColorMarks(mask), 'link': 'https://example.com/b'}),
            (text, textColorMarks(mask, '#2563EB')),
          ]);
        } on Object catch (error) {
          failures.add('$mask/$text: $error');
        }
      }
    }
    expect(failures.take(12), isEmpty, reason: '${failures.length} 个失败组合');
  });

  test('首尾空格、空白选区与代码空格保持颜色且不制造缩进或硬换行', () {
    for (var mask = 0; mask < 32; mask++) {
      final marks = textColorMarks(mask);
      for (final whitespace in [' ', '  ', '    ', '\t', '\u00a0']) {
        final content = '$whitespace如何呢$whitespace';
        verifyColorSegments(
          [(content, marks)],
          expected: marks['code'] == true
              ? [(content, marks)]
              : [
                  (whitespace, {'color': '#D14343'}),
                  ('如何呢', marks),
                  (whitespace, {'color': '#D14343'}),
                ],
        );
        verifyColorSegments(
          [(whitespace, marks)],
          expected: [
            (whitespace, marks['code'] == true ? marks : {'color': '#D14343'}),
          ],
        );
      }
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import '../../support/inline_combination_assertions.dart';

const _keys = ['bold', 'italic', 'strike', 'code', 'link'];

void main() {
  test('代码后正文尾空格不添加保护字符并稳定重开', () {
    verifyInlineCombination([
      ('甲', {'code': true}),
      ('  ', {}),
    ]);
  });
  test('逻辑外层内部空格保留两侧共有样式', () {
    for (final outer in ['bold', 'strike', 'link']) {
      final marks = <String, Object>{
        outer: outer == 'link' ? 'https://example.com/a' : true,
      };
      verifyInlineCombination([
        ('a ', marks),
        ('b', {...marks, 'italic': true}),
      ]);
      verifyInlineCombination([
        ('a', {...marks, 'italic': true}),
        (' b', marks),
      ]);
    }
  });
  test('32 种行内组合保持独立阅读文字和逐字样式', () {
    final failures = <String>[];
    for (var mask = 0; mask < 32; mask++) {
      final marks = _marks(mask);
      try {
        verifyInlineCombination([('culti', marks)]);
      } on Object catch (error) {
        failures.add('$mask: $error');
      }
    }
    expect(failures, isEmpty);
  });

  test('1024 种无空格有序邻接保持独立阅读文字和逐字样式', () {
    final failures = <String>[];
    for (var left = 0; left < 32; left++) {
      for (var right = 0; right < 32; right++) {
        try {
          verifyInlineCombination([
            ('土地', _marks(left)),
            ('culti', _marks(right)),
          ]);
        } on Object catch (error) {
          failures.add('$left/$right: $error');
        }
      }
    }
    expect(failures.take(20), isEmpty, reason: '${failures.length} 个失败组合');
  });

  test('ASCII 词内边界、不同链接和代码特殊字符保留原字面内容', () {
    final failures = <String>[];
    for (var mask = 0; mask < 32; mask++) {
      for (final text in [
        'culti',
        '*[_]~\\',
        '`code`',
        ' a ',
        '   ',
        '&amp;&#42;',
        '👩🏽‍💻',
      ]) {
        if (text.trim() != text && mask & 8 == 0) continue;
        try {
          verifyInlineCombination([('a', {}), (text, _marks(mask)), ('b', {})]);
          verifyInlineCombination([
            ('a', {..._marks(mask), 'link': 'https://example.com/b'}),
            (text, _marks(mask)),
          ]);
        } on Object catch (error) {
          failures.add('$mask/$text: $error');
        }
      }
    }
    expect(failures.take(15), isEmpty, reason: '${failures.length} 个失败组合');
  });
}

Map<String, Object> _marks(int mask) => {
  for (var index = 0; index < _keys.length; index++)
    if (mask & (1 << index) != 0)
      _keys[index]: _keys[index] == 'link' ? 'https://example.com/a' : true,
};

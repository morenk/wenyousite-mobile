import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';

void main() {
  final fixtures =
      jsonDecode(
            File('contracts/toolbox/text-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  for (final (index, value)
      in (fixtures['vertical']! as List<Object?>).indexed) {
    final item = value! as Map<String, Object?>;
    test('Web 已提交竖排向量 $index，保留每个空白与完整字符', () {
      expect(
        verticalText(
          item['text']! as String,
          VerticalOptions(
            width: item['width']! as int,
            height: item['height']! as int,
            gap: item['gap']! as int,
            direction: ReadingDirection.values.byName(
              item['direction']! as String,
            ),
            separator: item['separator'] as String?,
          ),
        ),
        item['expected'],
      );
    });
  }
  for (final value in fixtures['morse']! as List<Object?>) {
    final item = value! as Map<String, Object?>;
    test('Web 已提交摩斯向量 ${item['input']}', () {
      expect(encodeMorse(item['input']! as String), item['encoded']);
      expect(decodeMorse(item['encoded']! as String), item['decoded']);
    });
  }
  for (final value in fixtures['fancy']! as List<Object?>) {
    final item = value! as Map<String, Object?>;
    test('Web 已提交花体向量 ${item['style']}', () {
      expect(
        fancyText(
          item['input']! as String,
          FancyStyle.values.byName(item['style']! as String),
        ),
        item['expected'],
      );
    });
  }
  test('双格与窄字符一致', () {
    for (final char in [
      '가',
      'Ａ',
      '￥',
      '豈',
      '︰',
      '𠀀',
      '〈',
      '〉',
      'ᄀ',
      '💫',
      '🇨🇳',
      '1️⃣',
      '#\u20e3',
      '👍🏽',
      '👩‍👩‍👧‍👦',
      '©',
      '©︎',
      '™',
    ]) {
      expect(verticalCellWidth(char), 2);
    }
    for (final char in ['', 'a', 'ｦ', '1', '#', '*', '§', '¶']) {
      expect(verticalCellWidth(char), 1);
    }
  });
  test('竖排参数与膨胀限额在创建输出前拒绝', () {
    for (final options in [
      const VerticalOptions(width: 0),
      const VerticalOptions(width: 101),
      const VerticalOptions(height: 0),
      const VerticalOptions(height: 101),
      const VerticalOptions(gap: -1),
      const VerticalOptions(gap: 11),
      const VerticalOptions(separator: '\n'),
      const VerticalOptions(separator: '\t'),
      const VerticalOptions(separator: '\u2028'),
      const VerticalOptions(separator: '\u0000'),
      VerticalOptions(separator: 'x' * 21),
    ]) {
      expect(() => verticalText('字', options), throwsFormatException);
    }
    expect(
      () => verticalText(
        '\n' * 10000,
        const VerticalOptions(width: 1, height: 100),
      ),
      throwsFormatException,
    );
    expect(
      () => verticalText(
        '\n' * 4000,
        VerticalOptions(width: 100, height: 20, separator: 'x' * 20),
      ),
      throwsFormatException,
    );
  });
  test('UTF16 输入限制与摩斯未知字符保留错误', () {
    for (final transform in [
      encodeMorse,
      decodeMorse,
      (String text) => fancyText(text, FancyStyle.bold),
      (String text) => verticalText(text, const VerticalOptions()),
    ]) {
      expect(() => transform('字' * 10001), throwsFormatException);
      expect(() => transform('🙂' * 5001), throwsFormatException);
    }
    for (final text in ['中文', 'ß']) {
      expect(() => encodeMorse(text), throwsFormatException);
    }
    for (final text in ['......', 'constructor', '__proto__', 'toString']) {
      expect(() => decodeMorse(text), throwsFormatException);
    }
    for (final char in morseCodes.keys) {
      expect(decodeMorse(encodeMorse(char)), char);
    }
  });
}

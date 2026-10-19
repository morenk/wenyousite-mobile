import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';

import '../../../tool/generate_fancy_data.dart' as generator;

void main() {
  test('固定来源、manifest六文件与生成产物一致', () {
    generator.main(['--check']);
    final legacy =
        jsonDecode(
              File('contracts/toolbox/source-fancy-v1.json').readAsStringSync(),
            )
            as Map<String, Object?>;
    expect(
      sha256
          .convert(
            File('contracts/toolbox/fancy-fixtures-v1.json').readAsBytesSync(),
          )
          .toString(),
      legacy['sha256'],
    );
  });
  for (final fixtureFile in ['fancy-fixtures.json', 'fancy-fixtures-v1.json']) {
    final fixtures =
        jsonDecode(File('contracts/toolbox/$fixtureFile').readAsStringSync())
            as Map<String, Object?>;
    for (final item
        in (fixtures['cases']! as List<Object?>).cast<Map<String, Object?>>()) {
      test('Web 固定花体向量 $fixtureFile ${item['id']}', () {
        expect(
          fancyText(
            item['input']! as String,
            FancyStyle.byId(item['styleId']! as String),
          ),
          item['expected'],
        );
      });
    }
  }
  test('四类覆盖参考字形，全部Hello Wenyou预览等于真实转换', () {
    expect(FancyStyle.values, hasLength(49));
    expect(FancyStyle.values.map((style) => style.id).toSet(), hasLength(49));
    expect(fancyCategories, {
      'font': '字体',
      'symbol': '符号字形',
      'effect': '文字特效',
      'decoration': '边框装饰',
    });
    expect(
      FancyStyle.values.map((style) => style.id),
      containsAll([
        'pseudo-script',
        'pseudo-fraktur',
        'glitch',
        'bubble-pseudo',
        'radicals',
        'cursed',
        'dot-above',
        'dot-below',
        'zalgo',
      ]),
    );
    expect(FancyStyle.bold.id, 'bold');
    for (final category in fancyCategories.keys) {
      final styles = FancyStyle.values.where(
        (style) => style.category == category,
      );
      expect(
        styles,
        hasLength(
          {'font': 19, 'symbol': 6, 'effect': 8, 'decoration': 16}[category]!,
        ),
      );
      for (final style in styles) {
        expect(fancyText(style.previewInput, style), style.preview);
        expect(style.previewInput, 'Hello Wenyou');
      }
    }
  });
  test('UTF16界限覆盖全部样式，非法ID明确拒绝', () {
    for (final style in FancyStyle.values) {
      expect(fancyText('a' * 10000, style).length, lessThanOrEqualTo(100000));
      expect(() => fancyText('🙂' * 5001, style), throwsFormatException);
    }
    expect(() => FancyStyle.byId('unknown'), throwsFormatException);
  });
}

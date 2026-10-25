import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/dynamic_font_policy.dart';

import 'dynamic_font_fixture.dart';

void main() {
  final mutations = <String, void Function(Map<String, dynamic>)>{
    '重复分片': (value) =>
        (value['shards'] as List).add((value['shards'] as List).first),
    '错误覆盖并集': (value) => value['coverage']['unicodeRanges'] = ['U+0042'],
    '错误字符计数': (value) => value['shards'][0]['codepointCount'] = 2,
    '代理项不是Unicode标量': (value) =>
        value['shards'][0]['unicodeRanges'] = ['U+D800'],
    '无效原生family': (value) => value['shards'][0]['family'] = 'system-ui',
    'Mobile不能用WOFF2': (value) =>
        value['shards'][0]['mobile']['format'] = 'woff2',
    '不接受任意资源URL': (value) => value['shards'][0]['mobile']['url'] =
        'https://outside.invalid/font.ttf',
    '缺少授权声明': (value) => value['notices'] = [],
    '样张身份不一致': (value) => value['specimen']['sha256'] = 'e' * 64,
    '固定输出样式不允许变化': (value) => value['baseWeight'] = 700,
  };
  for (final entry in mutations.entries) {
    test('哈希正确仍拒绝无效清单：${entry.key}', () {
      final fixture = DynamicFontFixture();
      final value =
          jsonDecode(utf8.decode(fixture.manifestBytes))
              as Map<String, dynamic>;
      entry.value(value);
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(value)));
      final descriptor = standardSerializers.deserializeWith(
        FontVersionDescriptorDto.serializer,
        {
          ...fixture.descriptor(),
          'manifest': {
            'sha256': sha256.convert(bytes).toString(),
            'bytes': bytes.length,
            'format': 'json',
          },
        },
      )!;
      expect(
        () => DynamicFontManifest(bytes, descriptor),
        throwsFormatException,
      );
    });
  }
  test('策略允许收紧预算，但拒绝提高硬上限、改变刷新时间或遗漏字段', () {
    final fixture = DynamicFontFixture();
    final lower = fixture.policy;
    lower['mobile']['registration']['maxInputBytes'] = 1024;
    lower['mobile']['registration']['maxKeys'] = 1;
    expect(DynamicFontPolicy(lower).maximumInputBytes, 1024);
    final raised = fixture.policy;
    raised['mobile']['registration']['maxKeys'] = 1025;
    expect(() => DynamicFontPolicy(raised), throwsFormatException);
    final refresh = fixture.policy;
    refresh['metadata']['revalidateAfterMs'] = 600000;
    expect(() => DynamicFontPolicy(refresh), throwsFormatException);
    final missing = fixture.policy..remove('retry');
    expect(() => DynamicFontPolicy(missing), throwsFormatException);
  });
}

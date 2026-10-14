import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/toolbox/application/emoji_width.dart';

void main() {
  test('全部码点按固定 Unicode 官方属性分类，不扩大区间', () {
    final expected = <int>{0x20e3};
    for (var point = 0x1f1e6; point <= 0x1f1ff; point++) {
      expected.add(point);
    }
    final source = File('contracts/toolbox/unicode-16.0-emoji-data.txt');
    for (final line in source.readAsLinesSync()) {
      final match = RegExp(
        r'^([0-9A-F]+)(?:\.\.([0-9A-F]+))?\s*;\s*Extended_Pictographic\b',
      ).firstMatch(line);
      if (match == null) continue;
      final start = int.parse(match[1]!, radix: 16);
      final end = int.parse(match[2] ?? match[1]!, radix: 16);
      for (var point = start; point <= end; point++) {
        expected.add(point);
      }
    }
    expect(expected.length, 3564);
    for (var point = 0; point <= 0x10ffff; point++) {
      if (containsDoubleCellEmoji(String.fromCharCode(point)) !=
          expected.contains(point)) {
        fail('分类不同：U+${point.toRadixString(16)}');
      }
    }
  });

  test('Unicode 原始数据及许可证与来源摘要一致', () {
    final manifest =
        jsonDecode(
              File(
                'contracts/toolbox/source-unicode-emoji.json',
              ).readAsStringSync(),
            )
            as Map<String, Object?>;
    expect(manifest['unicodeVersion'], '16.0.0');
    for (final entry in (manifest['files']! as Map<String, Object?>).entries) {
      final data = File('contracts/toolbox/${entry.key}').readAsBytesSync();
      expect(sha256.convert(data).toString(), (entry.value! as Map)['sha256']);
    }
  });

  test('Unicode 许可证随工具使用注册一次', () async {
    registerEmojiWidthLicense();
    registerEmojiWidthLicense();
    final entries = await LicenseRegistry.licenses
        .where((entry) => entry.packages.contains('Unicode Emoji Data'))
        .toList();
    expect(entries, hasLength(1));
    expect(
      entries.single.paragraphs.map((item) => item.text).join(),
      contains('UNICODE LICENSE V3'),
    );
  });
}

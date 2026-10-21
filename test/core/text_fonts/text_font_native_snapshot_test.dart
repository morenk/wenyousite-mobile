import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_native_snapshot.dart';

void main() {
  final bytes = File(
    'contracts/thread-font-manifest-v1.json',
  ).readAsBytesSync();
  final manifest = TextFontManifest(bytes);
  TextFontNativeSnapshot snapshot() => TextFontNativeSnapshot(
    manifest: manifest,
    assetCount: 868,
    totalBytes: 184645488,
  );
  test('整个28款有限快照最多一次注册，超过旧8家族/32faces仍可继续', () {
    final value = snapshot();
    for (final shard in manifest.fonts.values.expand((f) => f.shards)) {
      expect(value.beginNativeAttempt(shard), isTrue);
      value.completeNativeAttempt(shard);
      expect(value.beginNativeAttempt(shard), isFalse);
      expect(value.loadedFamily(shard), shard.family);
    }
    expect(value.attemptedCount, 868);
    expect(value.loadedCount, 868);
    expect(value.possiblyRetainedInputBytes, 184645488);
  });
  test('原生失败不退额或重试，其他片仍可注册；后续目录不能重用别名', () {
    final value = snapshot();
    final shards = manifest.fonts.values.first.shards;
    expect(value.beginNativeAttempt(shards.first), isTrue);
    expect(value.loadedFamily(shards.first), isNull);
    expect(value.beginNativeAttempt(shards.first), isFalse);
    expect(value.beginNativeAttempt(shards[1]), isTrue);
    value.completeNativeAttempt(shards[1]);
    expect(value.loadedFamily(shards[1]), isNotNull);
    final changed = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    ((changed['fonts'] as List).first['shards'] as List).first['family'] =
        'WYF1-deadbeef-core';
    final changedManifest = TextFontManifest(
      Uint8List.fromList(utf8.encode(jsonEncode(changed))),
    );
    expect(
      value.contains(changedManifest.fonts.values.first.shards.first),
      isFalse,
    );
  });
  test('策略数量/字节不匹配时拒绝快照，不能只信大上限', () {
    expect(
      () => TextFontNativeSnapshot(
        manifest: manifest,
        assetCount: 869,
        totalBytes: 184645488,
      ),
      throwsFormatException,
    );
    expect(
      () => TextFontNativeSnapshot(
        manifest: manifest,
        assetCount: 868,
        totalBytes: 184645489,
      ),
      throwsFormatException,
    );
  });
}

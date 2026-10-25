import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_cache.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

void main() {
  test('缓存目录不可写时读作miss，已验证字节仍可用；完整性错误仍拒绝', () async {
    final directory = await Directory.systemTemp.createTemp('font-cache-io-');
    addTearDown(() => directory.delete(recursive: true));
    // 用普通文件占据目录路径，可靠触发跨平台FileSystemException。
    final blocked = File('${directory.path}/blocked');
    await blocked.writeAsString('not a directory');
    final cache = TextFontCache(Directory(blocked.path));
    final bytes = Uint8List.fromList([1, 2, 3]);
    final hash = sha256.convert(bytes).toString();
    final asset = TextFontAsset(
      path: 'fonts/v1/$hash.ttf',
      hash: hash,
      bytes: 3,
    );
    expect(await cache.read(asset), isNull);
    await expectLater(cache.write(asset, bytes), completes);
    expect(bytes, [1, 2, 3]);
    await expectLater(cache.write(asset, Uint8List(3)), throwsFormatException);
  });
}

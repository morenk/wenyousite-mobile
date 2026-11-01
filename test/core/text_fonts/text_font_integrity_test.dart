import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_integrity.dart';
import 'package:wenyousite_mobile/core/text_fonts/text_font_manifest.dart';

void main() {
  for (final size in [16, 1024 * 1024]) {
    test('小文件与工作 isolate 均拒绝哈希或长度错误 size=$size', () async {
      final bytes = Uint8List(size)..[0] = 13;
      final hash = sha256.convert(bytes).toString();
      final asset = TextFontAsset(
        path: 'fonts/v1/$hash.ttf',
        hash: hash,
        bytes: size,
      );
      expect(await verifyTextFontAsset(asset, bytes), isTrue);
      bytes[0] = 14;
      expect(await verifyTextFontAsset(asset, bytes), isFalse);
      expect(await verifyTextFontAsset(asset, Uint8List(size - 1)), isFalse);
    });
  }
}

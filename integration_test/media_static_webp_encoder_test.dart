import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 原生编码器输出可解码 WebP 并收束尺寸', (_) async {
    if (!Platform.isAndroid) return;
    final source = image.Image(width: 160, height: 80)
      ..clear(image.ColorRgb8(242, 176, 196));

    final output = await const FlutterStaticWebpEncoder().encode(
      Uint8List.fromList(image.encodePng(source)),
      targetWidth: 80,
      targetHeight: 40,
      quality: 85,
    );

    expect(output, isNotEmpty);
    final decoded = image.decodeWebP(output);
    expect(decoded, isNotNull);
    expect(decoded!.width, lessThanOrEqualTo(source.width));
    expect(decoded.height, lessThanOrEqualTo(source.height));
    expect(decoded.width / decoded.height, closeTo(2, 0.05));
  });

  testWidgets('Android 原生编码器纠正 EXIF 方向并移除源元数据', (_) async {
    if (!Platform.isAndroid) return;
    final source = image.Image(width: 160, height: 80)
      ..clear(image.ColorRgb8(110, 154, 196));
    source.exif.imageIfd
      ..orientation = 6
      ..['Make'] = 'Wenyou Integration Camera';
    final sourceBytes = Uint8List.fromList(image.encodeJpg(source));
    expect(image.decodeJpg(sourceBytes)!.exif, isNot(isEmpty));

    final output = await const FlutterStaticWebpEncoder().encode(
      sourceBytes,
      targetWidth: 80,
      targetHeight: 80,
      quality: 85,
    );

    final decoded = image.decodeWebP(output);
    expect(decoded, isNotNull);
    expect(decoded!.height, greaterThan(decoded.width));
    expect(decoded.exif, isEmpty);
  });
}

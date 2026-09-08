import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/data/image_crop_processor.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

import '../test/support/media_compatibility_fixtures.dart';
import '../test/support/media_encoded_fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android 图片兼容矩阵走真实引擎与原生 WebP 编码器', (_) async {
    if (!Platform.isAndroid) return;
    final processor = EngineImageCropProcessor();
    for (final bytes in [
      mediaJpegWithAppendedData(),
      progressiveJpeg(),
      cmykJpeg(),
      palettePng(),
      for (var orientation = 1; orientation <= 8; orientation++)
        mediaJpeg(orientation: orientation),
      image.encodePng(mediaQuadrants(alpha: true)),
    ]) {
      final input = MediaUploadInput(filename: 'fixture', bytes: bytes);
      final source = await processor.prepare(input);
      final cropped = await processor.cropImage(
        source,
        const NormalizedCropRect(left: 0, top: 0, width: 1, height: 1),
      );
      final reference = image.decodePng(source.previewBytes)!;
      for (final candidate in [input, cropped]) {
        final output = await FlutterMediaUploadNormalizer().normalize(
          candidate,
        );
        final decoded = image.decodeWebP(output.bytes)!;
        expect((decoded.width, decoded.height), (source.width, source.height));
        expect(decoded.exif, isEmpty);
        for (final x in [decoded.width ~/ 4, decoded.width * 3 ~/ 4]) {
          for (final y in [decoded.height ~/ 4, decoded.height * 3 ~/ 4]) {
            final expected = reference.getPixel(x, y);
            final actual = decoded.getPixel(x, y);
            expect(actual.r, closeTo(expected.r, 15));
            expect(actual.g, closeTo(expected.g, 15));
            expect(actual.b, closeTo(expected.b, 15));
            expect(actual.a, closeTo(expected.a, 2));
          }
        }
      }
    }
  });

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

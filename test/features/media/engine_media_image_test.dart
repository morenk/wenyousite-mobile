import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/data/engine_media_image.dart';
import 'package:wenyousite_mobile/features/media/data/image_crop_processor.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

import '../../support/media_compatibility_fixtures.dart';
import '../../support/media_encoded_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final fixture in [
    ('渐进 JPEG', progressiveJpeg),
    ('CMYK JPEG', cmykJpeg),
    ('调色板 PNG', palettePng),
  ]) {
    test('${fixture.$1} 预览和上传保持尺寸与象限颜色', () async {
      final input = _input(fixture.$2(), mime: null);
      final source = await EngineImageCropProcessor().prepare(input);
      final output = await FlutterMediaUploadNormalizer(
        encoder: _PngOnlyEncoder(),
      ).normalize(input);
      _expectCorners(image.decodePng(source.previewBytes)!, mediaQuadrants());
      _expectCorners(image.decodeWebP(output.bytes)!, mediaQuadrants());
    });
  }

  test('16 位灰阶 PNG 可转换为标准 8 位成品', () async {
    final output = await FlutterMediaUploadNormalizer(
      encoder: _PngOnlyEncoder(),
    ).normalize(_input(grayscalePng(), mime: null));
    final decoded = image.decodeWebP(output.bytes)!;
    expect((decoded.width, decoded.height), (80, 48));
    expect(decoded.getPixel(40, 24).r, closeTo(128, 2));
  });

  test('主图后附加 JPEG 的旧解码失败，新预览和完整裁剪保持主图画面', () async {
    final bytes = mediaJpegWithAppendedData();
    expect(() => image.decodeJpg(bytes), throwsA(isA<image.ImageException>()));
    final processor = EngineImageCropProcessor();
    final source = await processor.prepare(_input(bytes));
    final cropped = await processor.cropImage(source, _fullCrop);
    final expected = image.decodeJpg(mediaJpeg())!;
    expect(source.original.bytes, orderedEquals(bytes));
    _expectCorners(image.decodePng(source.previewBytes)!, expected);
    _expectCorners(image.decodePng(cropped.bytes)!, expected);
  });

  for (final purpose in MediaUploadPurpose.values) {
    test('${purpose.name} 归一化同类 JPEG 时编码器只接收无元数据标准 PNG', () async {
      final encoder = _PngOnlyEncoder();
      final output = await FlutterMediaUploadNormalizer(
        encoder: encoder,
      ).normalize(_input(mediaJpegWithAppendedData(), purpose: purpose));
      expect(encoder.calls, 1);
      expect(output.purpose, purpose);
      expect(output.declaredContentType, 'image/webp');
      _expectCorners(
        image.decodeWebP(output.bytes)!,
        image.decodeJpg(mediaJpeg())!,
      );
    });
  }

  // EXIF 方向 1..8 的左上、右上、左下、右下来源象限。
  const expectedCorners = [
    [0, 1, 2, 3],
    [1, 0, 3, 2],
    [3, 2, 1, 0],
    [2, 3, 0, 1],
    [0, 2, 1, 3],
    [2, 0, 3, 1],
    [3, 1, 2, 0],
    [1, 3, 0, 2],
  ];
  for (var orientation = 1; orientation <= 8; orientation++) {
    test('EXIF $orientation 预览、裁剪与上传方向一致且只校正一次', () async {
      final input = _input(mediaJpeg(orientation: orientation));
      final processor = EngineImageCropProcessor();
      final source = await processor.prepare(input);
      expect((
        source.width,
        source.height,
      ), orientation < 5 ? (80, 48) : (48, 80));
      final crop = await processor.cropImage(source, _fullCrop);
      final normalized = await FlutterMediaUploadNormalizer(
        encoder: _PngOnlyEncoder(),
      ).normalize(input);
      final original = image.decodeJpg(mediaJpeg())!;
      for (final decoded in [
        image.decodePng(source.previewBytes)!,
        image.decodePng(crop.bytes)!,
        image.decodeWebP(normalized.bytes)!,
      ]) {
        expect(decoded.exif, isEmpty);
        for (var corner = 0; corner < 4; corner++) {
          _expectPixel(
            _corner(decoded, corner),
            _corner(original, expectedCorners[orientation - 1][corner]),
          );
        }
      }
      // 真正取右半部分，核对坐标属于校正方向后的画面。
      final half = await processor.cropImage(
        source,
        const NormalizedCropRect(left: .5, top: 0, width: .5, height: 1),
      );
      final halfPixels = image.decodePng(half.bytes)!;
      _expectPixel(
        _corner(halfPixels, 0),
        _corner(original, expectedCorners[orientation - 1][1]),
      );
    });
  }

  test('透明 PNG 和静态 WebP 经预览、裁剪、归一化保留透明度及颜色', () async {
    final original = mediaQuadrants(alpha: true);
    for (final bytes in [
      image.encodePng(original),
      image.encodeWebP(original),
    ]) {
      final input = _input(bytes, mime: null);
      final processor = EngineImageCropProcessor();
      final source = await processor.prepare(input);
      final crop = await processor.cropImage(source, _fullCrop);
      final output = await FlutterMediaUploadNormalizer(
        encoder: _PngOnlyEncoder(),
      ).normalize(input);
      for (final decoded in [
        image.decodePng(crop.bytes)!,
        image.decodeWebP(output.bytes)!,
      ]) {
        for (var corner = 0; corner < 4; corner++) {
          _expectPixel(_corner(decoded, corner), _corner(original, corner));
          expect(
            _corner(decoded, corner).a,
            closeTo(_corner(original, corner).a, 1),
          );
        }
      }
    }
  });

  test('空文件、假扩展名、类型冲突和严重截断不会进入编码器', () async {
    for (final input in [
      _input(Uint8List(0)),
      _input(Uint8List.fromList([1, 2, 3, 4])),
      _input(image.encodePng(mediaQuadrants())),
      _input(Uint8List.sublistView(mediaJpeg(), 0, 100)),
      _input(Uint8List(maxMediaImageBytes + 1)),
    ]) {
      final encoder = _PngOnlyEncoder();
      await expectLater(
        FlutterMediaUploadNormalizer(encoder: encoder).normalize(input),
        throwsA(isA<ApiFailure>()),
      );
      expect(encoder.calls, 0);
    }
  });

  test('尺寸头超过像素预算时在像素解码前拒绝', () async {
    final bytes = mediaJpeg();
    for (var i = 0; i < bytes.length - 9; i++) {
      if (bytes[i] == 0xff && bytes[i + 1] == 0xc0) {
        bytes[i + 5] = 0x23;
        bytes[i + 6] = 0x28;
        bytes[i + 7] = 0x23;
        bytes[i + 8] = 0x28;
        break;
      }
    }
    await expectLater(
      EngineMediaImage.open(_input(bytes)),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.userMessage,
          'message',
          contains('像素过大'),
        ),
      ),
    );
  });

  test('有尺寸但缺失像素的编码器成品不会被上传', () async {
    await expectLater(
      FlutterMediaUploadNormalizer(
        encoder: _CorruptEncoder(),
      ).normalize(_input(mediaJpeg())),
      throwsA(isA<ApiFailure>()),
    );
  });
}

const _fullCrop = NormalizedCropRect(left: 0, top: 0, width: 1, height: 1);

MediaUploadInput _input(
  Uint8List bytes, {
  String? mime = 'image/jpeg',
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
}) => MediaUploadInput(
  filename: 'fixture.jpg',
  bytes: bytes,
  declaredContentType: mime,
  purpose: purpose,
);

image.Pixel _corner(image.Image pixels, int index) => pixels.getPixel(
  (pixels.width * (index.isEven ? .25 : .75)).floor(),
  (pixels.height * (index < 2 ? .25 : .75)).floor(),
);

void _expectPixel(image.Pixel actual, image.Pixel expected) {
  expect(actual.r, closeTo(expected.r, 4));
  expect(actual.g, closeTo(expected.g, 4));
  expect(actual.b, closeTo(expected.b, 4));
}

void _expectCorners(image.Image actual, image.Image expected) {
  expect((actual.width, actual.height), (expected.width, expected.height));
  for (var corner = 0; corner < 4; corner++) {
    _expectPixel(_corner(actual, corner), _corner(expected, corner));
  }
}

class _PngOnlyEncoder implements StaticWebpEncoder {
  int calls = 0;
  @override
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  }) async {
    calls++;
    final pixels = image.decodePng(bytes)!;
    expect((pixels.width, pixels.height), (targetWidth, targetHeight));
    expect(pixels.exif, isEmpty);
    return image.encodeWebP(pixels);
  }
}

class _CorruptEncoder implements StaticWebpEncoder {
  @override
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  }) async {
    final webp = image.encodeWebP(image.decodePng(bytes)!);
    return Uint8List.sublistView(webp, 0, 24);
  }
}

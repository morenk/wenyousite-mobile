import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/data/image_crop_processor.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  const processor = IsolateImageCropProcessor();

  test('头像按用户取景生成严格 512 × 512 PNG', () async {
    final source = await processor.prepare(_sourceInput());

    final output = await processor.cropAvatar(
      source,
      const NormalizedCropRect(left: .5, top: 0, width: .5, height: 1),
    );

    expect(_sizeOf(output.bytes), (512, 512));
    expect(output.filename, 'avatar.png');
    expect(output.declaredContentType, 'image/png');
  });

  test('同一来源按独立取景生成 Web 3:1 与移动端 2:1 双画幅', () async {
    final source = await processor.prepare(_sourceInput());

    final selection = await processor.cropProfileCover(
      source,
      webCrop: const NormalizedCropRect(
        left: 0,
        top: 1 / 6,
        width: 1,
        height: 2 / 3,
      ),
      mobileCrop: const NormalizedCropRect(
        left: 0,
        top: 0,
        width: 1,
        height: 1,
      ),
    );

    expect(_sizeOf(selection.web.bytes), (1920, 640));
    expect(_sizeOf(selection.mobile.bytes), (1600, 800));
    expect(selection.web.declaredContentType, 'image/png');
    expect(selection.mobile.declaredContentType, 'image/png');
  });
}

MediaUploadInput _sourceInput() {
  final source = image.Image(width: 180, height: 90);
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      source.setPixelRgb(x, y, x, y * 2, 80);
    }
  }
  return MediaUploadInput(
    filename: 'source.png',
    declaredContentType: 'image/png',
    bytes: image.encodePng(source),
  );
}

(int, int) _sizeOf(Uint8List bytes) {
  final decoded = image.decodePng(bytes);
  return (decoded!.width, decoded.height);
}

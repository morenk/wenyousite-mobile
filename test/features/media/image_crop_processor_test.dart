import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/data/image_crop_processor.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  const processor = IsolateImageCropProcessor();

  test('头像按用户取景生成严格 512 × 512 高质量图片', () async {
    final source = await processor.prepare(_sourceInput());

    final output = await processor.cropAvatar(
      source,
      const NormalizedCropRect(left: .5, top: 0, width: .5, height: 1),
    );

    expect(_sizeOf(output.bytes), (512, 512));
    expect(output.filename, 'avatar.jpg');
    expect(output.declaredContentType, 'image/jpeg');
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
    expect(selection.web.declaredContentType, 'image/jpeg');
    expect(selection.mobile.declaredContentType, 'image/jpeg');
    expect(selection.web.filename, 'profile-cover-web.jpg');
    expect(selection.mobile.filename, 'profile-cover-mobile.jpg');
  });

  test('通用图片按选定区域输出新的完整图片文件', () async {
    final source = await processor.prepare(_sourceInput());

    final output = await processor.cropImage(
      source,
      const NormalizedCropRect(left: .25, top: 0, width: .5, height: 1),
    );

    expect(_sizeOf(output.bytes), (90, 90));
    expect(output.filename, 'cropped-image.jpg');
    expect(output.declaredContentType, 'image/jpeg');
    expect(output.bytes.length, lessThanOrEqualTo(maxMediaImageBytes));
  });

  test('QQ JPEG 尾随重启标记不会阻断完整图片取景', () async {
    final input = _jpegInputWithTrailingRestartMarker();

    final source = await processor.prepare(input);
    final output = await processor.cropImage(
      source,
      const NormalizedCropRect(left: 0, top: 0, width: 1, height: 1),
    );

    expect(source.original.bytes.length, input.bytes.length - 2);
    expect(source.original.bytes.sublist(source.original.bytes.length - 2), [
      0xff,
      0xd9,
    ]);
    expect((source.width, source.height), (180, 90));
    expect(_sizeOf(output.bytes), (180, 90));
  });

  test('普通 JPEG 不经过尾随重启标记兼容改写', () async {
    final input = _jpegInput();

    final source = await processor.prepare(input);

    expect(source.original.bytes, orderedEquals(input.bytes));
  });

  test('JPEG 非精确尾随重启标记仍按损坏图片拒绝', () async {
    final jpeg = _jpegInput().bytes;
    final malformed = Uint8List(jpeg.length + 3)
      ..setRange(0, jpeg.length - 2, jpeg)
      ..setRange(jpeg.length - 2, jpeg.length + 1, [0xff, 0xd6, 0x00])
      ..setRange(jpeg.length + 1, jpeg.length + 3, jpeg, jpeg.length - 2);

    await expectLater(
      processor.prepare(
        MediaUploadInput(
          filename: 'malformed.jpg',
          declaredContentType: 'image/jpeg',
          bytes: malformed,
        ),
      ),
      throwsA(isA<image.ImageException>()),
    );
  });

  test('通用图片处理会在解码前读取延迟加载的相册文件', () async {
    final directory = await Directory.systemTemp.createTemp(
      'wenyou-crop-source-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}source.png');
    final bytes = _sourceInput().bytes;
    await file.writeAsBytes(bytes);
    final input = MediaUploadInput.fromPickedSource(
      PickedMediaSource.file(
        filename: 'source.png',
        path: file.path,
        length: bytes.length,
        declaredContentType: 'image/png',
      ),
    );

    final source = await processor.prepare(input);

    expect(input.isMaterialized, isFalse);
    expect(source.original.isMaterialized, isTrue);
    expect(source.original.bytes, orderedEquals(bytes));
    expect((source.width, source.height), (180, 90));
  });

  test('GIF 动图保留原始字节且不应用裁剪', () async {
    final animation = image.Image(width: 40, height: 20)..frameDuration = 80;
    animation.clear(image.ColorRgb8(255, 0, 0));
    animation.addFrame()
      ..frameDuration = 120
      ..clear(image.ColorRgb8(0, 0, 255));
    final source = await processor.prepare(
      MediaUploadInput(
        filename: 'animation.gif',
        declaredContentType: 'image/gif',
        bytes: image.encodeGif(animation),
      ),
    );

    final output = await processor.cropImage(
      source,
      const NormalizedCropRect(left: .25, top: 0, width: .5, height: 1),
    );
    expect(source.canCrop, isFalse);
    expect(output.filename, 'animation.gif');
    expect(output.declaredContentType, 'image/gif');
    expect(output.bytes, orderedEquals(source.original.bytes));
    expect((source.width, source.height), (40, 20));
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

MediaUploadInput _jpegInput() {
  final source = image.Image(width: 180, height: 90);
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      source.setPixelRgb(x, y, x, y * 2, 80);
    }
  }
  return MediaUploadInput(
    filename: 'source.jpg',
    declaredContentType: 'image/jpeg',
    bytes: image.encodeJpg(source),
  );
}

MediaUploadInput _jpegInputWithTrailingRestartMarker() {
  final original = _jpegInput();
  final bytes = original.bytes;
  final compatible = Uint8List(bytes.length + 2)
    ..setRange(0, bytes.length - 2, bytes)
    ..setRange(bytes.length - 2, bytes.length, [0xff, 0xd6])
    ..setRange(bytes.length, bytes.length + 2, bytes, bytes.length - 2);
  return MediaUploadInput(
    filename: original.filename,
    declaredContentType: original.declaredContentType,
    bytes: compatible,
  );
}

(int, int) _sizeOf(Uint8List bytes) {
  final decoded = image.decodeImage(bytes);
  return (decoded!.width, decoded.height);
}

import 'dart:typed_data';

import 'package:image/image.dart' as image;

/// 自行生成的四象限图，不包含用户图片；预期位置独立于被测解码器。
image.Image mediaQuadrants({bool alpha = false}) {
  final pixels = image.Image(width: 80, height: 48, numChannels: alpha ? 4 : 3);
  for (var y = 0; y < pixels.height; y++) {
    for (var x = 0; x < pixels.width; x++) {
      final right = x >= 40;
      final bottom = y >= 24;
      pixels.setPixelRgba(
        x,
        y,
        !right || bottom ? 240 : 20,
        right ? 230 : 20,
        bottom && !right ? 230 : 20,
        alpha && !right ? 96 : 255,
      );
    }
  }
  return pixels;
}

Uint8List mediaJpeg({int orientation = 1}) {
  final pixels = mediaQuadrants();
  pixels.exif.imageIfd
    ..orientation = orientation
    ..['Make'] = 'Compatibility fixture';
  return image.encodeJpg(pixels, quality: 98);
}

/// 模拟已确认原图的“主图末尾重启标记 + EOI + 第二张 JPEG + 附加数据”。
Uint8List mediaJpegWithAppendedData() {
  final original = mediaJpeg();
  final result = BytesBuilder(copy: false)
    ..add(original.sublist(0, original.length - 2))
    ..add([0xff, 0xd1, 0xff, 0xd9])
    ..add(mediaJpeg())
    ..add([0, 0, 0, 0x80, 0x3f, 0xb0, 1, 1]);
  return result.takeBytes();
}

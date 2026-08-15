import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  test('同一来源图生成严格 3:1 与 2:1 PNG 双画幅', () async {
    final sourceBytes = image.encodePng(image.Image(width: 1800, height: 900));

    final selection = await createCenteredProfileCoverCrops(
      MediaUploadInput(
        filename: 'source.png',
        declaredContentType: 'image/png',
        bytes: sourceBytes,
      ),
    );

    expect(_sizeOf(selection.web.bytes), (1500, 500));
    expect(_sizeOf(selection.mobile.bytes), (1200, 600));
    expect(selection.web.declaredContentType, 'image/png');
    expect(selection.mobile.declaredContentType, 'image/png');
  });
}

(int, int) _sizeOf(Uint8List bytes) {
  final decoded = image.decodePng(bytes);
  return (decoded!.width, decoded.height);
}

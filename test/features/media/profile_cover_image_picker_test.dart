import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_picker.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  testWidgets('同一来源图生成严格 3:1 与 2:1 PNG 双画幅', (tester) async {
    final sourceBytes = await _sourcePng();

    final selection = await createCenteredProfileCoverCrops(
      MediaUploadInput(
        filename: 'source.png',
        declaredContentType: 'image/png',
        bytes: sourceBytes,
      ),
    );

    expect(await _sizeOf(selection.web.bytes), const ui.Size(1500, 500));
    expect(await _sizeOf(selection.mobile.bytes), const ui.Size(1200, 600));
    expect(selection.web.declaredContentType, 'image/png');
    expect(selection.mobile.declaredContentType, 'image/png');
  });
}

Future<Uint8List> _sourcePng() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 1800, 900),
    ui.Paint()..color = const ui.Color(0xFFFFAFCB),
  );
  final image = await recorder.endRecording().toImage(1800, 900);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    image.dispose();
  }
}

Future<ui.Size> _sizeOf(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  try {
    return ui.Size(frame.image.width.toDouble(), frame.image.height.toDouble());
  } finally {
    frame.image.dispose();
    codec.dispose();
  }
}

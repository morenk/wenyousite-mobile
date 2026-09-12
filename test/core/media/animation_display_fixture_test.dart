import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final name in ['original.gif', 'full.webp', 'preview.webp']) {
    test('$name 保留两帧原时长和两轮播放', () async {
      final bytes = await File(
        'test/fixtures/animation-webp-all-surfaces/$name',
      ).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      addTearDown(codec.dispose);
      expect(codec.frameCount, 2);
      expect(codec.repetitionCount, 1);

      final first = await codec.getNextFrame();
      addTearDown(first.image.dispose);
      final second = await codec.getNextFrame();
      addTearDown(second.image.dispose);
      expect(first.duration, const Duration(milliseconds: 120));
      expect(second.duration, const Duration(milliseconds: 240));
      expect(first.image.width, name == 'preview.webp' ? 80 : 320);
      expect(first.image.height, name == 'preview.webp' ? 45 : 180);

      final firstPixels = (await first.image.toByteData())!;
      final secondPixels = (await second.image.toByteData())!;
      expect(
        firstPixels.buffer.asUint8List().take(4).toList(),
        isNot(secondPixels.buffer.asUint8List().take(4).toList()),
      );
    });
  }

  test('poster 是完整尺寸静态首帧，不具有动画时间线', () async {
    final bytes = await File(
      'test/fixtures/animation-webp-all-surfaces/poster.png',
    ).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    addTearDown(codec.dispose);
    expect(codec.frameCount, 1);
    final frame = await codec.getNextFrame();
    addTearDown(frame.image.dispose);
    expect(frame.image.width, 320);
    expect(frame.image.height, 180);
  });
}

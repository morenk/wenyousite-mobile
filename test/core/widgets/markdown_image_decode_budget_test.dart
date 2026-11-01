import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_image.dart';
import '../../features/moments/moment_animation_fixture.dart';

void main() {
  testWidgets('大图按展示尺寸真实解码，离开正文后释放活动图像监听', (tester) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.blue, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(4096, 3072);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      return data!.buffer.asUint8List();
    });
    const address = 'https://cdn.example/synthetic-large.png';
    await MomentAnimationFixture.run(tester, (fixture) async {
      final cache = PaintingBinding.instance.imageCache;
      final initialLive = cache.liveImageCount;
      final initialBytes = cache.currentSizeBytes;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: WenyouMarkdownImage(
                  uri: Uri.parse(address),
                  display: MediaDisplay(
                    url: address,
                    width: 4096,
                    height: 3072,
                    bytes: source.length,
                    animated: false,
                    frameCount: 1,
                    durationMs: 0,
                    loopCount: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      for (
        var attempt = 0;
        attempt < 40 && cache.currentSizeBytes == initialBytes;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      expect(fixture.requests, [address]);
      expect(cache.currentSizeBytes - initialBytes, greaterThan(0));
      expect(
        cache.currentSizeBytes - initialBytes,
        lessThanOrEqualTo(720 * 540 * 4),
      );
      expect(cache.liveImageCount, greaterThan(initialLive));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(cache.liveImageCount, initialLive);
      expect(tester.takeException(), isNull);
    }, resources: {address: source!});
  });
}

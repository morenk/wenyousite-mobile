import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/media/media_display.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown_image.dart';
import '../../features/moments/moment_animation_fixture.dart';

void main() {
  for (final entry in [
    (width: 320, height: 180, expected: const Size(200, 112.5)),
    (width: 160, height: 800, expected: const Size(84, 420)),
    (width: 80, height: 40, expected: const Size(80, 40)),
  ]) {
    testWidgets('可靠尺寸 ${entry.width}×${entry.height} 解码前后保持几何', (tester) async {
      const url = 'https://cdn.example/discussion-still.png';
      final bytes = Uint8List.fromList(
        image.encodePng(image.Image(width: entry.width, height: entry.height)),
      );
      await MomentAnimationFixture.run(tester, (fixture) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WenyouMarkdownImage(
                        uri: Uri.parse(url),
                        display: MediaDisplay(
                          url: url,
                          width: entry.width,
                          height: entry.height,
                          bytes: bytes.length,
                          animated: false,
                          frameCount: 1,
                          durationMs: 0,
                          loopCount: 1,
                        ),
                      ),
                      const Text('下一层', key: Key('neighbor')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final content = find.byKey(const ValueKey('markdown-image-$url'));
        final before = tester.getSize(content);
        final neighborTop = tester.getTopLeft(
          find.byKey(const Key('neighbor')),
        );
        expect(before, entry.expected);
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 30)),
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(fixture.requests, [url]);
        expect(tester.getSize(content), before);
        expect(
          tester.getTopLeft(find.byKey(const Key('neighbor'))),
          neighborTop,
        );
        expect(tester.takeException(), isNull);
      }, resources: {url: bytes});
    });
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const directory = 'contracts/fixtures/media-display';
  final manifest =
      jsonDecode(File('$directory/manifest.json').readAsStringSync())
          as Map<String, Object?>;
  for (final type in ['source', 'display']) {
    test('Backend 实际编码产物 $type 保留重复帧、原时长和有限循环', () async {
      final asset = manifest[type]! as Map<String, Object?>;
      final bytes = await File('$directory/${asset['file']}').readAsBytes();
      expect(bytes.length, asset['bytes']);
      expect(sha256.convert(bytes).toString(), asset['sha256']);
      final codec = await ui.instantiateImageCodec(bytes);
      addTearDown(codec.dispose);
      expect(codec.frameCount, 3);
      expect(codec.repetitionCount, 1);
      final colors = <List<int>>[];
      for (final duration in [300, 600, 600]) {
        final frame = await codec.getNextFrame();
        addTearDown(frame.image.dispose);
        expect(frame.duration.inMilliseconds, duration);
        expect(frame.image.width, 24);
        expect(frame.image.height, 16);
        final pixels = (await frame.image.toByteData())!;
        colors.add(pixels.buffer.asUint8List().take(4).toList());
      }
      expect(colors[0], colors[1]);
      expect(colors[1], isNot(colors[2]));
      expect(colors[0].first, greaterThan(colors[0][2]));
      expect(colors[2][2], greaterThan(colors[2].first));
    });
  }
}

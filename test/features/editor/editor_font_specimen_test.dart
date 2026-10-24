import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_font_specimen.dart';

void main() {
  test('透明边界包含微弱抗锯齿像素及四像素安全边距', () {
    final rgba = Uint8List(30 * 20 * 4);
    rgba[(7 * 30 + 10) * 4 + 3] = 1;
    rgba[(12 * 30 + 18) * 4 + 3] = 255;
    expect(
      editorFontAlphaBounds(rgba, 30, 20),
      const Rect.fromLTRB(6, 3, 23, 17),
    );
    rgba[3] = 1;
    rgba[rgba.length - 1] = 1;
    expect(
      editorFontAlphaBounds(rgba, 30, 20),
      const Rect.fromLTWH(0, 0, 30, 20),
    );
  });

  test('全透明或无效像素没有可绘制边界', () {
    expect(editorFontAlphaBounds(Uint8List(16), 2, 2), isNull);
    expect(editorFontAlphaBounds(Uint8List(15), 2, 2), isNull);
    expect(editorFontAlphaBounds(Uint8List(0), 0, 0), isNull);
  });

  Future<Uint8List> png({bool transparent = false, int width = 100}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    if (!transparent) {
      canvas.drawRect(const Rect.fromLTWH(20, 10, 60, 20), Paint());
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, 40);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }

  testWidgets('真实PNG可绘制，替换损坏PNG与离屏安全释放', (tester) async {
    await tester.runAsync(() async {
      final bytes = await png();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 42,
              child: EditorFontSpecimen(bytes: bytes, color: Colors.pink),
            ),
          ),
        ),
      );
      await tester
          .state<EditorFontSpecimenState>(find.byType(EditorFontSpecimen))
          .ready;
    });
    await tester.pump();
    final painted = find.descendant(
      of: find.byType(EditorFontSpecimen),
      matching: find.byType(CustomPaint),
    );
    expect(tester.widget<CustomPaint>(painted).painter, isNotNull);
    expect(tester.getSize(painted), const Size(200, 42));
    await tester.runAsync(() async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 42,
              child: EditorFontSpecimen(
                bytes: Uint8List.fromList([1, 2, 3]),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      await tester
          .state<EditorFontSpecimenState>(find.byType(EditorFontSpecimen))
          .ready;
    });
    await tester.pump();
    expect(tester.widget<CustomPaint>(painted).painter, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('全透明、尺寸超限及离屏中的解码安全回退', (tester) async {
    for (final transparent in [true, false]) {
      await tester.runAsync(() async {
        final bytes = await png(
          transparent: transparent,
          width: transparent ? 100 : 2050,
        );
        await tester.pumpWidget(
          SizedBox(
            width: 200,
            height: 42,
            child: EditorFontSpecimen(bytes: bytes, color: Colors.black),
          ),
        );
        final ready = tester
            .state<EditorFontSpecimenState>(find.byType(EditorFontSpecimen))
            .ready;
        await ready;
      });
      await tester.pump();
      expect(
        tester.widget<CustomPaint>(find.byType(CustomPaint)).painter,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
    await tester.runAsync(() async {
      final bytes = await png();
      await tester.pumpWidget(
        EditorFontSpecimen(bytes: bytes, color: Colors.black),
      );
      final ready = tester
          .state<EditorFontSpecimenState>(find.byType(EditorFontSpecimen))
          .ready;
      await tester.pumpWidget(const SizedBox.shrink());
      await ready;
    });
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_rgb_picker_tray.dart';
import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> pump(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1,
    ValueChanged<Color>? onApply,
    VoidCallback? onCancel,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: tester.view.physicalSize,
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: RepaintBoundary(
              key: const Key('color-preview-boundary'),
              child: EditorRgbPickerTray(
                initialColor: const Color(0xFF123456),
                onApply: onApply ?? (_) {},
                onCancel: onCancel ?? () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('RGB 0–255 校验、预览不提交，应用提交精确不透明颜色', (tester) async {
    Color? applied;
    await pump(tester, onApply: (color) => applied = color);
    await tester.enterText(find.byKey(const Key('editor-color-r')), '256');
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('editor-color-apply')))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byKey(const Key('editor-color-r')), '255');
    await tester.enterText(find.byKey(const Key('editor-color-g')), '0');
    await tester.enterText(find.byKey(const Key('editor-color-b')), '128');
    await tester.pump();
    expect(applied, isNull);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('editor-color-preview')))
          .style
          ?.color,
      const Color(0xFFFF0080),
    );
    await tester.tap(find.byKey(const Key('editor-color-apply')));
    expect(applied, const Color(0xFFFF0080));
  });

  testWidgets('取消不提交临时取色', (tester) async {
    var cancelled = false;
    var applied = false;
    await pump(
      tester,
      onApply: (_) => applied = true,
      onCancel: () => cancelled = true,
    );
    await tester.tap(find.byKey(const Key('editor-color-plane')));
    await tester.tap(find.text('取消'));
    expect(cancelled, isTrue);
    expect(applied, isFalse);
  });

  testWidgets('预览与操作同行，RGB 聚焦全选且键盘可顺序跳转', (tester) async {
    await pump(tester);
    expect(find.text('自定义颜色'), findsNothing);
    expect(find.text('文字预览 Aa'), findsNothing);
    expect(
      tester.getCenter(find.byKey(const Key('editor-color-preview'))).dy,
      tester.getCenter(find.byKey(const Key('editor-color-apply'))).dy,
    );
    for (final channel in ['r', 'g', 'b']) {
      final field = find.byKey(Key('editor-color-$channel'));
      await tester.tap(field);
      await tester.pump();
      final widget = tester.widget<TextField>(field);
      expect(
        widget.controller!.selection,
        TextSelection(
          baseOffset: 0,
          extentOffset: widget.controller!.text.length,
        ),
      );
      expect(
        widget.textInputAction,
        channel == 'b' ? TextInputAction.done : TextInputAction.next,
      );
    }
  });

  for (final width in [320, 360]) {
    for (final dark in [false, true]) {
      testWidgets('$width ${dark ? 'dark' : 'light'} 取色盘可滚动且明暗保持 RGB', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width.toDouble(), 720);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await pump(tester, dark: dark, scale: width == 320 ? 2 : 1);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Text>(find.byKey(const Key('editor-color-preview')))
              .style
              ?.color,
          const Color(0xFF123456),
        );
        await expectLater(
          find.byKey(const Key('color-preview-boundary')),
          matchesGoldenFile(
            'goldens/editor_rgb_picker_${width}_${dark ? 'dark' : 'light'}.png',
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}

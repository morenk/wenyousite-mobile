import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_palette.dart';

void main() {
  for (final enabled in [false, true]) {
    testWidgets('读屏可操作颜色及恢复默认，禁用时无写动作：$enabled', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EditorTextColorPalette(
              presets: const [(label: '红色', rgb: '#D14343')],
              recent: const [],
              selection: (enabled: enabled, mixed: false, color: null),
              writeEnabled: true,
              onSelect: changes.add,
              onCustom: () {},
            ),
          ),
        ),
      );
      for (final label in ['红色', '恢复默认色']) {
        final node = tester.getSemantics(
          find.bySemanticsLabel(enabled ? label : '$label，选择文字或放置输入光标'),
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), enabled);
        if (enabled) {
          node.owner!.performAction(node.id, SemanticsAction.tap);
        }
      }
      expect(changes, enabled ? ['#D14343', null] : isEmpty);
    });
  }
  for (final writeEnabled in [false, true]) {
    testWidgets('不可用时点按说明原因，不修改正文：$writeEnabled', (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EditorTextColorPalette(
              presets: const [(label: '红色', rgb: '#D14343')],
              recent: const [],
              selection: (enabled: !writeEnabled, mixed: false, color: null),
              writeEnabled: writeEnabled,
              onSelect: (_) => changes++,
              onCustom: () => changes++,
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('editor-color-custom')));
      await tester.pumpAndSettle();
      expect(
        find.text(writeEnabled ? '选择文字或放置输入光标' : '文字颜色暂未开放'),
        findsOneWidget,
      );
      expect(changes, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  for (final width in [320.0, 360.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('$width/$scale 单行颜色可滑动，自定义固定可点', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        String? selected;
        var custom = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(8),
                  child: EditorTextColorPalette(
                    presets: const [
                      (label: '红', rgb: '#D14343'),
                      (label: '橙', rgb: '#D97706'),
                      (label: '绿', rgb: '#22805A'),
                      (label: '蓝', rgb: '#2563EB'),
                      (label: '紫', rgb: '#8B5CF6'),
                    ],
                    recent: const ['#112233', '#445566', '#778899', '#AABBCC'],
                    selection: (enabled: true, mixed: true, color: null),
                    writeEnabled: true,
                    onSelect: (color) => selected = color,
                    onCustom: () => custom++,
                  ),
                ),
              ),
            ),
          ),
        );
        final customFinder = find.byKey(const Key('editor-color-custom'));
        final fixed = tester.getRect(customFinder);
        final reset = tester.getRect(
          find.byKey(const Key('editor-color-default')),
        );
        expect(reset.size, const Size(48, 48));
        expect(fixed.center.dy, reset.center.dy);
        expect(fixed.height, greaterThanOrEqualTo(48));
        expect(fixed.right, lessThanOrEqualTo(width - 8));
        expect(find.text('默认'), findsNothing);
        await tester.drag(
          find.byKey(const Key('editor-color-swatches')),
          const Offset(-600, 0),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(customFinder), fixed);
        await tester.tap(find.byKey(const Key('editor-text-color-#AABBCC')));
        expect(selected, '#AABBCC');
        await tester.tap(customFinder);
        expect(custom, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final enabled in [false, true]) {
    testWidgets('新写关闭包括默认色均禁用 $enabled', (tester) async {
      var changes = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EditorTextColorPalette(
              presets: const [(label: '测试', rgb: '#112233')],
              recent: const [],
              selection: (enabled: true, mixed: true, color: null),
              writeEnabled: enabled,
              onSelect: (_) => changes++,
              onCustom: () => changes++,
            ),
          ),
        ),
      );
      final restore = tester.widget<TextButton>(
        find.byKey(const Key('editor-color-default')),
      );
      final custom = tester.widget<TextButton>(
        find.byKey(const Key('editor-color-custom')),
      );
      expect(restore.onPressed != null, enabled);
      expect(custom.onPressed != null, enabled);
      await tester.tap(find.byKey(const Key('editor-text-color-#112233')));
      expect(changes, enabled ? 1 : 0);
    });
  }
}

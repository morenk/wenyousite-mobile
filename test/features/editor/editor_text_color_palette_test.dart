import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_palette.dart';

void main() {
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar_buttons.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final tray in [false, true]) {
      testWidgets('${theme.brightness} ${tray ? '托盘' : '主栏'} 选中与禁用颜色来自主题', (
        tester,
      ) async {
        final tokens = theme.extension<WenyouThemeTokens>()!;
        for (final enabled in [true, false]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Center(
                  child: tray
                      ? WenyouEditorTrayButton(
                          icon: WenyouIconIds.editorAlignCenter,
                          label: '居中',
                          selected: true,
                          enabled: enabled,
                          onPressed: () {},
                        )
                      : WenyouEditorToolbarButton(
                          icon: WenyouIconIds.editorBold,
                          label: '粗体',
                          selected: true,
                          enabled: enabled,
                          onPressed: () {},
                        ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final button = tester.widget<IconButton>(find.byType(IconButton));
          final states = {
            WidgetState.selected,
            if (!enabled) WidgetState.disabled,
          };
          expect(
            button.style!.backgroundColor!.resolve(states),
            enabled ? tokens.accentedBackground : Colors.transparent,
          );
          final icon = find.byType(WenyouIcon);
          expect(tester.widget<WenyouIcon>(icon).color, isNull);
          expect(
            IconTheme.of(tester.element(icon)).color,
            enabled ? tokens.onAccentedBackground : tokens.mutedText,
          );
          final shape =
              button.style!.shape!.resolve(states)! as RoundedRectangleBorder;
          expect(
            shape.borderRadius,
            BorderRadius.circular(tokens.radiusControl),
          );
          expect(
            tester.getSize(find.byType(IconButton)).shortestSide,
            greaterThanOrEqualTo(WenyouEditorContract.minimumActionExtent),
          );
          expect(button.onPressed == null, !enabled);
        }
      });
    }
  }
}

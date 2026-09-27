import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';

void main() {
  for (final width in [320.0, 360.0, 600.0, 1200.0]) {
    testWidgets('$width 设置页限制宽度并可在键盘和安全区内操作最后一项', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WenyouSettingsBody(
              children: [
                const SizedBox(key: Key('width-probe'), height: 800),
                TextButton(
                  onPressed: () => tapped = true,
                  child: const Text('最后一项'),
                ),
              ],
            ),
          ),
        ),
      );
      final probe = find.byKey(const Key('width-probe'));
      expect(
        tester.getSize(probe).width,
        lessThanOrEqualTo(
          tester.element(probe).wenyouTokens.pageContentMaxWidth,
        ),
      );
      expect(tester.getTopLeft(probe).dx, greaterThanOrEqualTo(12));
      await tester.scrollUntilVisible(find.text('最后一项'), 200);
      expect(
        tester.getBottomLeft(find.text('最后一项')).dy,
        lessThanOrEqualTo(520),
      );
      await tester.tap(find.text('最后一项'));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_management_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('个人设置分组样式的主题管理 $dark / $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(scale == 1 ? 360 : 320, 900);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpThreadManagementTestPage(
          tester,
          ThreadManagementTestRepository(
            initial: threadManagementTestBootstrap(
              rpIdentityEnabled: true,
              tagNames: const ['角色扮演', '共同创作'],
            ),
          ),
          dark: dark,
        );
        expect(find.byType(WenyouSettingsBody), findsOneWidget);
        expect(find.byType(WenyouSettingsGroup), findsNWidgets(4));
        expect(find.byTooltip('帖内身份说明'), findsNothing);
        if (scale == 2) await tester.ensureVisible(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold).last,
          matchesGoldenFile(
            'goldens/thread_management_rp_${dark ? 'dark' : 'light'}_${scale.toInt()}x.png',
          ),
        );
      });
    }
  }
}

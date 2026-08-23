import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('启动首帧按品牌契约展示标识、名称和文案', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const StartupCheckingPage()),
    );
    await tester.pump();
    final logoImage = tester.widget<Image>(find.byType(Image));
    await tester.runAsync(
      () => precacheImage(logoImage.image, tester.element(find.byType(Image))),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final mark = tester.widget<WenyouBrandMark>(
      find.byKey(const Key('startup-brand-mark')),
    );
    expect(mark.size, WenyouBrandContract.startupMarkSize);
    expect(mark.semanticLabel, isNull);
    expect(find.text(WenyouBrandContract.name), findsOneWidget);
    expect(find.text(WenyouBrandContract.tagline), findsOneWidget);
    expect(find.text('正在连接温油站'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, WenyouFoundationPalette.background);
    expect(scaffold.backgroundColor, const Color(0xFFFFFFFF));
    final contentCenter = tester.getCenter(
      find.byKey(const Key('startup-brand-content')),
    );
    expect(contentCenter.dx, closeTo(180, 0.01));
    expect(contentCenter.dy, closeTo(400, 0.01));
    final name = tester.widget<Text>(find.text(WenyouBrandContract.name));
    final tagline = tester.widget<Text>(find.text(WenyouBrandContract.tagline));
    expect(name.style?.fontSize, 22);
    expect(tagline.style?.fontSize, 16);
    expect(name.style?.fontFamily, WenyouFoundationTypography.display);
    expect(tagline.style?.fontFamily, WenyouFoundationTypography.display);
    await expectLater(
      find.byType(StartupCheckingPage),
      matchesGoldenFile('goldens/startup_brand_360.png'),
    );
  });
}

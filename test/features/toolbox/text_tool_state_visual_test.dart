import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';

import '../../support/deterministic_test_fonts.dart';
import 'fake_toolbox_webview.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final visual in const [
    (width: 400.0, height: 860.0, scale: 1.0, dark: false, name: '400_light'),
    (width: 400.0, height: 860.0, scale: 1.0, dark: true, name: '400_dark'),
    (
      width: 320.0,
      height: 640.0,
      scale: 2.0,
      dark: false,
      name: '320_2x_light',
    ),
    (width: 320.0, height: 640.0, scale: 2.0, dark: true, name: '320_2x_dark'),
  ]) {
    for (final failed in [false, true]) {
      final state = failed ? 'error' : 'loading';
      testWidgets('工具页面 $state ${visual.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(visual.width, visual.height);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final platform = FakeToolboxWebView();
        WebViewPlatform.instance = platform;
        await tester.pumpWidget(
          MaterialApp(
            theme: visual.dark ? AppTheme.dark : AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(visual.scale)),
              child: child!,
            ),
            home: const RepaintBoundary(
              key: Key('tool-state-visual'),
              child: TextToolPage(tool: TextTool.vertical),
            ),
          ),
        );
        await tester.pump();
        if (failed) {
          platform.navigation.resourceError(
            const WebResourceError(
              errorCode: -2,
              description: 'offline fixture',
              isForMainFrame: true,
            ),
          );
        }
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byTooltip('返回工具箱').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const Key('tool-state-visual')),
          matchesGoldenFile('goldens/toolbox_${state}_${visual.name}.png'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}

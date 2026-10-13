import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final tool in TextTool.values) {
    for (final dark in [false, true]) {
      for (final narrow in [false, true]) {
        final name =
            '${tool.id}_${narrow ? '320_2x' : '400'}_${dark ? 'dark' : 'light'}';
        testWidgets('原生工具视觉与键盘 $name', (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(
            narrow ? 320 : 400,
            narrow ? 640 : 860,
          );
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
                child: child!,
              ),
              home: RepaintBoundary(
                key: const Key('tool-state-visual'),
                child: TextToolPage(tool: tool),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            Theme.of(
              tester.element(find.byType(AppBar)),
            ).appBarTheme.titleTextStyle!.fontWeight,
            FontWeight.w400,
          );
          expect(find.byTooltip('返回工具箱').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byKey(const Key('tool-state-visual')),
            matchesGoldenFile('goldens/native_$name.png'),
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 260);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byKey(const Key('tool-generate')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('tool-generate')).hitTestable(),
            findsOneWidget,
          );
          expect(
            tester.getSize(find.byKey(const Key('tool-generate'))).height,
            greaterThanOrEqualTo(48),
          );
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}

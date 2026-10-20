import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_typography.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  for (final narrow in [false, true]) {
    testWidgets('双语结果长姓名 ${narrow ? '320_2x_light' : '400_dark'}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(narrow ? 320 : 400, 860);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var index = 0;
      final names = LocalNameGenerator().generate(
        const NameOptions(
          country: 'gb',
          sex: NameSex.male,
          surname: 'Montgomery-Wellington',
          surnameZh: '蒙哥马利-威灵顿',
          count: 3,
        ),
        random: () => [0.0, 0.5, 0.8][index++ % 3],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: narrow ? AppTheme.light : AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
            child: child!,
          ),
          home: ToolTypography(
            child: Builder(
              builder: (context) => RepaintBoundary(
                key: const Key('results-visual'),
                child: Scaffold(
                  backgroundColor: wenyouPersonalPageBackground(context),
                  appBar: AppBar(
                    title: const Text('起名工具'),
                    backgroundColor: wenyouPersonalPageBackground(context),
                  ),
                  body: WenyouSettingsBody(
                    children: [
                      NameToolResults(
                        names: names,
                        requestedCount: 3,
                        foreign: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['复制原文', '复制中文', '复制全部']) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      expect(find.byType(SelectableText), findsNWidgets(3));
      for (final result in tester.widgetList<SelectableText>(
        find.byType(SelectableText),
      )) {
        for (final span in result.textSpan!.children!.cast<TextSpan>()) {
          expect(span.style!.fontWeight, FontWeight.w400);
        }
      }
      await expectLater(
        find.byKey(const Key('results-visual')),
        matchesGoldenFile(
          'goldens/native_names_results_${narrow ? '320_2x_light' : '400_dark'}.png',
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final scale in [1.0, 2.0]) {
    testWidgets('系统字体中英数字 Emoji 混排在 ${scale}x 下保持布局与触控', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: WenyouContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '很长的系统字体标题 System Font 2026 😀',
                    style: AppTheme.light.textTheme.wenyouPageTitle,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正文 English 123,456 😀 @温油站 inline_code',
                    style: AppTheme.light.textTheme.wenyouReadingBody,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('mixed-font-action'),
                    onPressed: () {},
                    child: const Text('保存中英数字 123 😀'),
                  ),
                  Text(
                    '1,234,567',
                    key: const Key('tabular-number'),
                    style: AppTheme.light.textTheme.wenyouUtilityBody,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('mixed-font-action'))).height,
        greaterThanOrEqualTo(48),
      );
      final number = tester.widget<Text>(
        find.byKey(const Key('tabular-number')),
      );
      expect(
        number.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
    });
  }
}

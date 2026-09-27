import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_sheet.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  for (final width in [320.0, 360.0, 600.0]) {
    for (final keyboard in [false, true]) {
      testWidgets('$width 两倍字号抽屉安全区与键盘 $keyboard 内可滚动完成选择', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 800);
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard ? 300 : 0);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        int? result;
        await tester.pumpWidget(
          _app(onResult: (value) => result = value, count: 30),
        );
        await tester.tap(find.text('打开'));
        await tester.pumpAndSettle();
        final surface = find.byType(WenyouSheetBody);
        expect(
          tester.getBottomLeft(surface).dy,
          lessThanOrEqualTo(keyboard ? 500 : 776),
        );
        expect(tester.getTopLeft(surface).dy, greaterThanOrEqualTo(24));
        await tester.scrollUntilVisible(
          find.text('选项 29'),
          250,
          scrollable: find.descendant(
            of: surface,
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('选项 29'));
        await tester.pumpAndSettle();
        expect(result, 29);
        expect(surface, findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('短抽屉随内容收缩，关闭和系统返回均返回空值', (tester) async {
    final results = <int?>[];
    await tester.pumpWidget(_app(onResult: results.add, count: 1));
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(WenyouSheetBody)).height, lessThan(250));
    await tester.tap(find.byTooltip('关闭选择内容'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(results, [null, null]);
  });
}

Widget _app({required ValueChanged<int?> onResult, required int count}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              onResult(
                await showWenyouSheet<int>(
                  context: context,
                  builder: (context) => WenyouSheetBody(
                    title: '选择内容',
                    slivers: [
                      SliverList.builder(
                        itemCount: count,
                        itemBuilder: (context, index) => ListTile(
                          title: Text('选项 $index'),
                          onTap: () => Navigator.pop(context, index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ),
    );

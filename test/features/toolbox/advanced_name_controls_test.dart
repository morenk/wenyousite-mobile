import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/advanced_name_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_typography.dart';

import '../../support/deterministic_test_fonts.dart';

// 显式组件参数仅验证布局与回调，不构成词库或生成契约。
const _exampleStyles = {
  'example-one': '江户武家（1600–1868）',
  'example-two': '公家雅风',
};
const _exampleStructures = {'simple': '标准姓名', 'byname': '姓名与雅号'};

Future<void> pumpControls(
  WidgetTester tester, {
  bool dark = false,
  bool largeText = false,
  bool expanded = true,
  Map<String, String> structures = _exampleStructures,
  VoidCallback? onToggle,
  ValueChanged<String>? onMode,
  ValueChanged<String>? onStyle,
  ValueChanged<String>? onStructure,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 860);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => ToolTypography(
          child: Scaffold(
            backgroundColor: wenyouPersonalPageBackground(context),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.wenyouTokens.space16),
                child: AdvancedNameControls(
                  expanded: expanded,
                  onToggleExpanded: onToggle ?? () {},
                  mode: 'historical',
                  styleId: 'example-one',
                  styles: _exampleStyles,
                  structureId: 'simple',
                  structures: structures,
                  onModeChanged: onMode ?? (_) {},
                  onStyleChanged: onStyle ?? (_) {},
                  onStructureChanged: onStructure ?? (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> chooseControl(
  WidgetTester tester,
  String key,
  String option,
) async {
  final control = find.byKey(Key(key));
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  await tester.tap(control);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('展开仅显示类型风格和多结构；选择回调传递实际标识', (tester) async {
    String? mode;
    String? style;
    String? structure;
    await pumpControls(
      tester,
      onMode: (value) => mode = value,
      onStyle: (value) => style = value,
      onStructure: (value) => structure = value,
    );
    expect(find.text('历史起名'), findsNothing);
    expect(find.text('时代与地区'), findsNothing);
    expect(find.text('姓氏'), findsNothing);
    expect(find.byType(Switch), findsNothing);
    await chooseControl(tester, 'name-advanced-mode', '文学创作');
    expect(mode, 'literary');
    await chooseControl(tester, 'name-advanced-style', '公家雅风');
    expect(style, 'example-two');
    await chooseControl(tester, 'name-advanced-structure', '姓名与雅号');
    expect(structure, 'byname');
    expect(tester.takeException(), isNull);
  });

  testWidgets('只有一种结构时不显示结构选择', (tester) async {
    await pumpControls(tester, structures: const {'simple': '标准姓名'});
    expect(find.byKey(const Key('name-advanced-structure')), findsNothing);
    expect(find.text('姓名结构'), findsNothing);
    expect(find.byKey(const Key('name-advanced-style')), findsOneWidget);
  });

  testWidgets('收起仅保留入口，点击转交显式切换回调', (tester) async {
    var toggles = 0;
    await pumpControls(tester, expanded: false, onToggle: () => toggles++);
    expect(find.text('进阶选项'), findsOneWidget);
    expect(find.byKey(const Key('name-advanced-mode')), findsNothing);
    expect(find.byKey(const Key('name-advanced-style')), findsNothing);
    expect(find.byKey(const Key('name-advanced-structure')), findsNothing);
    final disclosure = find.byKey(const Key('name-advanced-disclosure'));
    expect(tester.getSize(disclosure).height, greaterThanOrEqualTo(48));
    await tester.tap(disclosure);
    expect(toggles, 1);
  });

  for (final dark in [false, true]) {
    for (final largeText in [false, true]) {
      final state = '320_${largeText ? '2x' : '1x'}_${dark ? 'dark' : 'light'}';
      testWidgets('独立进阶控件窄屏 $state', (tester) async {
        await pumpControls(tester, dark: dark, largeText: largeText);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('goldens/advanced_name_controls_$state.png'),
        );
        for (final key in [
          'name-advanced-mode',
          'name-advanced-style',
          'name-advanced-structure',
        ]) {
          expect(
            tester.getSize(find.byKey(Key(key))).height,
            greaterThanOrEqualTo(48),
          );
        }
        await chooseControl(tester, 'name-advanced-structure', '姓名与雅号');
        expect(tester.takeException(), isNull);
      });
    }
  }
}

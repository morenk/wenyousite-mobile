import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/application/historical_name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/historical_name_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';

import '../../support/deterministic_test_fonts.dart';

Future<void> pumpNames(
  WidgetTester tester, {
  bool dark = false,
  bool narrow = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(narrow ? 320 : 400, 860);
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
      home: const TextToolPage(tool: TextTool.names),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> selectNameOption(
  WidgetTester tester,
  String label,
  String option,
) async {
  await tapVisible(tester, find.text(label).first);
  await tapVisible(tester, find.text(option).last);
}

Future<void> enableHistory(WidgetTester tester) async {
  await tapVisible(tester, find.byKey(const Key('name-advanced-disclosure')));
  await tapVisible(tester, find.byKey(const Key('name-history-enabled')));
}

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('默认普通快生成；展开不启用，收起不关闭生效的历史条件', (tester) async {
    await pumpNames(tester);
    expect(find.byKey(const Key('name-history-enabled')), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(
      tester.widget<NameToolResults>(find.byType(NameToolResults)).names,
      hasLength(10),
    );
    await tapVisible(tester, find.byKey(const Key('name-advanced-disclosure')));
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('name-history-enabled')))
          .value,
      isFalse,
    );
    expect(find.byType(NameToolResults), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('name-history-enabled')));
    expect(find.byType(NameToolResults), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsNothing);
    await tapVisible(tester, find.byKey(const Key('name-advanced-disclosure')));
    expect(find.byKey(const Key('name-history-enabled')), findsNothing);
    expect(find.textContaining('1500–1644'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(
      tester.widget<NameToolResults>(find.byType(NameToolResults)).names.first,
      isA<GeneratedHistoricalName>(),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('历史启停清掉隐藏普通姓与幻想风，回到常见随机姓', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '风格', '幻想');
    await tester.enterText(find.byKey(const Key('name-surname')), '司马');
    await enableHistory(tester);
    expect(find.text('风格'), findsNothing);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    await tapVisible(tester, find.byKey(const Key('name-history-enabled')));
    expect(find.byType(NameToolResults), findsNothing);
    expect(find.text('常见'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('name-surname')))
          .controller!
          .text,
      isEmpty,
    );
    final controls = tester.widget<HistoricalNameControls>(
      find.byType(HistoricalNameControls),
    );
    expect(controls.profile, isNull);
    expect(controls.role, isNull);
    expect(controls.familyId, isEmpty);
    expect(controls.includePatronymic, isFalse);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(
      tester.widget<NameToolResults>(find.byType(NameToolResults)).names.first,
      isNot(isA<GeneratedHistoricalName>()),
    );
  });

  testWidgets('国家、时期和类型切换重置旧结果、家族与父称；无历史国家不显示入口', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '国家', '俄国');
    await enableHistory(tester);
    await tapVisible(tester, find.byKey(const Key('name-history-patronymic')));
    await selectNameOption(tester, '姓名类型', '家族姓氏');
    var controls = tester.widget<HistoricalNameControls>(
      find.byType(HistoricalNameControls),
    );
    expect(controls.includePatronymic, isFalse);
    await selectNameOption(tester, '家族', '尤苏波夫家族');
    await tapVisible(tester, find.byKey(const Key('name-history-patronymic')));
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(find.byType(NameToolResults), findsOneWidget);
    await selectNameOption(tester, '时代与地区', '帝俄十九世纪（1801–1917）');
    controls = tester.widget<HistoricalNameControls>(
      find.byType(HistoricalNameControls),
    );
    expect(controls.role!.id, 'period');
    expect(controls.familyId, isEmpty);
    expect(controls.includePatronymic, isFalse);
    expect(find.byType(NameToolResults), findsNothing);
    await selectNameOption(tester, '国家', '美国');
    expect(find.byType(HistoricalNameControls), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsOneWidget);
    await selectNameOption(tester, '国家', '中国');
    controls = tester.widget<HistoricalNameControls>(
      find.byType(HistoricalNameControls),
    );
    expect(controls.expanded, isFalse);
    expect(controls.profile, isNull);
  });

  testWidgets('历史完整双语复制与短促提示保留，有限姓名提示真实数量', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpNames(tester);
    await selectNameOption(tester, '国家', '英国');
    await enableHistory(tester);
    await selectNameOption(tester, '性别', '男');
    await selectNameOption(tester, '姓名类型', '家族姓氏');
    await selectNameOption(tester, '家族', '霍华德家族');
    await tester.ensureVisible(find.byKey(const Key('name-count')));
    await tester.enterText(find.byKey(const Key('name-count')), '50');
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    final names = tester
        .widget<NameToolResults>(find.byType(NameToolResults))
        .names;
    expect(names.length, lessThan(50));
    expect(find.text('已生成 ${names.length} 个不同姓名'), findsOneWidget);
    for (final entry in {
      '复制原文': names.map((name) => name.original).join('\n'),
      '复制中文': names.map((name) => name.zh).join('\n'),
      '复制全部': names.map((name) => name.bilingual).join('\n'),
    }.entries) {
      await tapVisible(tester, find.text(entry.key));
      expect(clipboard, entry.value);
      expect(find.text('复制成功'), findsOneWidget);
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).duration,
        const Duration(milliseconds: 1500),
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    for (final narrow in [false, true]) {
      testWidgets(
        '历史条件明暗与大字 ${narrow ? '320_2x' : '400'} ${dark ? 'dark' : 'light'}',
        (tester) async {
          await pumpNames(tester, dark: dark, narrow: narrow);
          await selectNameOption(tester, '国家', '日本');
          await enableHistory(tester);
          await selectNameOption(tester, '姓名类型', '华族家系（1884–1912）');
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(
            find.byKey(const Key('name-advanced-disclosure')),
          );
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(Scaffold).first,
            matchesGoldenFile(
              'goldens/history_names_${narrow ? '320_2x' : '400'}_${dark ? 'dark' : 'light'}.png',
            ),
          );
          await tapVisible(tester, find.byKey(const Key('tool-generate')));
          expect(find.byType(NameToolResults), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tapVisible(
            tester,
            find.byKey(const Key('name-advanced-disclosure')),
          );
          expect(find.textContaining('1884–1912'), findsOneWidget);
          await tapVisible(tester, find.byKey(const Key('tool-generate')));
          expect(
            tester.getSize(find.byKey(const Key('tool-generate'))).height,
            greaterThanOrEqualTo(48),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

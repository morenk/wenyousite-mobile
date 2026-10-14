import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_catalog.dart';
import 'package:wenyousite_mobile/features/toolbox/application/advanced_name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/advanced_name_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';

import '../../support/deterministic_test_fonts.dart';

Future<void> pumpNames(
  WidgetTester tester, {
  bool dark = false,
  bool narrow = false,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(narrow ? 320 : 400, 860);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? (dark ? AppTheme.dark : AppTheme.light),
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

Future<void> toggleAdvanced(WidgetTester tester) =>
    tapVisible(tester, find.byKey(const Key('name-advanced-disclosure')));

AdvancedNameControls controls(WidgetTester tester) =>
    tester.widget<AdvancedNameControls>(find.byType(AdvancedNameControls));

NameToolResults results(WidgetTester tester) =>
    tester.widget<NameToolResults>(find.byType(NameToolResults));

void main() {
  setUpAll(loadDeterministicTestFonts);
  final catalog = AdvancedNameCatalog();

  testWidgets('默认普通；展开即进阶，收起即普通并清理旧结果', (tester) async {
    await pumpNames(tester);
    expect(find.text('历史起名'), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).names, hasLength(10));
    await toggleAdvanced(tester);
    expect(find.byType(NameToolResults), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsNothing);
    expect(find.byKey(const Key('name-history-family')), findsNothing);
    expect(find.text('史实参考'), findsOneWidget);
    expect(find.text('时代与地区'), findsNothing);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).names.first, isA<GeneratedAdvancedName>());
    await toggleAdvanced(tester);
    expect(find.byType(NameToolResults), findsNothing);
    expect(find.text('史实参考'), findsNothing);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).names.first, isNot(isA<GeneratedAdvancedName>()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('进阶隔离普通姓与幻想风，收起恢复原参数', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '风格', '幻想');
    await tester.enterText(find.byKey(const Key('name-surname')), '司马');
    await toggleAdvanced(tester);
    expect(find.text('幻想'), findsNothing);
    await selectNameOption(tester, '类型', '文学创作');
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    await toggleAdvanced(tester);
    expect(find.byType(NameToolResults), findsNothing);
    expect(find.text('幻想'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('name-surname')))
          .controller!
          .text,
      '司马',
    );
    expect(controls(tester).styleId, isNull);
    expect(controls(tester).structureId, isNull);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(
      results(tester).names.every((name) => name.original.startsWith('司马')),
      isTrue,
    );
  });

  testWidgets('切换类型与风格清结果并回默认结构；国家改变回普通', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '国家', '俄国');
    await toggleAdvanced(tester);
    final structured = catalog
        .forCountry('ru', 'historical')
        .firstWhere((style) => style.structures.length > 1);
    await selectNameOption(tester, '风格', structured.label);
    final alternate = structured.structures.firstWhere(
      (structure) => structure.id != structured.defaultStructureId,
    );
    await selectNameOption(tester, '姓名结构', alternate.label);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).names.first, isA<GeneratedAdvancedName>());
    await selectNameOption(tester, '类型', '文学创作');
    final literary = catalog.forCountry('ru', 'literary');
    expect(controls(tester).styleId, literary.first.id);
    expect(controls(tester).structureId, literary.first.defaultStructureId);
    expect(find.byType(NameToolResults), findsNothing);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    await selectNameOption(tester, '风格', literary.last.label);
    expect(controls(tester).styleId, literary.last.id);
    expect(controls(tester).structureId, literary.last.defaultStructureId);
    expect(find.byType(NameToolResults), findsNothing);
    await selectNameOption(tester, '国家', '美国');
    expect(find.byType(AdvancedNameControls), findsNothing);
    expect(find.byKey(const Key('name-surname')), findsOneWidget);
    await selectNameOption(tester, '国家', '中国');
    expect(controls(tester).expanded, isFalse);
    expect(controls(tester).styleId, isNull);
  });

  testWidgets('进阶清空与收起不改普通自定义外文姓及中文写法', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '国家', '英国');
    await tester.enterText(find.byKey(const Key('name-surname')), 'Newfamily');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-surname-zh')), '纽法米利');
    await toggleAdvanced(tester);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    await tapVisible(tester, find.text('清空'));
    await toggleAdvanced(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('name-surname')))
          .controller!
          .text,
      'Newfamily',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('name-surname-zh')))
          .controller!
          .text,
      '纽法米利',
    );
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(
      results(tester).names.every(
        (name) =>
            name.original.endsWith('Newfamily') && name.zh.endsWith('纽法米利'),
      ),
      isTrue,
    );
  });

  testWidgets('热重载清进阶旧状态，旧浮层回调不能恢复条件，普通输入仍在', (tester) async {
    await pumpNames(tester);
    await tester.enterText(find.byKey(const Key('name-surname')), '司马');
    await toggleAdvanced(tester);
    await tapVisible(tester, find.text('风格'));
    final option = catalog.forCountry('cn', 'historical').first.label;
    final reassembly = tester.binding.reassembleApplication();
    // reassemble 等待下一帧；测试时须主动推进帧，不能先阻塞等待。
    await tester.pump();
    await reassembly;
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text(option).last);
    expect(controls(tester).expanded, isFalse);
    expect(controls(tester).styleId, isNull);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('name-surname')))
          .controller!
          .text,
      '司马',
    );
    await toggleAdvanced(tester);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).names.first, isA<GeneratedAdvancedName>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('进阶完整双语复制保留短提示和全部结果', (tester) async {
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
    await toggleAdvanced(tester);
    await selectNameOption(tester, '类型', '文学创作');
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    final names = results(tester).names;
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
  });

  testWidgets('小词池请求50个时显示实际不重复数量，不宣称容量上限', (tester) async {
    await pumpNames(tester);
    await selectNameOption(tester, '性别', '男');
    await tester.enterText(find.byKey(const Key('name-count')), '50');
    await toggleAdvanced(tester);
    await selectNameOption(tester, '类型', '文学创作');
    final style = catalog.forCountry('cn', 'literary').first;
    expect(style.families.length * style.given['male']!.length, lessThan(50));
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    final names = results(tester).names;
    expect(names.length, lessThan(50));
    expect(names.map((name) => name.original).toSet().length, names.length);
    expect(find.text('已生成 ${names.length} 个不重复姓名'), findsOneWidget);
  });

  testWidgets('编辑数量及键盘重建不改变上一批结果的请求数量', (tester) async {
    await pumpNames(tester);
    await tapVisible(tester, find.byKey(const Key('tool-generate')));
    expect(results(tester).requestedCount, 10);
    await tester.enterText(find.byKey(const Key('name-count')), '50');
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    expect(results(tester).requestedCount, 10);
    expect(find.text('已生成 10 个不重复姓名'), findsNothing);
    tester.view.resetViewInsets();
  });

  for (final mode in ['historical', 'literary']) {
    for (final dark in [false, true]) {
      for (final narrow in [false, true]) {
        final state =
            '${mode}_${narrow ? '320_2x' : '400'}_${dark ? 'dark' : 'light'}';
        testWidgets('进阶类型与风格明暗大字 $state', (tester) async {
          await pumpNames(tester, dark: dark, narrow: narrow);
          await selectNameOption(tester, '国家', '日本');
          await toggleAdvanced(tester);
          if (mode == 'literary') await selectNameOption(tester, '类型', '文学创作');
          await tester.ensureVisible(
            find.byKey(const Key('name-advanced-disclosure')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(Scaffold).first,
            matchesGoldenFile('goldens/advanced_names_$state.png'),
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 260);
          await tester.pumpAndSettle();
          await tapVisible(tester, find.byKey(const Key('tool-generate')));
          expect(results(tester).names.first, isA<GeneratedAdvancedName>());
          expect(
            tester.getSize(find.byKey(const Key('tool-generate'))).height,
            greaterThanOrEqualTo(48),
          );
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
        });
      }
    }
  }
}

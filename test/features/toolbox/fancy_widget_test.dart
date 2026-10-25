import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/toolbox/application/text_transformers.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/toolbox_test_fonts.dart';

Future<void> _pump(
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
      debugShowCheckedModeBanner: false,
      theme: toolboxGoldenTheme(dark ? AppTheme.dark : AppTheme.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
        child: child!,
      ),
      home: const TextToolPage(tool: TextTool.fancy),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _category(WidgetTester tester, String category) async {
  await _tap(tester, find.byKey(const Key('fancy-category')));
  await _tap(tester, find.text(fancyCategories[category]!).last);
}

String _option(String id) {
  final style = FancyStyle.byId(id);
  return '${style.label}\n${style.preview}';
}

void main() {
  setUpAll(loadDeterministicTestFonts);
  setUpAll(loadToolboxTestFonts);

  testWidgets('四分类提供真实样例，切换清旧结果，中文装饰复制保留空白和复合字符', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
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
    await _pump(tester);
    ToolSelect<FancyStyle> selector() => tester.widget<ToolSelect<FancyStyle>>(
      find.byKey(const Key('fancy-style')),
    );
    expect(selector().options, hasLength(19));
    expect(selector().value.id, 'bold');
    await tester.enterText(
      find.byKey(const Key('tool-input')),
      '温油 Aé👩🏽‍💻\n \n尾',
    );
    await _tap(tester, find.byKey(const Key('tool-generate')));
    expect(find.byKey(const Key('tool-result-text')), findsOneWidget);
    await _category(tester, 'symbol');
    expect(find.byKey(const Key('tool-result-text')), findsNothing);
    expect(selector().options, hasLength(6));
    expect(selector().value.id, 'pseudo-script');
    await _category(tester, 'effect');
    expect(selector().options, hasLength(8));
    expect(selector().value.id, 'dot-above');
    await _category(tester, 'decoration');
    expect(selector().options, hasLength(16));
    expect(selector().value.id, 'corner');
    await _tap(tester, find.byKey(const Key('fancy-style')));
    await _tap(tester, find.text(_option('corner')).last);
    await _tap(tester, find.byKey(const Key('tool-generate')));
    const expected = '【温油 Aé👩🏽‍💻】\n \n【尾】';
    expect(find.text(expected), findsOneWidget);
    await _tap(tester, find.byKey(const Key('tool-copy')));
    expect(copied, expected);
    expect(find.text('复制成功'), findsOneWidget);
    await _category(tester, 'font');
    expect(selector().value.id, 'bold');
    expect(find.byKey(const Key('tool-result-text')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final narrow in [false, true]) {
    final state = narrow ? '320_2x_dark' : '400_light';
    for (final category in ['font', 'symbol', 'effect', 'decoration']) {
      testWidgets('花体分类实际字形与窄屏 $category $state', (tester) async {
        await _pump(tester, dark: narrow, narrow: narrow);
        if (category != 'font') await _category(tester, category);
        await _tap(tester, find.byKey(const Key('fancy-style')));
        if (category == 'effect') {
          await tester.scrollUntilVisible(
            find.text(_option('zalgo')),
            200,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Overlay).first,
          matchesGoldenFile('goldens/fancy_${category}_$state.png'),
        );
        await _tap(
          tester,
          category == 'effect'
              ? find.text(_option('zalgo'))
              : find.byTooltip('关闭样式'),
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pumpAndSettle();
        await _tap(tester, find.byKey(const Key('tool-generate')));
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
      });
    }

    testWidgets('Zalgo 结果行距和边缘 $state', (tester) async {
      await _pump(tester, dark: narrow, narrow: narrow);
      await _category(tester, 'effect');
      await _tap(tester, find.byKey(const Key('fancy-style')));
      await tester.scrollUntilVisible(
        find.text(_option('zalgo')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await _tap(tester, find.text(_option('zalgo')));
      await tester.enterText(
        find.byKey(const Key('tool-input')),
        'Hello Wenyou\nHello Wenyou',
      );
      await _tap(tester, find.byKey(const Key('tool-generate')));
      await tester.ensureVisible(find.byKey(const Key('tool-result-text')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Overlay).first,
        matchesGoldenFile('goldens/fancy_zalgo_result_$state.png'),
      );
    });
  }
}

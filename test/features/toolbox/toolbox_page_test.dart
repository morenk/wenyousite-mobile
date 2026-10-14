import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_access.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/routes/account_routes.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_selection_menu.dart';
import 'package:wenyousite_mobile/features/toolbox/domain/text_tool.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/text_tool_page.dart';
import 'package:wenyousite_mobile/features/users/presentation/me_page.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  Future<void> pumpRoutes(
    WidgetTester tester, {
    String path = '/tools',
    ThemeData? theme,
  }) async {
    final provider = Provider((ref) {
      final router = GoRouter(
        initialLocation: path,
        routes: [
          GoRoute(path: '/me', builder: (_, _) => const MePage()),
          ...buildAccountRoutes(ref),
        ],
      );
      ref.onDispose(router.dispose);
      return router;
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: theme ?? AppTheme.light,
          routerConfig: container.read(provider),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpTool(
    WidgetTester tester,
    TextTool tool, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        home: TextToolPage(tool: tool),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> generate(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('tool-generate')));
    await tester.tap(find.byKey(const Key('tool-generate')));
    await tester.pumpAndSettle();
  }

  testWidgets('游客四工具目录公开，进入工具即有原生表单，不创建网页', (tester) async {
    await pumpRoutes(tester, path: '/me');
    await tester.tap(find.byKey(const Key('me-open-toolbox')));
    await tester.pumpAndSettle();
    for (final tool in TextTool.values) {
      expect(
        AppRouteAccessPolicy.forLocation('/tools/${tool.id}'),
        AppRouteAccess.public,
      );
      await tester.tap(find.byKey(ValueKey('toolbox-${tool.id}')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, tool.title), findsOneWidget);
      expect(find.byType(AndroidView), findsNothing);
      expect(find.byType(UiKitView), findsNothing);
      expect(find.byType(PlatformViewLink), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byKey(const Key('tool-generate')), findsOneWidget);
      await tester.tap(find.byTooltip('返回工具箱'));
      await tester.pumpAndSettle();
    }
  });
  testWidgets('未知工具回目录，退出不保留输入结果', (tester) async {
    await pumpRoutes(tester, path: '/tools/unknown');
    expect(find.text('工具箱'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toolbox-morse')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tool-input')), 'SOS');
    await generate(tester);
    expect(find.text('... --- ...'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toolbox-morse')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('tool-input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(find.byKey(const Key('tool-result-text')), findsNothing);
  });
  testWidgets('主题变化保留输入，转换与错误恢复', (tester) async {
    await pumpTool(tester, TextTool.morse);
    await tester.enterText(find.byKey(const Key('tool-input')), '中文');
    await generate(tester);
    expect(find.textContaining('国际摩斯不支持'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tool-input')), 'SOS');
    await pumpTool(tester, TextTool.morse, theme: AppTheme.dark);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('tool-input')))
          .controller!
          .text,
      'SOS',
    );
    await generate(tester);
    expect(find.text('... --- ...'), findsOneWidget);
    expect(find.textContaining('国际摩斯不支持'), findsNothing);
  });
  testWidgets('花体默认粗体有样例，超限粘贴可看见和修改', (tester) async {
    await pumpTool(tester, TextTool.fancy);
    expect(find.text('粗体\n𝐇𝐞𝐥𝐥𝐨 𝐖𝐞𝐧𝐲𝐨𝐮'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tool-input')), 'Az09中文');
    await generate(tester);
    expect(find.text('𝐀𝐳𝟎𝟗中文'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tool-input')), 'x' * 10001);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('tool-input')))
          .controller!
          .text
          .length,
      10001,
    );
    await generate(tester);
    expect(find.text('输入最多 10,000 个字符'), findsWidgets);
    expect(find.byKey(const Key('tool-result-text')), findsNothing);
  });
  testWidgets('默认竖排从右侧显示，复制保留所有首尾空白', (tester) async {
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
    await pumpTool(tester, TextTool.vertical);
    expect(find.text('从右向左'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('tool-input')), '甲');
    await generate(tester);
    final result = tester
        .widget<Text>(find.byKey(const Key('tool-result-text')))
        .data!;
    expect(result.split('\n').length, 20);
    expect(result.startsWith(' ' * 36), isTrue);
    expect(result.endsWith(' ' * 38), isTrue);
    final horizontal = tester
        .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .singleWhere((widget) => widget.scrollDirection == Axis.horizontal);
    expect(horizontal.reverse, isTrue);
    await tester.ensureVisible(find.byKey(const Key('tool-copy')));
    await tester.tap(find.byKey(const Key('tool-copy')));
    await tester.pumpAndSettle();
    expect(clipboard, result);
  });
  testWidgets('外文姓氏要求中文写法，生成和复制明确双语', (tester) async {
    await pumpTool(tester, TextTool.names);
    await tester.tap(find.text('中国'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英国').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-surname')), 'Newfamily');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('name-surname-zh')), findsOneWidget);
    await generate(tester);
    expect(find.text('请填写姓氏中文写法'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('name-surname-zh')));
    await tester.enterText(find.byKey(const Key('name-surname-zh')), '纽法米利');
    await generate(tester);
    expect(find.text('复制原文'), findsOneWidget);
    expect(find.text('复制中文'), findsOneWidget);
    expect(find.text('复制全部'), findsOneWidget);
    final results = tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    );
    expect(results.length, 10);
    expect(
      results.every((text) => text.textSpan!.toPlainText().contains('纽法米利')),
      isTrue,
    );
  });
  testWidgets('自定义分隔符不受隐藏的无效空格数阻断', (tester) async {
    await pumpTool(tester, TextTool.vertical);
    await tester.enterText(find.byKey(const Key('tool-input')), '甲');
    final gap = find.byKey(const Key('vertical-gap'));
    await tester.ensureVisible(gap);
    await tester.enterText(gap, '99');
    await tester.tap(find.text('空格'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('自定义').last);
    await tester.pumpAndSettle();
    final separator = find.byKey(const Key('vertical-separator'));
    await tester.ensureVisible(separator);
    await tester.enterText(separator, '|');
    await generate(tester);
    expect(find.byKey(const Key('tool-result-text')), findsOneWidget);
    expect(find.textContaining('列间空格须'), findsNothing);
  });
  testWidgets('工具参数、操作、标题及选择浮层使用常规字重', (tester) async {
    await pumpTool(tester, TextTool.names);
    final theme = Theme.of(tester.element(find.byType(AppBar)));
    expect(theme.appBarTheme.titleTextStyle!.fontWeight, FontWeight.w400);
    expect(theme.textTheme.wenyouRowTitle.fontWeight, FontWeight.w400);
    expect(
      theme.filledButtonTheme.style!.textStyle!.resolve({})!.fontWeight,
      FontWeight.w400,
    );
    expect(
      theme.textButtonTheme.style!.textStyle!.resolve({})!.fontWeight,
      FontWeight.w400,
    );
    final field = tester.widget<TextField>(find.byKey(const Key('name-count')));
    expect(field.decoration!.labelText, isNull);
    expect(field.decoration!.border, InputBorder.none);
    expect(field.style!.fontWeight, FontWeight.w400);
    expect(
      tester.getSize(find.byKey(const Key('name-count'))).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.text('中国'));
    await tester.pumpAndSettle();
    final selected = tester
        .widgetList<WenyouSelectionRow>(find.byType(WenyouSelectionRow))
        .singleWhere((row) => row.selected);
    expect(selected.emphasizeSelected, isFalse);
    expect(
      tester.widget<Text>(find.text('中国').last).style!.fontWeight,
      FontWeight.w400,
    );
    await tester.tap(find.text('英国').last);
    await tester.pumpAndSettle();
    expect(find.text('英国'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('完整工具目录视觉 ${theme.brightness.name}', (tester) async {
      tester.view.physicalSize = const Size(400, 860);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpRoutes(tester, theme: theme);
      expect(tester.takeException(), isNull);
      for (final tool in TextTool.values) {
        expect(
          tester.getSize(find.byKey(ValueKey('toolbox-${tool.id}'))).height,
          greaterThanOrEqualTo(48),
        );
      }
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile('goldens/toolbox_400_${theme.brightness.name}.png'),
      );
    });
    testWidgets('目录窄屏大字 ${theme.brightness.name}', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpRoutes(tester, theme: theme);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold).last,
        matchesGoldenFile(
          'goldens/toolbox_320_2x_${theme.brightness.name}.png',
        ),
      );
    });
  }
}

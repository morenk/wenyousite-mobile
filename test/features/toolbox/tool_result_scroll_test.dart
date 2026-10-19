import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_settings_body.dart';
import 'package:wenyousite_mobile/features/toolbox/application/name_generator.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/name_tool_results.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_controls.dart';
import 'package:wenyousite_mobile/features/toolbox/presentation/tool_typography.dart';

import '../../support/deterministic_test_fonts.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final vertical = find.byKey(const Key('tool-result-vertical-scroll'));
  final horizontal = find.byKey(const Key('tool-result-horizontal-scroll'));
  final viewport = find.byKey(const Key('tool-result-viewport'));
  ScrollController controller(WidgetTester tester, Finder finder) =>
      tester.widget<SingleChildScrollView>(finder).controller!;

  Future<void> pumpResult(
    WidgetTester tester,
    Widget result, {
    bool narrow = false,
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(narrow ? 2 : 1)),
          child: child!,
        ),
        home: ToolTypography(
          child: Builder(
            builder: (context) => Scaffold(
              backgroundColor: wenyouPersonalPageBackground(context),
              appBar: AppBar(title: const Text('工具结果')),
              body: WenyouSettingsBody(
                children: [result, const SizedBox(height: 600)],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void size(WidgetTester tester, {bool narrow = false}) {
    tester.view.physicalSize = Size(narrow ? 320 : 400, narrow ? 640 : 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> scrollToEnd(WidgetTester tester) async {
    final scroll = controller(tester, vertical);
    for (var i = 0; i < 60 && scroll.position.extentAfter > 1; i++) {
      await tester.drag(vertical, const Offset(0, -250));
      await tester.pumpAndSettle();
    }
    expect(scroll.position.extentAfter, lessThan(1));
  }

  String? copied;
  setUp(() {
    copied = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final narrow in [false, true]) {
    testWidgets('长姓名限高、常显滚动条、完整复制 ${narrow ? '320_2x_light' : '400_dark'}', (
      tester,
    ) async {
      size(tester, narrow: narrow);
      final names = List.generate(
        50,
        (index) => GeneratedName(
          original: 'James Smith ${index + 1}',
          zh: '詹姆斯·史密斯 ${index + 1}',
        ),
      );
      await pumpResult(
        tester,
        NameToolResults(names: names, requestedCount: 50, foreign: true),
        narrow: narrow,
        dark: !narrow,
      );
      final bar = tester.widget<Scrollbar>(
        find.byKey(const Key('tool-result-vertical-bar')),
      );
      expect(bar.thumbVisibility, isTrue);
      expect(bar.trackVisibility, isTrue);
      expect(bar.controller, same(controller(tester, vertical)));
      expect(controller(tester, vertical).positions.length, 1);
      expect(
        tester.getSize(viewport).height,
        lessThanOrEqualTo((narrow ? 640 : 860) * .45),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/native_names_scroll_${narrow ? '320_2x_light' : '400_dark'}.png',
        ),
      );
      final copyPosition = tester.getTopLeft(find.text('复制全部'));
      final pagePosition = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      await scrollToEnd(tester);
      expect(find.byType(SelectableText).last.hitTestable(), findsOneWidget);
      expect(tester.getTopLeft(find.text('复制全部')), copyPosition);
      expect(pagePosition.pixels, 0);
      await tester.tap(find.text('复制全部'));
      await tester.pumpAndSettle();
      expect(copied, names.map((name) => name.bilingual).join('\n'));
      await pumpResult(
        tester,
        NameToolResults(names: [...names], requestedCount: 50, foreign: true),
        narrow: narrow,
        dark: !narrow,
      );
      expect(controller(tester, vertical).offset, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('长转换结果内滚到末尾，复制完整且重新生成相同文本复位', (tester) async {
    size(tester);
    final text =
        '  ${List.generate(100, (index) => 'result $index').join('\n')}  \n';
    await pumpResult(tester, ToolResult(text: text, revision: 1));
    final copyPosition = tester.getTopLeft(find.byKey(const Key('tool-copy')));
    await scrollToEnd(tester);
    expect(controller(tester, vertical).offset, greaterThan(0));
    expect(tester.getTopLeft(find.byKey(const Key('tool-copy'))), copyPosition);
    await tester.tap(find.byKey(const Key('tool-copy')));
    await tester.pumpAndSettle();
    expect(copied, text);
    await pumpResult(tester, ToolResult(text: text, revision: 2));
    expect(controller(tester, vertical).offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('竖排双轴滚动条独立，右侧起点与重新生成复位', (tester) async {
    size(tester);
    final text = List.generate(
      50,
      (row) => 'row $row ${'甲  ' * 40}',
    ).join('\n');
    await pumpResult(
      tester,
      ToolResult(text: text, fixedLayout: true, fromRight: true, revision: 1),
      dark: true,
    );
    final v = controller(tester, vertical);
    final h = controller(tester, horizontal);
    expect(v, isNot(same(h)));
    expect(v.positions.length, 1);
    expect(h.positions.length, 1);
    expect(h.position.axisDirection, AxisDirection.left);
    expect(h.offset, 0);
    expect(h.position.maxScrollExtent, greaterThan(0), reason: '横轴需要实际溢出');
    for (final axis in ['vertical', 'horizontal']) {
      final bar = tester.widget<Scrollbar>(
        find.byKey(Key('tool-result-$axis-bar')),
      );
      expect(bar.thumbVisibility, isTrue);
      expect(bar.trackVisibility, isTrue);
    }
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/native_vertical_scroll_400_dark.png'),
    );
    await tester.drag(viewport, const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(
      h.offset,
      greaterThan(0),
      reason:
          'axis=${h.position.axisDirection} max=${h.position.maxScrollExtent}',
    );
    expect(v.offset, 0);
    final horizontalOffset = h.offset;
    await tester.drag(viewport, const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(v.offset, greaterThan(0));
    expect(h.offset, horizontalOffset);
    await pumpResult(
      tester,
      ToolResult(text: text, fixedLayout: true, fromRight: true, revision: 2),
      dark: true,
    );
    expect(v.offset, 0);
    expect(h.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('短结果收缩，键盘出现后长结果按可用高度缩小', (tester) async {
    size(tester);
    await pumpResult(tester, const ToolResult(text: '短结果'));
    expect(tester.getSize(viewport).height, lessThan(80));
    expect(controller(tester, vertical).position.maxScrollExtent, 0);
    await tester.longPressAt(
      tester.getTopLeft(find.byKey(const Key('tool-result-text'))) +
          const Offset(8, 12),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copy'), findsOneWidget);
    await tester.tap(find.text('工具结果'));
    await tester.pumpAndSettle();
    final text = List.filled(50, 'long result').join('\n');
    await pumpResult(tester, ToolResult(text: text));
    final height = tester.getSize(viewport).height;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getSize(viewport).height, lessThan(height));
    expect(
      tester.getSize(viewport).height,
      lessThanOrEqualTo((860 - 300) * .45),
    );
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

void main() {
  testWidgets('内容页签保留 48dp 命中区并由点击切换', (tester) async {
    var selected = 0;

    Widget buildTabs() {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => WenyouContentTabs<int>(
              semanticsLabel: '内容栏目',
              keyPrefix: 'test-tab',
              fillAvailableWidth: true,
              options: const [
                WenyouFilterOption(value: 0, label: '主题'),
                WenyouFilterOption(value: 1, label: '动态'),
              ],
              selected: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildTabs());

    expect(tester.getSize(find.byKey(const ValueKey('test-tab-0'))).height, 48);
    expect(find.bySemanticsLabel('内容栏目'), findsOneWidget);

    await tester.drag(find.bySemanticsLabel('内容栏目'), const Offset(-120, 0));
    await tester.pump();
    expect(selected, 0);

    await tester.tap(find.byKey(const ValueKey('test-tab-1')));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('内容框架统一响应式边距与最大宽度', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: WenyouContentFrame(
            child: ColoredBox(
              key: Key('framed-content'),
              color: Colors.pink,
              child: SizedBox(height: 40),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('framed-content'))).width, 600);
  });

  testWidgets('四栏内容页签在 320dp 窄屏保持单行且不溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouContentTabs<int>(
            semanticsLabel: '搜索结果栏目',
            fillAvailableWidth: true,
            options: const [
              WenyouFilterOption(value: 0, label: '动态'),
              WenyouFilterOption(value: 1, label: '主题帖'),
              WenyouFilterOption(value: 2, label: '楼层内容'),
              WenyouFilterOption(value: 3, label: '用户'),
            ],
            selected: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.text('楼层内容')).height, lessThan(24));
  });
}

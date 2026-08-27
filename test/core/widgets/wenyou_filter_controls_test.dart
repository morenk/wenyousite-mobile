import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('内容页签保留 48dp 命中区并由点击切换', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 200);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    var selected = 0;

    Widget buildTabs() {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => WenyouContentTabs<int>(
              semanticsLabel: '内容栏目',
              keyPrefix: 'test-tab',
              placement: WenyouTabPlacement.embedded,
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
    expect(tester.getSize(find.byKey(const ValueKey('test-tab-0'))).width, 180);
    expect(tester.getSize(find.byKey(const ValueKey('test-tab-1'))).width, 180);
    expect(find.bySemanticsLabel('内容栏目'), findsOneWidget);

    await tester.drag(find.bySemanticsLabel('内容栏目'), const Offset(-120, 0));
    await tester.pump();
    expect(selected, 0);

    await tester.tap(find.byKey(const ValueKey('test-tab-1')));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('内容滑动区按方向播放切栏动画并忽略短滑与边界', (tester) async {
    var selected = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => WenyouSwipeTabRegion<int>(
              key: const Key('test-swipe-tabs'),
              values: const [0, 1, 2],
              selected: selected,
              onSelected: (value) => setState(() => selected = value),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('test-swipe-tabs')),
      const Offset(-80, 0),
    );
    await tester.pump();
    expect(selected, 2);
    final slide = find.descendant(
      of: find.byKey(const Key('test-swipe-tabs')),
      matching: find.byType(SlideTransition),
    );
    expect(tester.widget<SlideTransition>(slide).position.value.dx, isPositive);
    await tester.pumpAndSettle();
    expect(tester.widget<SlideTransition>(slide).position.value.dx, 0);

    await tester.drag(
      find.byKey(const Key('test-swipe-tabs')),
      const Offset(-80, 0),
    );
    await tester.pump();
    expect(selected, 2);
    expect(tester.widget<SlideTransition>(slide).position.value.dx, 0);

    await tester.drag(
      find.byKey(const Key('test-swipe-tabs')),
      const Offset(30, 0),
    );
    await tester.pump();
    expect(selected, 2);

    await tester.drag(
      find.byKey(const Key('test-swipe-tabs')),
      const Offset(80, 0),
    );
    await tester.pump();
    expect(selected, 1);
    expect(tester.widget<SlideTransition>(slide).position.value.dx, isNegative);
    await tester.pumpAndSettle();
    expect(tester.widget<SlideTransition>(slide).position.value.dx, 0);
  });

  testWidgets('减少动态效果时切栏直接进入最终位置', (tester) async {
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => WenyouSwipeTabRegion<int>(
                key: const Key('reduced-motion-swipe-tabs'),
                values: const [0, 1],
                selected: selected,
                onSelected: (value) => setState(() => selected = value),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const Key('reduced-motion-swipe-tabs')),
      const Offset(-80, 0),
    );
    await tester.pump();

    expect(selected, 1);
    final slide = tester.widget<SlideTransition>(
      find.descendant(
        of: find.byKey(const Key('reduced-motion-swipe-tabs')),
        matching: find.byType(SlideTransition),
      ),
    );
    expect(slide.position.value.dx, 0);
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

  testWidgets('锚点下拉的触发态、菜单圆角、宽度和选项高度保持一致', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 224,
              child: WenyouDropdownFilter<int>(
                key: const Key('test-dropdown-filter'),
                options: const [
                  WenyouFilterOption(value: 0, label: '最早在前'),
                  WenyouFilterOption(value: 1, label: '最新在前'),
                ],
                selected: 0,
                onSelected: (_) {},
                tooltip: '选择排序',
                icon: WenyouIconIds.actionSort,
              ),
            ),
          ),
        ),
      ),
    );

    final popup = tester.widget<PopupMenuButton<int>>(
      find.descendant(
        of: find.byKey(const Key('test-dropdown-filter')),
        matching: find.byType(PopupMenuButton<int>),
      ),
    );
    final expectedRadius = BorderRadius.circular(
      WenyouThemeTokens.light.radius16,
    );
    expect(popup.borderRadius, expectedRadius);
    expect(
      (popup.shape! as RoundedRectangleBorder).borderRadius,
      expectedRadius,
    );
    expect(popup.clipBehavior, Clip.antiAlias);
    expect(popup.constraints?.minWidth, 224);
    expect(popup.constraints?.maxWidth, 224);
    expect(
      tester.getSize(find.byKey(const Key('test-dropdown-filter'))).height,
      WenyouThemeTokens.light.minimumTouchTarget,
    );

    await tester.tap(find.byKey(const Key('test-dropdown-filter')));
    await tester.pumpAndSettle();
    final menuItems = find.byWidgetPredicate(
      (widget) => widget is PopupMenuItem<int>,
    );
    expect(menuItems, findsNWidgets(2));
    for (final element in menuItems.evaluate()) {
      expect(
        tester.getSize(find.byWidget(element.widget)).height,
        WenyouThemeTokens.light.minimumTouchTarget,
      );
    }
  });

  testWidgets('表单下拉统一使用 48dp 选项与 16dp 展开圆角', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: WenyouDropdownFormField<int>(
                key: const Key('test-dropdown-form-field'),
                initialValue: 0,
                decoration: const InputDecoration(labelText: '主题状态'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('招募中')),
                  DropdownMenuItem(value: 1, child: Text('已停招')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final field = tester.widget<DropdownButton<int>>(
      find.descendant(
        of: find.byKey(const Key('test-dropdown-form-field')),
        matching: find.byType(DropdownButton<int>),
      ),
    );
    expect(field.isExpanded, isTrue);
    expect(field.itemHeight, WenyouThemeTokens.light.minimumTouchTarget);
    expect(
      field.borderRadius,
      BorderRadius.circular(WenyouThemeTokens.light.radius16),
    );
  });

  testWidgets('四栏内容页签在 360dp 等宽铺满且不溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouContentTabs<int>(
            semanticsLabel: '搜索结果栏目',
            placement: WenyouTabPlacement.embedded,
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
    for (var index = 0; index < 4; index++) {
      expect(
        tester.getSize(find.byKey(ValueKey('content-tab-$index'))).width,
        90,
      );
    }
    expect(tester.getSize(find.text('楼层内容')).height, lessThan(24));
  });

  testWidgets('长分类和放大字号自动横滑并把选中项带入视口', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: WenyouContentTabs<int>(
            semanticsLabel: '主题分类',
            keyPrefix: 'long-tab',
            placement: WenyouTabPlacement.embedded,
            options: const [
              WenyouFilterOption(value: 0, label: '全部主题分类'),
              WenyouFilterOption(value: 1, label: '角色扮演专区'),
              WenyouFilterOption(value: 2, label: '桌面游戏交流'),
              WenyouFilterOption(value: 3, label: '世界观与设定'),
              WenyouFilterOption(value: 4, label: '站务与系统公告'),
            ],
            selected: 4,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final horizontalScroll = find.byWidgetPredicate(
      (widget) =>
          widget is SingleChildScrollView &&
          widget.scrollDirection == Axis.horizontal,
    );
    expect(horizontalScroll, findsOneWidget);
    expect(tester.takeException(), isNull);
    final selectedRect = tester.getRect(
      find.byKey(const ValueKey('long-tab-4')),
    );
    expect(selectedRect.left, greaterThanOrEqualTo(0));
    expect(selectedRect.right, lessThanOrEqualTo(320));
  });

  testWidgets('标准页签视觉保持稳定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 160);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const visualKey = Key('standard-tabs-visual');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => RepaintBoundary(
              key: visualKey,
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    WenyouContentTabs<int>(
                      semanticsLabel: '两栏页签',
                      placement: WenyouTabPlacement.page,
                      options: const [
                        WenyouFilterOption(value: 0, label: '发现'),
                        WenyouFilterOption(value: 1, label: '关注'),
                      ],
                      selected: 0,
                      onSelected: (_) {},
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: _FourTabGoldenFixture(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/standard_content_tabs_360.png'),
    );
  });
}

class _FourTabGoldenFixture extends StatelessWidget {
  const _FourTabGoldenFixture();

  @override
  Widget build(BuildContext context) {
    return WenyouContentTabs<int>(
      semanticsLabel: '四栏页签',
      placement: WenyouTabPlacement.embedded,
      options: const [
        WenyouFilterOption(value: 0, label: '动态'),
        WenyouFilterOption(value: 1, label: '主题帖'),
        WenyouFilterOption(value: 2, label: '楼层内容'),
        WenyouFilterOption(value: 3, label: '用户'),
      ],
      selected: 1,
      onSelected: (_) {},
    );
  }
}

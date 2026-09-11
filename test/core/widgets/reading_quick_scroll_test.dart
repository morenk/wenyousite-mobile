import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  Future<_HarnessState> mount(
    WidgetTester tester, {
    double width = 360,
    double scale = 1,
    int initialCount = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<_HarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(scale),
          ),
          child: _Harness(key: key, initialCount: initialCount),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  testWidgets('工具栏占独立空间，开关保留正文宽度和阅读位置', (tester) async {
    final state = await mount(tester);
    final semantics = tester.ensureSemantics();
    try {
      final toggle = find.byKey(const Key('reading-quick-scroll-toggle'));
      expect(find.byTooltip('快翻'), findsOneWidget);
      expect(find.text('快翻'), findsNothing);
      expect(
        tester
            .widget<WenyouIcon>(
              find.descendant(of: toggle, matching: find.byType(WenyouIcon)),
            )
            .semanticId,
        WenyouIconIds.actionReadingQuickScroll,
      );
      expect(tester.getSize(toggle).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(toggle).height, greaterThanOrEqualTo(48));
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isToggled,
        Tristate.isFalse,
      );
      state.scroll.jumpTo(240);
      await tester.pumpAndSettle();
      final before = tester.getRect(find.byKey(const Key('reading-body')));
      await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isToggled,
        Tristate.isTrue,
      );
      expect(tester.getSemantics(toggle).label, '快翻');
      final after = tester.getRect(find.byKey(const Key('reading-body')));
      final bar = tester.getRect(
        find.byKey(const Key('reading-quick-scroll-bar')),
      );
      expect(after.width, before.width);
      expect(after.height, lessThan(before.height));
      expect(after.bottom, lessThanOrEqualTo(bar.top));
      expect(state.scroll.offset, 240);
      expect(state.navigationCount, 1);
      await tester.tap(find.text('收起'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(toggle)
            .getSemanticsData()
            .flagsCollection
            .isToggled,
        Tristate.isFalse,
      );
      expect(state.scroll.offset, 240);
      expect(tester.getRect(find.byKey(const Key('reading-body'))), before);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('长单层内实时移动，每帧合并且分页不改变本次拖动映射', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    final range = state.scroll.position.maxScrollExtent;
    state.quick.beginDrag(0.1);
    state.quick.updateDrag(0.2);
    state.quick.updateDrag(0.3);
    expect(state.scroll.offset, 0);
    await tester.pump();
    await tester.pump();
    expect(state.scroll.offset, closeTo(range * 0.3, 1));
    expect(state.quick.location, '第 128 楼附近');
    state.append();
    await tester.pumpAndSettle();
    state.quick.updateDrag(0.4);
    await tester.pump();
    await tester.pump();
    expect(state.scroll.offset, closeTo(range * 0.4, 1));
    state.quick.endDrag(0.4);
    await tester.pumpAndSettle();
    final stopped = state.scroll.offset;
    state.append();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(stopped, 1));
  });

  testWidgets('按住滑杆末端时持续抵达新增楼层和图片撑高后的末尾', (tester) async {
    final state = await mount(tester);
    state.setLoading();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final rect = tester.getRect(find.byType(Slider));
    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(Offset(rect.right - 1, rect.center.dy));
    await tester.pumpAndSettle();
    expect(state.quick.isDragging, isTrue);
    expect(state.quick.fraction, 1);
    expect(find.text('正在加载更多，按住末端继续快翻'), findsOneWidget);
    for (var page = 0; page < 3; page++) {
      state.append();
      await tester.pumpAndSettle();
      expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
      expect(state.quick.fraction, 1);
    }
    state.growBody();
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    await gesture.up();
    await tester.pumpAndSettle();
    final stopped = state.scroll.offset;
    state.append();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(stopped, 1));
    expect(state.quick.fraction, lessThan(1));
  });

  testWidgets('从末端往回拖用当前范围微调，离开末端后不再追随新增内容', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(1);
    await tester.pumpAndSettle();
    state.append();
    await tester.pumpAndSettle();
    final expandedRange = state.scroll.position.maxScrollExtent;
    state.quick.updateDrag(0.6);
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(expandedRange * 0.6, 1));
    state.append();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(expandedRange * 0.6, 1));
    state.quick.endDrag(0.6);
    await tester.pumpAndSettle();
  });

  testWidgets('末端跟随后收起或切换范围，后续加载不能继续拉动页面', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(1);
    await tester.pumpAndSettle();
    state.append();
    state.quick.close();
    final stopped = state.scroll.offset;
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(stopped, 1));
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(1);
    await tester.pumpAndSettle();
    state.changeScope();
    state.append();
    final beforeScopeLayout = state.scroll.offset;
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    expect(state.scroll.offset, closeTo(beforeScopeLayout, 1));
  });

  testWidgets('首次长短楼层懒布局收缩估算后，滑杆一半仍停在阅读范围中间', (tester) async {
    final state = await mount(tester, initialCount: 80);
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final coldRange = state.scroll.position.maxScrollExtent;
    final rect = tester.getRect(find.byType(Slider));
    final gesture = await tester.startGesture(
      Offset(rect.left + 24, rect.center.dy),
    );
    await gesture.moveTo(rect.center);
    await tester.pump();
    // 第一个完成布局的画面就不能错误停在底部，无需松手或二次快翻。
    expect(state.scroll.position.extentAfter, greaterThan(100));
    await tester.pumpAndSettle();
    expect(state.quick.isDragging, isTrue);
    expect(state.quick.fraction, closeTo(0.5, 0.03));
    final actualRange =
        state.bodyHeight +
        state.count * 80 -
        state.scroll.position.viewportDimension;
    // 首屏仅布局 7000dp 长楼层，对其余 80 条 80dp 楼层的外推明显偏大。
    expect(coldRange, greaterThan(actualRange * 2));
    expect(
      state.scroll.offset / actualRange,
      closeTo(state.quick.fraction, 0.03),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.quick.fraction, closeTo(0.5, 0.03));
    state.quick.beginDrag(0.5);
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(actualRange * 0.5, 1));
    state.quick.endDrag(0.5);
    final continuedGesture = await tester.startGesture(rect.center);
    await continuedGesture.moveTo(
      Offset(rect.left + rect.width * 0.7, rect.center.dy),
    );
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, greaterThan(100));
    await continuedGesture.moveTo(Offset(rect.right - 1, rect.center.dy));
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    await continuedGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('校正后的阅读范围在图片撑高和新页到达后失效', (tester) async {
    final state = await mount(tester, initialCount: 80);
    state.quick.toggle();
    await tester.pumpAndSettle();
    for (var round = 0; round < 3; round++) {
      state.quick.beginDrag(0.5);
      await tester.pumpAndSettle();
      final actualRange =
          state.bodyHeight +
          state.count * 80 -
          state.scroll.position.viewportDimension;
      expect(state.scroll.offset, closeTo(actualRange * 0.5, 1));
      state.quick.endDrag(0.5);
      await tester.pumpAndSettle();
      expect(state.quick.fraction, closeTo(0.5, 0.01));
      if (round < 2) {
        final stopped = state.scroll.offset;
        if (round == 0) {
          state.growBody();
        } else {
          state.append();
        }
        await tester.pumpAndSettle();
        expect(state.scroll.offset, closeTo(stopped, 1));
        expect(state.quick.fraction, lessThan(0.5));
      }
    }
  });

  testWidgets('收起或更换筛选取消排队中的快翻', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.6);
    state.quick.close();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.7);
    state.changeScope();
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    final offset = state.scroll.offset;
    // 旧 Slider 在筛选重建期间可能迟到，不得重新启动新列表的导航。
    state.quick.updateDrag(0.95);
    state.quick.seekEdge(true);
    await tester.pumpAndSettle();
    expect(state.scroll.offset, offset);
    expect(find.byKey(const Key('reading-quick-scroll-bar')), findsNothing);
  });

  testWidgets('手指仍按着滑杆时正文已移动，且不重建正文页面', (tester) async {
    final state = await mount(tester);
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    final builds = state.buildCount;
    final rect = tester.getRect(find.byType(Slider));
    final gesture = await tester.startGesture(
      Offset(rect.left + 24, rect.center.dy),
    );
    await gesture.moveBy(Offset((rect.width - 48) * 0.55, 0));
    await tester.pump();
    await tester.pump();
    expect(state.scroll.offset, greaterThan(1000));
    expect(state.buildCount, builds);
    await gesture.up();
    await tester.pumpAndSettle();
    final stopped = state.scroll.offset;
    await tester.pump(const Duration(seconds: 2));
    expect(state.scroll.offset, closeTo(stopped, 1));
    await tester.drag(
      find.byKey(const Key('reading-body')),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    expect(state.scroll.offset, greaterThan(stopped));
    expect(state.quick.isOpen, isTrue);
  });

  testWidgets('首尾按钮抵达边界，正常拖动可以中断校正', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-end')));
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    expect(state.quick.edgeFailed, isFalse);
    await tester.tap(find.byKey(const Key('reading-quick-scroll-start')));
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('未读完的分页明确标注已加载范围，失败可重试', (tester) async {
    final state = await mount(tester);
    state.setLoading();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('正在加载更多，当前可快翻已加载内容'), findsOneWidget);
    expect(find.text('已加载\n末尾'), findsOneWidget);
    state.failLoading();
    await tester.pumpAndSettle();
    expect(find.text('更多内容加载失败，当前可快翻已加载内容'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(state.retries, 1);
  });

  testWidgets('细进度提示不抢占边缘正文点击', (tester) async {
    final state = await mount(tester);
    state.scroll.jumpTo(180);
    await tester.pump();
    await tester.tapAt(const Offset(357, 160));
    expect(state.taps, 1);
    final scrollbar = tester.widget<RawScrollbar>(
      find.byKey(const Key('reading-progress-indicator')),
    );
    expect(scrollbar.interactive, isFalse);
    expect(scrollbar.timeToFade, const Duration(milliseconds: 1500));
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 双倍字号工具栏无溢出且提供语义调节', (tester) async {
      await mount(tester, width: width, scale: 2);
      final semantics = tester.ensureSemantics();

      await tester.tap(find.byKey(const Key('reading-quick-scroll-toggle')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('快翻阅读位置'), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNotNull);
      slider.onChanged!(0.2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets('移除页面取消所有后续滚动与通知', (tester) async {
    final state = await mount(tester);
    state.quick.toggle();
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.9);
    state.quick.seekEdge(true);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _Harness extends StatefulWidget {
  const _Harness({super.key, this.initialCount = 0});
  final int initialCount;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final scroll = ScrollController();
  late final quick = ReadingQuickScrollController(
    scrollController: scroll,
    onUserNavigation: () => navigationCount++,
  );
  int navigationCount = 0;
  int buildCount = 0;
  int taps = 0;
  int retries = 0;
  int scope = 0;
  late int count = widget.initialCount;
  double bodyHeight = 7000;
  bool hasMore = false;
  bool loading = false;
  bool failed = false;

  void append() => setState(() => count += 20);
  void growBody() => setState(() => bodyHeight += 3000);
  void changeScope() => setState(() => scope++);
  void setLoading() => setState(() {
    hasMore = true;
    loading = true;
  });
  void failLoading() => setState(() {
    loading = false;
    failed = true;
  });

  @override
  void dispose() {
    quick.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;
    quick.synchronize(scope: scope, enabled: true, contentRevision: count);
    return Scaffold(
      appBar: AppBar(actions: [ReadingQuickScrollAction(controller: quick)]),
      body: SizedBox.expand(
        key: const Key('reading-body'),
        child: ReadingProgressViewport(
          controller: quick,
          child: ListView(
            controller: scroll,
            physics: ReadingQuickScrollPhysics(controller: quick),
            children: [
              ReadingPositionAnchor(
                controller: quick,
                label: '第 128 楼附近',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                  child: SizedBox(
                    height: bodyHeight,
                    child: const Text('超长楼层正文'),
                  ),
                ),
              ),
              for (var i = 0; i < count; i++)
                ReadingPositionAnchor(
                  controller: quick,
                  label: '第 ${300 + i} 楼附近',
                  child: SizedBox(height: 80, child: Text('楼层 $i')),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ReadingQuickScrollBar(
        controller: quick,
        hasMore: hasMore,
        loading: loading,
        loadFailed: failed,
        onRetry: () => retries++,
        bottomSafeArea: true,
      ),
    );
  }
}

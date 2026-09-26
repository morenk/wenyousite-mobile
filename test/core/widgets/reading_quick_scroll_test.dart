import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/reading_scroll_harness.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);

  testWidgets('统一滑块展开保留正文宽高和阅读位置，无按钮或操作卡', (tester) async {
    final state = await mountReadingScroll(tester);
    state.scroll.jumpTo(240);
    await tester.pumpAndSettle();
    final before = tester.getRect(find.byKey(const Key('reading-body')));
    final center = tester.getCenter(
      find.byKey(const Key('reading-progress-indicator')),
    );
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const Key('reading-body'))), before);
    expect(
      tester.getCenter(find.byKey(const Key('reading-progress-indicator'))),
      center,
    );
    expect(state.scroll.offset, 240);
    expect(state.navigationCount, 0);
    expect(find.byKey(const Key('reading-quick-scroll-toggle')), findsNothing);
    await tester.tap(find.byKey(const Key('reading-quick-scroll-slider')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reading-quick-scroll-card')), findsNothing);
    expect(state.taps, 0);
    expect(state.scroll.offset, 240);
  });

  testWidgets('长单层内实时移动，每帧合并且分页不改变本次拖动映射', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
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
    final state = await mountReadingScroll(tester);
    state.setLoading();
    await tester.pumpAndSettle();
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    final rect = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-slider')),
    );
    final rail = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-rail')),
    );
    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(Offset(rect.center.dx, rail.bottom - rect.height / 2));
    await tester.pumpAndSettle();
    expect(state.quick.isDragging, isTrue);
    expect(state.quick.fraction, 1);
    expect(find.textContaining('正在加载 · 已加载范围'), findsOneWidget);
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
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
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
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.beginDrag(1);
    await tester.pumpAndSettle();
    state.append();
    state.quick.close();
    final stopped = state.scroll.offset;
    await tester.pumpAndSettle();
    expect(state.scroll.offset, closeTo(stopped, 1));
    state.quick.setKeyboardFocus(true);
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
    final state = await mountReadingScroll(tester, initialCount: 80);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    final coldRange = state.scroll.position.maxScrollExtent;
    final rect = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-slider')),
    );
    final rail = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-rail')),
    );
    final gesture = await tester.startGesture(rect.center);
    await gesture.moveTo(rail.center);
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
    await tester.pumpAndSettle();
    final continuedGesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('reading-quick-scroll-slider'))),
    );
    await continuedGesture.moveTo(
      Offset(
        rail.center.dx,
        rail.top + rect.height / 2 + (rail.height - rect.height) * 0.7,
      ),
    );
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, greaterThan(100));
    await continuedGesture.moveTo(
      Offset(rail.center.dx, rail.bottom - rect.height / 2),
    );
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    await continuedGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('校正后的阅读范围在图片撑高和新页到达后失效', (tester) async {
    final state = await mountReadingScroll(tester, initialCount: 80);
    state.quick.setKeyboardFocus(true);
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
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.6);
    state.quick.close();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
    state.quick.setKeyboardFocus(true);
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
    expect(state.quick.isOpen, isFalse);
  });

  testWidgets('手指仍按着滑杆时正文已移动，且不重建正文页面', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    final builds = state.buildCount;
    final rect = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-slider')),
    );
    final rail = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-rail')),
    );
    final gesture = await tester.startGesture(rect.center);
    await gesture.moveBy(Offset(0, (rail.height - rect.height) * 0.55));
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

  testWidgets('键盘首尾导航抵达边界，正文手势可中断校正', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.seekEdge(true);
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    expect(state.quick.edgeFailed, isFalse);
    state.quick.seekEdge(false);
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
    state.quick.seekEdge(true);
    state.quick.close();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
  });

  testWidgets('只在拖动时标注实际位置和已加载范围，不称全文末尾', (tester) async {
    final state = await mountReadingScroll(tester);
    state.setLoading();
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    expect(find.textContaining('已加载范围'), findsNothing);
    state.quick.beginDrag(0.3);
    await tester.pumpAndSettle();
    expect(find.textContaining('正在加载 · 已加载范围'), findsOneWidget);
    state.failLoading();
    await tester.pumpAndSettle();
    expect(find.textContaining('加载失败 · 已加载范围'), findsOneWidget);
    expect(find.text('全文末尾'), findsNothing);
    state.quick.endDrag(0.3);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('reading-quick-scroll-location')),
      findsNothing,
    );
  });

  testWidgets('细进度提示与轨道不抢占边缘正文点击', (tester) async {
    final state = await mountReadingScroll(tester);
    state.scroll.jumpTo(180);
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    final indicator = find.byKey(const Key('reading-progress-indicator'));
    expect(tester.getSize(indicator), const Size(2, 24));
    await tester.tapAt(tester.getCenter(indicator));
    expect(state.taps, 1);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 双倍字号工具栏无溢出且提供语义调节', (tester) async {
      final state = await mountReadingScroll(tester, width: width, scale: 2);
      final semantics = tester.ensureSemantics();

      state.quick.setKeyboardFocus(true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('快翻阅读位置'), findsOneWidget);
      final slider = tester.getSemantics(
        find.byKey(const Key('reading-quick-scroll-slider')),
      );
      expect(
        slider.getSemanticsData().hasAction(SemanticsAction.increase),
        isTrue,
      );
      slider.owner!.performAction(slider.id, SemanticsAction.increase);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets('展开滑块短点按被消费，轨道点击仍执行正文操作', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    final rail = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-rail')),
    );
    await tester.tap(find.byKey(const Key('reading-quick-scroll-slider')));
    await tester.pumpAndSettle();
    expect(state.taps, 0);
    expect(state.scroll.offset, 0);
    expect(find.byKey(const Key('reading-quick-scroll-card')), findsNothing);
    await tester.tapAt(Offset(rail.center.dx, rail.bottom - 30));
    expect(state.taps, 1);
    expect(state.scroll.offset, 0);
  });

  testWidgets('偏离滑块中心抓取不跳位，拖动中取消清除未绘制更新', (tester) async {
    final state = await mountReadingScroll(tester);
    state.scroll.jumpTo(2000);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    final thumb = find.byKey(const Key('reading-quick-scroll-slider'));
    final initial = tester.getRect(thumb);
    final gesture = await tester.startGesture(
      Offset(initial.left + 3, initial.bottom - 3),
    );
    await tester.pump();
    expect(state.scroll.offset, 2000);
    await gesture.moveBy(const Offset(0, 70));
    await tester.pumpAndSettle();
    expect(tester.getRect(thumb).top, closeTo(initial.top + 70, 1));
    expect(
      find.byKey(const Key('reading-quick-scroll-location')),
      findsOneWidget,
    );
    final painted = state.scroll.offset;
    await gesture.moveBy(const Offset(0, 40));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(state.quick.isDragging, isFalse);
    expect(state.scroll.offset, painted);
    expect(
      find.byKey(const Key('reading-quick-scroll-location')),
      findsNothing,
    );
    state.append();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, painted);
  });

  testWidgets('键盘按视口调整并支持首尾与收起', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    Focus.of(
      tester.element(find.byKey(const Key('reading-quick-scroll-slider'))),
    ).requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(
      state.scroll.offset,
      closeTo(state.scroll.position.viewportDimension, 1),
    );
    expect(find.byKey(const Key('reading-quick-scroll-card')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(state.scroll.position.extentAfter, lessThanOrEqualTo(1));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(state.scroll.offset, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
  });

  for (final dark in [false, true]) {
    testWidgets('窄屏双倍字主题 $dark 避开系统手势并提供实际位置', (tester) async {
      final state = await mountReadingScroll(
        tester,
        width: 320,
        scale: 2,
        dark: dark,
        gestureInsets: const EdgeInsets.only(right: 24, bottom: 24),
      );
      state.setLoading();
      state.quick.setKeyboardFocus(true);
      await tester.pumpAndSettle();
      final thumb = find.byKey(const Key('reading-quick-scroll-slider'));
      final rect = tester.getRect(thumb);
      expect(rect.right, lessThanOrEqualTo(320 - 24 - 8));
      expect(rect.size, const Size(48, 64));
      state.quick.beginDrag(0.4);
      await tester.pumpAndSettle();
      final label = tester.getRect(
        find.byKey(const Key('reading-quick-scroll-location')),
      );
      expect(label.left, greaterThanOrEqualTo(8));
      expect(label.right, lessThanOrEqualTo(rect.left - 8));
      expect(label.bottom, lessThanOrEqualTo(800 - 24 - 8));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile(
          'goldens/reading_scroll_drag_${dark ? 'dark' : 'light'}_320.png',
        ),
      );
    });
  }

  testWidgets('短视口双倍字拖动标签不溢出命中区', (tester) async {
    final state = await mountReadingScroll(
      tester,
      width: 320,
      height: 400,
      scale: 2,
    );
    state.failLoading();
    state.setLoading();
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.5);
    await tester.pumpAndSettle();
    final thumb = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-slider')),
    );
    final label = tester.getRect(
      find.byKey(const Key('reading-quick-scroll-location')),
    );
    expect(label.right, lessThanOrEqualTo(thumb.left - 8));
    expect(label.bottom, lessThanOrEqualTo(400));
    expect(tester.takeException(), isNull);
    state.quick.endDrag(0.5);
  });

  testWidgets('移除页面取消所有后续滚动与通知', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.9);
    state.quick.seekEdge(true);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

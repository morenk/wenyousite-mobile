import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/reading_scroll_harness.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  final indicator = find.byKey(const Key('reading-progress-indicator'));
  final slider = find.byKey(const Key('reading-quick-scroll-slider'));

  Future<TestGesture> swipe(
    WidgetTester tester, {
    double dy = -20,
    int stepMs = 20,
  }) async {
    final gesture = await tester.startGesture(const Offset(100, 600));
    for (var step = 1; step <= 7; step++) {
      await gesture.moveBy(
        Offset(0, dy),
        timeStamp: Duration(milliseconds: step * stepMs),
      );
      await tester.pump(Duration(milliseconds: stepMs));
    }
    return gesture;
  }

  testWidgets('一次真实快滑唤醒，原手势继续正文，下一次抓取停惯性且不跳位', (tester) async {
    final state = await mountReadingScroll(tester);
    final gesture = await swipe(tester);
    expect(state.quick.isOpen, isTrue);
    expect(state.quick.isDragging, isFalse);
    expect(state.navigationCount, 0);
    await tester.pump(const Duration(milliseconds: 180));
    expect(tester.getSize(indicator), const Size(8, 56));
    final current = state.scroll.offset;
    await gesture.moveBy(
      const Offset(0, -40),
      timeStamp: const Duration(milliseconds: 340),
    );
    await tester.pump();
    expect(state.scroll.offset, greaterThan(current));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));
    final actual = state.scroll.offset;
    final rect = tester.getRect(slider);
    final grabbed = await tester.startGesture(
      rect.bottomLeft + const Offset(4, -4),
    );
    await tester.pump();
    expect(state.scroll.offset, closeTo(actual, 0.01));
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.scroll.offset, closeTo(actual, 0.01));
    await grabbed.moveBy(const Offset(0, 80));
    await tester.pump();
    expect(state.scroll.offset, greaterThan(actual));
    final down = state.scroll.offset;
    await grabbed.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(state.scroll.offset, lessThan(down));
    await grabbed.up();
    await tester.pumpAndSettle();
    final stopped = state.scroll.offset;
    await tester.pump(const Duration(seconds: 3));
    expect(state.scroll.offset, stopped);
    expect(state.quick.isOpen, isFalse);
  });

  testWidgets('慢滑后即使有惯性也不唤醒，程序滚动和图片撑高不唤醒', (tester) async {
    final state = await mountReadingScroll(tester);
    final gesture = await swipe(tester, dy: -5, stepMs: 40);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    (state.scroll.position as ScrollPositionWithSingleContext).goBallistic(
      2500,
    );
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    state.scroll.jumpTo(1000);
    state.growBody();
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    unawaited(
      state.scroll.animateTo(
        2000,
        duration: const Duration(milliseconds: 120),
        curve: Curves.linear,
      ),
    );
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
  });

  testWidgets('横向轮播和顶部下拉回弹不唤醒', (tester) async {
    final state = await mountReadingScroll(tester);
    state.showCarousel();
    await tester.pumpAndSettle();
    await tester.timedDrag(
      find.byKey(const Key('reading-carousel')),
      const Offset(-250, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    final gesture = await swipe(tester, dy: 20);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
  });

  testWidgets('停稳后保持再收细，收细中快滑从当前形状继续展开', (tester) async {
    final state = await mountReadingScroll(tester);
    final gesture = await swipe(tester);
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up(timeStamp: const Duration(milliseconds: 440));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1499));
    expect(state.quick.isOpen, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final shrinking = tester.getSize(indicator).width;
    expect(shrinking, inExclusiveRange(2, 8));
    final again = await swipe(tester);
    expect(state.quick.isOpen, isTrue);
    final partial = tester.getSize(indicator).width;
    expect(partial, inInclusiveRange(2, 8));
    await tester.pump(const Duration(milliseconds: 180));
    expect(tester.getSize(indicator), const Size(8, 56));
    await again.up();
    await tester.pumpAndSettle();
  });

  testWidgets('读屏无需快滑持续可调，减少动画直接展开，无滚动内容隐藏', (tester) async {
    final state = await mountReadingScroll(
      tester,
      accessible: true,
      reducedMotion: true,
    );
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(state.quick.isOpen, isTrue);
    expect(tester.getSize(indicator), const Size(8, 56));
    await tester.pump(const Duration(seconds: 5));
    expect(state.quick.isOpen, isTrue);
    final node = tester.getSemantics(slider);
    node.owner!.performAction(node.id, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(
      state.scroll.offset,
      closeTo(state.scroll.position.viewportDimension, 1),
    );
    state.shorten();
    await tester.pumpAndSettle();
    expect(indicator, findsNothing);
    semantics.dispose();
  });

  testWidgets('键盘出现清除抓取与旧输入', (tester) async {
    final state = await mountReadingScroll(tester);
    final gesture = await swipe(tester);
    await gesture.up();
    await tester.pumpAndSettle();
    state.quick.beginDrag(0.8);
    state.openIme();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    expect(state.quick.isDragging, isFalse);
    expect(indicator, findsNothing);
  });

  testWidgets('路由覆盖取消末端跟随，返回不重用旧动作', (tester) async {
    final state = await mountReadingScroll(tester);
    state.quick.setKeyboardFocus(true);
    await tester.pumpAndSettle();
    state.quick.beginDrag(1);
    await tester.pumpAndSettle();
    unawaited(
      Navigator.of(state.context).push<void>(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('其他页面'))),
      ),
    );
    await tester.pumpAndSettle();
    expect(state.quick.isOpen, isFalse);
    final stopped = state.scroll.offset;
    state.append();
    await tester.pumpAndSettle();
    expect(state.scroll.offset, stopped);
    Navigator.of(state.context).pop();
    await tester.pumpAndSettle();
    expect(state.quick.isDragging, isFalse);
    expect(state.quick.isOpen, isFalse);
  });

  for (final dark in [false, true]) {
    testWidgets('主题 $dark 固定细态、展开中间态及展开态 Golden', (tester) async {
      final state = await mountReadingScroll(
        tester,
        width: 320,
        scale: 2,
        dark: dark,
      );
      state.scroll.jumpTo(700);
      await tester.pumpAndSettle();
      for (final phase in ['thin', 'expanding', 'expanded']) {
        if (phase == 'expanding') {
          state.quick.setKeyboardFocus(true);
          await tester.pump();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 90));
          expect(tester.getSize(indicator).width, inExclusiveRange(2, 8));
        } else if (phase == 'expanded') {
          await tester.pump(const Duration(milliseconds: 90));
        }
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            'goldens/reading_scroll_${phase}_${dark ? 'dark' : 'light'}_320.png',
          ),
        );
      }
    });
  }
}

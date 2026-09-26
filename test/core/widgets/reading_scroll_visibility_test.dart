import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/reading_scroll_visibility.dart';

void main() {
  ReadingScrollVisibility create() {
    final visibility = ReadingScrollVisibility(
      expandedHold: const Duration(milliseconds: 1500),
      collapseDuration: const Duration(milliseconds: 240),
      collapsedHold: const Duration(milliseconds: 600),
      slowReadHold: const Duration(milliseconds: 1500),
    )..configure(enabled: true, accessible: false);
    addTearDown(visibility.dispose);
    return visibility;
  }

  testWidgets('一次快滑锁定展开，惯性结束后才开始等待', (tester) async {
    final state = create()..setScrolling(true);
    state.showScroll(fast: true);
    state.showScroll(fast: false);
    await tester.pump(const Duration(seconds: 3));
    expect(state.expanded, isTrue);
    state.setScrolling(false);
    await tester.pump(const Duration(milliseconds: 1499));
    expect(state.expanded, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(state.expanded, isFalse);
    expect(state.visible, isTrue);
    await tester.pump(const Duration(milliseconds: 839));
    expect(state.visible, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(state.visible, isFalse);
  });

  testWidgets('慢读保持细态，惯性不会自行展开', (tester) async {
    final state = create()..setScrolling(true);
    state.showScroll(fast: false);
    await tester.pump(const Duration(seconds: 3));
    expect(state.visible, isTrue);
    expect(state.expanded, isFalse);
    state.setScrolling(false);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(state.visible, isFalse);
  });

  testWidgets('收回期间再次快滑取消旧淡出，保留新一轮等待', (tester) async {
    final state = create()..showScroll(fast: true);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(state.expanded, isFalse);
    state.showScroll(fast: true);
    await tester.pump(const Duration(milliseconds: 800));
    expect(state.expanded, isTrue);
    expect(state.visible, isTrue);
    await tester.pump(const Duration(milliseconds: 700));
    expect(state.expanded, isFalse);
    state.reset();
  });

  testWidgets('抓住时暂停，松手从停稳重新计时', (tester) async {
    final state = create()..showScroll(fast: true);
    await tester.pump(const Duration(seconds: 1));
    state.setPressed(true);
    await tester.pump(const Duration(seconds: 5));
    expect(state.expanded, isTrue);
    state.setPressed(false);
    await tester.pump(const Duration(milliseconds: 1499));
    expect(state.expanded, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(state.expanded, isFalse);
    state.reset();
  });

  testWidgets('键盘和读屏保持可操作；禁用与取消清理旧计时', (tester) async {
    final state = create()..setFocused(true);
    await tester.pump(const Duration(seconds: 5));
    expect(state.expanded, isTrue);
    state.reset();
    expect(state.visible, isFalse);
    state.configure(enabled: true, accessible: true);
    await tester.pump(const Duration(seconds: 5));
    expect(state.expanded, isTrue);
    state.configure(enabled: false, accessible: true);
    expect(state.visible, isFalse);
    await tester.pump(const Duration(seconds: 5));
    expect(state.visible, isFalse);
  });
}

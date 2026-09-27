import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_clock.dart';

void main() {
  testWidgets('多行共用分钟刷新，后台停止，恢复立即更新，最后一行移除后停止', (tester) async {
    var now = DateTime(2026, 9, 20, 12);
    final clock = WenyouTimeClock(now: () => now);
    var first = 0;
    var second = 0;
    void a() => first++;
    void b() => second++;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    clock.addListener(a);
    clock.addListener(b);
    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));
    expect((first, second), (1, 1));
    expect(clock.value, now);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(hours: 2));
    await tester.pump(const Duration(minutes: 2));
    expect((first, second), (1, 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect((first, second), (2, 2));
    expect(clock.value, now);
    clock.removeListener(a);
    clock.removeListener(b);
    await tester.pump(const Duration(minutes: 2));
    expect((first, second), (2, 2));
    clock.dispose();
  });
}

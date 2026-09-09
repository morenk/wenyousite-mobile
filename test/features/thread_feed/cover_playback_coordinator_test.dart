import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';

void main() {
  const viewport = Rect.fromLTWH(0, 0, 100, 400);
  CoverPlaybackGeometry geometry(double y) => CoverPlaybackGeometry(
    cover: Rect.fromLTWH(0, y, 100, 100),
    viewport: viewport,
  );

  test('普通封面裁切不改变滚动视口中心', () {
    const value = CoverPlaybackGeometry(
      cover: Rect.fromLTWH(0, 0, 100, 100),
      viewport: viewport,
      visibleBounds: Rect.fromLTWH(0, 0, 100, 60),
    );
    expect(value.visibleFraction, 0.6);
    expect(value.distance, 150 * 150);
  });

  testWidgets('非候选静态封面加载完成不延后动画停稳计时', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    addTearDown(coordinator.dispose);
    coordinator.register('animation', () => geometry(150));
    await tester.pump(const Duration(milliseconds: 200));
    coordinator.unregister('static-cover');
    await tester.pump(const Duration(milliseconds: 100));
    expect(coordinator.selected, 'animation');
  });

  testWidgets('300ms停稳后仅选中心项，滚动立即撤销并重置等待', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    addTearDown(coordinator.dispose);
    coordinator.register('top', () => geometry(0));
    coordinator.register('center', () => geometry(150));
    coordinator.register('bottom', () => geometry(300));
    await tester.pump(const Duration(milliseconds: 299));
    expect(coordinator.selected, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(coordinator.selected, 'center');
    coordinator.scrollStarted();
    expect(coordinator.selected, isNull);
    await tester.pump(const Duration(seconds: 1));
    expect(coordinator.selected, isNull);
    coordinator.scrollEnded();
    await tester.pump(const Duration(milliseconds: 200));
    coordinator.scrollStarted();
    coordinator.scrollEnded();
    await tester.pump(const Duration(milliseconds: 299));
    expect(coordinator.selected, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(coordinator.selected, 'center');
  });

  testWidgets('半可见门槛、当前项平距优先和稳定顺序', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    addTearDown(coordinator.dispose);
    var first = -51.0;
    var second = 350.0;
    coordinator.register('first', () => geometry(first));
    coordinator.register('second', () => geometry(second));
    await tester.pump(coverPlaybackSettleDelay);
    expect(coordinator.selected, 'second');
    first = 100;
    second = 200;
    coordinator.scrollStarted();
    coordinator.scrollEnded();
    await tester.pump(coverPlaybackSettleDelay);
    expect(coordinator.selected, 'second');
    coordinator.unregister('second');
    expect(coordinator.selected, isNull);
    await tester.pump(coverPlaybackSettleDelay);
    expect(coordinator.selected, 'first');
  });

  testWidgets('后台、省流量和路由遮挡取消计时，恢复重新等待', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    addTearDown(coordinator.dispose);
    var visible = true;
    coordinator.register('cover', () => visible ? geometry(150) : null);
    await tester.pump(coverPlaybackSettleDelay);
    coordinator.setAllowed(false);
    expect(coordinator.selected, isNull);
    coordinator.setAllowed(true);
    await tester.pump(coverPlaybackSettleDelay);
    expect(coordinator.selected, 'cover');
    coordinator.interrupt();
    visible = false;
    coordinator.settle();
    await tester.pump(coverPlaybackSettleDelay);
    expect(coordinator.selected, isNull);
  });
}

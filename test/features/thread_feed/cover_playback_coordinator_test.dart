import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_playback_coordinator.dart';

void main() {
  const viewport = Rect.fromLTWH(0, 0, 100, 400);
  CoverPlaybackGeometry geometry(double y) => CoverPlaybackGeometry(
    cover: Rect.fromLTWH(0, y, 100, 100),
    viewport: viewport,
  );

  test('可见面积同时受视口和祖先裁切约束', () {
    const value = CoverPlaybackGeometry(
      cover: Rect.fromLTWH(0, 350, 100, 100),
      viewport: viewport,
      visibleBounds: Rect.fromLTWH(0, 0, 100, 1000),
    );
    expect(value.visibleFraction, 0.5);
  });

  testWidgets('所有至少半可见项下一帧立即激活，不设数量上限', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    for (var i = 0; i < 20; i++) {
      coordinator.register(i, () => geometry(100));
    }
    expect(coordinator.activeTokens, isEmpty);
    await tester.pump();
    expect(
      coordinator.activeTokens,
      Set<Object>.from(List.generate(20, (i) => i)),
    );
    coordinator.dispose();
  });

  testWidgets('50%进入与0%退出滞回，重入必须重新达到半可见', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    var y = -51.0;
    coordinator.register('cover', () => geometry(y));
    await tester.pump();
    expect(coordinator.isActive('cover'), isFalse);
    y = -50;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.isActive('cover'), isTrue);
    y = -99;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.isActive('cover'), isTrue);
    y = -100;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.isActive('cover'), isFalse);
    y = -99;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.isActive('cover'), isFalse);
    y = -50;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.isActive('cover'), isTrue);
    coordinator.dispose();
  });

  testWidgets('连续滚动重测同帧合并，持续可见项不撤销不重建', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    var measurements = 0;
    var notifications = 0;
    coordinator.addListener(() => notifications++);
    coordinator.register('first', () {
      measurements++;
      return geometry(100);
    });
    coordinator.register('second', () {
      measurements++;
      return geometry(250);
    });
    await tester.pump();
    expect(notifications, 1);
    final baseline = measurements;
    for (var i = 0; i < 15; i++) {
      coordinator.remeasure();
    }
    await tester.pump();
    expect(measurements, baseline + 2);
    expect(notifications, 1);
    coordinator.register('offscreen', () => geometry(500));
    await tester.pump();
    expect(notifications, 1);
    coordinator.unregister('first');
    expect(coordinator.activeTokens, {'second'});
    expect(notifications, 2);
    coordinator.dispose();
  });

  testWidgets('后台省流量等全局限制立即撤销，恢复按当前可见性激活', (tester) async {
    final coordinator = CoverPlaybackCoordinator();
    var visible = true;
    coordinator.register('cover', () => visible ? geometry(100) : null);
    await tester.pump();
    coordinator.setAllowed(false);
    expect(coordinator.activeTokens, isEmpty);
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.activeTokens, isEmpty);
    coordinator.setAllowed(true);
    await tester.pump();
    expect(coordinator.isActive('cover'), isTrue);
    visible = false;
    coordinator.remeasure();
    await tester.pump();
    expect(coordinator.activeTokens, isEmpty);
    coordinator.dispose();
  });
}

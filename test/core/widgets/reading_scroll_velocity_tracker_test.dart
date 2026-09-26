import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/widgets/reading_scroll_velocity_tracker.dart';

void main() {
  late ReadingScrollVelocityTracker tracker;
  setUp(() {
    tracker = ReadingScrollVelocityTracker(
      window: const Duration(milliseconds: 100),
      minimumDuration: const Duration(milliseconds: 50),
      minimumDistance: 48,
      minimumVelocity: 650,
      viewportVelocityFactor: 0.9,
    );
    tracker.start(Duration.zero, 0);
  });

  bool sample(int ms, double pixels, {double height = 600}) =>
      tracker.addSample(
        timestamp: Duration(milliseconds: ms),
        pixels: pixels,
        viewportDimension: height,
      );

  test('一次同向快滑同时满足持续时间、距离与速度才唤醒', () {
    expect(sample(25, 30), isFalse);
    expect(sample(50, 47), isFalse);
    expect(sample(60, 60), isTrue);
  });

  test('向上与向下使用相同速度条件', () {
    expect(sample(25, -25), isFalse);
    expect(sample(50, -50), isTrue);
  });

  test('短时间大位移和短距离抖动都不唤醒', () {
    expect(sample(10, 60), isFalse);
    tracker.start(Duration.zero, 0);
    for (var ms = 10; ms <= 200; ms += 10) {
      expect(sample(ms, (ms ~/ 10).isEven ? 2 : 0), isFalse);
    }
  });

  test('慢读的累计距离不会越过时间窗唤醒', () {
    for (var ms = 20; ms <= 2000; ms += 20) {
      expect(sample(ms, ms * 0.3), isFalse);
    }
  });

  test('高视口使用归一化速度门槛', () {
    expect(sample(50, 48, height: 1200), isFalse);
    expect(sample(100, 96, height: 1200), isFalse);
    expect(sample(150, 156, height: 1200), isTrue);
  });

  test('反向重新累计，不把折返距离当成一次快滑', () {
    expect(sample(20, 20), isFalse);
    expect(sample(40, 40), isFalse);
    expect(sample(60, 20), isFalse);
    expect(sample(80, 0), isFalse);
    expect(sample(100, -20), isTrue);
  });

  test('窗口边界插值，不依赖60Hz或120Hz采样相位', () {
    for (final interval in [8, 16, 25]) {
      tracker.start(Duration.zero, 0);
      var activated = false;
      for (var ms = interval; ms < 400; ms += interval) {
        activated = sample(ms, ms * 0.8) || activated;
      }
      expect(activated, isTrue, reason: '$interval ms');
    }
  });

  test('停顿及取消后不能继承旧速度', () {
    expect(sample(20, 30), isFalse);
    expect(sample(40, 60), isFalse);
    expect(sample(200, 150), isFalse);
    expect(sample(230, 180), isFalse);
    tracker.reset();
    expect(sample(260, 210), isFalse);
    expect(sample(290, 240), isFalse);
  });

  test('失序、重复时间和无效布局清除样本', () {
    expect(sample(25, 30), isFalse);
    expect(sample(25, 60), isFalse);
    expect(sample(20, 90), isFalse);
    expect(sample(75, 150, height: 0), isFalse);
    expect(sample(100, 180), isFalse);
    expect(sample(125, double.nan), isFalse);
    expect(sample(150, 210), isFalse);
  });
}

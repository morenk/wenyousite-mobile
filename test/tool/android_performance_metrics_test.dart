import 'package:flutter_test/flutter_test.dart';

import '../../tool/android_performance_metrics.dart';

void main() {
  test('三轮中位数满足预算时通过全部 60 Hz 场景', () {
    final report = evaluateAndroidPerformance(
      runs: [_run(4000), _run(5000), _run(6000)],
      device: const {'model': 'test-phone', 'refreshRateHz': 60},
      sourceRevision: 'abc123',
      generatedAt: DateTime.utc(2026, 8, 26),
    );

    expect(report['passed'], isTrue);
    expect(report['runCount'], 3);
    expect(report['profilePackage'], 'site.wenyou.app.profile');
  });

  test('任一场景的中位数超出预算时门禁失败', () {
    final runs = [_run(4000), _run(5000), _run(6000)];
    for (final run in runs) {
      run['appearance_swap'] = _scenario(18000);
    }

    final report = evaluateAndroidPerformance(
      runs: runs,
      device: const {'model': 'test-phone', 'refreshRateHz': 60},
      sourceRevision: 'abc123',
      generatedAt: DateTime.utc(2026, 8, 26),
    );
    final scenarios = report['scenarios']! as Map<String, Object?>;
    final appearance = scenarios['appearance_swap']! as Map<String, Object?>;

    expect(report['passed'], isFalse);
    expect(appearance['passed'], isFalse);
  });

  test('少于三轮或缺少场景数据时拒绝生成基线', () {
    expect(
      () => evaluateAndroidPerformance(
        runs: [_run(4000)],
        device: const {},
        sourceRevision: 'abc123',
        generatedAt: DateTime.utc(2026, 8, 26),
      ),
      throwsArgumentError,
    );
    final incomplete = _run(4000)..remove('moment_feed_scroll');
    expect(
      () => evaluateAndroidPerformance(
        runs: [incomplete, incomplete, incomplete],
        device: const {},
        sourceRevision: 'abc123',
        generatedAt: DateTime.utc(2026, 8, 26),
      ),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _run(int frameTimeUs) => {
  for (final key in androidPerformanceScenarioKeys) key: _scenario(frameTimeUs),
};

Map<String, Object?> _scenario(int frameTimeUs) => {
  'frame_build_times': List<int>.filled(100, frameTimeUs),
  'frame_rasterizer_times': List<int>.filled(100, frameTimeUs),
};

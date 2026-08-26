const androidPerformanceScenarioKeys = <String>[
  'appearance_swap',
  'standard_navigation',
  'moment_feed_scroll',
  'markdown_timeline_scroll',
];

const androidPerformanceBudget = (
  targetHz: 60.0,
  p90PipelineMs: 8.0,
  p99PipelineMs: 16.7,
  overBudgetRate: 0.01,
);

Map<String, Object?> evaluateAndroidPerformance({
  required List<Map<String, Object?>> runs,
  required Map<String, Object?> device,
  required String sourceRevision,
  required DateTime generatedAt,
}) {
  if (runs.length < 3) {
    throw ArgumentError.value(runs.length, 'runs', '至少需要三轮采样');
  }

  final scenarios = <String, Object?>{};
  var passed = true;
  for (final scenarioKey in androidPerformanceScenarioKeys) {
    final runMetrics = <Map<String, Object?>>[];
    for (var index = 0; index < runs.length; index++) {
      final raw = runs[index][scenarioKey];
      if (raw is! Map) {
        throw FormatException('第 ${index + 1} 轮缺少 $scenarioKey 数据');
      }
      runMetrics.add(_evaluateRun(Map<String, Object?>.from(raw)));
    }
    final median = <String, Object?>{
      'frameCount': _median(
        runMetrics.map((metrics) => metrics['frameCount'] as num),
      ).round(),
      'p90BuildMs': _rounded(
        _median(runMetrics.map((metrics) => metrics['p90BuildMs'] as num)),
      ),
      'p90RasterMs': _rounded(
        _median(runMetrics.map((metrics) => metrics['p90RasterMs'] as num)),
      ),
      'p99BuildMs': _rounded(
        _median(runMetrics.map((metrics) => metrics['p99BuildMs'] as num)),
      ),
      'p99RasterMs': _rounded(
        _median(runMetrics.map((metrics) => metrics['p99RasterMs'] as num)),
      ),
      'overBudgetRate': _rounded(
        _median(runMetrics.map((metrics) => metrics['overBudgetRate'] as num)),
      ),
    };
    final scenarioPassed =
        (median['p90BuildMs']! as num) <=
            androidPerformanceBudget.p90PipelineMs &&
        (median['p90RasterMs']! as num) <=
            androidPerformanceBudget.p90PipelineMs &&
        (median['p99BuildMs']! as num) <=
            androidPerformanceBudget.p99PipelineMs &&
        (median['p99RasterMs']! as num) <=
            androidPerformanceBudget.p99PipelineMs &&
        (median['overBudgetRate']! as num) <=
            androidPerformanceBudget.overBudgetRate;
    passed = passed && scenarioPassed;
    scenarios[scenarioKey] = <String, Object?>{
      'passed': scenarioPassed,
      'median': median,
      'runs': runMetrics,
    };
  }

  return <String, Object?>{
    'schemaVersion': 1,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'sourceRevision': sourceRevision,
    'profilePackage': 'site.wenyou.app.profile',
    'device': device,
    'runCount': runs.length,
    'blockingTarget': <String, Object?>{
      'refreshRateHz': androidPerformanceBudget.targetHz,
      'p90BuildAndRasterMs': androidPerformanceBudget.p90PipelineMs,
      'p99BuildAndRasterMs': androidPerformanceBudget.p99PipelineMs,
      'overBudgetRate': androidPerformanceBudget.overBudgetRate,
    },
    'passed': passed,
    'scenarios': scenarios,
  };
}

Map<String, Object?> _evaluateRun(Map<String, Object?> raw) {
  final buildTimes = _microseconds(raw, 'frame_build_times');
  final rasterTimes = _microseconds(raw, 'frame_rasterizer_times');
  if (buildTimes.isEmpty || rasterTimes.isEmpty) {
    throw const FormatException('性能场景没有采集到帧数据');
  }
  final frameCount = buildTimes.length < rasterTimes.length
      ? buildTimes.length
      : rasterTimes.length;
  final frameBudgetUs = 1000000 / androidPerformanceBudget.targetHz;
  var overBudgetCount = 0;
  for (var index = 0; index < frameCount; index++) {
    if (buildTimes[index] > frameBudgetUs ||
        rasterTimes[index] > frameBudgetUs) {
      overBudgetCount++;
    }
  }
  return <String, Object?>{
    'frameCount': frameCount,
    'p90BuildMs': _rounded(_percentile(buildTimes, 0.90) / 1000),
    'p90RasterMs': _rounded(_percentile(rasterTimes, 0.90) / 1000),
    'p99BuildMs': _rounded(_percentile(buildTimes, 0.99) / 1000),
    'p99RasterMs': _rounded(_percentile(rasterTimes, 0.99) / 1000),
    'overBudgetRate': _rounded(overBudgetCount / frameCount),
  };
}

List<double> _microseconds(Map<String, Object?> raw, String key) {
  final values = raw[key];
  if (values is! List) throw FormatException('$key 不是数组');
  return values
      .map((value) {
        if (value is! num) throw FormatException('$key 包含非数字值');
        return value.toDouble();
      })
      .toList(growable: false);
}

double _percentile(List<double> values, double percentile) {
  final sorted = [...values]..sort();
  return sorted[((sorted.length - 1) * percentile).round()];
}

double _median(Iterable<num> values) {
  final sorted = values.map((value) => value.toDouble()).toList()..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return (sorted[middle - 1] + sorted[middle]) / 2;
}

double _rounded(double value) => (value * 1000).round() / 1000;

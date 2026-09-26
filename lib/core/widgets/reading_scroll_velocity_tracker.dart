import 'dart:math' as math;

/// 只接收主阅读列表的手指位移；阈值由调用方传入共享契约。
class ReadingScrollVelocityTracker {
  ReadingScrollVelocityTracker({
    required this.window,
    required this.minimumDuration,
    required this.minimumDistance,
    required this.minimumVelocity,
    required this.viewportVelocityFactor,
  }) : assert(window >= minimumDuration),
       assert(minimumDuration > Duration.zero),
       assert(minimumDistance > 0),
       assert(minimumVelocity > 0),
       assert(viewportVelocityFactor > 0);

  final Duration window;
  final Duration minimumDuration;
  final double minimumDistance;
  final double minimumVelocity;
  final double viewportVelocityFactor;
  final _samples = <({Duration at, double pixels})>[];
  double _direction = 0;

  void reset() {
    _samples.clear();
    _direction = 0;
  }

  void start(Duration timestamp, double pixels) {
    reset();
    if (pixels.isFinite) _samples.add((at: timestamp, pixels: pixels));
  }

  bool addSample({
    required Duration timestamp,
    required double pixels,
    required double viewportDimension,
  }) {
    if (!pixels.isFinite ||
        !viewportDimension.isFinite ||
        viewportDimension <= 0) {
      reset();
      return false;
    }
    if (_samples.isEmpty) {
      start(timestamp, pixels);
      return false;
    }
    final previous = _samples.last;
    final interval = timestamp - previous.at;
    // 不能把重复/回退的时间戳或停顿后的单次大位移当成持续快滑。
    if (interval <= Duration.zero || interval > window) {
      start(timestamp, pixels);
      return false;
    }
    final direction = (pixels - previous.pixels).sign;
    if (direction != 0 && _direction != 0 && direction != _direction) {
      start(previous.at, previous.pixels);
    }
    if (direction != 0) _direction = direction;
    _samples.add((at: timestamp, pixels: pixels));

    final cutoff = timestamp - window;
    while (_samples.length > 2 && _samples[1].at <= cutoff) {
      _samples.removeAt(0);
    }
    if (_samples.first.at < cutoff) {
      final first = _samples[0];
      final next = _samples[1];
      final fraction =
          (cutoff - first.at).inMicroseconds /
          (next.at - first.at).inMicroseconds;
      _samples[0] = (
        at: cutoff,
        pixels: first.pixels + (next.pixels - first.pixels) * fraction,
      );
    }
    final elapsed = timestamp - _samples.first.at;
    final distance = (pixels - _samples.first.pixels).abs();
    if (elapsed < minimumDuration || distance < minimumDistance) return false;
    final velocity =
        distance * Duration.microsecondsPerSecond / elapsed.inMicroseconds;
    return velocity >=
        math.max(minimumVelocity, viewportVelocityFactor * viewportDimension);
  }
}

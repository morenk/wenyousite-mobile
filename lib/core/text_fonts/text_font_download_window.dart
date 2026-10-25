/// 按单调时钟计算的滑动窗口。网络尝试失败也不退还流量预留；
/// 到期自然补充额度，不能因页面销毁重置窗口。
class TextFontDownloadWindow {
  TextFontDownloadWindow({
    required this.period,
    required this.maximumBytes,
    required this.maximumRequests,
  }) {
    if (period <= Duration.zero || maximumBytes <= 0 || maximumRequests <= 0) {
      throw ArgumentError('下载窗口必须为正数');
    }
  }
  final Duration period;
  int maximumBytes;
  int maximumRequests;
  void tighten({required int bytes, required int requests}) {
    if (bytes < 1 || requests < 1) throw ArgumentError('窗口上限必须为正数');
    if (bytes < maximumBytes) maximumBytes = bytes;
    if (requests < maximumRequests) maximumRequests = requests;
  }

  final _attempts = <({Duration at, int bytes})>[];
  Duration _lastObserved = Duration.zero;

  /// 返回最早可开始的单调时刻；调用方定时唤醒，不要求用户刷新。
  Duration availableAt(int bytes, Duration elapsed) {
    if (bytes <= 0 || bytes > maximumBytes) {
      throw RangeError.range(bytes, 1, maximumBytes, 'bytes');
    }
    // 时间输入倒退时不能提前释放额度。
    final now = elapsed < _lastObserved ? _lastObserved : elapsed;
    _lastObserved = now;
    _attempts.removeWhere((a) => now - a.at >= period);
    return _firstAdmission(bytes, now, _attempts);
  }

  Duration _firstAdmission(
    int bytes,
    Duration now,
    List<({Duration at, int bytes})> attempts,
  ) {
    var usedBytes = attempts.fold(0, (sum, a) => sum + a.bytes);
    var usedRequests = attempts.length;
    if (usedBytes + bytes <= maximumBytes && usedRequests < maximumRequests) {
      return now;
    }
    for (final attempt in attempts) {
      usedBytes -= attempt.bytes;
      usedRequests--;
      if (usedBytes + bytes <= maximumBytes && usedRequests < maximumRequests) {
        return attempt.at + period;
      }
    }
    throw StateError('窗口记账不一致');
  }

  bool reserve(int bytes, Duration elapsed, {int? reservedForEarlier}) {
    final ready = availableAt(bytes, elapsed);
    if (ready > elapsed) return false;
    if (reservedForEarlier != null) {
      final earlierReady = availableAt(reservedForEarlier, elapsed);
      // 后来的小资源可以使用余量，但不能推迟队首大资源的最早时刻。
      if (earlierReady <= elapsed ||
          _firstAdmission(reservedForEarlier, elapsed, [
                ..._attempts,
                (at: elapsed, bytes: bytes),
              ]) >
              earlierReady) {
        return false;
      }
    }
    _attempts.add((at: elapsed, bytes: bytes));
    return true;
  }
}

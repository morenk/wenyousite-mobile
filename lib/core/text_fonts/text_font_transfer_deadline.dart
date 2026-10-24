import 'dart:async';

enum TextFontDeadlineReason { firstResponse, noProgress, total }

/// 传输进度与总生命周期是独立期限；只接受非空字节延长进度期限。
/// 时限由已协商策略传入，本对象不替远端策略扩大额度。
class TextFontTransferDeadline {
  TextFontTransferDeadline({
    required this.firstResponseTimeout,
    required this.progressTimeout,
    required Duration maximumDuration,
    required this.onTimeout,
    Duration Function()? elapsed,
  }) : _elapsed = elapsed ?? _clock() {
    if (firstResponseTimeout <= Duration.zero ||
        progressTimeout <= Duration.zero ||
        maximumDuration <= Duration.zero) {
      throw ArgumentError('传输期限必须为正数');
    }
    final start = _elapsed();
    _idleAt = start + firstResponseTimeout;
    _totalAt = start + maximumDuration;
    _idle = Timer(firstResponseTimeout, check);
    _total = Timer(maximumDuration, check);
  }
  final Duration firstResponseTimeout;
  final Duration progressTimeout;
  final void Function(TextFontDeadlineReason) onTimeout;
  final Duration Function() _elapsed;
  late Duration _idleAt;
  late final Duration _totalAt;
  Timer? _idle, _total;
  bool _closed = false;
  bool _responded = false;

  bool responseReceived() {
    if (!check()) return false;
    _responded = true;
    return true;
  }

  bool bytesReceived(int length) {
    if (!check()) return false;
    if (length <= 0) return true;
    _responded = true;
    _resetProgress();
    return true;
  }

  /// 流回调和EOF必须再次检查，不能依赖可能被事件循环延迟的timer。
  bool check() {
    if (_closed) return false;
    final now = _elapsed();
    if (now >= _totalAt) {
      _expire(TextFontDeadlineReason.total);
    } else if (now >= _idleAt) {
      _expire(
        _responded
            ? TextFontDeadlineReason.noProgress
            : TextFontDeadlineReason.firstResponse,
      );
    }
    return !_closed;
  }

  void _resetProgress() {
    _idle?.cancel();
    _idleAt = _elapsed() + progressTimeout;
    _idle = Timer(progressTimeout, check);
  }

  void _expire(TextFontDeadlineReason reason) {
    if (_closed) return;
    dispose();
    onTimeout(reason);
  }

  void dispose() {
    _closed = true;
    _idle?.cancel();
    _total?.cancel();
  }

  static Duration Function() _clock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }
}

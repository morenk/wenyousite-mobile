import 'dart:math';

/// 资源粒度退避。可见性或网络唤醒只能查询期限，不能清空失败历史。
class TextFontRetryLedger {
  TextFontRetryLedger({double Function()? random})
    : _random = random ?? Random().nextDouble;
  final double Function() _random;
  final _failures = <String, ({int count, Duration at, bool terminal})>{};

  bool isTerminal(String key) => _failures[key]?.terminal ?? false;
  int attempts(String key) => _failures[key]?.count ?? 0;
  Duration availableAt(String key) => _failures[key]?.at ?? Duration.zero;

  void transientFailure(String key, Duration now, {Duration? retryAfter}) {
    if (isTerminal(key)) return;
    final count = attempts(key) + 1;
    final seconds = count >= 7 ? 60 : 1 << (count - 1);
    final jitter = Duration(
      milliseconds: (_random().clamp(0, 0.999999999999) * (seconds * 1000 + 1))
          .floor(),
    );
    final delay = retryAfter != null && retryAfter > jitter
        ? retryAfter
        : jitter;
    _failures[key] = (count: count, at: now + delay, terminal: false);
  }

  void success(String key) {
    if (!isTerminal(key)) _failures.remove(key);
  }

  void quarantine(String key) {
    _failures[key] = (
      count: attempts(key),
      at: availableAt(key),
      terminal: true,
    );
  }
}

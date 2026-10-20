import 'dart:async';

/// 只负责倒计时，不发送验证码、不改变投递结果或重试策略。
class ResendCooldown {
  ResendCooldown({required this.isActive, required this.onTick});

  final bool Function() isActive;
  final void Function(int remaining) onTick;
  Timer? _timer;

  void start(int seconds) {
    cancel();
    if (seconds <= 0) return;
    var remaining = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isActive()) {
        cancel();
        return;
      }
      remaining--;
      if (remaining == 0) cancel();
      onTick(remaining);
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

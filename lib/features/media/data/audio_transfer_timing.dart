import 'dart:async';

import 'package:dio/dio.dart';

class AudioTransferTiming {
  const AudioTransferTiming({
    this.total = const Duration(minutes: 5),
    this.idle = const Duration(seconds: 30),
  });

  static const connect = Duration(seconds: 15);
  final Duration total;
  final Duration idle;
}

enum AudioTransferTimeout { total, idle }

/// 只取消本次存储传输；不能把内部超时写成队列的用户取消。
class AudioTransferGuard {
  AudioTransferGuard(CancelToken parent, AudioTransferTiming timing)
    : _timing = timing {
    _total = Timer(timing.total, () => _stop(AudioTransferTimeout.total));
    _idle = Timer(timing.idle, () => _stop(AudioTransferTimeout.idle));
    _parent = parent.whenCancel.asStream().listen(_stop);
    if (parent.isCancelled) _stop(parent.cancelError!);
  }

  final AudioTransferTiming _timing;
  final token = CancelToken();
  final _interrupt = StreamController<Object>.broadcast(sync: true);
  late final Timer _total;
  late Timer _idle;
  late final StreamSubscription<DioException> _parent;
  Object? _error;
  var _bytes = 0;
  var _disposed = false;

  void progress(int bytes) {
    if (_disposed || _error != null || bytes <= _bytes) return;
    _bytes = bytes;
    _idle.cancel();
    _idle = Timer(_timing.idle, () => _stop(AudioTransferTimeout.idle));
  }

  void _stop(Object error) {
    if (_disposed || _error != null) return;
    _error = error;
    _total.cancel();
    _idle.cancel();
    _interrupt.add(error);
    token.cancel(error);
  }

  /// 除 HTTP 头等待外也用于流读取，底层静默不再吐 chunk 时仍能退出。
  Future<T> wait<T>(Future<T> operation) async {
    final interrupted = Completer<T>();
    final subscription = _interrupt.stream.listen(interrupted.completeError);
    if (_error case final error?) interrupted.completeError(error);
    try {
      return await Future.any([operation, interrupted.future]);
    } finally {
      // 本地广播订阅同步解除；不等待 Future-stream 的无资源收尾。
      unawaited(subscription.cancel());
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _total.cancel();
    _idle.cancel();
    unawaited(_parent.cancel());
    unawaited(_interrupt.close());
  }
}

Future<void> waitForAudioProcessing(
  Duration duration,
  CancelToken cancel,
) async {
  if (cancel.isCancelled) throw cancel.cancelError!;
  final completed = Completer<void>();
  final timer = Timer(duration, completed.complete);
  final subscription = cancel.whenCancel.asStream().listen((error) {
    if (!completed.isCompleted) completed.completeError(error);
  });
  try {
    await completed.future;
  } finally {
    timer.cancel();
    unawaited(subscription.cancel());
  }
}

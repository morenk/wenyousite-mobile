import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaUploadWorkCoordinator {
  MediaUploadWorkCoordinator({
    int preparationConcurrency = 1,
    int transferConcurrency = 2,
    int queryConcurrency = 2,
  }) : _preparation = _AsyncWorkGate(preparationConcurrency),
       _transfer = _AsyncWorkGate(transferConcurrency),
       _query = _AsyncWorkGate(queryConcurrency);

  final _AsyncWorkGate _preparation;
  final _AsyncWorkGate _transfer;
  final _AsyncWorkGate _query;

  Future<T> prepare<T>(Future<T> Function() operation) {
    return _preparation.run(operation);
  }

  Future<T> transfer<T>(
    Future<T> Function() operation, {
    Future<void>? releaseWhen,
  }) {
    return _transfer.run(operation, releaseWhen: releaseWhen);
  }

  /// 只包住一次查询请求；轮询间隔不能占用请求名额。
  Future<T> query<T>(Future<T> Function() operation) => _query.run(operation);
}

final mediaUploadWorkCoordinatorProvider = Provider<MediaUploadWorkCoordinator>(
  (ref) => MediaUploadWorkCoordinator(),
);

class _AsyncWorkGate {
  _AsyncWorkGate(this.maximumConcurrency) : assert(maximumConcurrency > 0);

  final int maximumConcurrency;
  final Queue<Future<void> Function()> _queue = Queue();
  var _active = 0;

  Future<T> run<T>(
    Future<T> Function() operation, {
    Future<void>? releaseWhen,
  }) {
    final completer = Completer<T>();
    _queue.add(() async {
      final released = Completer<void>();
      void release() {
        if (!released.isCompleted) released.complete();
      }

      if (releaseWhen != null) {
        unawaited(
          releaseWhen.then(
            (_) => release(),
            // 失败信号不表示传输结束；仍由 operation 的结局释放名额。
            onError: (Object _, StackTrace _) {},
          ),
        );
      }
      unawaited(() async {
        try {
          completer.complete(await operation());
        } on Object catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        } finally {
          release();
        }
      }());
      await released.future;
    });
    _drain();
    return completer.future;
  }

  void _drain() {
    while (_active < maximumConcurrency && _queue.isNotEmpty) {
      final operation = _queue.removeFirst();
      _active += 1;
      unawaited(
        operation().whenComplete(() {
          _active -= 1;
          _drain();
        }),
      );
    }
  }
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaUploadWorkCoordinator {
  MediaUploadWorkCoordinator({
    int preparationConcurrency = 1,
    int transferConcurrency = 2,
  }) : _preparation = _AsyncWorkGate(preparationConcurrency),
       _transfer = _AsyncWorkGate(transferConcurrency);

  final _AsyncWorkGate _preparation;
  final _AsyncWorkGate _transfer;

  Future<T> prepare<T>(Future<T> Function() operation) {
    return _preparation.run(operation);
  }

  Future<T> transfer<T>(Future<T> Function() operation) {
    return _transfer.run(operation);
  }
}

final mediaUploadWorkCoordinatorProvider = Provider<MediaUploadWorkCoordinator>(
  (ref) => MediaUploadWorkCoordinator(),
);

class _AsyncWorkGate {
  _AsyncWorkGate(this.maximumConcurrency) : assert(maximumConcurrency > 0);

  final int maximumConcurrency;
  final Queue<Future<void> Function()> _queue = Queue();
  var _active = 0;

  Future<T> run<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _queue.add(() async {
      try {
        completer.complete(await operation());
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
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

import 'dart:async';

import 'package:flutter/foundation.dart';

enum ThreadManagementAutosaveStatus { idle, scheduled, saving, saved, failed }

/// Serializes aggregate theme saves while coalescing edits made during an
/// in-flight request into the next write.
class ThreadManagementAutosaveCoordinator extends ChangeNotifier {
  ThreadManagementAutosaveCoordinator({
    required this.hasChanges,
    required this.onSave,
    this.delay = const Duration(milliseconds: 1200),
  });

  final bool Function() hasChanges;
  final Future<bool> Function() onSave;
  final Duration delay;

  Timer? _timer;
  Timer? _savedTimer;
  Future<bool>? _drainFuture;
  var _requested = false;
  var _disposed = false;
  var _status = ThreadManagementAutosaveStatus.idle;

  ThreadManagementAutosaveStatus get status => _status;

  void schedule() {
    if (_disposed || !hasChanges()) return;
    _timer?.cancel();
    _setStatus(ThreadManagementAutosaveStatus.scheduled);
    _timer = Timer(delay, () => unawaited(saveNow()));
  }

  Future<bool> saveNow() {
    if (_disposed) return Future.value(false);
    _timer?.cancel();
    _requested = true;
    final active = _drainFuture;
    if (active != null) return active;
    final drain = _drain();
    _drainFuture = drain;
    return drain;
  }

  void markSaved() {
    if (_disposed) return;
    _timer?.cancel();
    _requested = false;
    _setStatus(ThreadManagementAutosaveStatus.saved);
  }

  Future<bool> _drain() async {
    var succeeded = true;
    try {
      while (_requested || hasChanges()) {
        _requested = false;
        if (!hasChanges()) break;
        _timer?.cancel();
        _setStatus(ThreadManagementAutosaveStatus.saving);
        succeeded = await onSave();
        if (_disposed) return false;
        if (!succeeded) {
          _setStatus(ThreadManagementAutosaveStatus.failed);
          return false;
        }
      }
      _setStatus(ThreadManagementAutosaveStatus.saved);
      return !hasChanges();
    } finally {
      _drainFuture = null;
      if (!_disposed && succeeded && _requested) unawaited(saveNow());
    }
  }

  void _setStatus(ThreadManagementAutosaveStatus value) {
    _savedTimer?.cancel();
    _savedTimer = null;
    if (_status != value) {
      _status = value;
      notifyListeners();
    }
    if (value == ThreadManagementAutosaveStatus.saved) {
      _savedTimer = Timer(const Duration(milliseconds: 1500), () {
        _savedTimer = null;
        if (!_disposed && _status == ThreadManagementAutosaveStatus.saved) {
          _setStatus(ThreadManagementAutosaveStatus.idle);
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _savedTimer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

/// Tracks ordinary feedback so deferred receipts never interrupt an action.
class WenyouSnackBarActivity extends ChangeNotifier {
  static final _instances = Expando<WenyouSnackBarActivity>();

  static WenyouSnackBarActivity of(ScaffoldMessengerState messenger) =>
      _instances[messenger] ??= WenyouSnackBarActivity();

  int _epoch = 0;
  bool _busy = false;
  bool get busy => _busy;

  int begin() {
    _busy = true;
    final epoch = ++_epoch;
    notifyListeners();
    return epoch;
  }

  void finish(int epoch) {
    if (epoch != _epoch) return;
    _busy = false;
    notifyListeners();
  }
}

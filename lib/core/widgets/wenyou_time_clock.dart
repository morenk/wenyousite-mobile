import 'dart:async';

import 'package:flutter/widgets.dart';

/// 内容时间共用分钟刷新；没有消费者或应用退到后台时停止。
class WenyouTimeClock extends ChangeNotifier with WidgetsBindingObserver {
  WenyouTimeClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  Timer? _timer;
  DateTime get value => _now();

  @override
  void addListener(VoidCallback listener) {
    final wasEmpty = !hasListeners;
    super.addListener(listener);
    if (wasEmpty) {
      WidgetsBinding.instance.addObserver(this);
      _start();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _stop();
  }

  void _start() {
    _timer?.cancel();
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
    }
  }

  void _refresh() {
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    if (state == AppLifecycleState.resumed && hasListeners) {
      _refresh();
      _start();
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }
}

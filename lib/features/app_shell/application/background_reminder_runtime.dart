import 'dart:async';

import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_reminder_coordinator.dart';

enum ReminderVisibility { foreground, inactive, background }

/// 与页面状态无关的运行编排；原生持有启动窗口，Dart 持有账号和检测基线。
class BackgroundReminderRuntime {
  BackgroundReminderRuntime({
    required this.execution,
    required this.coordinator,
    required this.onUnavailable,
  }) {
    _subscription = execution.statusChanges.listen(
      _handleStatus,
      onError: (Object error) =>
          _handleStatus(BackgroundExecutionStatus.failed),
    );
  }

  final BackgroundExecutionGateway execution;
  final BackgroundOnlineReminderCoordinator coordinator;
  final void Function(BackgroundExecutionStatus status) onUnavailable;
  late final StreamSubscription<BackgroundExecutionStatus> _subscription;
  ({Object? scope, bool enabled, bool direct, ReminderVisibility visibility})?
  _configuration;
  int _epoch = 0;
  bool _disposed = false;
  bool _unavailableReported = false;

  void synchronize({
    required Object? scope,
    required bool enabled,
    required bool includeDirectMessages,
    required ReminderVisibility visibility,
  }) {
    if (_disposed) return;
    final next = (
      scope: scope,
      enabled: enabled && scope != null && execution.isSupported,
      direct: includeDirectMessages,
      visibility: visibility,
    );
    if (_configuration == next) return;
    final previous = _configuration;
    _configuration = next;
    final epoch = ++_epoch;
    if (previous?.scope != next.scope ||
        previous?.direct != next.direct ||
        !next.enabled ||
        visibility == ReminderVisibility.foreground) {
      coordinator.stop();
    }
    if (visibility == ReminderVisibility.foreground) {
      _unavailableReported = false;
    }
    unawaited(_reconcile(epoch));
  }

  Future<void> _reconcile(int epoch) async {
    final configuration = _configuration!;
    try {
      await execution.setEnabled(configuration.enabled);
      if (!_current(epoch)) return;
      if (!configuration.enabled ||
          configuration.visibility == ReminderVisibility.foreground) {
        await execution.stop();
        return;
      }
      final status = await execution.start();
      if (_current(epoch)) _handleStatus(status);
    } on Object {
      if (_current(epoch)) _handleStatus(BackgroundExecutionStatus.failed);
    }
  }

  void _handleStatus(BackgroundExecutionStatus status) {
    if (_disposed) return;
    final configuration = _configuration;
    if (configuration == null ||
        !configuration.enabled ||
        configuration.visibility == ReminderVisibility.foreground) {
      return;
    }
    if (status == BackgroundExecutionStatus.running) {
      coordinator.prepare(includeDirectMessages: configuration.direct);
      if (configuration.visibility == ReminderVisibility.background) {
        coordinator.start(includeDirectMessages: configuration.direct);
      }
      return;
    }
    coordinator.stop();
    if (status == BackgroundExecutionStatus.foreground) return;
    if (status == BackgroundExecutionStatus.starting) return;
    // inactive 可能早于原生 onPause；尚未启动不当作失败，等待原生事件。
    if (status == BackgroundExecutionStatus.stopped &&
        configuration.visibility == ReminderVisibility.inactive) {
      return;
    }
    if (_unavailableReported) return;
    _unavailableReported = true;
    onUnavailable(status);
  }

  bool _current(int epoch) => !_disposed && epoch == _epoch;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _epoch++;
    coordinator.dispose();
    unawaited(_subscription.cancel());
    // 释放 UI/Flutter engine 之后不留下只有卡片、没有检测者的服务。
    unawaited(execution.setEnabled(false).catchError((Object _) {}));
    unawaited(execution.stop().catchError((Object _) {}));
  }
}

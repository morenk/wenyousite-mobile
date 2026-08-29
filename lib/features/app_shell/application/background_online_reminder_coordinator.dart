import 'dart:async';

import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';

abstract interface class BackgroundOnlineReminderTimer {
  void cancel();
}

typedef BackgroundOnlineReminderTimerFactory =
    BackgroundOnlineReminderTimer Function(
      Duration interval,
      void Function() onTick,
    );

typedef BackgroundOnlineReminderDiagnosticSink =
    void Function(String stage, Map<String, Object?> fields);

class BackgroundOnlineReminderCoordinator {
  BackgroundOnlineReminderCoordinator({
    required this.pollingSession,
    required this.notificationGateway,
    required this.onPermissionDenied,
    this.interval = const Duration(seconds: 30),
    this.timerFactory = _createTimer,
    this.diagnostics,
  });

  final BackgroundOnlinePollingSession pollingSession;
  final BackgroundNotificationGateway notificationGateway;
  final Future<void> Function() onPermissionDenied;
  final Duration interval;
  final BackgroundOnlineReminderTimerFactory timerFactory;
  final BackgroundOnlineReminderDiagnosticSink? diagnostics;

  BackgroundOnlineReminderTimer? _timer;
  bool _prepared = false;
  bool _active = false;
  bool _cycleInFlight = false;
  bool _includeDirectMessages = false;
  bool _disposed = false;
  int _epoch = 0;

  void prepare({required bool includeDirectMessages}) {
    if (_disposed) return;
    if (_prepared && _includeDirectMessages == includeDirectMessages) return;
    _resetForBackground(includeDirectMessages);
    final epoch = _epoch;
    _record('prepare', {'outcome': 'started'});
    unawaited(_prepareBaseline(epoch));
  }

  void start({required bool includeDirectMessages}) {
    if (_disposed) return;
    prepare(includeDirectMessages: includeDirectMessages);
    if (_active) return;
    _active = true;
    _timer = timerFactory(interval, _handleTick);
    _record('schedule', {
      'outcome': 'started',
      'intervalSeconds': interval.inSeconds,
    });
  }

  void stop() {
    if (_disposed || (!_prepared && !_active && _timer == null)) return;
    _epoch++;
    _timer?.cancel();
    _timer = null;
    _prepared = false;
    _active = false;
    pollingSession.invalidate();
    _record('schedule', {'outcome': 'stopped'});
  }

  void dispose() {
    if (_disposed) return;
    stop();
    _disposed = true;
  }

  void _resetForBackground(bool includeDirectMessages) {
    _epoch++;
    _timer?.cancel();
    _timer = null;
    _active = false;
    _prepared = true;
    _includeDirectMessages = includeDirectMessages;
    pollingSession.invalidate();
  }

  Future<void> _prepareBaseline(int epoch) async {
    var stage = 'capability';
    try {
      final canNotify = await notificationGateway.canNotify();
      if (!_isPreparedEpochCurrent(epoch)) return;
      if (!canNotify) {
        _record(stage, {'outcome': 'blocked'});
        await _denyPermissionAndStop(epoch);
        return;
      }
      stage = 'baseline';
      final ready = await pollingSession.ensureBaseline(
        includeDirectMessages: _includeDirectMessages,
      );
      if (!_isPreparedEpochCurrent(epoch)) return;
      _record(stage, {'outcome': ready ? 'ready' : 'stale'});
    } on Object catch (error) {
      if (_isPreparedEpochCurrent(epoch)) {
        _record(stage, {
          'outcome': 'failed',
          'errorType': error.runtimeType.toString(),
        });
      }
    }
  }

  void _handleTick() {
    if (!_active || _disposed) return;
    if (_cycleInFlight) {
      _record('poll', {'outcome': 'skipped_in_flight'});
      return;
    }
    _cycleInFlight = true;
    final epoch = _epoch;
    unawaited(_runCycle(epoch));
  }

  Future<void> _runCycle(int epoch) async {
    var stage = 'capability';
    try {
      final canNotify = await notificationGateway.canNotify();
      if (!_isActiveEpochCurrent(epoch)) return;
      if (!canNotify) {
        _record(stage, {'outcome': 'blocked'});
        await _denyPermissionAndStop(epoch);
        return;
      }

      stage = 'baseline';
      final hadBaseline = pollingSession.hasBaseline;
      final ready = await pollingSession.ensureBaseline(
        includeDirectMessages: _includeDirectMessages,
      );
      if (!_isActiveEpochCurrent(epoch)) return;
      if (!ready) {
        _record(stage, {'outcome': 'stale'});
        return;
      }
      if (!hadBaseline) {
        _record(stage, {'outcome': 'ready'});
        return;
      }

      stage = 'poll';
      final batch = await pollingSession.poll(
        includeDirectMessages: _includeDirectMessages,
      );
      if (!_isActiveEpochCurrent(epoch) || batch == null) return;
      _record(stage, {
        'outcome': 'collected',
        'alertCount': batch.alerts.length,
      });

      stage = 'present';
      if (batch.alerts.isNotEmpty) {
        await notificationGateway.showAlerts(batch.alerts);
      }
      if (!_isActiveEpochCurrent(epoch)) return;

      stage = 'commit';
      final committed = batch.commit();
      _record(stage, {'outcome': committed ? 'committed' : 'stale'});
    } on Object catch (error) {
      if (_isActiveEpochCurrent(epoch)) {
        _record(stage, {
          'outcome': 'failed',
          'errorType': error.runtimeType.toString(),
        });
      }
    } finally {
      _cycleInFlight = false;
    }
  }

  Future<void> _denyPermissionAndStop(int epoch) async {
    await onPermissionDenied();
    if (_isPreparedEpochCurrent(epoch)) stop();
  }

  bool _isPreparedEpochCurrent(int epoch) {
    return !_disposed && _prepared && epoch == _epoch;
  }

  bool _isActiveEpochCurrent(int epoch) {
    return _active && _isPreparedEpochCurrent(epoch);
  }

  void _record(String stage, Map<String, Object?> fields) {
    diagnostics?.call(stage, {
      'epoch': _epoch,
      'includeDirectMessages': _includeDirectMessages,
      ...fields,
    });
  }
}

class _PeriodicBackgroundOnlineReminderTimer
    implements BackgroundOnlineReminderTimer {
  _PeriodicBackgroundOnlineReminderTimer(
    Duration interval,
    void Function() onTick,
  ) : _timer = Timer.periodic(interval, (_) => onTick());

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}

BackgroundOnlineReminderTimer _createTimer(
  Duration interval,
  void Function() onTick,
) => _PeriodicBackgroundOnlineReminderTimer(interval, onTick);

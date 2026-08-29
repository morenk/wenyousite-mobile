import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_reminder_coordinator.dart';

void main() {
  test('后台超过十分钟后仍保持每三十秒轮询且每轮提交一次', () async {
    final polling = _FakePollingSession();
    final gateway = _FakeGateway();
    final timers = _FakeTimerFactory();
    final coordinator = _coordinator(polling, gateway, timers);
    addTearDown(coordinator.dispose);

    coordinator.prepare(includeDirectMessages: true);
    coordinator.start(includeDirectMessages: true);
    await _settle();

    expect(timers.intervals, [const Duration(seconds: 30)]);
    for (var tick = 0; tick < 21; tick++) {
      timers.tick();
      await _settle();
    }

    expect(polling.pollCalls, 21);
    expect(polling.commitCalls, 21);
    expect(timers.intervals, [const Duration(seconds: 30)]);
  });

  test('上一轮未完成时跳过节拍且完成后可以继续', () async {
    final polling = _FakePollingSession();
    final firstPoll = Completer<BackgroundOnlinePollBatch?>();
    var first = true;
    polling.pollHandler = () {
      if (first) {
        first = false;
        return firstPoll.future;
      }
      return Future.value(polling.emptyBatch());
    };
    final gateway = _FakeGateway();
    final timers = _FakeTimerFactory();
    final coordinator = _coordinator(polling, gateway, timers);
    addTearDown(coordinator.dispose);

    coordinator.start(includeDirectMessages: false);
    await _settle();
    timers.tick();
    await _settle();
    timers.tick();
    await _settle();

    expect(polling.pollCalls, 1);
    firstPoll.complete(polling.emptyBatch());
    await _settle();
    timers.tick();
    await _settle();

    expect(polling.pollCalls, 2);
    expect(polling.commitCalls, 2);
  });

  test('返回前台后迟到的轮询结果不能展示或提交', () async {
    final polling = _FakePollingSession();
    final pending = Completer<BackgroundOnlinePollBatch?>();
    polling.pollHandler = () => pending.future;
    final gateway = _FakeGateway();
    final timers = _FakeTimerFactory();
    final coordinator = _coordinator(polling, gateway, timers);
    addTearDown(coordinator.dispose);

    coordinator.start(includeDirectMessages: false);
    await _settle();
    timers.tick();
    await _settle();
    coordinator.stop();
    pending.complete(polling.alertBatch());
    await _settle();

    expect(gateway.showCalls, 0);
    expect(polling.commitCalls, 0);
    expect(timers.activeTimer, isNull);
  });

  test('系统通知展示失败时不提交并在下一节拍重试', () async {
    final polling = _FakePollingSession();
    polling.pollHandler = () => Future.value(polling.alertBatch());
    final gateway = _FakeGateway(showFailuresRemaining: 1);
    final timers = _FakeTimerFactory();
    final coordinator = _coordinator(polling, gateway, timers);
    addTearDown(coordinator.dispose);

    coordinator.start(includeDirectMessages: false);
    await _settle();
    timers.tick();
    await _settle();

    expect(gateway.showCalls, 1);
    expect(polling.commitCalls, 0);

    timers.tick();
    await _settle();
    expect(gateway.showCalls, 2);
    expect(polling.commitCalls, 1);
  });

  test('通知权限不可用时不建立消息基线或请求消息接口', () async {
    final polling = _FakePollingSession();
    final gateway = _FakeGateway(canNotifyValue: false);
    final timers = _FakeTimerFactory();
    var deniedCalls = 0;
    final coordinator = BackgroundOnlineReminderCoordinator(
      pollingSession: polling,
      notificationGateway: gateway,
      onPermissionDenied: () async => deniedCalls++,
      timerFactory: timers.create,
    );
    addTearDown(coordinator.dispose);

    coordinator.start(includeDirectMessages: true);
    await _settle();
    timers.tick();
    await _settle();

    expect(deniedCalls, 1);
    expect(polling.ensureCalls, 0);
    expect(polling.pollCalls, 0);
    expect(timers.activeTimer, isNull);
  });
}

BackgroundOnlineReminderCoordinator _coordinator(
  _FakePollingSession polling,
  _FakeGateway gateway,
  _FakeTimerFactory timers,
) {
  return BackgroundOnlineReminderCoordinator(
    pollingSession: polling,
    notificationGateway: gateway,
    onPermissionDenied: () async {},
    timerFactory: timers.create,
  );
}

Future<void> _settle() async {
  for (var index = 0; index < 12; index++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakePollingSession implements BackgroundOnlinePollingSession {
  bool baseline = false;
  int ensureCalls = 0;
  int pollCalls = 0;
  int commitCalls = 0;
  Future<BackgroundOnlinePollBatch?> Function()? pollHandler;

  @override
  bool get hasBaseline => baseline;

  @override
  Future<bool> ensureBaseline({required bool includeDirectMessages}) async {
    ensureCalls++;
    baseline = true;
    return true;
  }

  @override
  void invalidate() {
    baseline = false;
  }

  @override
  Future<BackgroundOnlinePollBatch?> poll({
    required bool includeDirectMessages,
  }) {
    pollCalls++;
    return pollHandler?.call() ?? Future.value(emptyBatch());
  }

  BackgroundOnlinePollBatch emptyBatch() {
    return BackgroundOnlinePollBatch(
      alerts: const [],
      commitCallback: () {
        commitCalls++;
        return true;
      },
    );
  }

  BackgroundOnlinePollBatch alertBatch() {
    return BackgroundOnlinePollBatch(
      alerts: const [
        BackgroundLocalAlert(
          id: 1,
          title: '温油站',
          body: '有一条新消息',
          payload: '{"v":1,"type":"messageCenter"}',
        ),
      ],
      commitCallback: () {
        commitCalls++;
        return true;
      },
    );
  }
}

class _FakeGateway implements BackgroundNotificationGateway {
  _FakeGateway({this.canNotifyValue = true, this.showFailuresRemaining = 0});

  bool canNotifyValue;
  int showFailuresRemaining;
  int showCalls = 0;

  @override
  bool get isSupported => true;

  @override
  Stream<String> get notificationTaps => const Stream.empty();

  @override
  Future<bool> canNotify() async => canNotifyValue;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => canNotifyValue;

  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {
    showCalls++;
    if (showFailuresRemaining > 0) {
      showFailuresRemaining--;
      throw StateError('transient platform failure');
    }
  }

  @override
  Future<String?> takeLaunchPayload() async => null;
}

class _FakeTimerFactory {
  final intervals = <Duration>[];
  _FakeTimer? activeTimer;

  BackgroundOnlineReminderTimer create(
    Duration interval,
    void Function() onTick,
  ) {
    intervals.add(interval);
    return activeTimer = _FakeTimer(onTick, () => activeTimer = null);
  }

  void tick() => activeTimer?.tick();
}

class _FakeTimer implements BackgroundOnlineReminderTimer {
  _FakeTimer(this._onTick, this._onCancel);

  final void Function() _onTick;
  final void Function() _onCancel;
  bool _active = true;

  void tick() {
    if (_active) _onTick();
  }

  @override
  void cancel() {
    if (!_active) return;
    _active = false;
    _onCancel();
  }
}

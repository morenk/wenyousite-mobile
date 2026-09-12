import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_reminder_coordinator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_reminder_runtime.dart';

void main() {
  late _Execution execution;
  late _Coordinator coordinator;
  late BackgroundReminderRuntime runtime;
  late List<BackgroundExecutionStatus> failures;
  setUp(() {
    execution = _Execution();
    coordinator = _Coordinator();
    failures = [];
    runtime = BackgroundReminderRuntime(
      execution: execution,
      coordinator: coordinator,
      onUnavailable: failures.add,
    );
  });
  tearDown(() async {
    runtime.dispose();
    await execution.events.close();
    await _settle();
  });
  void sync({
    Object? scope = 'a',
    bool enabled = true,
    ReminderVisibility visibility = ReminderVisibility.background,
  }) {
    runtime.synchronize(
      scope: scope,
      enabled: enabled,
      includeDirectMessages: true,
      visibility: visibility,
    );
  }

  test('前台只预置许可，后台必须等服务确认运行才准备和轮询', () async {
    sync(visibility: ReminderVisibility.foreground);
    await _settle();
    expect(execution.enabled, isTrue);
    expect(execution.starts, 0);
    sync(visibility: ReminderVisibility.inactive);
    await _settle();
    sync();
    await _settle();
    verifyNever(() => coordinator.prepare(includeDirectMessages: true));
    verifyNever(() => coordinator.start(includeDirectMessages: true));
    execution.emit(BackgroundExecutionStatus.running);
    await _settle();
    verify(() => coordinator.prepare(includeDirectMessages: true)).called(1);
    verify(() => coordinator.start(includeDirectMessages: true)).called(1);
    expect(failures, isEmpty);
  });

  test('原生回前台事件立即停止；迟到的启动结果不能重新拉取', () async {
    final start = Completer<BackgroundExecutionStatus>();
    execution.pending = start.future;
    sync();
    await _settle();
    execution.emit(BackgroundExecutionStatus.foreground);
    await _settle();
    verify(() => coordinator.stop()).called(greaterThanOrEqualTo(1));
    sync(visibility: ReminderVisibility.foreground);
    start.complete(BackgroundExecutionStatus.running);
    await _settle();
    execution.emit(BackgroundExecutionStatus.running);
    await _settle();
    verifyNever(() => coordinator.start(includeDirectMessages: true));
    expect(failures, isEmpty);
  });

  for (final status in [
    BackgroundExecutionStatus.blocked,
    BackgroundExecutionStatus.failed,
    BackgroundExecutionStatus.stopped,
  ]) {
    test('服务 $status 使当前轮询失效且只报告一次', () async {
      execution.status = BackgroundExecutionStatus.running;
      sync();
      await _settle();
      clearInteractions(coordinator);
      execution.emit(status);
      execution.emit(status);
      await _settle();
      verify(() => coordinator.stop()).called(2);
      expect(failures, [status]);
    });
  }

  test('退出、切号、关闭功能均立即作废基线；停止后忽略旧服务事件', () async {
    execution.status = BackgroundExecutionStatus.running;
    sync();
    await _settle();
    clearInteractions(coordinator);
    sync(scope: 'b');
    verify(() => coordinator.stop()).called(1);
    await _settle();
    sync(enabled: false);
    await _settle();
    expect(execution.enabled, isFalse);
    clearInteractions(coordinator);
    execution.emit(BackgroundExecutionStatus.running);
    await _settle();
    verifyNever(() => coordinator.start(includeDirectMessages: true));
    sync(scope: null);
    await _settle();
    expect(execution.enabled, isFalse);
    expect(execution.stops, greaterThanOrEqualTo(2));
  });

  test('inactive 早于原生 onPause 时 stopped 不是失败；异常则停止', () async {
    execution.status = BackgroundExecutionStatus.stopped;
    sync(visibility: ReminderVisibility.inactive);
    await _settle();
    expect(failures, isEmpty);
    execution.throwOnStart = true;
    sync();
    await _settle();
    expect(failures, [BackgroundExecutionStatus.failed]);
    verifyNever(() => coordinator.start(includeDirectMessages: true));
  });

  test('重复配置不重复启动；回前台停止，再次后台可以恢复', () async {
    execution.status = BackgroundExecutionStatus.running;
    sync();
    await _settle();
    sync();
    await _settle();
    expect(execution.starts, 1);
    sync(visibility: ReminderVisibility.foreground);
    await _settle();
    sync();
    await _settle();
    expect(execution.starts, 2);
    expect(execution.stops, 1);
  });
}

Future<void> _settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Coordinator extends Mock
    implements BackgroundOnlineReminderCoordinator {}

class _Execution extends UnsupportedBackgroundExecutionGateway {
  final events = StreamController<BackgroundExecutionStatus>.broadcast();
  bool enabled = false;
  bool throwOnStart = false;
  int starts = 0;
  int stops = 0;
  BackgroundExecutionStatus status = BackgroundExecutionStatus.starting;
  Future<BackgroundExecutionStatus>? pending;
  void emit(BackgroundExecutionStatus value) {
    status = value;
    events.add(value);
  }

  @override
  bool get isSupported => true;
  @override
  Stream<BackgroundExecutionStatus> get statusChanges => events.stream;
  @override
  Future<void> setEnabled(bool value) async => enabled = value;
  @override
  Future<BackgroundExecutionStatus> start() async {
    starts++;
    if (throwOnStart) throw StateError('platform');
    return pending ?? status;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

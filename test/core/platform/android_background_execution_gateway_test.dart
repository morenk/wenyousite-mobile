import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/platform/android_background_execution_gateway.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('site.wenyou.app/background_execution');
  final calls = <MethodCall>[];
  late AndroidBackgroundExecutionGateway gateway;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls.clear();
    gateway = AndroidBackgroundExecutionGateway(channel: channel);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return switch (call.method) {
        'start' => 'starting',
        'getStatus' => 'running',
        _ => null,
      };
    });
  });
  tearDown(() {
    gateway.dispose();
    debugDefaultTargetPlatformOverride = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('桥接启动、实际状态和设置；原生不接收账号或凭据', () async {
    await gateway.setEnabled(true);
    expect(await gateway.start(), BackgroundExecutionStatus.starting);
    expect(await gateway.getStatus(), BackgroundExecutionStatus.running);
    await gateway.openNotificationSettings();
    await gateway.stop();
    await gateway.setEnabled(false);
    expect(calls.map((call) => call.method), [
      'setEnabled',
      'start',
      'getStatus',
      'openNotificationSettings',
      'stop',
      'setEnabled',
    ]);
    expect(calls.first.arguments, {'enabled': true});
    expect(calls.last.arguments, {'enabled': false});
    expect(
      calls.skip(1).take(4).map((call) => call.arguments),
      everyElement(isNull),
    );
  });

  test('服务事件区分前台、运行、阻止和失败；未知状态失败关闭', () async {
    await gateway.initialize();
    final statuses = <BackgroundExecutionStatus>[];
    final subscription = gateway.statusChanges.listen(statuses.add);
    addTearDown(subscription.cancel);
    for (final status in [
      'starting',
      'running',
      'foreground',
      'blocked',
      'failed',
      'unknown',
      'stopped',
    ]) {
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('statusChanged', status),
        ),
        (_) {},
      );
    }
    await Future<void>.delayed(Duration.zero);
    expect(statuses, [
      BackgroundExecutionStatus.starting,
      BackgroundExecutionStatus.running,
      BackgroundExecutionStatus.foreground,
      BackgroundExecutionStatus.blocked,
      BackgroundExecutionStatus.failed,
      BackgroundExecutionStatus.failed,
      BackgroundExecutionStatus.stopped,
    ]);
  });

  test('非 Android 不调用原生服务', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(gateway.isSupported, isFalse);
    await gateway.setEnabled(true);
    expect(await gateway.start(), BackgroundExecutionStatus.stopped);
    await gateway.stop();
    await gateway.openNotificationSettings();
    expect(calls, isEmpty);
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';

void main() {
  test('本地通知载荷只接受 v1 安全目标并对未知载荷回退失败', () {
    final direct = const BackgroundNotificationPayload.directMessage(
      'conversation / 1',
    );
    final parsed = BackgroundNotificationPayload.tryParse(direct.encode());

    expect(parsed?.location, '/messages/conversation%20%2F%201');
    expect(
      BackgroundNotificationPayload.notification(
        '/threads/thread-1?post=post-1',
      ).location,
      '/threads/thread-1?post=post-1',
    );
    expect(
      BackgroundNotificationPayload.notification('/auth/login').location,
      '/notifications',
    );
    expect(
      BackgroundNotificationPayload.tryParse('{"v":2,"type":"notification"}'),
      isNull,
    );
  });

  test('登录后固定开启并主动请求通知权限', () async {
    final gateway = _FakeGateway(
      notificationsEnabled: false,
      permissionRequestResult: true,
    );
    final controller = BackgroundOnlineController(gateway);
    addTearDown(controller.dispose);
    await _settleLoad(controller);

    await controller.activateForAuthenticatedSession();
    expect(gateway.requestCalls, 1);
    expect(controller.state.permissionDenied, isFalse);
    expect(controller.state.canRun, isTrue);
  });

  test('系统拒绝通知权限时不启动轮询', () async {
    final gateway = _FakeGateway(
      notificationsEnabled: false,
      permissionRequestResult: false,
    );
    final controller = BackgroundOnlineController(gateway);
    addTearDown(controller.dispose);
    await _settleLoad(controller);

    await controller.activateForAuthenticatedSession();
    expect(gateway.requestCalls, 1);
    expect(controller.state.permissionDenied, isTrue);
    expect(controller.state.canRun, isFalse);
  });
}

Future<void> _settleLoad(BackgroundOnlineController controller) async {
  for (var attempt = 0; attempt < 10 && controller.state.isLoading; attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeGateway implements BackgroundNotificationGateway {
  _FakeGateway({
    required this.notificationsEnabled,
    required this.permissionRequestResult,
  });

  bool notificationsEnabled;
  final bool permissionRequestResult;
  int requestCalls = 0;

  @override
  bool get isSupported => true;

  @override
  Stream<String> get notificationTaps => const Stream.empty();

  @override
  Future<bool> canNotify() async => notificationsEnabled;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    requestCalls++;
    notificationsEnabled = permissionRequestResult;
    return permissionRequestResult;
  }

  @override
  Future<void> showAlerts(List<BackgroundLocalAlert> alerts) async {}

  @override
  Future<String?> takeLaunchPayload() async => null;
}

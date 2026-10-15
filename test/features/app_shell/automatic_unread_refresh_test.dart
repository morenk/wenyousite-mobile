import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_recovery.dart';
import 'package:wenyousite_mobile/features/app_shell/application/automatic_unread_refresh.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_unread_controller.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';

void main() {
  test('全部已启用读取成功恢复预算，失败或跳过的分支不冒充成功', () async {
    var elapsed = Duration.zero;
    final recovery = NetworkRecovery(elapsed: () => elapsed);
    final notifications = _Notifications();
    final messages = _Messages();
    final unread = NotificationUnreadController(
      notifications,
      autoStart: false,
    );
    final direct = DirectUnreadController(messages, autoStart: false);
    addTearDown(unread.dispose);
    addTearDown(direct.dispose);
    when(notifications.fetchUnreadCount).thenAnswer((_) async {
      return 1;
    });
    when(
      messages.fetchUnreadCounts,
    ).thenThrow(const ApiFailure(httpStatus: 502));
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    await refreshAutomaticUnreadCounts(recovery, [
      unread.refresh,
      direct.refresh,
    ]);
    verifyNever(notifications.fetchUnreadCount);
    elapsed += recovery.remaining;
    await refreshAutomaticUnreadCounts(recovery, [
      unread.refresh,
      direct.refresh,
    ]);
    expect(direct.state.failure, isNotNull);
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    expect(recovery.remaining.inSeconds, inInclusiveRange(60, 66));
    elapsed += recovery.remaining;
    when(messages.fetchUnreadCounts).thenAnswer(
      (_) async =>
          const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
    );
    final settle = unread.beginRemoval(isUnread: true);
    await refreshAutomaticUnreadCounts(recovery, [
      unread.refresh,
      direct.refresh,
    ]);
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    expect(recovery.remaining.inSeconds, inInclusiveRange(120, 132));
    settle(true);
    await Future<void>.delayed(Duration.zero);
    elapsed += recovery.remaining;
    await refreshAutomaticUnreadCounts(recovery, [
      unread.refresh,
      direct.refresh,
    ]);
    expect(unread.state.failure, isNull);
    expect(direct.state.failure, isNull);
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    expect(recovery.remaining.inSeconds, inInclusiveRange(30, 33));
  });

  test('仅启用通知也能恢复；较早成功或旧账号批次不能清除新失败', () async {
    final recovery = NetworkRecovery();
    final result = Completer<bool>();
    final pending = refreshAutomaticUnreadCounts(recovery, [
      () => result.future,
    ]);
    recovery.resetSession();
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    result.complete(true);
    await pending;
    expect(recovery.isCoolingDown, isTrue);
    recovery.resetSession();
    await refreshAutomaticUnreadCounts(recovery, [() async => true]);
    expect(recovery.isCoolingDown, isFalse);
  });

  test('通知和私聊失效、在途以及迟到读取明确返回非成功', () async {
    final notifications = _Notifications();
    final messages = _Messages();
    final notificationResult = Completer<int>();
    final messageResult = Completer<DirectUnreadCounts>();
    when(
      notifications.fetchUnreadCount,
    ).thenAnswer((_) => notificationResult.future);
    when(messages.fetchUnreadCounts).thenAnswer((_) => messageResult.future);
    final unread = NotificationUnreadController(
      notifications,
      autoStart: false,
    );
    final direct = DirectUnreadController(messages, autoStart: false);
    final notificationPending = unread.refresh();
    final directPending = direct.refresh();
    expect(await unread.refresh(), isFalse);
    expect(await direct.refresh(), isFalse);
    unread.dispose();
    direct.dispose();
    notificationResult.complete(1);
    messageResult.complete(
      const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
    );
    expect(await notificationPending, isFalse);
    expect(await directPending, isFalse);
    expect(await unread.refresh(), isFalse);
    expect(await direct.refresh(), isFalse);
  });
}

class _Notifications extends Mock implements NotificationRepository {}

class _Messages extends Mock implements DirectMessageRepository {}

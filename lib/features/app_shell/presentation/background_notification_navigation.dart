import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/system_notification_read_service.dart';

class BackgroundNotificationNavigation extends ConsumerStatefulWidget {
  const BackgroundNotificationNavigation({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BackgroundNotificationNavigation> createState() =>
      _BackgroundNotificationNavigationState();
}

class _BackgroundNotificationNavigationState
    extends ConsumerState<BackgroundNotificationNavigation> {
  StreamSubscription<String>? _subscription;
  BackgroundNotificationPayload? _pending;
  bool _navigationScheduled = false;
  bool _waitingForLogin = false;
  bool _receivedTap = false;

  @override
  void initState() {
    super.initState();
    final gateway = ref.read(backgroundNotificationGatewayProvider);
    _subscription = gateway.notificationTaps.listen((raw) {
      _receivedTap = true;
      _queuePayload(raw);
    });
    unawaited(_readColdLaunchPayload(gateway));
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(
      sessionControllerProvider.select((state) => state.status),
    );
    if (_pending != null &&
        status != SessionStatus.restoring &&
        (status == SessionStatus.authenticated || !_waitingForLogin)) {
      _scheduleNavigation();
    }
    return widget.child;
  }

  Future<void> _readColdLaunchPayload(
    BackgroundNotificationGateway gateway,
  ) async {
    try {
      final payload = await gateway.takeLaunchPayload();
      if (payload != null && mounted && !_receivedTap) _queuePayload(payload);
    } on Object {
      // Startup remains usable if the operating system cannot report launch
      // notification details.
    }
  }

  void _queuePayload(String raw) {
    if (!mounted) return;
    _waitingForLogin = false;
    _pending =
        BackgroundNotificationPayload.tryParse(raw) ??
        const BackgroundNotificationPayload.messageCenter();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    if (_navigationScheduled) return;
    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      if (mounted) unawaited(_openPending());
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _openPending() async {
    final pending = _pending;
    final session = ref.read(sessionControllerProvider);
    if (pending == null || session.status == SessionStatus.restoring) return;
    if (!session.isAuthenticated) {
      // 保留点击意图，登录恢复后才能确认接收账号并提交单条已读。
      _waitingForLogin = true;
      ref.read(appRouterProvider).go(pending.location);
      return;
    }
    _pending = null;
    _waitingForLogin = false;
    final scope = ref.read(sessionControllerProvider.notifier).scope;
    if (pending.recipientId != null && pending.recipientId != scope.accountId) {
      ref.read(appRouterProvider).go('/notifications');
      return;
    }
    // 跳转不等待未读数或回执网络请求，离线时仍可进入目标页。
    ref.read(appRouterProvider).go(pending.location);
    final notificationId = pending.notificationId;
    if (notificationId != null) {
      unawaited(_markRead(notificationId, scope));
    } else {
      unawaited(
        ref.read(notificationUnreadControllerProvider.notifier).refresh(),
      );
    }
    if (ref.read(directMessagesEnabledProvider)) {
      unawaited(ref.read(directUnreadControllerProvider.notifier).refresh());
    }
  }

  Future<void> _markRead(String id, SessionScope scope) async {
    final service = ref.read(systemNotificationReadServiceProvider);
    final succeeded = await service.markRead(id, scope);
    if (!mounted || !service.isCurrent(scope) || succeeded) return;
    showWenyouSnackBar(
      context,
      '通知未能标为已读，请重试。',
      tone: WenyouSnackBarTone.error,
      actionLabel: '重试',
      onAction: () {
        if (mounted && service.isCurrent(scope)) {
          unawaited(_markRead(id, scope));
        }
      },
    );
  }
}

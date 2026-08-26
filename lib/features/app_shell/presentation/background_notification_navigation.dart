import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';

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

  @override
  void initState() {
    super.initState();
    final gateway = ref.read(backgroundNotificationGatewayProvider);
    _subscription = gateway.notificationTaps.listen(_queuePayload);
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
    if (_pending != null && status != SessionStatus.restoring) {
      _scheduleNavigation();
    }
    return widget.child;
  }

  Future<void> _readColdLaunchPayload(
    BackgroundNotificationGateway gateway,
  ) async {
    try {
      final payload = await gateway.takeLaunchPayload();
      if (payload != null && mounted) _queuePayload(payload);
    } on Object {
      // Startup remains usable if the operating system cannot report launch
      // notification details.
    }
  }

  void _queuePayload(String raw) {
    if (!mounted) return;
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
  }

  Future<void> _openPending() async {
    final pending = _pending;
    final session = ref.read(sessionControllerProvider);
    if (pending == null || session.status == SessionStatus.restoring) return;
    _pending = null;
    if (session.isAuthenticated) {
      final notificationRefresh = ref
          .read(notificationUnreadControllerProvider.notifier)
          .refresh();
      final directRefresh = ref.read(directMessagesEnabledProvider)
          ? ref.read(directUnreadControllerProvider.notifier).refresh()
          : Future<void>.value();
      await Future.wait([notificationRefresh, directRefresh]);
      if (!mounted) return;
    }
    ref.read(appRouterProvider).go(pending.location);
  }
}

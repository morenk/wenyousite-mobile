import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_unread_indicator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold>
    with WidgetsBindingObserver {
  static const _unreadRefreshInterval = Duration(seconds: 30);
  static const _backgroundFastPeriod = Duration(minutes: 10);
  static const _backgroundSlowInterval = Duration(minutes: 2);

  Timer? _unreadTimer;
  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  bool _pollingActive = false;
  bool _pollDirectMessages = false;
  bool _pollingSyncScheduled = false;
  SessionStatus _requestedSessionStatus = SessionStatus.restoring;
  bool _requestedDirectMessages = false;
  bool _requestedBackgroundOnline = false;
  bool _backgroundTransitionPrepared = false;
  bool _activatedAuthenticatedReminder = false;
  DateTime? _backgroundStartedAt;
  int _pollingEpoch = 0;
  late final BackgroundOnlinePoller _backgroundPoller;

  @override
  void initState() {
    super.initState();
    _backgroundPoller = ref.read(backgroundOnlinePollerProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    _backgroundPoller.invalidate();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    final session = ref.read(sessionControllerProvider);
    final messagesEnabled = ref.read(directMessagesEnabledProvider);
    final backgroundOnline = ref
        .read(backgroundOnlineControllerProvider)
        .canRun;
    _syncUnreadPolling(session.status, messagesEnabled, backgroundOnline);
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref
            .read(backgroundOnlineControllerProvider.notifier)
            .refreshPermission(),
      );
    }
    if (state != AppLifecycleState.resumed || !session.isAuthenticated) return;
    if (widget.navigationShell.currentIndex == 2 &&
        ref.exists(notificationListControllerProvider)) {
      ref.read(notificationListControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final session = ref.watch(sessionControllerProvider);
    final notificationUnread = session.isAuthenticated
        ? ref.watch(notificationUnreadControllerProvider).count
        : 0;
    final messagesEnabled = ref.watch(directMessagesEnabledProvider);
    final backgroundOnline = ref.watch(
      backgroundOnlineControllerProvider.select((state) => state.canRun),
    );
    _scheduleUnreadPollingSync(
      session.status,
      messagesEnabled,
      backgroundOnline,
    );
    final directUnread = session.isAuthenticated && messagesEnabled
        ? ref.watch(directUnreadControllerProvider).counts.total
        : 0;
    final unreadCount = notificationUnread + directUnread;
    final shellIndex = widget.navigationShell.currentIndex;
    final navigationIndex = shellIndex < 2 ? shellIndex : shellIndex + 1;
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: WenyouAnchoredActionBubble<String>(
          actions: const [
            WenyouPopoverAction(
              value: AppRouteLocations.composeThread,
              icon: WenyouIconIds.contentArticle,
              label: '主题',
              semanticsLabel: '发布主题',
              key: Key('global-publish-thread'),
            ),
            WenyouPopoverAction(
              value: AppRouteLocations.composeMoment,
              icon: WenyouIconIds.navigationMoments,
              label: '动态',
              semanticsLabel: '发布动态',
              key: Key('global-publish-moment'),
            ),
          ],
          placement: WenyouPopoverPlacement.above,
          alignment: WenyouPopoverAlignment.center,
          semanticLabel: '发布内容',
          onSelected: (location) => context.push(location),
          anchorBuilder: (context, handle) => NavigationBar(
            selectedIndex: navigationIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                handle.toggle();
                return;
              }
              final targetShellIndex = index > 2 ? index - 1 : index;
              widget.navigationShell.goBranch(
                targetShellIndex,
                initialLocation:
                    targetShellIndex == widget.navigationShell.currentIndex,
              );
              if (targetShellIndex == 2 && session.isAuthenticated) {
                ref
                    .read(notificationUnreadControllerProvider.notifier)
                    .refresh();
                if (messagesEnabled) {
                  ref.read(directUnreadControllerProvider.notifier).refresh();
                }
                if (ref.exists(notificationListControllerProvider)) {
                  ref.read(notificationListControllerProvider.notifier).load();
                }
              }
            },
            destinations: [
              const NavigationDestination(
                icon: WenyouIcon(WenyouIconIds.navigationHome),
                selectedIcon: WenyouIcon(WenyouIconIds.navigationHome),
                label: '首页',
              ),
              const NavigationDestination(
                icon: WenyouIcon(WenyouIconIds.navigationMoments),
                selectedIcon: WenyouIcon(WenyouIconIds.navigationMoments),
                label: '动态',
              ),
              const NavigationDestination(
                icon: _PublishNavigationIcon(),
                selectedIcon: _PublishNavigationIcon(),
                label: '发布',
              ),
              NavigationDestination(
                icon: _NotificationNavigationIcon(count: unreadCount),
                selectedIcon: _NotificationNavigationIcon(count: unreadCount),
                label: '消息',
              ),
              const NavigationDestination(
                icon: WenyouIcon(WenyouIconIds.navigationProfile),
                selectedIcon: WenyouIcon(WenyouIconIds.navigationProfile),
                label: '我的',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleUnreadPollingSync(
    SessionStatus sessionStatus,
    bool messagesEnabled,
    bool backgroundOnline,
  ) {
    _requestedSessionStatus = sessionStatus;
    _requestedDirectMessages = messagesEnabled;
    _requestedBackgroundOnline = backgroundOnline;
    if (_pollingSyncScheduled) return;
    _pollingSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pollingSyncScheduled = false;
      if (!mounted) return;
      _syncUnreadPolling(
        _requestedSessionStatus,
        _requestedDirectMessages,
        _requestedBackgroundOnline,
      );
    });
  }

  void _syncUnreadPolling(
    SessionStatus sessionStatus,
    bool messagesEnabled,
    bool backgroundOnline,
  ) {
    if (sessionStatus != SessionStatus.authenticated) {
      _stopAllPolling();
      _activatedAuthenticatedReminder = false;
      return;
    }
    if (_lifecycleState == AppLifecycleState.resumed) {
      if (!_activatedAuthenticatedReminder) {
        _activatedAuthenticatedReminder = true;
        unawaited(
          ref
              .read(backgroundOnlineControllerProvider.notifier)
              .activateForAuthenticatedSession(),
        );
      }
      _enterForegroundPolling(messagesEnabled);
      return;
    }
    if (_lifecycleState == AppLifecycleState.inactive) {
      _prepareBackgroundTransition(
        messagesEnabled: messagesEnabled,
        enabled: backgroundOnline,
      );
      return;
    }
    if (_lifecycleState == AppLifecycleState.hidden ||
        _lifecycleState == AppLifecycleState.paused) {
      _prepareBackgroundTransition(
        messagesEnabled: messagesEnabled,
        enabled: backgroundOnline,
      );
      if (backgroundOnline) {
        _startBackgroundPolling(messagesEnabled);
      } else {
        _stopBackgroundPolling();
      }
      return;
    }
    _stopAllPolling();
  }

  void _enterForegroundPolling(bool messagesEnabled) {
    if (_pollingActive && _pollDirectMessages == messagesEnabled) return;
    _pollingEpoch++;
    _unreadTimer?.cancel();
    _stopBackgroundPolling(invalidate: true);
    _backgroundTransitionPrepared = false;
    _pollingActive = true;
    _pollDirectMessages = messagesEnabled;
    _refreshUnreadCounts();
    _unreadTimer = Timer.periodic(
      _unreadRefreshInterval,
      (_) => _refreshUnreadCounts(),
    );
  }

  void _prepareBackgroundTransition({
    required bool messagesEnabled,
    required bool enabled,
  }) {
    _unreadTimer?.cancel();
    _unreadTimer = null;
    _pollingActive = false;
    _pollDirectMessages = messagesEnabled;
    if (!enabled || _backgroundTransitionPrepared) return;
    _backgroundTransitionPrepared = true;
    _pollingEpoch++;
    final poller = ref.read(backgroundOnlinePollerProvider)..invalidate();
    unawaited(poller.ensureBaseline(includeDirectMessages: messagesEnabled));
  }

  void _startBackgroundPolling(bool messagesEnabled) {
    if (_backgroundStartedAt != null) return;
    final epoch = _pollingEpoch;
    _backgroundStartedAt = DateTime.now();
    unawaited(_prepareBackgroundPolling(epoch, messagesEnabled));
  }

  Future<void> _prepareBackgroundPolling(
    int epoch,
    bool messagesEnabled,
  ) async {
    try {
      if (!await ref.read(backgroundNotificationGatewayProvider).canNotify()) {
        if (mounted && epoch == _pollingEpoch) {
          await ref
              .read(backgroundOnlineControllerProvider.notifier)
              .markPermissionDenied();
        }
        return;
      }
      if (!_isBackgroundEpochCurrent(epoch)) return;
      await ref
          .read(backgroundOnlinePollerProvider)
          .ensureBaseline(includeDirectMessages: messagesEnabled);
      if (_isBackgroundEpochCurrent(epoch)) {
        _scheduleBackgroundPoll(epoch, messagesEnabled);
      }
    } on Object {
      if (_isBackgroundEpochCurrent(epoch)) {
        _scheduleBackgroundPoll(epoch, messagesEnabled);
      }
    }
  }

  void _scheduleBackgroundPoll(int epoch, bool messagesEnabled) {
    _unreadTimer?.cancel();
    if (!_isBackgroundEpochCurrent(epoch)) return;
    final elapsed = DateTime.now().difference(
      _backgroundStartedAt ?? DateTime.now(),
    );
    final interval = elapsed < _backgroundFastPeriod
        ? _unreadRefreshInterval
        : _backgroundSlowInterval;
    _unreadTimer = Timer(
      interval,
      () => unawaited(_runBackgroundPoll(epoch, messagesEnabled)),
    );
  }

  Future<void> _runBackgroundPoll(int epoch, bool messagesEnabled) async {
    if (!_isBackgroundEpochCurrent(epoch)) return;
    try {
      if (!await ref.read(backgroundNotificationGatewayProvider).canNotify()) {
        if (_isBackgroundEpochCurrent(epoch)) {
          await ref
              .read(backgroundOnlineControllerProvider.notifier)
              .markPermissionDenied();
        }
        return;
      }
    } on Object {
      if (_isBackgroundEpochCurrent(epoch)) {
        _scheduleBackgroundPoll(epoch, messagesEnabled);
      }
      return;
    }
    if (!_isBackgroundEpochCurrent(epoch)) return;
    final alerts = await ref
        .read(backgroundOnlinePollerProvider)
        .poll(includeDirectMessages: messagesEnabled);
    if (!_isBackgroundEpochCurrent(epoch)) return;
    try {
      await ref.read(backgroundNotificationGatewayProvider).showAlerts(alerts);
    } on Object {
      // A transient local-notification failure must not create overlapping
      // HTTP polls or silently change the user's saved preference.
    }
    if (_isBackgroundEpochCurrent(epoch)) {
      _scheduleBackgroundPoll(epoch, messagesEnabled);
    }
  }

  bool _isBackgroundEpochCurrent(int epoch) {
    return mounted &&
        epoch == _pollingEpoch &&
        (_lifecycleState == AppLifecycleState.hidden ||
            _lifecycleState == AppLifecycleState.paused) &&
        ref.read(sessionControllerProvider).isAuthenticated &&
        ref.read(backgroundOnlineControllerProvider).canRun;
  }

  void _stopBackgroundPolling({bool invalidate = false}) {
    _unreadTimer?.cancel();
    _unreadTimer = null;
    _backgroundStartedAt = null;
    if (invalidate) ref.read(backgroundOnlinePollerProvider).invalidate();
  }

  void _stopAllPolling() {
    _pollingEpoch++;
    _pollingActive = false;
    _pollDirectMessages = false;
    _backgroundTransitionPrepared = false;
    _stopBackgroundPolling(invalidate: true);
  }

  void _refreshUnreadCounts() {
    unawaited(
      ref.read(notificationUnreadControllerProvider.notifier).refresh(),
    );
    if (_pollDirectMessages) {
      unawaited(ref.read(directUnreadControllerProvider.notifier).refresh());
    }
  }
}

class _PublishNavigationIcon extends StatelessWidget {
  const _PublishNavigationIcon();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '发布内容',
      child: Container(
        key: const Key('global-publish'),
        width: 42,
        height: 36,
        decoration: BoxDecoration(
          color: tokens.actionSurface,
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: WenyouIcon(
          WenyouIconIds.actionAdd,
          color: tokens.onActionSurface,
          size: 26,
        ),
      ),
    );
  }
}

class _NotificationNavigationIcon extends StatelessWidget {
  const _NotificationNavigationIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return WenyouUnreadCountBadge(
      key: const Key('notification-navigation-badge'),
      count: count,
      child: WenyouIcon(WenyouIconIds.navigationMessages),
    );
  }
}

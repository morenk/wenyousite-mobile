import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/background_execution.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_unread_indicator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_reminder_coordinator.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_reminder_runtime.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/notification_permission_guidance.dart';
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

  Timer? _unreadTimer;
  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  bool _pollingActive = false;
  bool _pollDirectMessages = false;
  bool _pollingSyncScheduled = false;
  bool _activatedAuthenticatedReminder = false;
  bool _backgroundOnlineNoticeScheduled = false;
  String? _pendingBackgroundOnlineNotice;
  late final BackgroundOnlineReminderCoordinator _backgroundCoordinator;
  late final BackgroundReminderRuntime _backgroundRuntime;

  @override
  void initState() {
    super.initState();
    _backgroundCoordinator = BackgroundOnlineReminderCoordinator(
      pollingSession: ref.read(backgroundOnlinePollerProvider),
      notificationGateway: ref.read(backgroundNotificationGatewayProvider),
      executionGateway: ref.read(backgroundExecutionGatewayProvider),
      onExecutionUnavailable: (status) async =>
          _handleExecutionUnavailable(status),
      onPermissionDenied: () async {
        if (!mounted) return;
        await ref
            .read(backgroundOnlineControllerProvider.notifier)
            .markPermissionDenied();
      },
      diagnostics: wenyouFieldDiagnosticsEnabled
          ? (stage, fields) {
              DebugDiagnosticBuffer.instance.record(
                'background_online_reminder',
                {'stage': stage, ...fields},
              );
            }
          : null,
    );
    _backgroundRuntime = BackgroundReminderRuntime(
      execution: ref.read(backgroundExecutionGatewayProvider),
      coordinator: _backgroundCoordinator,
      onUnavailable: _handleExecutionUnavailable,
    );
    // 后台可能没有新帧；退出、切号和开关变化必须立即取消旧工作。
    // 直接监听认证源，不能等待派生 Provider 在下一帧重算。
    ref.listenManual(sessionControllerProvider, (previous, next) {
      if (previous?.generation == next.generation &&
          previous?.status == next.status) {
        return;
      }
      _stopAllPolling();
      _activatedAuthenticatedReminder = false;
      _syncCurrentPolling();
    });
    ref.listenManual(backgroundReminderPreferenceProvider, (previous, next) {
      if (previous?.enabled != next.enabled) {
        _activatedAuthenticatedReminder = false;
      }
      _syncCurrentPolling();
    });
    ref.listenManual(backgroundOnlineControllerProvider, (previous, next) {
      _syncCurrentPolling();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    _backgroundRuntime.dispose();
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
      _scheduleBackgroundOnlineNotice();
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
    ref.listen<BackgroundOnlineState>(
      backgroundOnlineControllerProvider,
      _handleBackgroundOnlineState,
    );
    _scheduleUnreadPollingSync();
    final directUnread = session.isAuthenticated && messagesEnabled
        ? ref.watch(directUnreadControllerProvider).counts.total
        : 0;
    final unreadCount = notificationUnread + directUnread;
    final shellIndex = widget.navigationShell.currentIndex;
    final navigationIndex = shellIndex < 2 ? shellIndex : shellIndex + 1;
    return Scaffold(
      body: NotificationPermissionGuidance(child: widget.navigationShell),
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

  void _scheduleUnreadPollingSync() {
    if (_pollingSyncScheduled) return;
    _pollingSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pollingSyncScheduled = false;
      if (!mounted) return;
      _syncCurrentPolling();
    });
  }

  void _syncUnreadPolling(
    SessionStatus sessionStatus,
    bool messagesEnabled,
    bool backgroundOnline,
  ) {
    if (sessionStatus != SessionStatus.authenticated ||
        _lifecycleState == AppLifecycleState.detached) {
      _stopAllPolling();
      _activatedAuthenticatedReminder = false;
      return;
    }
    final preference = ref.read(backgroundReminderPreferenceProvider);
    final enabled =
        backgroundOnline && preference.enabled && !preference.isSaving;
    _backgroundRuntime.synchronize(
      scope: ref.read(sessionControllerProvider.notifier).scope,
      enabled: enabled,
      includeDirectMessages: messagesEnabled,
      visibility: switch (_lifecycleState) {
        AppLifecycleState.resumed => ReminderVisibility.foreground,
        AppLifecycleState.inactive => ReminderVisibility.inactive,
        _ => ReminderVisibility.background,
      },
    );
    if (_lifecycleState == AppLifecycleState.resumed) {
      if (!_activatedAuthenticatedReminder &&
          preference.enabled &&
          !preference.isSaving) {
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
      _pauseForegroundPolling(messagesEnabled);
      return;
    }
    if (_lifecycleState == AppLifecycleState.hidden ||
        _lifecycleState == AppLifecycleState.paused) {
      _pauseForegroundPolling(messagesEnabled);
      return;
    }
    _stopAllPolling();
  }

  void _enterForegroundPolling(bool messagesEnabled) {
    if (_pollingActive && _pollDirectMessages == messagesEnabled) return;
    _unreadTimer?.cancel();
    _pollingActive = true;
    _pollDirectMessages = messagesEnabled;
    _refreshUnreadCounts();
    _unreadTimer = Timer.periodic(
      _unreadRefreshInterval,
      (_) => _refreshUnreadCounts(),
    );
  }

  void _pauseForegroundPolling(bool messagesEnabled) {
    _unreadTimer?.cancel();
    _unreadTimer = null;
    _pollingActive = false;
    _pollDirectMessages = messagesEnabled;
  }

  void _stopAllPolling() {
    _unreadTimer?.cancel();
    _unreadTimer = null;
    _pollingActive = false;
    _pollDirectMessages = false;
    _backgroundRuntime.synchronize(
      scope: null,
      enabled: false,
      includeDirectMessages: false,
      visibility: ReminderVisibility.foreground,
    );
  }

  void _syncCurrentPolling() {
    if (!mounted) return;
    _syncUnreadPolling(
      ref.read(sessionControllerProvider).status,
      ref.read(directMessagesEnabledProvider),
      ref.read(backgroundOnlineControllerProvider).canRun,
    );
  }

  void _handleExecutionUnavailable(BackgroundExecutionStatus status) {
    if (!mounted) return;
    ref
        .read(backgroundOnlineControllerProvider.notifier)
        .markExecutionUnavailable(
          blocked: status == BackgroundExecutionStatus.blocked,
        );
  }

  void _refreshUnreadCounts() {
    unawaited(
      ref.read(notificationUnreadControllerProvider.notifier).refresh(),
    );
    if (_pollDirectMessages) {
      unawaited(ref.read(directUnreadControllerProvider.notifier).refresh());
    }
  }

  void _handleBackgroundOnlineState(
    BackgroundOnlineState? previous,
    BackgroundOnlineState next,
  ) {
    if (!ref.read(sessionControllerProvider).isAuthenticated ||
        !ref.read(backgroundReminderPreferenceProvider).enabled ||
        next.isLoading) {
      return;
    }
    final failureMessage = next.failureMessage;
    if (failureMessage != null && failureMessage != previous?.failureMessage) {
      _queueBackgroundOnlineNotice(failureMessage);
      return;
    }
    // 权限未开由一次性引导和账号设置保留可操作入口，不反复弹短暂提示。
  }

  void _queueBackgroundOnlineNotice(String message) {
    _pendingBackgroundOnlineNotice = message;
    _scheduleBackgroundOnlineNotice();
  }

  void _scheduleBackgroundOnlineNotice() {
    if (_backgroundOnlineNoticeScheduled ||
        _pendingBackgroundOnlineNotice == null ||
        _lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _backgroundOnlineNoticeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backgroundOnlineNoticeScheduled = false;
      if (!mounted || _lifecycleState != AppLifecycleState.resumed) return;
      final message = _pendingBackgroundOnlineNotice;
      if (message == null) return;
      _pendingBackgroundOnlineNotice = null;
      showWenyouSnackBar(
        context,
        message,
        pacing: WenyouSnackBarPacing.extended,
      );
    });
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

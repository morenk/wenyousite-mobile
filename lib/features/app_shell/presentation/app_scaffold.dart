import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_unread_indicator.dart';
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
  bool _requestedPollingAuthentication = false;
  bool _requestedDirectMessages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    final authenticated = ref.read(sessionControllerProvider).isAuthenticated;
    final messagesEnabled = ref.read(directMessagesEnabledProvider);
    _syncUnreadPolling(authenticated, messagesEnabled);
    if (state != AppLifecycleState.resumed || !authenticated) return;
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
    _scheduleUnreadPollingSync(session.isAuthenticated, messagesEnabled);
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
              semanticsLabel: '发布主题帖',
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

  void _scheduleUnreadPollingSync(bool authenticated, bool messagesEnabled) {
    _requestedPollingAuthentication = authenticated;
    _requestedDirectMessages = messagesEnabled;
    if (_pollingSyncScheduled) return;
    _pollingSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pollingSyncScheduled = false;
      if (!mounted) return;
      _syncUnreadPolling(
        _requestedPollingAuthentication,
        _requestedDirectMessages,
      );
    });
  }

  void _syncUnreadPolling(bool authenticated, bool messagesEnabled) {
    final shouldPoll =
        authenticated && _lifecycleState == AppLifecycleState.resumed;
    if (!shouldPoll) {
      _unreadTimer?.cancel();
      _unreadTimer = null;
      _pollingActive = false;
      _pollDirectMessages = false;
      return;
    }
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

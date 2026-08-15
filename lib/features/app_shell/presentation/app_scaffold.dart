import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !ref.read(sessionControllerProvider).isAuthenticated) {
      return;
    }
    ref.read(notificationUnreadControllerProvider.notifier).refresh();
    if (ref.read(directMessagesEnabledProvider)) {
      ref.read(directUnreadControllerProvider.notifier).refresh();
    }
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
        child: NavigationBar(
          selectedIndex: navigationIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              unawaited(_openPublishMenu(context));
              return;
            }
            final targetShellIndex = index > 2 ? index - 1 : index;
            widget.navigationShell.goBranch(
              targetShellIndex,
              initialLocation:
                  targetShellIndex == widget.navigationShell.currentIndex,
            );
            if (targetShellIndex == 2 && session.isAuthenticated) {
              ref.read(notificationUnreadControllerProvider.notifier).refresh();
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
    );
  }

  Future<void> _openPublishMenu(BuildContext context) async {
    final location = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final tokens = context.wenyouTokens;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.space12,
            0,
            tokens.space12,
            tokens.space16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('发布内容', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: tokens.space8),
              ListTile(
                key: const Key('global-publish-thread'),
                minTileHeight: tokens.minimumTouchTarget,
                leading: const WenyouIcon(WenyouIconIds.contentArticle),
                title: const Text('发布主题帖'),
                trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                onTap: () =>
                    Navigator.pop(context, AppRouteLocations.composeThread),
              ),
              ListTile(
                key: const Key('global-publish-moment'),
                minTileHeight: tokens.minimumTouchTarget,
                leading: const WenyouIcon(WenyouIconIds.navigationMoments),
                title: const Text('发布动态'),
                trailing: const WenyouIcon(WenyouIconIds.navigationNext),
                onTap: () =>
                    Navigator.pop(context, AppRouteLocations.composeMoment),
              ),
            ],
          ),
        );
      },
    );
    if (location != null && context.mounted) await context.push(location);
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
          color: tokens.brandSurface,
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: WenyouIcon(
          WenyouIconIds.actionAdd,
          color: tokens.onBrandSurface,
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
    return Badge(
      key: const Key('notification-navigation-badge'),
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      child: WenyouIcon(WenyouIconIds.navigationMessages),
    );
  }
}

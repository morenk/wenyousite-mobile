import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    if (widget.navigationShell.currentIndex == 3 &&
        ref.exists(notificationListControllerProvider)) {
      ref.read(notificationListControllerProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final session = ref.watch(sessionControllerProvider);
    final unreadCount = session.isAuthenticated
        ? ref.watch(notificationUnreadControllerProvider).count
        : 0;
    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: switch (widget.navigationShell.currentIndex) {
        0 => FloatingActionButton(
          onPressed: () => context.push(AppRouteLocations.composeThread),
          tooltip: '创建主题',
          child: const Icon(Icons.edit_rounded),
        ),
        1 => FloatingActionButton(
          onPressed: () => context.push(AppRouteLocations.composeMoment),
          tooltip: '发布动态',
          child: const Icon(Icons.add_rounded),
        ),
        _ => null,
      },
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
            if (index == 3 && session.isAuthenticated) {
              ref.read(notificationUnreadControllerProvider.notifier).refresh();
              if (ref.exists(notificationListControllerProvider)) {
                ref.read(notificationListControllerProvider.notifier).load();
              }
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: '首页',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: '动态',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search_rounded),
              label: '搜索',
            ),
            NavigationDestination(
              icon: _NotificationNavigationIcon(
                count: unreadCount,
                selected: false,
              ),
              selectedIcon: _NotificationNavigationIcon(
                count: unreadCount,
                selected: true,
              ),
              label: '通知',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationNavigationIcon extends StatelessWidget {
  const _NotificationNavigationIcon({
    required this.count,
    required this.selected,
  });

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      key: const Key('notification-navigation-badge'),
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(
        selected
            ? Icons.notifications_rounded
            : Icons.notifications_none_rounded,
      ),
    );
  }
}

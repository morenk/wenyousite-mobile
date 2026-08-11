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
    final notificationUnread = session.isAuthenticated
        ? ref.watch(notificationUnreadControllerProvider).count
        : 0;
    final messagesEnabled = ref.watch(directMessagesEnabledProvider);
    final directUnread = session.isAuthenticated && messagesEnabled
        ? ref.watch(directUnreadControllerProvider).counts.total
        : 0;
    final unreadCount = notificationUnread + directUnread;
    return Scaffold(
      body: widget.navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('global-publish'),
        onPressed: () => _openPublishMenu(context),
        tooltip: '发布内容',
        icon: const Icon(Icons.add_rounded),
        label: const Text('发布'),
      ),
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
              label: '消息',
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

  Future<void> _openPublishMenu(BuildContext context) async {
    final currentIndex = widget.navigationShell.currentIndex;
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
                leading: const Icon(Icons.article_outlined),
                title: const Text('发布主题帖'),
                subtitle: Text(currentIndex == 0 ? '当前频道推荐' : '创建可持续讨论的共同创作主题'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () =>
                    Navigator.pop(context, AppRouteLocations.composeThread),
              ),
              ListTile(
                key: const Key('global-publish-moment'),
                minTileHeight: tokens.minimumTouchTarget,
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('发布动态'),
                subtitle: Text(currentIndex == 1 ? '当前频道推荐' : '分享短文字或最多九张图片'),
                trailing: const Icon(Icons.chevron_right_rounded),
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
            ? Icons.chat_bubble_rounded
            : Icons.chat_bubble_outline_rounded,
      ),
    );
  }
}

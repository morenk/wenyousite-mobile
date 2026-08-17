import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_messages_page.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notifications_page.dart';

abstract final class MessageCenterSections {
  static final String notifications =
      WenyouNavigationContract.messageSections[0];
  static final String directMessages =
      WenyouNavigationContract.messageSections[1];
}

class MessageCenterPage extends ConsumerStatefulWidget {
  const MessageCenterPage({this.requestedSection, super.key});

  final String? requestedSection;

  @override
  ConsumerState<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends ConsumerState<MessageCenterPage> {
  var _canonicalizationScheduled = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) return const _MessageCenterLoginPrompt();

    final messagesEnabled = ref.watch(directMessagesEnabledProvider);
    final selected = _selectedSection(messagesEnabled);
    _canonicalizeIfNeeded(selected);

    final notificationUnread = ref.watch(
      notificationUnreadControllerProvider.select((state) => state.count),
    );
    final directUnread = messagesEnabled
        ? ref.watch(
            directUnreadControllerProvider.select(
              (state) => state.counts.total,
            ),
          )
        : 0;
    final notificationState = selected == MessageCenterSections.notifications
        ? ref.watch(notificationListControllerProvider)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          if (selected == MessageCenterSections.notifications &&
              notificationUnread > 0 &&
              notificationState?.phase == NotificationListPhase.ready)
            TextButton.icon(
              key: const Key('notification-mark-all-read'),
              onPressed: notificationState!.isMutating
                  ? null
                  : _markAllNotificationsRead,
              icon:
                  notificationState.pendingAction ==
                      NotificationPendingAction.markAllRead
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const WenyouIcon(WenyouIconIds.actionMarkRead, size: 19),
              label: const Text('全部已读'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (messagesEnabled)
            _MessageSectionBar(
              selected: selected,
              notificationUnread: notificationUnread,
              directUnread: directUnread,
              onSelected: _replaceSection,
            ),
          Expanded(
            child: selected == MessageCenterSections.directMessages
                ? const DirectMessagesPage(embedded: true)
                : const NotificationSection(),
          ),
        ],
      ),
    );
  }

  String _selectedSection(bool messagesEnabled) {
    if (messagesEnabled &&
        widget.requestedSection == MessageCenterSections.directMessages) {
      return MessageCenterSections.directMessages;
    }
    return MessageCenterSections.notifications;
  }

  void _canonicalizeIfNeeded(String selected) {
    final requested = widget.requestedSection;
    final isCanonical =
        (requested == null &&
            selected == MessageCenterSections.notifications) ||
        requested == selected;
    if (isCanonical || _canonicalizationScheduled) return;
    _canonicalizationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _canonicalizationScheduled = false;
      if (!mounted) return;
      context.replace(AppRouteLocations.messageCenter());
    });
  }

  void _replaceSection(String section) {
    context.replace(
      AppRouteLocations.messageCenter(
        section: section == MessageCenterSections.notifications
            ? null
            : section,
      ),
    );
  }

  Future<void> _markAllNotificationsRead() async {
    final succeeded = await ref
        .read(notificationListControllerProvider.notifier)
        .markAllRead();
    if (!mounted || !succeeded) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已全部标记为已读。')));
  }
}

class _MessageSectionBar extends StatelessWidget {
  const _MessageSectionBar({
    required this.selected,
    required this.notificationUnread,
    required this.directUnread,
    required this.onSelected,
  });

  final String selected;
  final int notificationUnread;
  final int directUnread;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Material(
      color: tokens.panel,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space8,
          tokens.space12,
          tokens.space8,
        ),
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            selected: {selected},
            onSelectionChanged: (values) => onSelected(values.single),
            segments: [
              ButtonSegment(
                value: MessageCenterSections.notifications,
                icon: const WenyouIcon(WenyouIconIds.statusNotifications),
                label: Text(_labelWithCount('通知', notificationUnread)),
              ),
              ButtonSegment(
                value: MessageCenterSections.directMessages,
                icon: const WenyouIcon(WenyouIconIds.navigationMessages),
                label: Text(
                  _labelWithCount(
                    WenyouNavigationContract.labels['directMessages'] ?? '私聊',
                    directUnread,
                  ),
                  key: const Key('notification-open-direct-messages'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCenterLoginPrompt extends StatelessWidget {
  const _MessageCenterLoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.metricComments,
            title: '登录后查看消息',
            message: '',
            action: FilledButton.icon(
              key: const Key('notification-login'),
              onPressed: () => context.pushNamed(
                'login',
                queryParameters: const {'returnTo': '/notifications'},
              ),
              icon: const WenyouIcon(WenyouIconIds.actionLogin),
              label: const Text('去登录'),
            ),
          ),
        ),
      ),
    );
  }
}

String _labelWithCount(String label, int count) {
  if (count <= 0) return label;
  return '$label ${count > 99 ? '99+' : count}';
}

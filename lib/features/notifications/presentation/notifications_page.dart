import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_messages_page.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

enum _MessageSection { notifications, directMessages }

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  var _section = _MessageSection.notifications;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    if (!session.isAuthenticated) {
      return const _NotificationLoginPrompt();
    }

    final state = ref.watch(notificationListControllerProvider);
    final unread = ref.watch(notificationUnreadControllerProvider);
    final messagesEnabled = ref.watch(directMessagesEnabledProvider);
    final directUnread = messagesEnabled
        ? ref.watch(directUnreadControllerProvider).counts.total
        : 0;
    final notifier = ref.read(notificationListControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          if (_section == _MessageSection.notifications &&
              state.phase == NotificationListPhase.ready &&
              state.hasUnread)
            TextButton.icon(
              key: const Key('notification-mark-all-read'),
              onPressed: state.isMutating
                  ? null
                  : () async {
                      final succeeded = await notifier.markAllRead();
                      if (!context.mounted || !succeeded) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已全部标记为已读。')),
                      );
                    },
              icon: state.pendingAction == NotificationPendingAction.markAllRead
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all_rounded, size: 19),
              label: const Text('全部已读'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (messagesEnabled)
            _MessageSectionBar(
              selected: _section,
              notificationUnread: unread.count,
              directUnread: directUnread,
              onSelected: (section) => setState(() => _section = section),
            ),
          Expanded(
            child: _section == _MessageSection.directMessages && messagesEnabled
                ? const DirectMessagesPage(embedded: true)
                : _NotificationSection(
                    state: state,
                    unreadCount: unread.count,
                    notifier: notifier,
                    onRefreshUnread: () => unreadRefresh(ref),
                    onOpen: (item) =>
                        _openNotification(context, notifier, item),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> unreadRefresh(WidgetRef ref) {
    return ref.read(notificationUnreadControllerProvider.notifier).refresh();
  }

  void _openNotification(
    BuildContext context,
    NotificationListController notifier,
    NotificationListItem item,
  ) {
    if (!item.isRead) unawaited(notifier.markRead(item.id));
    final deletedHint = item.target.deletedHint;
    if (deletedHint != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(deletedHint)));
      return;
    }
    switch (item.target.kind) {
      case NotificationTargetKind.post:
        final threadId = item.target.threadId;
        final postId = item.target.postId;
        if (threadId != null && postId != null) {
          context.pushNamed(
            'thread-detail',
            pathParameters: {'threadId': threadId},
            queryParameters: {'post': postId},
          );
        }
        return;
      case NotificationTargetKind.thread:
        final threadId = item.target.threadId;
        if (threadId != null) {
          context.pushNamed(
            'thread-detail',
            pathParameters: {'threadId': threadId},
          );
        }
        return;
      case NotificationTargetKind.user:
        final userId = item.target.userId;
        if (userId != null) {
          context.pushNamed('user-profile', pathParameters: {'userId': userId});
        }
        return;
      case NotificationTargetKind.moment:
        final momentId = item.target.momentId;
        if (momentId != null) {
          context.pushNamed(
            'moment-detail',
            pathParameters: {'momentId': momentId},
          );
        }
        return;
      case NotificationTargetKind.none:
      case NotificationTargetKind.unknown:
        return;
    }
  }
}

class _MessageSectionBar extends StatelessWidget {
  const _MessageSectionBar({
    required this.selected,
    required this.notificationUnread,
    required this.directUnread,
    required this.onSelected,
  });

  final _MessageSection selected;
  final int notificationUnread;
  final int directUnread;
  final ValueChanged<_MessageSection> onSelected;

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
          child: SegmentedButton<_MessageSection>(
            showSelectedIcon: false,
            selected: {selected},
            onSelectionChanged: (values) => onSelected(values.single),
            segments: [
              ButtonSegment(
                value: _MessageSection.notifications,
                icon: const Icon(Icons.notifications_none_rounded),
                label: Text(
                  notificationUnread == 0 ? '通知' : '通知 $notificationUnread',
                ),
              ),
              ButtonSegment(
                value: _MessageSection.directMessages,
                icon: const Icon(Icons.forum_outlined),
                label: Text(
                  directUnread == 0 ? '私信' : '私信 $directUnread',
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

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.state,
    required this.unreadCount,
    required this.notifier,
    required this.onRefreshUnread,
    required this.onOpen,
  });

  final NotificationListState state;
  final int unreadCount;
  final NotificationListController notifier;
  final Future<void> Function() onRefreshUnread;
  final ValueChanged<NotificationListItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NotificationFilterBar(
          selected: state.filter,
          unreadCount: unreadCount,
          isEnabled: !state.isBusy,
          onSelected: notifier.selectFilter,
        ),
        Expanded(
          child: switch (state.phase) {
            NotificationListPhase.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            NotificationListPhase.failed => WenyouPageBody(
              maxWidth: 600,
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: '通知列表没有加载完成',
                  message: state.failure?.userMessage ?? '请稍后重试。',
                  detail: state.failure?.requestId == null
                      ? null
                      : '请求 ID：${state.failure!.requestId}',
                  action: OutlinedButton.icon(
                    key: const Key('notification-list-retry'),
                    onPressed: notifier.load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('重新加载'),
                  ),
                ),
              ),
            ),
            NotificationListPhase.ready => _ReadyNotificationList(
              state: state,
              onRefresh: () async {
                await Future.wait([notifier.load(), onRefreshUnread()]);
              },
              onLoadMore: notifier.loadMore,
              onOpen: onOpen,
              onRemove: (id) async {
                final succeeded = await notifier.remove(id);
                if (!context.mounted || !succeeded) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('通知已删除。')));
              },
              onDismissFailure: notifier.clearActionFailure,
            ),
          },
        ),
      ],
    );
  }
}

class _NotificationLoginPrompt extends StatelessWidget {
  const _NotificationLoginPrompt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: '登录后查看消息',
            message: '通知、私信请求和未读会话会集中显示在这里。',
            action: FilledButton.icon(
              key: const Key('notification-login'),
              onPressed: () => context.pushNamed(
                'login',
                queryParameters: const {'returnTo': '/notifications'},
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('去登录'),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.selected,
    required this.unreadCount,
    required this.isEnabled,
    required this.onSelected,
  });

  final NotificationFilter selected;
  final int unreadCount;
  final bool isEnabled;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space12,
          tokens.space8,
          tokens.space12,
          tokens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (unreadCount > 0) ...[
              Text(
                '$unreadCount 条未读',
                key: const Key('notification-unread-summary'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
              SizedBox(height: tokens.space8),
            ],
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in NotificationFilter.values) ...[
                    ChoiceChip(
                      key: ValueKey('notification-filter-${filter.name}'),
                      label: Text(filter.label),
                      selected: selected == filter,
                      onSelected: isEnabled ? (_) => onSelected(filter) : null,
                    ),
                    if (filter != NotificationFilter.values.last)
                      SizedBox(width: tokens.space8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyNotificationList extends StatelessWidget {
  const _ReadyNotificationList({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onOpen,
    required this.onRemove,
    required this.onDismissFailure,
  });

  final NotificationListState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final ValueChanged<NotificationListItem> onOpen;
  final Future<void> Function(String id) onRemove;
  final VoidCallback onDismissFailure;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width <= 400 ? tokens.space12 : tokens.space24;
    return RefreshIndicator(
      onRefresh: state.isBusy ? () async {} : onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          horizontal,
          tokens.space16,
          horizontal,
          tokens.space32,
        ),
        children: [
          if (state.actionFailure != null) ...[
            _Centered(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.actionFailure!.userMessage,
                detail: state.actionFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.actionFailure!.requestId}',
                action: TextButton(
                  key: const Key('notification-action-error-dismiss'),
                  onPressed: onDismissFailure,
                  child: const Text('知道了'),
                ),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.items.isEmpty)
            _Centered(
              child: WenyouEmptyState(
                icon: Icons.notifications_none_rounded,
                title: state.filter == NotificationFilter.all
                    ? '暂无通知'
                    : '这个分类暂无通知',
                message: state.filter == NotificationFilter.all
                    ? '新的回复、提及、关注等会出现在这里。'
                    : '可以切换其他分类继续查看。',
              ),
            )
          else
            for (var index = 0; index < state.items.length; index++) ...[
              if (index > 0) const Divider(height: 1),
              _Centered(
                child: _NotificationCard(
                  item: state.items[index],
                  isPending: state.pendingId == state.items[index].id,
                  actionsDisabled:
                      state.isMutating &&
                      state.pendingId != state.items[index].id,
                  onOpen: () => onOpen(state.items[index]),
                  onRemove: () => onRemove(state.items[index].id),
                ),
              ),
            ],
          if (state.loadMoreFailure != null) ...[
            SizedBox(height: tokens.space12),
            _Centered(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.loadMoreFailure!.userMessage,
                detail: state.loadMoreFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.loadMoreFailure!.requestId}',
                action: TextButton.icon(
                  key: const Key('notification-load-more-retry'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('重试'),
                ),
              ),
            ),
          ] else if (state.hasMore) ...[
            SizedBox(height: tokens.space12),
            _Centered(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('notification-load-more'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: state.isLoadingMore
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more_rounded),
                  label: Text(state.isLoadingMore ? '正在加载' : '加载更多'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.isPending,
    required this.actionsDisabled,
    required this.onOpen,
    required this.onRemove,
  });

  final NotificationListItem item;
  final bool isPending;
  final bool actionsDisabled;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '${item.isRead ? '已读' : '未读'}通知：${item.displayText}',
      child: Material(
        key: ValueKey('notification-${item.id}'),
        color: item.isRead ? tokens.background : tokens.accentedBackground,
        child: InkWell(
          onTap: actionsDisabled ? null : onOpen,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space4,
              tokens.space12,
              0,
              tokens.space12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationLeading(item: item),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: item.isRead
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                      ),
                      if (item.target.deletedHint != null) ...[
                        SizedBox(height: tokens.space4),
                        Text(
                          item.target.deletedHint!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      SizedBox(height: tokens.space4),
                      Text(
                        _relativeTime(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  Padding(
                    padding: EdgeInsets.only(top: tokens.space8),
                    child: Container(
                      key: ValueKey('notification-unread-${item.id}'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tokens.brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                IconButton(
                  key: ValueKey('notification-remove-${item.id}'),
                  tooltip: '删除通知',
                  onPressed: isPending || actionsDisabled ? null : onRemove,
                  icon: isPending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  const _NotificationLeading({required this.item});

  final NotificationListItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final actor = item.actor;
    final fallback = ColoredBox(
      color: item.isRead ? tokens.softPanel : tokens.panel,
      child: Icon(
        actor == null ? _kindIcon(item.kind) : Icons.person_rounded,
        size: 21,
        color: item.isRead ? tokens.mutedText : tokens.focus,
      ),
    );
    return ClipOval(
      child: SizedBox.square(
        dimension: 40,
        child: actor?.avatarUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: actor!.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: child,
      ),
    );
  }
}

IconData _kindIcon(NotificationKind kind) => switch (kind) {
  NotificationKind.reply => Icons.chat_bubble_outline_rounded,
  NotificationKind.mention => Icons.alternate_email_rounded,
  NotificationKind.newPost => Icons.post_add_rounded,
  NotificationKind.threadCreated => Icons.note_add_outlined,
  NotificationKind.follow => Icons.person_add_alt_rounded,
  NotificationKind.like => Icons.favorite_border_rounded,
  NotificationKind.tip => Icons.redeem_rounded,
  NotificationKind.levelUp => Icons.trending_up_rounded,
  NotificationKind.system => Icons.campaign_outlined,
  NotificationKind.unknown => Icons.notifications_none_rounded,
};

String _relativeTime(DateTime value) {
  final now = DateTime.now();
  final local = value.toLocal();
  final difference = now.difference(local);
  if (difference.isNegative || difference.inMinutes < 1) return '刚刚';
  if (difference.inHours < 1) return '${difference.inMinutes} 分钟前';
  if (difference.inDays < 1) return '${difference.inHours} 小时前';
  if (difference.inDays < 7) return '${difference.inDays} 天前';
  return DateFormat(
    local.year == now.year ? 'MM-dd HH:mm' : 'yyyy-MM-dd',
  ).format(local);
}

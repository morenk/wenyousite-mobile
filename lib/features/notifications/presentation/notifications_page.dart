import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notification_copy.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notification_navigation.dart';

class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationListControllerProvider);
    final notifier = ref.read(notificationListControllerProvider.notifier);
    return Column(
      children: [
        _NotificationFilterBar(
          selected: state.filter,
          isEnabled: !state.isBusy,
          onSelected: notifier.selectFilter,
        ),
        Expanded(
          child: switch (state.phase) {
            NotificationListPhase.loading => const Padding(
              padding: EdgeInsets.all(12),
              child: WenyouListSkeleton(label: '正在加载通知'),
            ),
            NotificationListPhase.failed => _NotificationListFailure(
              state: state,
              onRetry: notifier.load,
            ),
            NotificationListPhase.ready => _ReadyNotificationList(
              state: state,
              onRefresh: () async {
                await Future.wait([
                  notifier.load(),
                  ref
                      .read(notificationUnreadControllerProvider.notifier)
                      .refresh(),
                ]);
              },
              onLoadMore: notifier.loadMore,
              onOpen: (item) => _openNotification(context, notifier, item),
              onRemove: (id) => _confirmRemove(context, notifier, id),
              onDismissFailure: notifier.clearActionFailure,
            ),
          },
        ),
      ],
    );
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
    final location = notificationTargetLocation(item.target);
    if (location != null) unawaited(context.push(location));
  }

  Future<void> _confirmRemove(
    BuildContext context,
    NotificationListController notifier,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除这条通知？'),
        content: const Text('删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('notification-remove-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded = await notifier.remove(id);
    if (!context.mounted || !succeeded) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('通知已删除。')));
  }
}

class _NotificationListFailure extends StatelessWidget {
  const _NotificationListFailure({required this.state, required this.onRetry});

  final NotificationListState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      maxWidth: 600,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.statusOffline,
          title: '通知列表加载失败',
          message: state.failure?.userMessage ?? '请稍后重试。',
          detail: state.failure?.requestId == null
              ? null
              : '问题编号：${state.failure!.requestId}',
          action: OutlinedButton.icon(
            key: const Key('notification-list-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh),
            label: const Text('重新加载'),
          ),
        ),
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.selected,
    required this.isEnabled,
    required this.onSelected,
  });

  final NotificationFilter selected;
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in NotificationFilters.values) ...[
                ChoiceChip(
                  key: ValueKey('notification-filter-${filter.id}'),
                  label: Text(filter.label),
                  selected: selected == filter,
                  onSelected: isEnabled ? (_) => onSelected(filter) : null,
                ),
                if (filter != NotificationFilters.values.last)
                  SizedBox(width: tokens.space8),
              ],
            ],
          ),
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
    final horizontal = wenyouHorizontalPagePadding(context);
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
                    : '问题编号：${state.actionFailure!.requestId}',
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
                icon: WenyouIconIds.statusNotifications,
                title: state.filter == NotificationFilters.all
                    ? '暂无通知'
                    : '这个分类暂无通知',
                message: '',
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
                    : '问题编号：${state.loadMoreFailure!.requestId}',
                action: TextButton.icon(
                  key: const Key('notification-load-more-retry'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
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
                      : const WenyouIcon(WenyouIconIds.navigationExpand),
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
    final copy = formatNotificationCopy(item);
    return Semantics(
      button: true,
      label: '${item.isRead ? '已读' : '未读'}通知：${copy.plainText}',
      child: Material(
        key: ValueKey('notification-${item.id}'),
        color: tokens.background,
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
                  child: _NotificationBody(item: item, copy: copy),
                ),
                if (!item.isRead)
                  Padding(
                    padding: EdgeInsets.only(top: tokens.space8),
                    child: Container(
                      key: ValueKey('notification-unread-${item.id}'),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tokens.brandForeground,
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
                      : const WenyouIcon(WenyouIconIds.actionDelete, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({required this.item, required this.copy});

  final NotificationListItem item;
  final NotificationCopy copy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (copy.isStructured) ...[
          Text.rich(
            TextSpan(
              style: bodyStyle,
              children: [
                TextSpan(
                  text: copy.actorName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' ${copy.actionText}'),
              ],
            ),
          ),
          if (copy.preview != null) ...[
            SizedBox(height: tokens.space4),
            Text(
              copy.preview!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: bodyStyle?.copyWith(color: tokens.mutedText),
            ),
          ],
        ] else
          Text(
            copy.fallbackText,
            style: bodyStyle?.copyWith(
              fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        if (item.target.deletedHint != null) ...[
          SizedBox(height: tokens.space4),
          Text(
            item.target.deletedHint!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: tokens.space4),
        WenyouTimeText(
          value: item.createdAt,
          semanticsPrefix: '通知时间：',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
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
    final notificationFallback = ColoredBox(
      color: item.isRead ? tokens.softPanel : tokens.panel,
      child: WenyouIcon(
        _kindIcon(item.kind),
        size: 21,
        color: item.isRead ? tokens.mutedText : tokens.focus,
      ),
    );
    if (actor == null) {
      return ClipOval(
        child: SizedBox.square(dimension: 40, child: notificationFallback),
      );
    }
    return WenyouAvatar(
      username: actor.username,
      avatarUrl: actor.avatarUrl,
      size: 40,
      fallbackBackgroundColor: item.isRead ? tokens.softPanel : tokens.panel,
      fallbackForegroundColor: item.isRead ? tokens.mutedText : tokens.focus,
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => WenyouConstrainedWidth(child: child);
}

String _kindIcon(NotificationKind kind) => switch (kind) {
  NotificationKind.reply => WenyouIconIds.metricComments,
  NotificationKind.mention => WenyouIconIds.actionMention,
  NotificationKind.newPost => WenyouIconIds.actionAddComment,
  NotificationKind.threadCreated => WenyouIconIds.contentThread,
  NotificationKind.follow => WenyouIconIds.actionFollow,
  NotificationKind.like => WenyouIconIds.actionLike,
  NotificationKind.tip => WenyouIconIds.actionRedeem,
  NotificationKind.levelUp => WenyouIconIds.statusTrending,
  NotificationKind.system => WenyouIconIds.contentAnnouncement,
  NotificationKind.unknown => WenyouIconIds.statusNotifications,
};

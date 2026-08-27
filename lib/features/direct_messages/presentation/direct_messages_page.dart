import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_page_failure_state.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_unread_indicator.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_message_widgets.dart';

class DirectMessagesPage extends ConsumerStatefulWidget {
  const DirectMessagesPage({this.embedded = false, super.key});

  final bool embedded;

  @override
  ConsumerState<DirectMessagesPage> createState() => _DirectMessagesPageState();
}

class _DirectMessagesPageState extends ConsumerState<DirectMessagesPage> {
  var _view = DirectConversationView.inbox;

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(directMessagesEnabledProvider);
    if (!enabled) return const _DirectMessagesUnavailablePage();
    final provider = directConversationListControllerProvider(_view);
    final state = ref.watch(provider);
    final unread = ref.watch(directUnreadControllerProvider).counts;
    final notifier = ref.read(provider.notifier);
    final body = Column(
      children: [
        _DirectMessageViewBar(
          selected: _view,
          unread: unread,
          enabled: !state.isLoadingMore && !state.isRefreshing,
          onSelected: (view) => setState(() => _view = view),
        ),
        Expanded(
          child: switch (state.phase) {
            DirectConversationListPhase.loading => const Padding(
              padding: EdgeInsets.all(12),
              child: WenyouListSkeleton(label: '正在加载私聊会话'),
            ),
            DirectConversationListPhase.failed => _DirectListFailure(
              state: state,
              onRetry: notifier.load,
            ),
            DirectConversationListPhase.ready => _DirectConversationList(
              state: state,
              onRefresh: () async {
                await Future.wait([
                  notifier.refresh(),
                  ref.read(directUnreadControllerProvider.notifier).refresh(),
                ]);
              },
              onOpen: (conversation) =>
                  _openConversation(context, notifier, conversation),
              onLoadMore: notifier.loadMore,
            ),
          },
        ),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('私聊')),
      body: body,
    );
  }

  Future<void> _openConversation(
    BuildContext context,
    DirectConversationListController notifier,
    DirectConversation conversation,
  ) async {
    await context.pushNamed(
      'direct-conversation',
      pathParameters: {'conversationId': conversation.id},
    );
    if (!context.mounted) return;
    await Future.wait([
      notifier.refresh(),
      ref.read(directUnreadControllerProvider.notifier).refresh(),
    ]);
  }
}

class _DirectMessageViewBar extends StatelessWidget {
  const _DirectMessageViewBar({
    required this.selected,
    required this.unread,
    required this.enabled,
    required this.onSelected,
  });

  final DirectConversationView selected;
  final DirectUnreadCounts unread;
  final bool enabled;
  final ValueChanged<DirectConversationView> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wenyouHorizontalPagePadding(context),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: WenyouDropdownFilter<DirectConversationView>(
          key: const Key('direct-message-view-menu'),
          optionKeyPrefix: 'direct-message-view',
          tooltip: '切换私聊列表',
          icon: WenyouIconIds.actionFilter,
          appearance: WenyouDropdownFilterAppearance.quiet,
          enabled: enabled,
          selectedLabel: unread.pendingRequests > 0
              ? '${selected.label} · 请求 ${unread.pendingRequests}'
              : selected.label,
          options: [
            for (final view in DirectConversationView.values)
              WenyouFilterOption(
                value: view,
                keyValue: view.name,
                label:
                    view == DirectConversationView.requests &&
                        unread.pendingRequests > 0
                    ? '${view.label} ${unread.pendingRequests}'
                    : view.label,
              ),
          ],
          selected: selected,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class _DirectConversationList extends StatelessWidget {
  const _DirectConversationList({
    required this.state,
    required this.onRefresh,
    required this.onOpen,
    required this.onLoadMore,
  });

  final DirectConversationListState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<DirectConversation> onOpen;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: _pagePadding(context),
          children: [
            WenyouEmptyState(
              icon: state.view == DirectConversationView.archived
                  ? WenyouIconIds.statusArchived
                  : state.view == DirectConversationView.requests
                  ? WenyouIconIds.actionMarkUnread
                  : WenyouIconIds.navigationMessages,
              title: switch (state.view) {
                DirectConversationView.inbox => '暂无私聊会话',
                DirectConversationView.requests => '暂无消息请求',
                DirectConversationView.archived => '暂无归档会话',
              },
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        addAutomaticKeepAlives: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _pagePadding(context),
        itemCount: state.items.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index < state.items.length) {
            final item = state.items[index];
            return _DirectConversationCard(
              conversation: item,
              onTap: () => onOpen(item),
            );
          }
          return WenyouPaginationFooter(
            hasMore: state.hasMore,
            isLoading: state.isLoadingMore,
            failure: state.transientFailure,
            onLoadMore: onLoadMore,
            loadMoreKey: const Key('direct-messages-load-more'),
            retryKey: const Key('direct-messages-load-more-retry'),
            endLabel: '已经看到全部会话',
          );
        },
      ),
    );
  }
}

class _DirectConversationCard extends StatelessWidget {
  const _DirectConversationCard({
    required this.conversation,
    required this.onTap,
  });

  final DirectConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final unread = conversation.unreadCount > 0;
    final previewStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: unread ? tokens.text : tokens.mutedText,
      fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
    );
    return Semantics(
      button: true,
      label:
          '打开与 ${conversation.otherUser.username} 的私聊'
          '${unread ? '，${conversation.unreadCount} 条未读' : ''}',
      child: Material(
        key: ValueKey('direct-conversation-${conversation.id}'),
        color: tokens.background,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.space12),
            child: Row(
              children: [
                DirectMessageAvatar(user: conversation.otherUser),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.otherUser.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: unread
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                          if (conversation.lastMessageAt != null) ...[
                            SizedBox(width: tokens.space8),
                            WenyouTimeText(
                              value: conversation.lastMessageAt!,
                              semanticsPrefix: '最后消息时间：',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: tokens.mutedText),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: tokens.space4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage?.displayText ?? '暂无消息',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: previewStyle,
                            ),
                          ),
                          if (conversation.unreadCount > 0) ...[
                            SizedBox(width: tokens.space8),
                            WenyouUnreadCountBadge(
                              key: ValueKey(
                                'direct-conversation-unread-${conversation.id}',
                              ),
                              count: conversation.unreadCount,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectListFailure extends StatelessWidget {
  const _DirectListFailure({required this.state, required this.onRetry});

  final DirectConversationListState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageFailureState(
      title: '私聊会话加载失败',
      failure: state.failure,
      onRetry: onRetry,
      maxWidth: 600,
      retryKey: const Key('direct-messages-retry'),
    );
  }
}

class _DirectMessagesUnavailablePage extends StatelessWidget {
  const _DirectMessagesUnavailablePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('私聊')),
      body: const WenyouPageBody(
        maxWidth: 600,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: WenyouIconIds.navigationMessages,
            title: '私聊功能当前未开放',
          ),
        ),
      ),
    );
  }
}

EdgeInsets _pagePadding(BuildContext context) {
  final tokens = context.wenyouTokens;
  final horizontal = wenyouHorizontalPagePadding(context);
  return EdgeInsets.fromLTRB(
    horizontal,
    tokens.space12,
    horizontal,
    tokens.space32,
  );
}

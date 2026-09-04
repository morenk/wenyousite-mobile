import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_thread_feed_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/users/application/public_user_controller.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

class PublicUserContentArea extends ConsumerWidget {
  const PublicUserContentArea({
    required this.userId,
    required this.state,
    super.key,
  });

  final String userId;
  final PublicUserState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final notifier = ref.read(publicUserControllerProvider(userId).notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouPanel(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WenyouSectionHeader(title: '公开内容'),
              SizedBox(height: tokens.space12),
              WenyouContentTabs<PublicUserContentTab>(
                key: const Key('public-user-content-tabs'),
                keyPrefix: 'public-user',
                semanticsLabel: '用户公开内容',
                placement: WenyouTabPlacement.embedded,
                options: [
                  for (final tab in state.availableTabs)
                    WenyouFilterOption(
                      value: tab,
                      label: tab.label,
                      keyValue: '${tab.name}-tab',
                    ),
                ],
                selected: state.activeTab,
                onSelected: notifier.selectTab,
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        PublicUserContentSectionView(
          tab: state.activeTab,
          state: state,
          onRetry: notifier.retryActive,
          onLoadMore: notifier.loadMoreActive,
        ),
      ],
    );
  }
}

class PublicUserContentSectionView extends StatelessWidget {
  const PublicUserContentSectionView({
    required this.tab,
    required this.state,
    required this.onRetry,
    required this.onLoadMore,
    this.isSelf = false,
    super.key,
  });

  final PublicUserContentTab tab;
  final PublicUserState state;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      PublicUserContentTab.created => _ThreadSection(
        tab: tab,
        section: state.created,
        onRetry: onRetry,
        onLoadMore: onLoadMore,
        isSelf: isSelf,
      ),
      PublicUserContentTab.played => _ThreadSection(
        tab: tab,
        section: state.played,
        onRetry: onRetry,
        onLoadMore: onLoadMore,
        isSelf: isSelf,
      ),
      PublicUserContentTab.replies => _ReplySection(
        section: state.replies,
        onRetry: onRetry,
        isSelf: isSelf,
      ),
      PublicUserContentTab.bookmarks => _ThreadSection(
        tab: tab,
        section: state.bookmarks,
        onRetry: onRetry,
        onLoadMore: onLoadMore,
        isSelf: isSelf,
      ),
    };
  }
}

class _ThreadSection extends StatelessWidget {
  const _ThreadSection({
    required this.tab,
    required this.section,
    required this.onRetry,
    required this.onLoadMore,
    this.isSelf = false,
  });

  final PublicUserContentTab tab;
  final PublicUserContentSection<PublicUserThreadModel> section;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    if (section.phase == PublicUserContentPhase.idle ||
        section.phase == PublicUserContentPhase.loading) {
      return const _ContentLoadingState();
    }
    if (section.phase == PublicUserContentPhase.failed) {
      return _ContentFailureState(
        tab: tab,
        failure: section.failure,
        onRetry: onRetry,
        isSelf: isSelf,
      );
    }
    if (section.items.isEmpty) {
      return _ContentEmptyState(tab: tab);
    }
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < section.items.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          ThreadFeedCard(
            key: Key('user-thread-${section.items[index].id}'),
            thread: section.items[index],
            category: null,
            onTap: () => context.pushNamed(
              'thread-detail',
              pathParameters: {'threadId': section.items[index].id},
            ),
            onTagTap: (tag) => context.pushNamed(
              'tag-threads',
              pathParameters: {'tagId': tag.id},
            ),
          ),
        ],
        if (section.failure != null) ...[
          SizedBox(height: tokens.space12),
          _ContentInlineFailure(failure: section.failure!, onRetry: onLoadMore),
        ],
        if (section.hasMore && section.failure == null) ...[
          SizedBox(height: tokens.space12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: Key('public-user-${tab.name}-load-more'),
              onPressed: section.isLoadingMore ? null : onLoadMore,
              icon: section.isLoadingMore
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const WenyouIcon(WenyouIconIds.navigationExpand),
              label: Text(section.isLoadingMore ? '正在加载' : '加载更多'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReplySection extends StatelessWidget {
  const _ReplySection({
    required this.section,
    required this.onRetry,
    this.isSelf = false,
  });

  final PublicUserContentSection<PublicUserReplyModel> section;
  final VoidCallback onRetry;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    if (section.phase == PublicUserContentPhase.idle ||
        section.phase == PublicUserContentPhase.loading) {
      return const _ContentLoadingState();
    }
    if (section.phase == PublicUserContentPhase.failed) {
      return _ContentFailureState(
        tab: PublicUserContentTab.replies,
        failure: section.failure,
        onRetry: onRetry,
        isSelf: isSelf,
      );
    }
    if (section.items.isEmpty) {
      return const _ContentEmptyState(tab: PublicUserContentTab.replies);
    }
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < section.items.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          _UserReplyCard(item: section.items[index]),
        ],
      ],
    );
  }
}

class _UserReplyCard extends StatelessWidget {
  const _UserReplyCard({required this.item});

  final PublicUserReplyModel item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final location = AppRouteLocations.thread(item.threadId, postId: item.id);
    return Semantics(
      button: true,
      label: '打开 ${item.threadTitle} 中的最近回复',
      child: WenyouPanel(
        onTap: () => context.push(location),
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.threadTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.wenyouCompactTitle,
                  ),
                ),
                SizedBox(width: tokens.space8),
                _ContentPill(label: _replyKind(item)),
              ],
            ),
            SizedBox(height: tokens.space8),
            Text(
              item.preview.isEmpty ? '该回复没有可显示的文字预览' : item.preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tokens.space8),
            Text(
              '${item.subthreadTitle} · '
              '${DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt)}',
              style: Theme.of(context).textTheme.wenyouCaption,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentPill extends StatelessWidget {
  const _ContentPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
        ),
      ),
    );
  }
}

class _ContentLoadingState extends StatelessWidget {
  const _ContentLoadingState();

  @override
  Widget build(BuildContext context) {
    return const WenyouListSkeleton(label: '正在加载公开内容', itemCount: 2);
  }
}

class _ContentEmptyState extends StatelessWidget {
  const _ContentEmptyState({required this.tab});

  final PublicUserContentTab tab;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      child: WenyouEmptyState(icon: _emptyIcon(tab), title: _emptyTitle(tab)),
    );
  }
}

class _ContentFailureState extends StatelessWidget {
  const _ContentFailureState({
    required this.tab,
    required this.failure,
    required this.onRetry,
    this.isSelf = false,
  });

  final PublicUserContentTab tab;
  final ApiFailure? failure;
  final VoidCallback onRetry;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final hidden = failure?.httpStatus == 404;
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: hidden ? WenyouIconIds.actionHide : WenyouIconIds.statusOffline,
        title: hidden && !isSelf
            ? '该用户未公开${tab.description}'
            : '${tab.description}加载失败',
        message: hidden && !isSelf
            ? '隐私设置可能刚刚发生变化。'
            : (failure?.userMessage ?? '请稍后重试。'),
        detail: wenyouFailureDetail(failure),
        action: OutlinedButton.icon(
          key: Key('public-user-${tab.name}-retry'),
          onPressed: onRetry,
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
          label: const Text('重新加载'),
        ),
      ),
    );
  }
}

class _ContentInlineFailure extends StatelessWidget {
  const _ContentInlineFailure({required this.failure, required this.onRetry});

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: failure.userMessage,
      detail: wenyouFailureDetail(failure),
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
        label: const Text('重试加载更多'),
      ),
    );
  }
}

String _replyKind(PublicUserReplyModel item) {
  if (item.parentPostId != null) return '楼中楼';
  if (item.floorNumber != null) return '#${item.floorNumber}';
  return '正文';
}

String _emptyTitle(PublicUserContentTab tab) => switch (tab) {
  PublicUserContentTab.created => '还没有创建过主题',
  PublicUserContentTab.played => '还没有参与过主题',
  PublicUserContentTab.replies => '还没有发布过回复',
  PublicUserContentTab.bookmarks => '还没有公开收藏',
};

String _emptyIcon(PublicUserContentTab tab) => switch (tab) {
  PublicUserContentTab.created => WenyouIconIds.contentThread,
  PublicUserContentTab.played => WenyouIconIds.metricPlayers,
  PublicUserContentTab.replies => WenyouIconIds.metricComments,
  PublicUserContentTab.bookmarks => WenyouIconIds.actionBookmark,
};

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
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
      children: [
        WenyouPanel(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WenyouSectionHeader(
                title: '公开内容',
                subtitle: state.activeTab.description,
              ),
              SizedBox(height: tokens.space12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<PublicUserContentTab>(
                  showSelectedIcon: false,
                  selected: {state.activeTab},
                  onSelectionChanged: (selection) {
                    notifier.selectTab(selection.single);
                  },
                  segments: [
                    for (final tab in state.availableTabs)
                      ButtonSegment(value: tab, label: Text(tab.label)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space12),
        switch (state.activeTab) {
          PublicUserContentTab.created => _ThreadSection(
            tab: state.activeTab,
            section: state.created,
            onRetry: notifier.retryActive,
            onLoadMore: notifier.loadMoreActive,
          ),
          PublicUserContentTab.played => _ThreadSection(
            tab: state.activeTab,
            section: state.played,
            onRetry: notifier.retryActive,
            onLoadMore: notifier.loadMoreActive,
          ),
          PublicUserContentTab.replies => _ReplySection(
            section: state.replies,
            onRetry: notifier.retryActive,
          ),
          PublicUserContentTab.bookmarks => _ThreadSection(
            tab: state.activeTab,
            section: state.bookmarks,
            onRetry: notifier.retryActive,
            onLoadMore: notifier.loadMoreActive,
          ),
        },
      ],
    );
  }
}

class _ThreadSection extends StatelessWidget {
  const _ThreadSection({
    required this.tab,
    required this.section,
    required this.onRetry,
    required this.onLoadMore,
  });

  final PublicUserContentTab tab;
  final PublicUserContentSection<PublicUserThreadModel> section;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

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
      );
    }
    if (section.items.isEmpty) {
      return _ContentEmptyState(tab: tab);
    }
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        for (var index = 0; index < section.items.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          _UserThreadCard(item: section.items[index]),
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
                  : const Icon(Icons.expand_more_rounded),
              label: Text(section.isLoadingMore ? '正在加载' : '加载更多'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReplySection extends StatelessWidget {
  const _ReplySection({required this.section, required this.onRetry});

  final PublicUserContentSection<PublicUserReplyModel> section;
  final VoidCallback onRetry;

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
      );
    }
    if (section.items.isEmpty) {
      return const _ContentEmptyState(tab: PublicUserContentTab.replies);
    }
    final tokens = context.wenyouTokens;
    return Column(
      children: [
        for (var index = 0; index < section.items.length; index++) ...[
          if (index > 0) SizedBox(height: tokens.space12),
          _UserReplyCard(item: section.items[index]),
        ],
      ],
    );
  }
}

class _UserThreadCard extends StatelessWidget {
  const _UserThreadCard({required this.item});

  final PublicUserThreadModel item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '打开主题 ${item.title}',
      child: WenyouPanel(
        onTap: () => context.pushNamed(
          'thread-detail',
          pathParameters: {'threadId': item.id},
          extra: item.categorySlug,
        ),
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                if (item.categorySlug != null)
                  _ContentPill(label: item.categorySlug!),
                _ContentPill(
                  label: _statusLabel(item.status),
                  accent: item.status == PublicUserThreadStatus.recruiting,
                ),
                if (item.isPrivate)
                  const _ContentPill(label: '私密', icon: Icons.lock_outline),
              ],
            ),
            SizedBox(height: tokens.space12),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.space8),
            Text(
              '${item.ownerName} · Lv.${item.ownerLevel} · '
              '${DateFormat('yyyy-MM-dd').format(item.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: tokens.space4),
            Text(
              '${item.memberCount} 成员 · ${item.postCount} 条内容',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserReplyCard extends StatelessWidget {
  const _UserReplyCard({required this.item});

  final PublicUserReplyModel item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final location = Uri(
      path: '/threads/${item.threadId}',
      queryParameters: {'post': item.id},
    ).toString();
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
                    style: Theme.of(context).textTheme.titleSmall,
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentPill extends StatelessWidget {
  const _ContentPill({required this.label, this.icon, this.accent = false});

  final String label;
  final IconData? icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = accent ? tokens.brand : tokens.mutedText;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              SizedBox(width: tokens.space4),
            ],
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentLoadingState extends StatelessWidget {
  const _ContentLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: tokens.space12),
          const Text('正在加载公开内容…'),
        ],
      ),
    );
  }
}

class _ContentEmptyState extends StatelessWidget {
  const _ContentEmptyState({required this.tab});

  final PublicUserContentTab tab;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: _emptyIcon(tab),
        title: _emptyTitle(tab),
        message: '这里只展示服务端允许公开的内容。',
      ),
    );
  }
}

class _ContentFailureState extends StatelessWidget {
  const _ContentFailureState({
    required this.tab,
    required this.failure,
    required this.onRetry,
  });

  final PublicUserContentTab tab;
  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hidden = failure?.httpStatus == 404;
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: hidden ? Icons.visibility_off_outlined : Icons.cloud_off_outlined,
        title: hidden ? '该用户未公开${tab.description}' : '${tab.description}没有加载完成',
        message: hidden ? '隐私设置可能刚刚发生变化。' : (failure?.userMessage ?? '请稍后重试。'),
        detail: failure?.requestId == null
            ? null
            : '请求 ID：${failure!.requestId}',
        action: OutlinedButton.icon(
          key: Key('public-user-${tab.name}-retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
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
      detail: failure.requestId == null ? null : '请求 ID：${failure.requestId}',
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('重试加载更多'),
      ),
    );
  }
}

String _statusLabel(PublicUserThreadStatus status) => switch (status) {
  PublicUserThreadStatus.recruiting => '招募中',
  PublicUserThreadStatus.closed => '已关闭',
  PublicUserThreadStatus.finished => '已完结',
  PublicUserThreadStatus.unknown => '状态未知',
};

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

IconData _emptyIcon(PublicUserContentTab tab) => switch (tab) {
  PublicUserContentTab.created => Icons.forum_outlined,
  PublicUserContentTab.played => Icons.sports_esports_outlined,
  PublicUserContentTab.replies => Icons.chat_bubble_outline_rounded,
  PublicUserContentTab.bookmarks => Icons.bookmark_border_rounded,
};

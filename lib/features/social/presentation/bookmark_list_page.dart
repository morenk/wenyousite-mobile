import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/application/bookmark_list_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

class BookmarkListPage extends ConsumerWidget {
  const BookmarkListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkListControllerProvider);
    final notifier = ref.read(bookmarkListControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: switch (state.phase) {
        BookmarkListPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        BookmarkListPhase.failed => WenyouPageBody(
          maxWidth: 600,
          child: WenyouPanel(
            child: WenyouEmptyState(
              icon: Icons.cloud_off_outlined,
              title: '收藏列表没有加载完成',
              message: state.failure?.userMessage ?? '请稍后重试。',
              detail: state.failure?.requestId == null
                  ? null
                  : '请求 ID：${state.failure!.requestId}',
              action: OutlinedButton.icon(
                key: const Key('bookmark-list-retry'),
                onPressed: notifier.load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重新加载'),
              ),
            ),
          ),
        ),
        BookmarkListPhase.ready => _ReadyBookmarkList(
          state: state,
          onRefresh: notifier.load,
          onLoadMore: notifier.loadMore,
          onRemove: (bookmarkId) async {
            final succeeded = await notifier.removeBookmark(bookmarkId);
            if (!context.mounted || !succeeded) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('已取消收藏。')));
          },
          onDismissFailure: notifier.clearActionFailure,
        ),
      },
    );
  }
}

class _ReadyBookmarkList extends StatelessWidget {
  const _ReadyBookmarkList({
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRemove,
    required this.onDismissFailure,
  });

  final BookmarkListState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final Future<void> Function(String bookmarkId) onRemove;
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
            _CenteredContent(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.actionFailure!.userMessage,
                detail: state.actionFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.actionFailure!.requestId}',
                action: TextButton(
                  key: const Key('bookmark-list-error-dismiss'),
                  onPressed: onDismissFailure,
                  child: const Text('知道了'),
                ),
              ),
            ),
            SizedBox(height: tokens.space12),
          ],
          if (state.items.isEmpty)
            const _CenteredContent(
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: '还没有收藏',
                  message: '在主题详情页点击收藏后，会出现在这里。',
                ),
              ),
            )
          else
            for (var index = 0; index < state.items.length; index++) ...[
              if (index > 0) SizedBox(height: tokens.space12),
              _CenteredContent(
                child: _BookmarkCard(
                  item: state.items[index],
                  isPending:
                      state.pendingBookmarkId == state.items[index].bookmarkId,
                  disableRemove:
                      state.isBusy &&
                      state.pendingBookmarkId != state.items[index].bookmarkId,
                  onRemove: () => onRemove(state.items[index].bookmarkId),
                ),
              ),
            ],
          if (state.loadMoreFailure != null) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: state.loadMoreFailure!.userMessage,
                detail: state.loadMoreFailure!.requestId == null
                    ? null
                    : '请求 ID：${state.loadMoreFailure!.requestId}',
                action: TextButton.icon(
                  key: const Key('bookmark-list-load-more-retry'),
                  onPressed: state.isBusy ? null : onLoadMore,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('重试'),
                ),
              ),
            ),
          ] else if (state.hasMore) ...[
            SizedBox(height: tokens.space12),
            _CenteredContent(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('bookmark-list-load-more'),
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

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.item,
    required this.isPending,
    required this.disableRemove,
    required this.onRemove,
  });

  final BookmarkListItem item;
  final bool isPending;
  final bool disableRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      label: '打开收藏主题 ${item.title}',
      child: WenyouPanel(
        key: ValueKey('bookmark-thread-${item.threadId}'),
        onTap: () => context.pushNamed(
          'thread-detail',
          pathParameters: {'threadId': item.threadId},
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
                  _BookmarkPill(label: item.categorySlug!),
                _BookmarkPill(
                  label: _statusLabel(item.status),
                  accent: item.status == BookmarkedThreadStatus.recruiting,
                ),
                if (item.isPinned)
                  const _BookmarkPill(
                    label: '置顶',
                    icon: Icons.push_pin_outlined,
                  ),
                if (item.isPrivate)
                  const _BookmarkPill(
                    label: '私密',
                    icon: Icons.lock_outline_rounded,
                  ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.ownerName} · Lv.${item.ownerLevel} · ${DateFormat('yyyy-MM-dd').format(item.createdAt)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                  ),
                ),
                SizedBox(width: tokens.space8),
                IconButton(
                  key: ValueKey('bookmark-remove-${item.bookmarkId}'),
                  tooltip: '取消收藏',
                  onPressed: isPending || disableRemove ? null : onRemove,
                  icon: isPending
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_remove_outlined),
                ),
              ],
            ),
            SizedBox(height: tokens.space4),
            Text(
              '${item.memberCount} 成员 · ${item.postCount} 条内容 · ${item.tipTotal}L',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkPill extends StatelessWidget {
  const _BookmarkPill({required this.label, this.icon, this.accent = false});

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

class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WenyouConstrainedWidth(child: child);
  }
}

String _statusLabel(BookmarkedThreadStatus status) => switch (status) {
  BookmarkedThreadStatus.recruiting => '招募中',
  BookmarkedThreadStatus.closed => '已关闭',
  BookmarkedThreadStatus.finished => '已完结',
  BookmarkedThreadStatus.unknown => '状态未知',
};

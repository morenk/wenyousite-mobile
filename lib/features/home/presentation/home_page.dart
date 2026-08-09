import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/home/application/home_feed_controller.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMoreNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 480) {
      return;
    }
    ref.read(homeFeedControllerProvider.notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeFeedControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('温油站')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(homeFeedControllerProvider.notifier).refresh(),
        child: CustomScrollView(
          key: const PageStorageKey('home-feed-scroll'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _buildSlivers(context, state),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context, HomeFeedState state) {
    if (state.phase == HomeFeedPhase.loading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _HomeCenteredState(child: _HomeLoadingState()),
        ),
      ];
    }
    if (state.phase == HomeFeedPhase.failed) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _HomeCenteredState(
            child: _HomeErrorState(
              failure: state.failure,
              onRetry: () =>
                  ref.read(homeFeedControllerProvider.notifier).loadInitial(),
            ),
          ),
        ),
      ];
    }

    final categoryNames = {
      for (final category in state.categories) category.slug: category.name,
    };
    return [
      SliverToBoxAdapter(
        child: _HomeContent(
          top: 16,
          child: _HomeFilters(
            state: state,
            onCategorySelected: (slug) => ref
                .read(homeFeedControllerProvider.notifier)
                .selectCategory(slug),
            onSortSelected: (sort) =>
                ref.read(homeFeedControllerProvider.notifier).selectSort(sort),
            onStatusSelected: (status) => ref
                .read(homeFeedControllerProvider.notifier)
                .selectStatus(status),
          ),
        ),
      ),
      if (state.transientFailure != null)
        SliverToBoxAdapter(
          child: _HomeContent(
            top: 12,
            child: _HomeTransientError(
              failure: state.transientFailure!,
              onRetry:
                  state.transientRetryAction == HomeFeedRetryAction.loadMore
                  ? () =>
                        ref.read(homeFeedControllerProvider.notifier).loadMore()
                  : () =>
                        ref.read(homeFeedControllerProvider.notifier).refresh(),
            ),
          ),
        ),
      if (state.items.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _HomeCenteredState(
            topPadding: 12,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: Icons.forum_outlined,
                title: '这里还没有公开主题',
                message: '可以换一个分类或状态，也可以下拉刷新看看。',
                action: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(homeFeedControllerProvider.notifier)
                      .clearFilters(),
                  icon: const Icon(Icons.filter_alt_off_rounded),
                  label: const Text('查看全部主题'),
                ),
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final thread = state.items[index];
            return _HomeContent(
              top: 12,
              child: HomeThreadCard(
                key: Key('home-thread-${thread.id}'),
                thread: thread,
                categoryName:
                    categoryNames[thread.categorySlug] ?? thread.categorySlug,
                onTap: () => context.pushNamed(
                  'thread-detail',
                  pathParameters: {'threadId': thread.id},
                  extra:
                      categoryNames[thread.categorySlug] ?? thread.categorySlug,
                ),
              ),
            );
          }, childCount: state.items.length),
        ),
      if (state.items.isNotEmpty)
        SliverToBoxAdapter(
          child: _HomeContent(
            top: 12,
            bottom: 112,
            child: _HomeFeedFooter(
              state: state,
              onLoadMore: () =>
                  ref.read(homeFeedControllerProvider.notifier).loadMore(),
            ),
          ),
        ),
    ];
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.child, this.top = 0, this.bottom = 0});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}

class _HomeCenteredState extends StatelessWidget {
  const _HomeCenteredState({required this.child, this.topPadding = 16});

  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: _HomeContent(top: topPadding, bottom: 112, child: child),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: tokens.space16),
          Text('正在整理推荐主题', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.space8),
          Text(
            '分类和主题列表会一起加载。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPanel(
      child: WenyouEmptyState(
        icon: Icons.cloud_off_rounded,
        title: '主题列表没有加载完成',
        message: failure?.userMessage ?? '请检查网络后重试。',
        detail: failure?.requestId == null
            ? null
            : '请求 ID：${failure!.requestId}',
        action: FilledButton.icon(
          key: const Key('home-retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('重新加载'),
        ),
      ),
    );
  }
}

class _HomeTransientError extends StatelessWidget {
  const _HomeTransientError({required this.failure, required this.onRetry});

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      message: failure.userMessage,
      detail: failure.requestId == null ? null : '请求 ID：${failure.requestId}',
      tone: WenyouStatusTone.error,
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('重试'),
      ),
    );
  }
}

class _HomeFilters extends StatelessWidget {
  const _HomeFilters({
    required this.state,
    required this.onCategorySelected,
    required this.onSortSelected,
    required this.onStatusSelected,
  });

  final HomeFeedState state;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<HomeFeedSort> onSortSelected;
  final ValueChanged<HomeThreadStatusFilter> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WenyouSectionHeader(
            title: '发现主题',
            subtitle: '按分类、状态和活跃度找到想加入的故事。',
          ),
          SizedBox(height: tokens.space16),
          Semantics(
            label: '主题分类筛选',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    key: const Key('home-category-all'),
                    label: const Text('全部'),
                    selected: state.query.categorySlug == null,
                    onSelected: (_) => onCategorySelected(null),
                  ),
                  for (final category in state.categories) ...[
                    SizedBox(width: tokens.space8),
                    Tooltip(
                      message: category.description ?? category.name,
                      child: ChoiceChip(
                        key: Key('home-category-${category.slug}'),
                        label: Text(category.name),
                        selected: state.query.categorySlug == category.slug,
                        onSelected: (_) => onCategorySelected(category.slug),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space8,
            children: [
              _HomeFilterMenu<HomeFeedSort>(
                key: const Key('home-sort-menu'),
                icon: Icons.swap_vert_rounded,
                label: state.query.sort.label,
                tooltip: '选择主题排序',
                values: HomeFeedSort.values,
                selected: state.query.sort,
                labelFor: (value) => value.label,
                onSelected: onSortSelected,
              ),
              _HomeFilterMenu<HomeThreadStatusFilter>(
                key: const Key('home-status-menu'),
                icon: Icons.tune_rounded,
                label: state.query.status.label,
                tooltip: '选择主题状态',
                values: HomeThreadStatusFilter.values,
                selected: state.query.status,
                labelFor: (value) => value.label,
                onSelected: onStatusSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeFilterMenu<T> extends StatelessWidget {
  const _HomeFilterMenu({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
    super.key,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return PopupMenuButton<T>(
      initialValue: selected,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final value in values)
          PopupMenuItem(
            value: value,
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: value == selected
                      ? Icon(Icons.check_rounded, size: 20, color: tokens.brand)
                      : null,
                ),
                SizedBox(width: tokens.space8),
                Text(labelFor(value)),
              ],
            ),
          ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.softPanel,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(tokens.radius16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                SizedBox(width: tokens.space8),
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                SizedBox(width: tokens.space4),
                const Icon(Icons.arrow_drop_down_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeThreadCard extends StatelessWidget {
  const HomeThreadCard({
    required this.thread,
    required this.categoryName,
    required this.onTap,
    super.key,
  });

  final HomeThreadCardModel thread;
  final String? categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      button: true,
      label: '打开主题：${thread.title}，作者 ${thread.ownerName}',
      child: WenyouPanel(
        onTap: onTap,
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThreadAuthor(thread: thread),
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                if (thread.isPinned)
                  const _ThreadPill(
                    icon: Icons.push_pin_rounded,
                    label: '置顶',
                    accent: true,
                  ),
                if (categoryName != null)
                  _ThreadPill(
                    icon: Icons.folder_open_rounded,
                    label: categoryName!,
                  ),
                _ThreadPill(
                  icon: _statusIcon(thread.status),
                  label: thread.status.label,
                  accent: thread.status == HomeThreadStatus.recruiting,
                ),
              ],
            ),
            SizedBox(height: tokens.space8),
            Text(thread.title, style: Theme.of(context).textTheme.titleLarge),
            if (thread.preview != null) ...[
              SizedBox(height: tokens.space8),
              Text(
                thread.preview!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (thread.coverImageUrls.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              _ThreadCoverGrid(urls: thread.coverImageUrls),
            ],
            if (thread.tags.isNotEmpty) ...[
              SizedBox(height: tokens.space12),
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space4,
                children: [
                  for (final tag in thread.tags.take(4))
                    _ThreadPill(icon: Icons.tag_rounded, label: tag.name),
                ],
              ),
            ],
            SizedBox(height: tokens.space12),
            Divider(color: tokens.border),
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space16,
              runSpacing: tokens.space8,
              children: [
                _ThreadStat(
                  icon: Icons.people_outline_rounded,
                  label: '${thread.memberCount} 成员',
                ),
                _ThreadStat(
                  icon: Icons.theater_comedy_outlined,
                  label: '${thread.playerCount} 玩家',
                ),
                _ThreadStat(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${thread.postCount} 回复',
                ),
                if (thread.tipTotal != '0')
                  _ThreadStat(
                    icon: Icons.local_gas_station_outlined,
                    label: '${thread.tipTotal}L 加油',
                    accent: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _statusIcon(HomeThreadStatus status) {
    return switch (status) {
      HomeThreadStatus.recruiting => Icons.group_add_outlined,
      HomeThreadStatus.closed => Icons.lock_outline_rounded,
      HomeThreadStatus.finished => Icons.check_circle_outline_rounded,
      HomeThreadStatus.unknown => Icons.help_outline_rounded,
    };
  }
}

class _ThreadAuthor extends StatelessWidget {
  const _ThreadAuthor({required this.thread});

  final HomeThreadCardModel thread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      children: [
        _ThreadAvatar(url: thread.ownerAvatarUrl, username: thread.ownerName),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                thread.ownerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space4),
              Text(
                'Lv.${thread.ownerLevel} · ${_relativeTime(thread.lastActivityAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.url, required this.username});

  final String? url;
  final String username;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return Semantics(
      image: true,
      label: '$username 的头像',
      child: ClipOval(
        child: SizedBox.square(
          dimension: 44,
          child: url == null
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => fallback,
                  errorWidget: (_, _, _) => fallback,
                ),
        ),
      ),
    );
  }
}

class _ThreadCoverGrid extends StatelessWidget {
  const _ThreadCoverGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radius12),
      child: AspectRatio(
        aspectRatio: urls.length == 1 ? 16 / 9 : 2.2,
        child: Row(
          children: [
            for (var index = 0; index < urls.length; index++) ...[
              if (index > 0) SizedBox(width: tokens.space4),
              Expanded(child: _ThreadCover(url: urls[index])),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThreadCover extends StatelessWidget {
  const _ThreadCover({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final placeholder = ColoredBox(
      color: tokens.softPanel,
      child: Center(child: Icon(Icons.image_outlined, color: tokens.mutedText)),
    );
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => Semantics(
        label: '图片加载失败',
        child: ColoredBox(
          color: tokens.softPanel,
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: tokens.mutedText),
          ),
        ),
      ),
    );
  }
}

class _ThreadPill extends StatelessWidget {
  const _ThreadPill({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: tokens.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: accent ? tokens.brand : tokens.mutedText,
            ),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ThreadStat extends StatelessWidget {
  const _ThreadStat({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = accent ? tokens.brand : tokens.mutedText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: tokens.space4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _HomeFeedFooter extends StatelessWidget {
  const _HomeFeedFooter({required this.state, required this.onLoadMore});

  final HomeFeedState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (!state.hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space12),
        child: Text(
          '已经看到全部公开主题',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return OutlinedButton.icon(
      key: const Key('home-load-more'),
      onPressed: state.isLoadingMore ? null : onLoadMore,
      icon: state.isLoadingMore
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.expand_more_rounded),
      label: Text(state.isLoadingMore ? '正在加载更多' : '加载更多主题'),
    );
  }
}

String _relativeTime(DateTime value) {
  final difference = DateTime.now().difference(value.toLocal());
  if (difference.isNegative || difference.inMinutes < 1) return '刚刚活跃';
  if (difference.inHours < 1) return '${difference.inMinutes} 分钟前活跃';
  if (difference.inDays < 1) return '${difference.inHours} 小时前活跃';
  if (difference.inDays < 30) return '${difference.inDays} 天前活跃';
  return '${value.toLocal().month} 月 ${value.toLocal().day} 日活跃';
}

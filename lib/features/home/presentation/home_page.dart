import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/home/application/home_feed_controller.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_feed_card.dart';

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
      appBar: AppBar(
        title: const Text('温油站'),
        actions: [
          IconButton(
            key: const Key('home-open-search'),
            onPressed: () => context.pushNamed('search'),
            tooltip: '搜索',
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
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
              top: index == 0 ? 12 : 0,
              child: Column(
                children: [
                  if (index > 0)
                    Divider(
                      key: Key('home-thread-divider-${thread.id}'),
                      height: 1,
                    ),
                  HomeThreadCard(
                    key: Key('home-thread-${thread.id}'),
                    thread: thread,
                    categoryName:
                        categoryNames[thread.categorySlug] ??
                        thread.categorySlug,
                    onTap: () => context.pushNamed(
                      'thread-detail',
                      pathParameters: {'threadId': thread.id},
                      extra:
                          categoryNames[thread.categorySlug] ??
                          thread.categorySlug,
                    ),
                    onTagTap: (tag) => context.pushNamed(
                      'tag-threads',
                      pathParameters: {'tagId': tag.id},
                    ),
                  ),
                ],
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
      child: WenyouConstrainedWidth(child: child),
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
    const allCategories = '__all_categories__';
    final tokens = context.wenyouTokens;
    final categoryLabels = <String, String>{
      allCategories: '全部分类',
      for (final category in state.categories) category.slug: category.name,
    };
    final selectedCategory = state.query.categorySlug ?? allCategories;
    return Row(
      children: [
        Expanded(
          flex: 12,
          child: _HomeFilterMenu<String>(
            key: const Key('home-category-menu'),
            label: categoryLabels[selectedCategory] ?? selectedCategory,
            tooltip: '选择主题分类',
            values: categoryLabels.keys.toList(growable: false),
            selected: selectedCategory,
            labelFor: (value) => categoryLabels[value] ?? value,
            active: selectedCategory != allCategories,
            onSelected: (value) =>
                onCategorySelected(value == allCategories ? null : value),
          ),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          flex: 10,
          child: _HomeFilterMenu<HomeFeedSort>(
            key: const Key('home-sort-menu'),
            label: state.query.sort.label,
            tooltip: '选择主题排序',
            values: HomeFeedSort.values,
            selected: state.query.sort,
            labelFor: (value) => value.label,
            onSelected: onSortSelected,
          ),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          flex: 11,
          child: _HomeFilterMenu<HomeThreadStatusFilter>(
            key: const Key('home-status-menu'),
            label: state.query.status.label,
            tooltip: '选择主题状态',
            values: HomeThreadStatusFilter.values,
            selected: state.query.status,
            labelFor: (value) => value.label,
            active: state.query.status != HomeThreadStatusFilter.all,
            onSelected: onStatusSelected,
          ),
        ),
      ],
    );
  }
}

class _HomeFilterMenu<T> extends StatelessWidget {
  const _HomeFilterMenu({
    required this.label,
    required this.tooltip,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
    this.active = false,
    super.key,
  });

  final String label;
  final String tooltip;
  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return PopupMenuButton<T>(
      initialValue: selected,
      tooltip: tooltip,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      offset: Offset(0, tokens.space4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius16),
        side: BorderSide(color: tokens.border),
      ),
      constraints: const BoxConstraints(minWidth: 152, maxWidth: 260),
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
          color: active ? tokens.accentedBackground : tokens.softPanel,
          border: Border.all(
            color: active
                ? tokens.brand.withValues(alpha: 0.42)
                : tokens.border,
          ),
          borderRadius: BorderRadius.circular(tokens.radius12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: active ? tokens.brand : null,
                    ),
                  ),
                ),
                SizedBox(width: tokens.space4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: active ? tokens.brand : tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
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
            icon: const WenyouIcon(WenyouIconIds.actionSearch),
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
      if (state.transientFailure != null)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
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
                icon: WenyouIconIds.contentThread,
                title: '暂无公开主题',
                message: '可以换一个分类或状态，也可以下拉刷新看看。',
                action: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(homeFeedControllerProvider.notifier)
                      .clearFilters(),
                  icon: const WenyouIcon(WenyouIconIds.actionClearFilter),
                  label: const Text('查看全部主题'),
                ),
              ),
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final thread = state.items[index];
              return WenyouContentFrame(
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
                        categoryNames[thread.categorySlug] ??
                        thread.categorySlug,
                  ),
                  onTagTap: (tag) => context.pushNamed(
                    'tag-threads',
                    pathParameters: {'tagId': tag.id},
                  ),
                ),
              );
            },
            childCount: state.items.length,
            addAutomaticKeepAlives: false,
          ),
        ),
      if (state.items.isNotEmpty)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
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

class _HomeCenteredState extends StatelessWidget {
  const _HomeCenteredState({required this.child, this.topPadding = 16});

  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: WenyouContentFrame(top: topPadding, bottom: 112, child: child),
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const WenyouListSkeleton(label: '正在加载推荐主题', itemCount: 2);
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
        icon: WenyouIconIds.statusOffline,
        title: '主题列表加载失败',
        message: failure?.userMessage ?? '请检查网络后重试。',
        detail: failure?.requestId == null
            ? null
            : '问题编号：${failure!.requestId}',
        action: FilledButton.icon(
          key: const Key('home-retry'),
          onPressed: onRetry,
          icon: const WenyouIcon(WenyouIconIds.actionRefresh),
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
      detail: failure.requestId == null ? null : '问题编号：${failure.requestId}',
      tone: WenyouStatusTone.error,
      action: TextButton.icon(
        onPressed: onRetry,
        icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WenyouContentTabs<String>(
          key: const Key('home-category-menu'),
          keyPrefix: 'home-category',
          semanticsLabel: '主题帖分类',
          placement: WenyouTabPlacement.page,
          options: [
            for (final entry in categoryLabels.entries)
              WenyouFilterOption(
                value: entry.key,
                label: entry.value,
                keyValue: entry.key,
              ),
          ],
          selected: selectedCategory,
          onSelected: (value) =>
              onCategorySelected(value == allCategories ? null : value),
        ),
        WenyouContentFrame(
          top: tokens.space8,
          child: Row(
            children: [
              Expanded(
                child: WenyouDropdownFilter<HomeFeedSort>(
                  key: const Key('home-sort-menu'),
                  tooltip: '选择主题排序',
                  icon: WenyouIconIds.actionSort,
                  options: [
                    for (final value in HomeFeedSort.values)
                      WenyouFilterOption(value: value, label: value.label),
                  ],
                  selected: state.query.sort,
                  onSelected: onSortSelected,
                ),
              ),
              SizedBox(width: tokens.space8),
              Expanded(
                child: WenyouDropdownFilter<HomeThreadStatusFilter>(
                  key: const Key('home-status-menu'),
                  tooltip: '选择主题状态',
                  icon: WenyouIconIds.actionFilter,
                  options: [
                    for (final value in HomeThreadStatusFilter.values)
                      WenyouFilterOption(value: value, label: value.label),
                  ],
                  selected: state.query.status,
                  onSelected: onStatusSelected,
                ),
              ),
            ],
          ),
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
          : const WenyouIcon(WenyouIconIds.navigationExpand),
      label: Text(state.isLoadingMore ? '正在加载更多' : '加载更多主题'),
    );
  }
}

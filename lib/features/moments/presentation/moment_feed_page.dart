import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_card.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';

class MomentFeedPage extends ConsumerStatefulWidget {
  const MomentFeedPage({super.key});

  @override
  ConsumerState<MomentFeedPage> createState() => _MomentFeedPageState();
}

class _MomentFeedPageState extends ConsumerState<MomentFeedPage> {
  var _mode = MomentFeedMode.discover;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态'),
        actions: [
          IconButton(
            key: const Key('moment-open-bookmarks'),
            onPressed: () => session.isAuthenticated
                ? context.pushNamed('moment-bookmarks')
                : _openLogin(context, '/moments/bookmarks'),
            tooltip: '动态收藏',
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          MomentContentPadding(
            top: context.wenyouTokens.space12,
            bottom: context.wenyouTokens.space12,
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<MomentFeedMode>(
                segments: const [
                  ButtonSegment(
                    value: MomentFeedMode.discover,
                    icon: Icon(Icons.explore_outlined),
                    label: Text('发现'),
                  ),
                  ButtonSegment(
                    value: MomentFeedMode.following,
                    icon: Icon(Icons.people_outline_rounded),
                    label: Text('关注'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.single);
                },
              ),
            ),
          ),
          Expanded(
            child: _mode == MomentFeedMode.following && !session.isAuthenticated
                ? _FollowingLoginState(
                    onLogin: () => _openLogin(context, '/moments'),
                  )
                : MomentFeedList(
                    key: ValueKey(_mode),
                    target: MomentFeedTarget.main(_mode),
                    emptyTitle: _mode == MomentFeedMode.discover
                        ? '还没有公开动态'
                        : '关注动态暂时为空',
                    emptyMessage: _mode == MomentFeedMode.discover
                        ? '下拉刷新看看，也可以发布第一条动态。'
                        : '关注更多用户后，他们的新动态会出现在这里。',
                  ),
          ),
        ],
      ),
    );
  }
}

class MomentCollectionPage extends StatelessWidget {
  const MomentCollectionPage({
    required this.target,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    super.key,
  });

  final MomentFeedTarget target;
  final String title;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: MomentFeedList(
        target: target,
        emptyTitle: emptyTitle,
        emptyMessage: emptyMessage,
      ),
    );
  }
}

class MomentFeedList extends ConsumerStatefulWidget {
  const MomentFeedList({
    required this.target,
    required this.emptyTitle,
    required this.emptyMessage,
    super.key,
  });

  final MomentFeedTarget target;
  final String emptyTitle;
  final String emptyMessage;

  @override
  ConsumerState<MomentFeedList> createState() => _MomentFeedListState();
}

class _MomentFeedListState extends ConsumerState<MomentFeedList> {
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
    ref.read(momentFeedControllerProvider(widget.target).notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final provider = momentFeedControllerProvider(widget.target);
    final state = ref.watch(provider);
    ref.listen(provider.select((value) => value.transientFailure), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.userMessage)));
      }
    });
    return Semantics(
      container: true,
      label: '动态瀑布流',
      child: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: CustomScrollView(
          key: PageStorageKey('moment-feed-${widget.target.hashCode}'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _slivers(context, state, provider),
        ),
      ),
    );
  }

  List<Widget> _slivers(
    BuildContext context,
    MomentFeedState state,
    AutoDisposeStateNotifierProvider<MomentFeedController, MomentFeedState>
    provider,
  ) {
    if (state.phase == MomentLoadPhase.loading) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            _feedHorizontalPadding(context),
            context.wenyouTokens.space4,
            _feedHorizontalPadding(context),
            context.wenyouTokens.space24,
          ),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: context.wenyouTokens.space12,
            crossAxisSpacing: context.wenyouTokens.space12,
            childCount: 4,
            itemBuilder: (context, index) =>
                _MomentWaterfallSkeletonCard(index: index),
          ),
        ),
      ];
    }
    if (state.phase == MomentLoadPhase.failed) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MomentContentPadding(
            top: 16,
            bottom: 80,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: Icons.cloud_off_outlined,
                title: '动态列表没有加载完成',
                message: state.failure?.userMessage ?? '请稍后重试。',
                detail: state.failure?.requestId == null
                    ? null
                    : '请求 ID：${state.failure!.requestId}',
                action: OutlinedButton.icon(
                  key: const Key('moment-feed-retry'),
                  onPressed: () => ref.read(provider.notifier).loadInitial(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新加载'),
                ),
              ),
            ),
          ),
        ),
      ];
    }
    if (state.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: MomentContentPadding(
            top: 16,
            bottom: 80,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: Icons.auto_awesome_outlined,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _feedHorizontalPadding(context),
          context.wenyouTokens.space4,
          _feedHorizontalPadding(context),
          0,
        ),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: context.wenyouTokens.space12,
          crossAxisSpacing: context.wenyouTokens.space12,
          childCount: state.items.length,
          itemBuilder: (context, index) {
            final moment = state.items[index];
            return MomentWaterfallCard(
              key: Key('moment-card-${moment.id}'),
              moment: moment,
              busy: state.busyMomentIds.contains(moment.id),
              onTap: () => context.pushNamed(
                'moment-detail',
                pathParameters: {'momentId': moment.id},
              ),
              onAuthorTap: () => context.pushNamed(
                'user-profile',
                pathParameters: {'userId': moment.author.id},
              ),
              onLike: () => _authenticatedAction(
                context,
                () => ref.read(provider.notifier).toggleLike(moment),
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: MomentContentPadding(
          top: 12,
          bottom: 112,
          child: Center(
            child: state.isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  )
                : state.hasMore
                ? OutlinedButton.icon(
                    key: const Key('moment-load-more'),
                    onPressed: () => ref.read(provider.notifier).loadMore(),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('加载更多'),
                  )
                : Text('已经看到这里了', style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ),
    ];
  }

  double _feedHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final basePadding = width <= 400
        ? context.wenyouTokens.space12
        : context.wenyouTokens.space24;
    final availableWidth = width - basePadding * 2;
    final contentWidth = availableWidth < 600 ? availableWidth : 600.0;
    return (width - contentWidth) / 2;
  }

  void _authenticatedAction(BuildContext context, VoidCallback action) {
    if (ref.read(sessionControllerProvider).isAuthenticated) {
      action();
      return;
    }
    _openLogin(context, GoRouterState.of(context).uri.toString());
  }
}

class _MomentWaterfallSkeletonCard extends StatelessWidget {
  const _MomentWaterfallSkeletonCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '正在加载动态',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.panel,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: index.isEven ? 3 / 4 : 1,
                  child: ColoredBox(color: tokens.softPanel),
                ),
                Padding(
                  padding: EdgeInsets.all(tokens.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: index.isEven ? 0.82 : 0.68,
                        child: _SkeletonLine(
                          color: tokens.softPanel,
                          height: 14,
                        ),
                      ),
                      SizedBox(height: tokens.space12),
                      FractionallySizedBox(
                        widthFactor: 0.58,
                        child: _SkeletonLine(
                          color: tokens.softPanel,
                          height: 12,
                        ),
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

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.wenyouTokens.radiusPill),
      ),
    );
  }
}

class _FollowingLoginState extends StatelessWidget {
  const _FollowingLoginState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return MomentContentPadding(
      top: 16,
      bottom: 80,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: Icons.people_outline_rounded,
          title: '登录后查看关注动态',
          message: '这里会按时间展示你关注用户发布的动态。',
          action: FilledButton.icon(
            key: const Key('moment-following-login'),
            onPressed: onLogin,
            icon: const Icon(Icons.login_rounded),
            label: const Text('去登录'),
          ),
        ),
      ),
    );
  }
}

void _openLogin(BuildContext context, String returnTo) {
  context.push(AppRouteLocations.login(returnTo: returnTo));
}

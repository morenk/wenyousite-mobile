import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_filter_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_nested_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_pagination.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_card.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_waterfall_sliver.dart';

class MomentFeedPage extends ConsumerStatefulWidget {
  const MomentFeedPage({super.key});

  @override
  ConsumerState<MomentFeedPage> createState() => _MomentFeedPageState();
}

class _MomentFeedPageState extends ConsumerState<MomentFeedPage> {
  var _mode = MomentFeedMode.discover;
  final _visitedModes = <MomentFeedMode>{MomentFeedMode.discover};

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    return Scaffold(
      backgroundColor: wenyouBrowsePageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouBrowsePageBackground(context),
        title: const Text('动态'),
        actions: [
          IconButton(
            key: const Key('moment-open-search'),
            onPressed: () => context.pushNamed('search'),
            tooltip: '搜索',
            icon: const WenyouIcon(WenyouIconIds.actionSearch),
          ),
        ],
      ),
      body: Column(
        children: [
          WenyouContentTabs<MomentFeedMode>(
            key: const Key('moment-feed-filter'),
            keyPrefix: 'moment-feed',
            semanticsLabel: '动态信息流',
            placement: WenyouTabPlacement.page,
            options: const [
              WenyouFilterOption(
                value: MomentFeedMode.discover,
                label: '发现',
                keyValue: 'discover',
              ),
              WenyouFilterOption(
                value: MomentFeedMode.following,
                label: '关注',
                keyValue: 'following',
              ),
            ],
            selected: _mode,
            onSelected: _selectMode,
          ),
          Expanded(
            child: WenyouSwipeTabRegion<MomentFeedMode>(
              key: const Key('moment-feed-swipe'),
              values: MomentFeedMode.values,
              selected: _mode,
              onSelected: _selectMode,
              child: IndexedStack(
                index: MomentFeedMode.values.indexOf(_mode),
                children: [
                  for (final mode in MomentFeedMode.values)
                    _visitedModes.contains(mode)
                        ? _buildModeContent(
                            mode,
                            isAuthenticated: session.isAuthenticated,
                          )
                        : const SizedBox.expand(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectMode(MomentFeedMode mode) {
    if (_mode == mode) return;
    setState(() {
      _visitedModes.add(mode);
      _mode = mode;
    });
  }

  Widget _buildModeContent(
    MomentFeedMode mode, {
    required bool isAuthenticated,
  }) {
    if (mode == MomentFeedMode.following && !isAuthenticated) {
      return _FollowingLoginState(
        onLogin: () => _openLogin(context, '/moments'),
      );
    }
    return MomentFeedList(
      key: ValueKey(mode),
      target: MomentFeedTarget.main(mode),
      emptyTitle: mode == MomentFeedMode.discover ? '还没有公开动态' : '关注动态暂时为空',
      emptyMessage: '',
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
      backgroundColor: wenyouBrowsePageBackground(context),
      appBar: AppBar(
        backgroundColor: wenyouBrowsePageBackground(context),
        title: Text(title),
      ),
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
    this.pullToRefreshEnabled = true,
    super.key,
  });

  final MomentFeedTarget target;
  final String emptyTitle;
  final String emptyMessage;
  final bool pullToRefreshEnabled;

  @override
  ConsumerState<MomentFeedList> createState() => _MomentFeedListState();
}

class _MomentFeedListState extends ConsumerState<MomentFeedList> {
  bool _loadMoreNearEnd(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical ||
        !wenyouShouldPrefetch(notification.metrics) ||
        (notification is! ScrollUpdateNotification &&
            notification is! OverscrollNotification)) {
      return false;
    }
    ref.read(momentFeedControllerProvider(widget.target).notifier).loadMore();
    return false;
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
        showWenyouSnackBar(
          context,
          next.userMessage,
          tone: WenyouSnackBarTone.error,
          pacing: WenyouSnackBarPacing.extended,
        );
      }
    });
    final scrollView = NotificationListener<ScrollNotification>(
      onNotification: _loadMoreNearEnd,
      child: CustomScrollView(
        key: PageStorageKey('moment-feed-${widget.target.hashCode}'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const WenyouNestedScrollInset(),
          ..._slivers(context, state, provider),
        ],
      ),
    );
    return Semantics(
      container: true,
      label: '动态瀑布流',
      child: widget.pullToRefreshEnabled
          ? RefreshIndicator(
              onRefresh: () => ref.read(provider.notifier).refresh(),
              child: scrollView,
            )
          : scrollView,
    );
  }

  List<Widget> _slivers(
    BuildContext context,
    MomentFeedState state,
    AutoDisposeStateNotifierProvider<MomentFeedController, MomentFeedState>
    provider,
  ) {
    if (state.phase == MomentLoadPhase.loading) {
      return const [MomentWaterfallLoadingSliver()];
    }
    if (state.phase == MomentLoadPhase.failed) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 16,
            bottom: 80,
            child: WenyouRetryFailure(
              panel: true,
              icon: WenyouIconIds.statusOffline,
              title: '动态列表加载失败',
              message: state.failure?.userMessage ?? '请稍后重试。',
              failure: state.failure,
              retryKey: const Key('moment-feed-retry'),
              onRetry: () => ref.read(provider.notifier).loadInitial(),
              retryLabel: '重试',
            ),
          ),
        ),
      ];
    }
    if (state.items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 16,
            bottom: 80,
            child: WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.navigationMoments,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            ),
          ),
        ),
      ];
    }
    return [
      MomentWaterfallSliver(
        itemKeys: [
          for (final item in state.items) Key('moment-card-${item.id}'),
        ],
        footerKey: const Key('moment-feed-footer'),
        footer: _buildFeedFooter(context, state, provider),
        itemBuilder: (context, index) {
          final moment = state.items[index];
          return MomentWaterfallCard(
            moment: moment,
            pendingAction: state.pendingMomentActions[moment.id],
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
    ];
  }

  Widget _buildFeedFooter(
    BuildContext context,
    MomentFeedState state,
    AutoDisposeStateNotifierProvider<MomentFeedController, MomentFeedState>
    provider,
  ) {
    return WenyouContentFrame(
      top: 12,
      bottom: 112,
      child: WenyouPaginationFooter(
        hasMore: state.hasMore,
        isLoading: state.isLoadingMore,
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        loadMoreKey: const Key('moment-load-more'),
        endLabel: '已经看到这里了',
      ),
    );
  }

  void _authenticatedAction(BuildContext context, VoidCallback action) {
    if (ref.read(sessionControllerProvider).isAuthenticated) {
      action();
      return;
    }
    _openLogin(context, GoRouterState.of(context).uri.toString());
  }
}

class _FollowingLoginState extends StatelessWidget {
  const _FollowingLoginState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return WenyouContentFrame(
      top: 16,
      bottom: 80,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.identityMembers,
          title: '登录后查看关注动态',
          action: FilledButton.icon(
            key: const Key('moment-following-login'),
            onPressed: onLogin,
            icon: const WenyouIcon(WenyouIconIds.actionLogin),
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

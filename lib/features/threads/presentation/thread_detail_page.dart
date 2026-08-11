import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_card_action_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_membership_controls.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

part 'thread_detail_sections.dart';

class ThreadDetailPage extends ConsumerStatefulWidget {
  const ThreadDetailPage({
    required this.threadId,
    this.categoryNameHint,
    this.targetPostId,
    super.key,
  });

  final String threadId;
  final String? categoryNameHint;
  final String? targetPostId;

  @override
  ConsumerState<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends ConsumerState<ThreadDetailPage> {
  final _scrollController = ScrollController();
  final _targetKey = GlobalKey();
  String? _lastRevealedTargetId;

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

  @override
  void didUpdateWidget(covariant ThreadDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetPostId != widget.targetPostId) {
      _lastRevealedTargetId = null;
    }
  }

  void _loadMoreNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 520) {
      return;
    }
    ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final provider = threadDetailControllerProvider(widget.threadId);
    final actionsProvider = postActionControllerProvider(widget.threadId);
    ref.listen(sessionControllerProvider.select((session) => session.status), (
      previous,
      next,
    ) {
      if (previous == null || previous == next) return;
      ref
        ..invalidate(provider)
        ..invalidate(actionsProvider);
    });
    final state = ref.watch(provider);
    final session = ref.watch(sessionControllerProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    final actions = ref.watch(actionsProvider);
    final selectedSubthread = state.phase == ThreadDetailPhase.ready
        ? state.selectedSubthread
        : null;
    final target = widget.targetPostId == null
        ? null
        : ref.watch(threadPostTargetProvider(widget.targetPostId!));
    final resolvedTarget = target?.valueOrNull;
    if (state.phase == ThreadDetailPhase.ready &&
        resolvedTarget != null &&
        resolvedTarget.threadId == widget.threadId &&
        state.detail?.subthreadById(resolvedTarget.subthreadId) != null &&
        state.selectedSubthreadId != resolvedTarget.subthreadId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(provider.notifier).selectSubthread(resolvedTarget.subthreadId);
      });
    }
    _revealTargetWhenReady(state, resolvedTarget);
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      appBar: AppBar(
        leading: BackButton(
          key: const Key('thread-detail-back'),
          onPressed: _leaveDetail,
        ),
        title: const Text('主题详情'),
        actions: [
          if (state.detail case final detail? when !detail.isCurrentUserOwner)
            WenyouTipButton(
              key: const Key('thread-detail-tip'),
              target: TipTarget.thread(
                id: detail.id,
                recipientUserId: detail.owner.id,
              ),
              recipientName: detail.owner.username,
              returnTo: _currentThreadLocation(),
              iconOnly: true,
              onSuccess: (_) => ref.read(provider.notifier).refresh(),
            ),
          if (state.detail case final detail?
              when !detail.isPrivate && !detail.isCurrentUserOwner)
            WenyouReportButton(
              key: const Key('thread-detail-report'),
              target: ReportTarget.thread(detail.id),
              targetLabel: '这个主题',
              returnTo: _currentThreadLocation(),
              iconOnly: true,
            ),
          IconButton(
            key: const Key('thread-detail-search'),
            tooltip: '搜索主题内容',
            onPressed: () => context.pushNamed(
              'thread-post-search',
              pathParameters: {'threadId': widget.threadId},
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          if (state.detail?.canManageThread == true)
            IconButton(
              key: const Key('thread-detail-manage'),
              tooltip: '管理主题',
              onPressed: _openManagement,
              icon: const Icon(Icons.tune_rounded),
            ),
        ],
      ),
      body: switch (state.phase) {
        ThreadDetailPhase.loading => const _DetailLoadingState(),
        ThreadDetailPhase.failed => _DetailFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).loadInitial(),
        ),
        ThreadDetailPhase.ready => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).refresh(),
          child: CustomScrollView(
            key: PageStorageKey('thread-detail-${widget.threadId}'),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: _buildReadySlivers(
              context,
              state,
              provider,
              target,
              actions: actions,
              authenticated: session.isAuthenticated,
              viewerId: viewerId,
            ),
          ),
        ),
      },
      bottomNavigationBar: selectedSubthread == null
          ? null
          : WenyouComposerDock(
              key: const Key('thread-floor-compose'),
              label: session.isAuthenticated ? '发表楼层…' : '登录后发表楼层',
              icon: session.isAuthenticated
                  ? Icons.add_comment_outlined
                  : Icons.login_rounded,
              onPressed: session.isAuthenticated
                  ? () =>
                        _compose(_floorTarget(state.detail!, selectedSubthread))
                  : _requireLogin,
            ),
    );
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) context.go(AppRouteLocations.home);
      },
      child: scaffold,
    );
  }

  void _leaveDetail() {
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    } else {
      context.go(AppRouteLocations.home);
    }
  }

  Future<void> _openManagement() async {
    final changed = await context.push<bool>(
      '/threads/${widget.threadId}/manage',
    );
    if (changed == true && mounted) {
      await ref
          .read(threadDetailControllerProvider(widget.threadId).notifier)
          .refresh();
    }
  }

  Future<void> _handlePlayerExited(ThreadDetailModel detail) async {
    ref.invalidate(
      threadSubscriptionControllerProvider(
        ThreadSubscriptionTarget(
          threadId: detail.id,
          viewerUserId: detail.currentUserId,
        ),
      ),
    );
    await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .refresh();
  }

  void _revealTargetWhenReady(
    ThreadDetailState state,
    ThreadPostTargetModel? target,
  ) {
    if (target == null ||
        target.threadId != widget.threadId ||
        state.selectedSubthreadId != target.subthreadId ||
        state.isLoadingFloors ||
        _lastRevealedTargetId == target.requestedPostId) {
      return;
    }
    _lastRevealedTargetId = target.requestedPostId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _targetKey.currentContext;
      if (!mounted || targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: Duration.zero,
        alignment: 0.12,
      );
    });
  }

  List<Widget> _buildReadySlivers(
    BuildContext context,
    ThreadDetailState state,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider,
    AsyncValue<ThreadPostTargetModel>? targetState, {
    required PostActionState actions,
    required bool authenticated,
    required String? viewerId,
  }) {
    final detail = state.detail!;
    final selected = state.selectedSubthread;
    final target = targetState?.valueOrNull;
    final usableTarget =
        target != null &&
            target.threadId == widget.threadId &&
            target.subthreadId == state.selectedSubthreadId
        ? target
        : null;
    final displayedFloors = _floorsWithTarget(state.floors, usableTarget);
    return [
      SliverToBoxAdapter(
        child: _DetailContent(
          top: 16,
          child: _ThreadOverview(
            detail: detail,
            categoryName:
                widget.categoryNameHint ?? detail.categorySlug ?? '未分类',
            selectedSubthreadId: state.selectedSubthreadId,
            onSubthreadSelected: (id) =>
                ref.read(provider.notifier).selectSubthread(id),
            onRequireAuthentication: () => context.pushNamed(
              'login',
              queryParameters: {'returnTo': _currentThreadLocation()},
            ),
            onPlayerExited: () => _handlePlayerExited(detail),
          ),
        ),
      ),
      if (state.transientFailure != null &&
          state.retryAction == ThreadDetailRetryAction.refresh)
        SliverToBoxAdapter(
          child: _DetailContent(
            top: 12,
            child: _DetailTransientFailure(
              failure: state.transientFailure!,
              onRetry: () => ref.read(provider.notifier).refresh(),
            ),
          ),
        ),
      if (detail.subthreads.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _DetailContent(
            top: 12,
            bottom: 40,
            child: const WenyouPanel(
              child: WenyouEmptyState(
                icon: Icons.topic_outlined,
                title: '这个主题还没有子贴',
                message: '楼主补充内容后，可以在这里继续阅读。',
              ),
            ),
          ),
        )
      else ...[
        SliverToBoxAdapter(
          child: _DetailContent(
            top: 12,
            child: _SubthreadBody(
              subthread: selected!,
              canEdit: detail.canManageThread,
              onEdit: () => _compose(_bodyTarget(detail, selected)),
            ),
          ),
        ),
        if (actions.failure != null)
          SliverToBoxAdapter(
            child: _DetailContent(
              top: 12,
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: actions.failure!.userMessage,
                detail: actions.failure!.requestId == null
                    ? null
                    : '请求 ID：${actions.failure!.requestId}',
              ),
            ),
          ),
        if (targetState != null)
          SliverToBoxAdapter(
            child: _DetailContent(
              top: 12,
              child: _TargetPostStatus(
                targetState: targetState,
                expectedThreadId: widget.threadId,
                availableSubthreadIds: {
                  for (final subthread in detail.subthreads) subthread.id,
                },
                onRetry: () => ref.invalidate(
                  threadPostTargetProvider(widget.targetPostId!),
                ),
              ),
            ),
          ),
        if (state.isLoadingFloors)
          const SliverToBoxAdapter(
            child: _DetailContent(top: 12, child: _FloorsLoadingState()),
          )
        else if (state.transientFailure != null &&
            state.retryAction == ThreadDetailRetryAction.floors)
          SliverToBoxAdapter(
            child: _DetailContent(
              top: 12,
              child: _DetailTransientFailure(
                failure: state.transientFailure!,
                onRetry: () => ref.read(provider.notifier).retryFloors(),
              ),
            ),
          )
        else if (displayedFloors.isEmpty)
          const SliverToBoxAdapter(
            child: _DetailContent(
              top: 12,
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '还没有楼层',
                  message: '这个子贴目前只有正文，暂时没有后续讨论。',
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final floor = displayedFloors[index];
              final focused = usableTarget?.floor.id == floor.id;
              return _DetailContent(
                top: index == 0 ? 12 : 0,
                child: Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    _FloorCard(
                      key: focused ? _targetKey : null,
                      threadId: widget.threadId,
                      floor: floor,
                      isFocused: focused,
                      authenticated: authenticated,
                      viewerId: viewerId,
                      canManageThread: detail.canManageThread,
                      reportsEnabled: !detail.isPrivate,
                      pendingPostId: actions.pendingPostId,
                      canEdit: floor.author.id == viewerId,
                      canDelete:
                          floor.author.id == viewerId || detail.canManageThread,
                      pending: actions.pendingPostId == floor.id,
                      onDiscussion: () => _openDiscussion(
                        floor,
                        reportsEnabled: !detail.isPrivate,
                      ),
                      showDiscussion: floor.replyCount > 0 || authenticated,
                      reportReturnTo:
                          !detail.isPrivate && floor.author.id != viewerId
                          ? _postLocation(floor.id)
                          : null,
                      onEdit: () =>
                          _compose(_editFloorTarget(detail, selected, floor)),
                      onDelete: () => _deleteFloor(floor),
                      onReplyToReply: (reply) => _compose(
                        _replyTarget(detail, selected, floor, reply),
                      ),
                      onEditReply: (reply) => _compose(
                        _editReplyTarget(detail, selected, floor, reply),
                      ),
                      onDeleteReply: (reply) =>
                          _deleteReply(detail, selected, floor, reply),
                    ),
                  ],
                ),
              );
            }, childCount: displayedFloors.length),
          ),
        SliverToBoxAdapter(
          child: _DetailContent(
            top: 12,
            bottom: 40,
            child: _FloorsFooter(
              state: state,
              onLoadMore: () => ref.read(provider.notifier).loadMore(),
            ),
          ),
        ),
      ],
    ];
  }

  Future<void> _compose(PostComposerTarget target) async {
    final result = await showPostComposerSheet(
      context: context,
      target: target,
    );
    if (result == null || !mounted) return;
    await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .refresh();
  }

  void _requireLogin() {
    context.pushNamed(
      'login',
      queryParameters: {'returnTo': _currentThreadLocation()},
    );
  }

  void _openDiscussion(ThreadFloorModel floor, {required bool reportsEnabled}) {
    final focusedReplyId =
        widget.targetPostId != null &&
            floor.replies.any((reply) => reply.id == widget.targetPostId)
        ? widget.targetPostId
        : null;
    context.pushNamed(
      'post-replies',
      pathParameters: {'threadId': widget.threadId, 'postId': floor.id},
      queryParameters: {
        if (reportsEnabled) 'reports': '1',
        'post': ?focusedReplyId,
      },
    );
  }

  Future<void> _deleteFloor(ThreadFloorModel floor) async {
    final state = ref.read(threadDetailControllerProvider(widget.threadId));
    final detail = state.detail;
    final subthread = state.selectedSubthread;
    if (detail == null || subthread == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这个楼层？'),
        content: const Text('楼层会被标记为已删除，操作无法在移动端撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(postActionControllerProvider(widget.threadId).notifier)
        .remove(_floorAsPost(detail, subthread, floor));
    if (!removed || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('楼层已删除。')));
    await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .refresh();
  }

  Future<void> _deleteReply(
    ThreadDetailModel detail,
    ThreadSubthreadModel subthread,
    ThreadFloorModel floor,
    ThreadReplyModel reply,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这条回复？'),
        content: const Text('回复会被标记为已删除，操作无法在移动端撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(postActionControllerProvider(widget.threadId).notifier)
        .remove(_replyAsPost(detail, subthread, floor, reply));
    if (!removed || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('回复已删除。')));
    await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .refresh();
  }

  String _currentThreadLocation() {
    return Uri(
      pathSegments: ['', 'threads', widget.threadId],
      queryParameters: widget.targetPostId == null
          ? null
          : {'post': widget.targetPostId!},
    ).toString();
  }

  String _postLocation(String postId) {
    return Uri(
      pathSegments: ['', 'threads', widget.threadId],
      queryParameters: {'post': postId},
    ).toString();
  }

  List<ThreadFloorModel> _floorsWithTarget(
    List<ThreadFloorModel> floors,
    ThreadPostTargetModel? target,
  ) {
    if (target == null) return floors;
    final index = floors.indexWhere((floor) => floor.id == target.floor.id);
    var focusedFloor = index == -1 ? target.floor : floors[index];
    if (target.focusedReplyId != null &&
        !focusedFloor.replies.any(
          (reply) => reply.id == target.focusedReplyId,
        )) {
      final focusedReply = target.floor.replies.single;
      final replies = [...focusedFloor.replies, focusedReply]
        ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
      focusedFloor = ThreadFloorModel(
        id: focusedFloor.id,
        floorNumber: focusedFloor.floorNumber,
        author: focusedFloor.author,
        body: focusedFloor.body,
        createdAt: focusedFloor.createdAt,
        isDeleted: focusedFloor.isDeleted,
        replyCount: focusedFloor.replyCount,
        replies: replies,
        version: focusedFloor.version,
      );
    }
    return [
      focusedFloor,
      ...floors.where((floor) => floor.id != focusedFloor.id),
    ];
  }
}

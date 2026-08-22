import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_subscription_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_bottom_bar.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_floor_filters.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_membership_controls.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class ThreadDetailPage extends ConsumerStatefulWidget {
  const ThreadDetailPage({
    required this.threadId,
    this.categoryNameHint,
    this.targetPostId,
    this.subthreadIdHint,
    super.key,
  });

  final String threadId;
  final String? categoryNameHint;
  final String? targetPostId;
  final String? subthreadIdHint;

  @override
  ConsumerState<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends ConsumerState<ThreadDetailPage> {
  static const _contentCacheExtent = 4000.0;
  static const _loadMoreThreshold = 2400.0;

  final _scrollController = ScrollController();
  final _targetKey = GlobalKey();
  final _composerDrafts = <String, String>{};
  String? _lastRevealSignature;
  String? _revealScopeSignature;
  String? _lastOpenedReplyTargetId;
  final _targetFilterRestore = ThreadTargetFilterRestoreCoordinator();
  String? _revealAttemptTargetId;
  var _revealAttempts = 0;
  var _revealScheduled = false;
  var _targetRevealReleased = false;

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
      _lastRevealSignature = null;
      _revealScopeSignature = null;
      _lastOpenedReplyTargetId = null;
      _targetFilterRestore.reset();
      _revealAttemptTargetId = null;
      _revealAttempts = 0;
    }
  }

  void _loadMoreNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > _loadMoreThreshold) {
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
    final authorsProvider = postDiscussionAuthorsProvider(widget.threadId);
    ref.listen(sessionScopeProvider, (previous, next) {
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
    final discussionAuthors = selectedSubthread == null
        ? const AsyncValue<List<PostDiscussionAuthor>>.data([])
        : ref.watch(authorsProvider);
    final target = widget.targetPostId == null
        ? null
        : ref.watch(threadPostTargetProvider(widget.targetPostId!));
    final resolvedTarget = target?.valueOrNull;
    final hintedSubthreadId = resolvedTarget == null
        ? widget.subthreadIdHint
        : null;
    if (state.phase == ThreadDetailPhase.ready &&
        hintedSubthreadId != null &&
        state.detail?.subthreadById(hintedSubthreadId) != null &&
        state.selectedSubthreadId != hintedSubthreadId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(provider.notifier).selectSubthread(hintedSubthreadId);
      });
    }
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
    final targetExcludedByFilter = _targetFilterRestore.scheduleIfNeeded(
      state: state,
      target: resolvedTarget,
      threadId: widget.threadId,
      onRestore: (authorId, subthreadId) async {
        if (!mounted) return;
        final current = ref.read(provider);
        if (current.floorAuthorId != authorId ||
            current.selectedSubthreadId != subthreadId) {
          return;
        }
        await ref
            .read(provider.notifier)
            .applyFloorFilters(order: current.floorOrder, authorId: null);
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已取消发言者筛选，以显示目标楼层。')));
      },
    );
    if (!targetExcludedByFilter) {
      _revealTargetWhenReady(state, resolvedTarget);
    }
    _openReplyTargetWhenReady(state, resolvedTarget);
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      appBar: WenyouReadingAppBar(
        leading: BackButton(
          key: const Key('thread-detail-back'),
          onPressed: _leaveDetail,
        ),
        actions: _threadAppBarActions(state, provider),
      ),
      body: switch (state.phase) {
        ThreadDetailPhase.loading => const ThreadDetailLoadingState(),
        ThreadDetailPhase.failed => ThreadDetailFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).loadInitial(),
        ),
        ThreadDetailPhase.ready => NotificationListener<ScrollNotification>(
          onNotification: _handleUserScroll,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _handleTargetLayoutChange,
            child: RefreshIndicator(
              onRefresh: () => ref.read(provider.notifier).refresh(),
              child: CustomScrollView(
                key: PageStorageKey('thread-detail-${widget.threadId}'),
                controller: _scrollController,
                scrollCacheExtent: const ScrollCacheExtent.pixels(
                  _contentCacheExtent,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ..._buildReadySlivers(
                    context,
                    state,
                    provider,
                    target,
                    actions: actions,
                    discussionAuthors: discussionAuthors,
                    authenticated: session.isAuthenticated,
                    viewerId: viewerId,
                  ),
                ],
              ),
            ),
          ),
        ),
      },
      bottomNavigationBar: state.phase == ThreadDetailPhase.ready
          ? ThreadDetailBottomBar(
              detail: state.detail!,
              authenticated: session.isAuthenticated,
              canCompose: selectedSubthread != null,
              onRequireAuthentication: _requireLogin,
              onCompose: selectedSubthread == null
                  ? () {}
                  : () => _compose(
                      threadDetailFloorTarget(state.detail!, selectedSubthread),
                    ),
            )
          : null,
    );
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) context.go(AppRouteLocations.home);
      },
      child: scaffold,
    );
  }

  List<Widget> _threadAppBarActions(
    ThreadDetailState state,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider,
  ) {
    return [
      IconButton(
        key: const Key('thread-detail-search'),
        tooltip: '搜索主题内容',
        onPressed: () => context.pushNamed(
          'thread-post-search',
          pathParameters: {'threadId': widget.threadId},
        ),
        icon: const WenyouIcon(WenyouIconIds.actionSearch),
      ),
      if (state.detail case final detail?
          when !detail.isCurrentUserOwner || detail.canManageThread)
        WenyouAnchoredActionBubble<_ThreadDetailAction>(
          actions: [
            if (detail.canManageThread)
              WenyouPopoverAction(
                value: _ThreadDetailAction.editBody,
                icon: state.selectedSubthread?.body == null
                    ? WenyouIconIds.contentDraft
                    : WenyouIconIds.actionEdit,
                label: state.selectedSubthread?.body == null ? '添加正文' : '编辑正文',
                semanticsLabel: state.selectedSubthread?.body == null
                    ? '添加当前子贴正文'
                    : '编辑当前子贴正文',
                enabled: state.selectedSubthread != null,
                key: const Key('thread-detail-edit-body'),
              ),
            if (detail.canManageThread)
              const WenyouPopoverAction(
                value: _ThreadDetailAction.manage,
                icon: WenyouIconIds.actionFilter,
                label: '管理',
                semanticsLabel: '管理主题',
                key: Key('thread-detail-manage'),
              ),
            if (!detail.isCurrentUserOwner)
              const WenyouPopoverAction(
                value: _ThreadDetailAction.tip,
                icon: WenyouIconIds.actionTip,
                label: '加油',
                semanticsLabel: '为创作者加油',
                key: Key('thread-detail-tip'),
              ),
            if (!detail.isPrivate && !detail.isCurrentUserOwner)
              const WenyouPopoverAction(
                value: _ThreadDetailAction.report,
                icon: WenyouIconIds.actionReport,
                label: '举报',
                semanticsLabel: '举报主题',
                tone: WenyouPopoverActionTone.destructive,
                key: Key('thread-detail-report'),
              ),
            if (detail.isCurrentUserPlayer && !detail.isCurrentUserOwner)
              const WenyouPopoverAction(
                value: _ThreadDetailAction.exitPlayer,
                icon: WenyouIconIds.actionLogout,
                label: '退出玩家身份',
                semanticsLabel: '退出当前主题的玩家身份',
                tone: WenyouPopoverActionTone.destructive,
                key: Key('thread-detail-exit-player'),
              ),
          ],
          placement: WenyouPopoverPlacement.below,
          alignment: WenyouPopoverAlignment.end,
          semanticLabel: '主题操作',
          onSelected: (action) => _handleThreadAction(
            action,
            detail,
            provider,
            selectedSubthread: state.selectedSubthread,
          ),
          anchorBuilder: (context, handle) => IconButton(
            key: const Key('thread-detail-more'),
            tooltip: '更多主题操作',
            onPressed: handle.toggle,
            icon: const WenyouIcon(WenyouIconIds.actionMore),
          ),
        ),
    ];
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

  Future<void> _handleThreadAction(
    _ThreadDetailAction action,
    ThreadDetailModel detail,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider, {
    required ThreadSubthreadModel? selectedSubthread,
  }) async {
    switch (action) {
      case _ThreadDetailAction.editBody:
        if (selectedSubthread != null) {
          await _compose(threadDetailBodyTarget(detail, selectedSubthread));
        }
      case _ThreadDetailAction.manage:
        await _openManagement();
      case _ThreadDetailAction.tip:
        await showWenyouTipFlow(
          context: context,
          ref: ref,
          target: TipTarget.thread(
            id: detail.id,
            recipientUserId: detail.owner.id,
          ),
          recipientName: detail.owner.username,
          returnTo: _currentThreadLocation(),
          onSuccess: (_) => ref.read(provider.notifier).refresh(),
        );
      case _ThreadDetailAction.report:
        await showWenyouReportFlow(
          context: context,
          ref: ref,
          target: ReportTarget.thread(detail.id),
          targetLabel: '这个主题',
          returnTo: _currentThreadLocation(),
        );
      case _ThreadDetailAction.exitPlayer:
        await _showPlayerExitSheet(detail);
    }
  }

  Future<void> _showPlayerExitSheet(ThreadDetailModel detail) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final tokens = sheetContext.wenyouTokens;
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.space16,
              0,
              tokens.space16,
              tokens.space16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '玩家身份',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                SizedBox(height: tokens.space4),
                Text(
                  '退出后会从“我参与的”主题中移除。',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
                ThreadMembershipControls(
                  threadId: detail.id,
                  canExitPlayer: true,
                  onExited: () async {
                    await _handlePlayerExited(detail);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
        target.focusedReplyId != null ||
        target.threadId != widget.threadId ||
        state.selectedSubthreadId != target.subthreadId) {
      return;
    }
    final scopeSignature =
        '${target.requestedPostId}:${state.floorOrder.name}:'
        '${state.floorAuthorId ?? ''}:${state.selectedSubthreadId}';
    if (_revealScopeSignature != scopeSignature) {
      _revealScopeSignature = scopeSignature;
      _lastRevealSignature = null;
      _revealAttemptTargetId = null;
      _revealAttempts = 0;
      _revealScheduled = false;
      _targetRevealReleased = false;
    }
    if (state.isLoadingFloors || _targetRevealReleased || _revealScheduled) {
      return;
    }
    final displayedFloors = threadFloorsWithTarget(
      state.floors,
      target,
      state.floorOrder,
    );
    final targetIndex = displayedFloors.indexWhere(
      (floor) => floor.id == target.floor.id,
    );
    final signature =
        '${target.requestedPostId}:${state.floorOrder.name}:'
        '${state.selectedSubthreadId}:$targetIndex:${displayedFloors.length}';
    if (_lastRevealSignature == signature) return;
    if (_revealAttemptTargetId != target.requestedPostId) {
      _revealAttemptTargetId = target.requestedPostId;
      _revealAttempts = 0;
    }
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      final targetContext = _targetKey.currentContext;
      if (!mounted ||
          _targetRevealReleased ||
          _revealScopeSignature != scopeSignature) {
        return;
      }
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: Duration.zero,
          alignment: 0.12,
        );
        _lastRevealSignature = signature;
        _revealAttemptTargetId = null;
        _revealAttempts = 0;
        return;
      }
      if (!_scrollController.hasClients || _revealAttempts >= 6) return;
      if (targetIndex < 0) return;
      _revealAttempts += 1;
      final position = _scrollController.position;
      final fraction = (targetIndex + 1) / (displayedFloors.length + 1);
      final estimated = position.maxScrollExtent * fraction;
      _scrollController.jumpTo(
        estimated.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
      if (mounted) setState(() {});
    });
  }

  bool _handleTargetLayoutChange(ScrollMetricsNotification notification) {
    if (widget.targetPostId == null ||
        _lastRevealSignature == null ||
        _targetRevealReleased) {
      return false;
    }
    _lastRevealSignature = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    return false;
  }

  bool _handleUserScroll(ScrollNotification notification) {
    final startsUserScroll =
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical &&
        notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        _revealScopeSignature != null;
    if (startsUserScroll) _targetRevealReleased = true;
    return false;
  }

  void _openReplyTargetWhenReady(
    ThreadDetailState state,
    ThreadPostTargetModel? target,
  ) {
    final focusedReplyId = target?.focusedReplyId;
    if (target == null ||
        focusedReplyId == null ||
        target.threadId != widget.threadId ||
        state.phase != ThreadDetailPhase.ready ||
        state.selectedSubthreadId != target.subthreadId ||
        _lastOpenedReplyTargetId == target.requestedPostId) {
      return;
    }
    _lastOpenedReplyTargetId = target.requestedPostId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openDiscussion(target.floor, focusedReplyId: focusedReplyId);
    });
  }

  List<Widget> _buildReadySlivers(
    BuildContext context,
    ThreadDetailState state,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider,
    AsyncValue<ThreadPostTargetModel>? targetState, {
    required PostActionState actions,
    required AsyncValue<List<PostDiscussionAuthor>> discussionAuthors,
    required bool authenticated,
    required String? viewerId,
  }) {
    final detail = state.detail!;
    final selected = state.selectedSubthread;
    final target = targetState?.valueOrNull;
    final usableTarget =
        target != null &&
            target.threadId == widget.threadId &&
            target.subthreadId == state.selectedSubthreadId &&
            (state.floorAuthorId == null ||
                target.floor.author.id == state.floorAuthorId)
        ? target
        : null;
    final displayedFloors = threadFloorsWithTarget(
      state.floors,
      usableTarget,
      state.floorOrder,
    );
    return [
      SliverToBoxAdapter(
        child: WenyouContentFrame(
          top: 8,
          child: ThreadDetailOverview(
            detail: detail,
            selectedSubthreadId: state.selectedSubthreadId,
            onSubthreadSelected: (id) =>
                ref.read(provider.notifier).selectSubthread(id),
          ),
        ),
      ),
      if (state.transientFailure != null &&
          state.retryAction == ThreadDetailRetryAction.refresh)
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: ThreadDetailTransientFailure(
              failure: state.transientFailure!,
              onRetry: () => ref.read(provider.notifier).refresh(),
            ),
          ),
        ),
      if (detail.subthreads.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: WenyouContentFrame(
            top: 12,
            bottom: 40,
            child: const WenyouPanel(
              child: WenyouEmptyState(
                icon: WenyouIconIds.contentTopic,
                title: '这个主题还没有子贴',
                message: '',
              ),
            ),
          ),
        )
      else ...[
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            child: ThreadSubthreadBody(subthread: selected!),
          ),
        ),
        if (actions.failure != null)
          SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: actions.failure!.userMessage,
                detail: actions.failure!.requestId == null
                    ? null
                    : '问题编号：${actions.failure!.requestId}',
              ),
            ),
          ),
        if (targetState != null)
          SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: ThreadTargetPostStatus(
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
        SliverToBoxAdapter(
          child: ThreadFloorFilters(
            state: state,
            floorCount: selected.postCount,
            authors: discussionAuthors,
            onRetryAuthors: () =>
                ref.invalidate(postDiscussionAuthorsProvider(widget.threadId)),
            onApply: (order, authorId) => ref
                .read(provider.notifier)
                .applyFloorFilters(order: order, authorId: authorId),
          ),
        ),
        if (state.isLoadingFloors)
          const SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: ThreadFloorsLoadingState(),
            ),
          )
        else if (state.transientFailure != null &&
            state.retryAction == ThreadDetailRetryAction.floors)
          SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: ThreadDetailTransientFailure(
                failure: state.transientFailure!,
                onRetry: () => ref.read(provider.notifier).retryFloors(),
              ),
            ),
          )
        else if (displayedFloors.isEmpty)
          SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: WenyouPanel(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.metricComments,
                  title: state.floorAuthorId == null ? '还没有楼层' : '没有符合条件的楼层',
                  message: state.floorAuthorId == null
                      ? '这个子贴目前只有正文，暂时没有后续讨论。'
                      : '可以换一位发言者，或查看全部楼层。',
                  action: state.floorAuthorId == null
                      ? null
                      : TextButton.icon(
                          key: const Key('thread-floors-clear-author'),
                          onPressed: () => ref
                              .read(provider.notifier)
                              .applyFloorFilters(
                                order: state.floorOrder,
                                authorId: null,
                              ),
                          icon: const WenyouIcon(
                            WenyouIconIds.actionClearFilter,
                          ),
                          label: const Text('查看全部楼层'),
                        ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final floor = displayedFloors[index];
              final focused =
                  usableTarget?.focusedReplyId == null &&
                  usableTarget?.floor.id == floor.id;
              return WenyouContentFrame(
                top: index == 0 ? 12 : 0,
                child: Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    ThreadFloorCard(
                      key: focused ? _targetKey : null,
                      threadId: widget.threadId,
                      floor: floor,
                      isFocused: focused,
                      canEdit: floor.author.id == viewerId,
                      canDelete:
                          floor.author.id == viewerId || detail.canManageThread,
                      pending: actions.pendingPostId == floor.id,
                      onReply: authenticated
                          ? () => _compose(
                              threadDetailReplyFloorTarget(
                                detail,
                                selected,
                                floor,
                              ),
                            )
                          : _requireLogin,
                      onReplyToReply: authenticated
                          ? (reply) => _compose(
                              threadDetailReplyInlineTarget(
                                detail,
                                selected,
                                floor,
                                reply,
                              ),
                            )
                          : (_) => _requireLogin(),
                      onDiscussion: () => _openDiscussion(
                        floor,
                        focusedReplyId: usableTarget?.floor.id == floor.id
                            ? usableTarget?.focusedReplyId
                            : null,
                      ),
                      reportReturnTo:
                          !detail.isPrivate && floor.author.id != viewerId
                          ? _postLocation(floor.id)
                          : null,
                      onEdit: () => _compose(
                        threadDetailEditFloorTarget(detail, selected, floor),
                      ),
                      onDelete: () => _deleteFloor(floor),
                    ),
                  ],
                ),
              );
            }, childCount: displayedFloors.length),
          ),
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            top: 12,
            bottom:
                context.wenyouTokens.minimumTouchTarget +
                context.wenyouTokens.space32 +
                context.wenyouTokens.space16,
            child: ThreadFloorsFooter(
              state: state,
              onLoadMore: () => ref.read(provider.notifier).loadMore(),
            ),
          ),
        ),
      ],
    ];
  }

  Future<void> _compose(PostComposerTarget target) async {
    final draftKey = postComposerDraftKey(target);
    final result = await showPostComposerSheet(
      context: context,
      target: target,
      initialDraft: _composerDrafts[draftKey],
      onDraftChanged: (content) {
        if (content == target.initialContent) {
          _composerDrafts.remove(draftKey);
        } else {
          _composerDrafts[draftKey] = content;
        }
      },
    );
    if (result == null || !mounted) return;
    _composerDrafts.remove(draftKey);
    await ref
        .read(threadDetailControllerProvider(widget.threadId).notifier)
        .refreshMetadata();
    if (!mounted) return;
    switch (target.kind) {
      case PostComposerKind.createFloor ||
          PostComposerKind.createReply ||
          PostComposerKind.editPost:
        context.replace(_postLocation(result.id));
      case PostComposerKind.upsertBody:
        break;
    }
  }

  void _requireLogin() {
    context.pushNamed(
      'login',
      queryParameters: {'returnTo': _currentThreadLocation()},
    );
  }

  void _openDiscussion(ThreadFloorModel floor, {String? focusedReplyId}) {
    context.pushNamed(
      'post-replies',
      pathParameters: {'threadId': widget.threadId, 'postId': floor.id},
      queryParameters: {'post': ?focusedReplyId},
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
        content: const Text('楼层会被标记为已删除，且无法恢复。'),
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
        .remove(threadFloorAsPost(detail, subthread, floor));
    if (!removed || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('楼层已删除。')));
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
}

enum _ThreadDetailAction { editBody, manage, tip, report, exitPlayer }

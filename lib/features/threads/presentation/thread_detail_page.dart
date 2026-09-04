import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_author_filter_restore.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_item_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_render_diagnostics.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/social/application/thread_subscription_controller.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_app_bar_actions.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_bottom_bar.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_overview.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_render_diagnostics.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_floor_filters.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_membership_controls.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class ThreadDetailPage extends ConsumerStatefulWidget {
  const ThreadDetailPage({
    required this.threadId,
    this.entryTarget = const ThreadDetailEntryTarget.none(),
    this.enableRenderDiagnostics = wenyouFieldDiagnosticsEnabled,
    super.key,
  });

  final String threadId;
  final ThreadDetailEntryTarget entryTarget;
  final bool enableRenderDiagnostics;

  @override
  ConsumerState<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends ConsumerState<ThreadDetailPage> {
  final _pageInstanceToken = Object();
  final _subthreadScroll = ThreadDetailSubthreadScrollCoordinator();
  final _targetKey = GlobalKey();
  final _composerDrafts = <String, PostComposerDraft>{};
  final _entryTargetCoordinator = ThreadDetailEntryTargetCoordinator();
  final _targetReveal = DiscussionTargetRevealCoordinator();
  String? _lastOpenedReplyTargetId;
  final _targetFilterRestore = ThreadTargetFilterRestoreCoordinator();
  final _prefetchScheduler = DiscussionPrefetchScheduler();
  final _authorFilterRestore =
      DiscussionAuthorFilterRestoreCoordinator<PostDiscussionAuthor>(
        authorIdOf: (author) => author.userId,
      );
  final _renderDiagnostics = ThreadDetailRenderDiagnosticCoordinator();
  final _renderGeometry = ThreadDetailRenderGeometryProbe();

  @override
  void dispose() {
    _renderGeometry.dispose();
    _subthreadScroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ThreadDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId ||
        oldWidget.entryTarget != widget.entryTarget) {
      _targetReveal.reset();
      _lastOpenedReplyTargetId = null;
      _targetFilterRestore.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _detailProvider;
    final actionsProvider = postActionControllerProvider(widget.threadId);
    final sessionScope = ref.watch(sessionScopeProvider);
    _entryTargetCoordinator.synchronize(
      threadId: widget.threadId,
      target: widget.entryTarget,
      sessionScope: sessionScope,
    );
    ref.listen(sessionScopeProvider, (previous, next) {
      if (previous == null || previous == next) return;
      _composerDrafts.clear();
      ref
        ..invalidate(provider)
        ..invalidate(actionsProvider);
    });
    ref.listen<int>(actionsProvider.select((value) => value.pinRevision), (
      previous,
      next,
    ) {
      if (previous == null || next <= previous) return;
      unawaited(ref.read(provider.notifier).retryFloors());
    });
    final state = ref.watch(provider);
    if (widget.enableRenderDiagnostics) {
      _renderDiagnostics.schedule(
        context: context,
        state: state,
        diagnostics: ref.read(postRenderDiagnosticsProvider),
        scrollViewportKey: _renderGeometry.scrollViewportKey,
        isMounted: () => mounted,
      );
      _renderGeometry.schedule(
        context: context,
        state: state,
        scrollController: _subthreadScroll.controller,
        isMounted: () => mounted,
      );
    }
    _prefetchScheduler.schedule(
      shouldPrefetch:
          state.phase == ThreadDetailPhase.ready &&
          !state.isLoadingFloors &&
          !state.isPrefetchingFloors &&
          state.transientFailure == null &&
          state.hasMore,
      isMounted: () => mounted,
      prefetch: () => ref.read(provider.notifier).prefetchRemainingFloors(),
    );
    final session = ref.watch(sessionControllerProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    final actions = ref.watch(actionsProvider);
    final selectedSubthread = state.phase == ThreadDetailPhase.ready
        ? state.selectedSubthread
        : null;
    final authorsProvider = selectedSubthread == null
        ? null
        : postFloorDiscussionAuthorsProvider(selectedSubthread.id);
    final discussionAuthors = selectedSubthread == null
        ? const AsyncValue<List<PostDiscussionAuthor>>.data([])
        : ref.watch(authorsProvider!);
    _authorFilterRestore.scheduleIfMissing(
      scopeId: selectedSubthread?.id,
      selectedAuthorId: state.floorAuthorId,
      authors: discussionAuthors,
      readCurrent: () => (
        selectedAuthorId: ref.read(provider).floorAuthorId,
        authors: ref.read(authorsProvider!),
      ),
      clearAuthor: () => ref.read(provider.notifier).setFloorAuthor(null),
      isMounted: () => mounted,
    );
    final targetPostId = widget.entryTarget.postId;
    final target = targetPostId == null
        ? null
        : ref.watch(threadPostTargetProvider(targetPostId));
    final resolvedTarget = target?.valueOrNull;
    _applyEntryTarget(
      _entryTargetCoordinator.resolve(state: state, postTarget: resolvedTarget),
      provider,
    );
    final effectiveTarget = _entryTargetCoordinator.allowsTargetEffects
        ? resolvedTarget
        : null;
    final targetExcludedByFilter = _targetFilterRestore.scheduleIfNeeded(
      state: state,
      target: effectiveTarget,
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
        showWenyouSnackBar(
          context,
          '已取消发言者筛选，以显示目标楼层。',
          pacing: WenyouSnackBarPacing.extended,
        );
      },
    );
    if (!targetExcludedByFilter) {
      _revealTargetWhenReady(state, effectiveTarget);
    }
    _openReplyTargetWhenReady(state, effectiveTarget);
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      key: _renderGeometry.scaffoldKey,
      appBar: WenyouReadingAppBar(
        key: _renderGeometry.appBarKey,
        leading: BackButton(
          key: const Key('thread-detail-back'),
          onPressed: _leaveDetail,
        ),
        actions: buildThreadDetailAppBarActions(
          threadId: widget.threadId,
          state: state,
          onSearch: () => context.pushNamed(
            'thread-post-search',
            pathParameters: {'threadId': widget.threadId},
          ),
          onLatestTarget: _openLatestPost,
          onSelected: (action) => _handleThreadAction(
            action,
            state.detail!,
            provider,
            selectedSubthread: state.selectedSubthread,
          ),
        ),
      ),
      body: switch (state.phase) {
        ThreadDetailPhase.loading => const ThreadDetailLoadingState(),
        ThreadDetailPhase.failed => ThreadDetailFatalState(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).loadInitial(),
        ),
        ThreadDetailPhase.ready => NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _handleTargetLayoutChange,
            child: RefreshIndicator(
              onRefresh: () => ref.read(provider.notifier).refresh(),
              child: KeyedSubtree(
                key: _renderGeometry.scrollViewportKey,
                child: CustomScrollView(
                  key: PageStorageKey(
                    'thread-detail-${widget.threadId}-'
                    '${identityHashCode(_pageInstanceToken)}',
                  ),
                  controller: _subthreadScroll.controller,
                  scrollCacheExtent: discussionScrollCacheExtent,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ..._buildReadySlivers(
                      context,
                      state,
                      provider,
                      _entryTargetCoordinator.allowsTargetEffects
                          ? target
                          : null,
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
        ),
      },
      bottomNavigationBar: state.phase == ThreadDetailPhase.ready
          ? KeyedSubtree(
              key: _renderGeometry.bottomBarKey,
              child: ThreadDetailBottomBar(
                detail: state.detail!,
                authenticated: session.isAuthenticated,
                canCompose: selectedSubthread != null,
                onRequireAuthentication: _requireLogin,
                onCompose: selectedSubthread == null
                    ? () {}
                    : () => _compose(
                        threadDetailFloorTarget(
                          state.detail!,
                          selectedSubthread,
                        ),
                      ),
              ),
            )
          : null,
    );
    return PopScope<Object?>(
      key: _renderGeometry.routeKey,
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) context.go(AppRouteLocations.home);
      },
      child: scaffold,
    );
  }

  AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
  get _detailProvider => threadDetailControllerProvider((
    threadId: widget.threadId,
    pageInstanceToken: _pageInstanceToken,
  ));
  String get _location => AppRouteLocations.thread(
    widget.threadId,
    postId: widget.entryTarget.postId,
    subthreadId: widget.entryTarget.subthreadId,
  );

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
      await ref.read(_detailProvider.notifier).refresh();
    }
  }

  Future<void> _handleThreadAction(
    ThreadDetailAppBarAction action,
    ThreadDetailModel detail,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider, {
    required ThreadSubthreadModel? selectedSubthread,
  }) async {
    switch (action) {
      case ThreadDetailAppBarAction.editBody:
        if (selectedSubthread != null) {
          await _compose(threadDetailBodyTarget(detail, selectedSubthread));
        }
      case ThreadDetailAppBarAction.manage:
        await _openManagement();
      case ThreadDetailAppBarAction.tip:
        await showWenyouTipFlow(
          context: context,
          ref: ref,
          target: TipTarget.thread(
            id: detail.id,
            recipientUserId: detail.owner.id,
          ),
          recipientName: detail.owner.username,
          returnTo: _location,
          onSuccess: (_) => ref.read(provider.notifier).refresh(),
        );
      case ThreadDetailAppBarAction.report:
        await showWenyouReportFlow(
          context: context,
          ref: ref,
          target: ReportTarget.thread(detail.id),
          targetLabel: '这个主题',
          returnTo: _location,
        );
      case ThreadDetailAppBarAction.exitPlayer:
        await showThreadPlayerExitSheet(
          context: context,
          threadId: detail.id,
          onExited: () => _handlePlayerExited(detail),
        );
    }
  }

  Future<void> _handlePlayerExited(ThreadDetailModel detail) async {
    ref.invalidate(threadSubscriptionControllerProvider(detail.id));
    await ref.read(_detailProvider.notifier).refresh();
  }

  void _applyEntryTarget(
    ThreadDetailEntrySelection? selection,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider,
  ) {
    if (selection == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_entryTargetCoordinator.isCurrent(selection.generation)) {
        return;
      }
      ref.read(provider.notifier).selectSubthread(selection.subthreadId);
    });
  }

  Future<void> _selectSubthreadFromUser(
    String subthreadId,
    AutoDisposeStateNotifierProvider<ThreadDetailController, ThreadDetailState>
    provider,
  ) {
    _entryTargetCoordinator.cancelForUserSelection();
    return ref.read(provider.notifier).selectSubthread(subthreadId);
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
    _targetReveal.schedule(
      targetId: target.requestedPostId,
      scopeSignature: scopeSignature,
      contentSignature: signature,
      targetIndex: targetIndex,
      itemCount: displayedFloors.length,
      ready: !state.isLoadingFloors,
      targetKey: _targetKey,
      scrollController: _subthreadScroll.controller,
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
  }

  bool _handleTargetLayoutChange(ScrollMetricsNotification notification) =>
      _targetReveal.handleLayoutChange(
        isMounted: () => mounted,
        requestRebuild: () => setState(() {}),
      );

  bool _onScroll(ScrollNotification e) => _targetReveal.handleUserScroll(e);
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
          child: KeyedSubtree(
            key: _renderGeometry.overviewKey,
            child: ThreadDetailOverview(
              detail: detail,
              onTagPressed: (tag) => context.pushNamed(
                AppRouteNames.tagThreads,
                pathParameters: {'tagId': tag.id},
              ),
            ),
          ),
        ),
      ),
      ThreadDetailSubthreadHeaderSliver(
        subthreads: detail.subthreads,
        selectedSubthreadId: state.selectedSubthreadId,
        scrollCoordinator: _subthreadScroll,
        onSelected: (subthreadId) =>
            _selectSubthreadFromUser(subthreadId, provider),
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
              ),
            ),
          ),
        )
      else ...[
        SliverToBoxAdapter(
          child: WenyouContentFrame(
            key: _subthreadScroll.bodyKey,
            top: context.wenyouTokens.space12,
            bottom: context.wenyouTokens.space12,
            child: KeyedSubtree(
              key: _renderGeometry.bodyKey,
              child: ThreadSubthreadBody(
                detail,
                selected!,
                onEdit: _compose,
                diagnosticMarkdownKey: _renderGeometry.markdownKey,
              ),
            ),
          ),
        ),
        if (actions.failure != null)
          SliverToBoxAdapter(
            child: WenyouContentFrame(
              top: 12,
              child: WenyouStatusBanner(
                tone: WenyouStatusTone.error,
                message: actions.failure!.userMessage,
                detail: wenyouFailureDetail(
                  actions.failure,
                  treatAsWrite: true,
                ),
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
                onRetry: () {
                  _entryTargetCoordinator.rearmForRetry();
                  ref.invalidate(
                    threadPostTargetProvider(widget.entryTarget.postId!),
                  );
                },
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: ThreadFloorFilters(
            state: state,
            floorCount: selected.postCount,
            authors: discussionAuthors,
            onRetryAuthors: () =>
                ref.invalidate(postFloorDiscussionAuthorsProvider(selected.id)),
            onOrderChanged: ref.read(provider.notifier).setFloorOrder,
            onAuthorChanged: ref.read(provider.notifier).setFloorAuthor,
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final floor = displayedFloors[index];
                final focused =
                    usableTarget?.focusedReplyId == null &&
                    usableTarget?.floor.id == floor.id;
                return DiscussionKeepAlive(
                  key: ValueKey('thread-floor-item-${floor.id}'),
                  child: WenyouContentFrame(
                    top: index == 0 ? 12 : 0,
                    child: Column(
                      children: [
                        if (index > 0)
                          WenyouContentItemDivider(
                            key: ValueKey('thread-floor-divider-${floor.id}'),
                            variant: WenyouContentItemDividerVariant.line,
                          ),
                        ThreadFloorCard(
                          key: ValueKey('thread-floor-${floor.id}'),
                          threadId: widget.threadId,
                          floor: floor,
                          isFocused: focused,
                          targetFrameKey: focused ? _targetKey : null,
                          canEdit: floor.author.id == viewerId,
                          canDelete:
                              floor.author.id == viewerId ||
                              detail.canManageThread,
                          canPin: detail.canManageThread,
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
                              ? AppRouteLocations.thread(
                                  widget.threadId,
                                  postId: floor.id,
                                )
                              : null,
                          onEdit: () => _compose(
                            threadDetailEditFloorTarget(
                              detail,
                              selected,
                              floor,
                            ),
                          ),
                          onDelete: () => _deleteFloor(floor),
                          onTogglePin: () => _toggleFloorPin(floor),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: displayedFloors.length,
              findChildIndexCallback: (key) {
                final value = key is ValueKey<String> ? key.value : null;
                if (value == null || !value.startsWith('thread-floor-item-')) {
                  return null;
                }
                final floorId = value.substring('thread-floor-item-'.length);
                final index = displayedFloors.indexWhere(
                  (floor) => floor.id == floorId,
                );
                return index < 0 ? null : index;
              },
            ),
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
    final openedSessionScope = ref.read(sessionScopeProvider);
    final result = await showPostComposerSheet(
      context: context,
      target: target,
      initialDraft: _composerDrafts[draftKey],
      onDraftChanged: (draft) {
        if (!mounted || ref.read(sessionScopeProvider) != openedSessionScope) {
          return;
        }
        setPostComposerDraft(_composerDrafts, draftKey, draft);
      },
    );
    if (result == null ||
        !mounted ||
        ref.read(sessionScopeProvider) != openedSessionScope) {
      return;
    }
    _composerDrafts.remove(draftKey);
    if (target.kind == PostComposerKind.createFloor) {
      ref.invalidate(postFloorDiscussionAuthorsProvider(target.subthreadId));
    }
    ref.invalidate(threadPostTargetProvider(result.id));
    await ref.read(_detailProvider.notifier).refreshMetadata();
    if (!mounted) return;
    switch (target.kind) {
      case PostComposerKind.createFloor ||
          PostComposerKind.createReply ||
          PostComposerKind.editPost:
        context.replace(
          AppRouteLocations.thread(widget.threadId, postId: result.id),
        );
      case PostComposerKind.upsertBody:
        break;
    }
  }

  void _requireLogin() {
    context.pushNamed('login', queryParameters: {'returnTo': _location});
  }

  void _openDiscussion(ThreadFloorModel floor, {String? focusedReplyId}) {
    context.pushNamed(
      'post-replies',
      pathParameters: {'threadId': widget.threadId, 'postId': floor.id},
      queryParameters: {'post': ?focusedReplyId},
    );
  }

  void _openLatestPost(ThreadLatestPostModel target) {
    final parentPostId = target.parentPostId;
    if (parentPostId != null) {
      context.pushNamed(
        'post-replies',
        pathParameters: {'threadId': widget.threadId, 'postId': parentPostId},
        queryParameters: {'post': target.id},
      );
      return;
    }
    if (widget.entryTarget.postId == target.id) {
      _targetReveal.reset();
      _targetFilterRestore.reset();
      _entryTargetCoordinator.rearmForRetry();
      ref.invalidate(threadPostTargetProvider(target.id));
      setState(() {});
      return;
    }
    context.replace(
      AppRouteLocations.thread(widget.threadId, postId: target.id),
    );
  }

  Future<void> _deleteFloor(ThreadFloorModel floor) async {
    final state = ref.read(_detailProvider);
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
    showWenyouSnackBar(context, '楼层已删除。', tone: WenyouSnackBarTone.success);
    ref.invalidate(postFloorDiscussionAuthorsProvider(subthread.id));
    await ref.read(_detailProvider.notifier).refresh();
  }

  Future<void> _toggleFloorPin(ThreadFloorModel floor) async {
    final state = ref.read(_detailProvider);
    final detail = state.detail;
    final subthread = state.selectedSubthread;
    if (detail == null || subthread == null) return;
    final actionsProvider = postActionControllerProvider(widget.threadId);
    final updated = await ref
        .read(actionsProvider.notifier)
        .setPinned(
          threadFloorAsPost(detail, subthread, floor),
          pinned: !floor.isPinned,
        );
    if (!mounted) return;
    if (updated) {
      showWenyouSnackBar(
        context,
        floor.isPinned ? '已取消楼层置顶。' : '楼层已置顶。',
        tone: WenyouSnackBarTone.success,
      );
    } else if (ref.read(actionsProvider).failure?.httpStatus == 403) {
      await ref.read(_detailProvider.notifier).refresh();
    }
  }
}

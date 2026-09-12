import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_author_filter_restore.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
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
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_reading_content.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_render_diagnostics.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_sections.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
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
  final _itemListKey = GlobalKey();
  final _composerDrafts = <String, PostComposerDraft>{};
  final _entryTargetCoordinator = ThreadDetailEntryTargetCoordinator();
  final _targetReveal = DiscussionTargetRevealCoordinator();
  late final _quickScroll = ReadingQuickScrollController(
    scrollController: _subthreadScroll.controller,
    pinnedHeaderKey: _subthreadScroll.headerKey,
    onUserNavigation: () {
      _entryTargetCoordinator.cancelForUserSelection();
      _targetReveal.releaseForUserNavigation();
    },
  );
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
    _quickScroll.dispose();
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
    });
    ref.listen<int>(actionsProvider.select((value) => value.pinRevision), (
      previous,
      next,
    ) {
      if (previous == null || next <= previous) return;
      unawaited(ref.read(provider.notifier).retryFloors());
    });
    final state = ref.watch(provider);
    _quickScroll.synchronize(
      contentRevision: (state.floors, state.selectedSubthread?.body),
      scope: (
        widget.threadId,
        state.selectedSubthreadId,
        state.floorOrder,
        state.floorAuthorId,
        sessionScope,
      ),
      enabled:
          state.phase == ThreadDetailPhase.ready &&
          !state.isLoadingFloors &&
          state.selectedSubthread != null &&
          MediaQuery.viewInsetsOf(context).bottom == 0,
    );
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
    final resolvedTarget = resolvedThreadPostTarget(target);
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
          quickScrollAction: ReadingQuickScrollAction(controller: _quickScroll),
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
      body: ReadingProgressViewport(
        controller: _quickScroll,
        hasMore: state.hasMore,
        loading: state.isPrefetchingFloors,
        loadFailed:
            state.transientFailure != null &&
            state.retryAction == ThreadDetailRetryAction.loadMore,
        onRetry: () => ref.read(provider.notifier).loadMore(),
        child: switch (state.phase) {
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
                onRefresh: _refreshDetail,
                child: KeyedSubtree(
                  key: _renderGeometry.scrollViewportKey,
                  child: CustomScrollView(
                    key: PageStorageKey(
                      'thread-detail-${widget.threadId}-'
                      '${identityHashCode(_pageInstanceToken)}',
                    ),
                    controller: _subthreadScroll.controller,
                    scrollCacheExtent: discussionScrollCacheExtent,
                    physics: ReadingQuickScrollPhysics(
                      controller: _quickScroll,
                      parent: const AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      ...buildThreadDetailReadingSlivers(
                        context,
                        state,
                        provider,
                        _entryTargetCoordinator.allowsTargetEffects
                            ? target
                            : null,
                        ref: ref,
                        threadId: widget.threadId,
                        subthreadScroll: _subthreadScroll,
                        renderGeometry: _renderGeometry,
                        quickScroll: _quickScroll,
                        targetKey: _targetKey,
                        itemListKey: _itemListKey,
                        onSelectSubthread: (id) =>
                            _selectSubthreadFromUser(id, provider),
                        onCompose: _compose,
                        onDeleteFloor: _deleteFloor,
                        onToggleFloorPin: _toggleFloorPin,
                        onDiscussion: _openDiscussion,
                        onRequireLogin: _requireLogin,
                        onRetryTarget: () {
                          _entryTargetCoordinator.rearmForRetry();
                          ref.invalidate(
                            threadPostTargetProvider(
                              widget.entryTarget.postId!,
                            ),
                          );
                        },
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
      ),
      bottomNavigationBar: state.phase == ThreadDetailPhase.ready
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyedSubtree(
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
                ),
              ],
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

  Future<void> _refreshDetail() async {
    final targetPostId = widget.entryTarget.postId;
    if (targetPostId != null) {
      ref.invalidate(threadPostTargetProvider(targetPostId));
    }
    await ref.read(_detailProvider.notifier).refresh();
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
    _quickScroll.close();
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
      itemListKey: _itemListKey,
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

  Future<void> _compose(PostComposerTarget target) async {
    _quickScroll.close();
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
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: '删除这个楼层？',
      confirmLabel: '删除',
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(postActionControllerProvider(widget.threadId).notifier)
        .remove(threadFloorAsPost(detail, subthread, floor));
    if (!removed || !mounted) return;
    showWenyouSnackBar(context, '楼层已删除。', tone: WenyouSnackBarTone.success);
    final targetId = widget.entryTarget.postId;
    final target = targetId == null
        ? null
        : resolvedThreadPostTarget(
            ref.read(threadPostTargetProvider(targetId)),
          );
    if (targetId == floor.id || target?.floor.id == floor.id) {
      context.replace(
        AppRouteLocations.thread(widget.threadId, subthreadId: subthread.id),
      );
    }
    ref.invalidate(threadPostTargetProvider(floor.id));
    ref.invalidate(postFloorDiscussionAuthorsProvider(subthread.id));
    await ref.read(_detailProvider.notifier).removeDeletedFloor(floor.id);
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_author_filter_restore.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_navigation.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_navigation_feedback.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_position_button.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_selection_scope.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_window_prefetch.dart';
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
  final _countKey = GlobalKey();
  final _itemListKey = GlobalKey();
  final _composerDrafts = <String, PostComposerDraft>{};
  final _entryTargetCoordinator = ThreadDetailEntryTargetCoordinator();
  late final _quickScroll = ReadingQuickScrollController(
    scrollController: _subthreadScroll.controller,
    pinnedHeaderKey: _subthreadScroll.headerKey,
    onUserNavigation: () {
      _entryTargetCoordinator.cancelForUserSelection();
    },
  );
  String? _lastOpenedReplyTargetId;
  final _selection = DiscussionSelectionController();
  late final _prefetch = DiscussionWindowPrefetch(
    reading: _quickScroll,
    isMounted: () => mounted,
    canMutate: () =>
        !_selection.active && ModalRoute.of(context)?.isCurrent == true,
  );
  ThreadPostTargetModel? _numberTarget;
  ThreadDetailEntryTarget get _entryTarget => _navigation.targetId == null
      ? widget.entryTarget
      : ThreadDetailEntryTarget.post(_navigation.targetId!);
  late final _navigation =
      DiscussionNavigation<
          ({String subthreadId, ThreadFloorOrder order, String? authorId})
        >(
          reading: _quickScroll,
          currentScope: () {
            final state = ref.read(_detailProvider);
            return (
              subthreadId: state.selectedSubthreadId!,
              order: state.floorOrder,
              authorId: state.floorAuthorId,
            );
          },
          locate: ({number, postId, required scope, required active}) => ref
              .read(_detailProvider.notifier)
              .locate(
                number: number,
                postId: postId,
                subthreadId: scope.subthreadId,
                order: scope.order,
                authorId: scope.authorId,
                active: active,
              ),
        )
        ..addListener(_onLocated);
  void _onLocated() {
    if (!mounted) return;
    final state = ref.read(_detailProvider);
    final floor = state.floors
        .where((item) => item.id == _navigation.targetId)
        .firstOrNull;
    if (floor == null) return;
    setState(() {
      _numberTarget = ThreadPostTargetModel(
        requestedPostId: floor.id,
        threadId: widget.threadId,
        subthreadId: state.selectedSubthreadId!,
        floor: floor,
      );
      _targetAttempt++;
      _targetRevealed = false;
      _entryTargetCoordinator.rearmForRetry();
    });
  }

  void _readingChanged() {
    if (mounted) {
      ref.read(_detailProvider.notifier).visibleFloorId =
          _quickScroll.visibleBookmark?.id;
    }
  }

  @override
  void initState() {
    super.initState();
    _quickScroll.addListener(_readingChanged);
    _selection.addListener(() => _prefetch.resume());
  }

  void _openNumber() => unawaited(
    showDiscussionNavigation(
      context: context,
      navigation: _navigation,
      replies: false,
      maxNumber: ref.read(_detailProvider).maxNumber,
    ),
  );
  void _cancelNumberNavigation() {
    _navigation.clear();
    _numberTarget = null;
    _entryTargetCoordinator.cancelForUserSelection();
  }

  final _authorFilterRestore =
      DiscussionAuthorFilterRestoreCoordinator<PostDiscussionAuthor>(
        authorIdOf: (author) => author.userId,
      );
  final _renderDiagnostics = ThreadDetailRenderDiagnosticCoordinator();
  final _renderGeometry = ThreadDetailRenderGeometryProbe();
  var _didInvalidateInitialTarget = false;
  var _targetAttempt = 0;
  var _targetRevealed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInvalidateInitialTarget) return;
    _didInvalidateInitialTarget = true;
    final postId = widget.entryTarget.postId;
    if (postId != null) {
      // 新坐标必须重新核验；Riverpod 曾缓存的结果不能先显示一帧。
      ref.invalidate(threadPostTargetProvider(postId));
    }
  }

  @override
  void dispose() {
    _selection.dispose();
    _prefetch.dispose();
    _navigation.dispose();
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
      _lastOpenedReplyTargetId = null;
      _navigation.clear();
      _numberTarget = null;
      _targetAttempt += 1;
      _targetRevealed = false;
      final postId = widget.entryTarget.postId;
      if (postId != null) {
        ref.invalidate(threadPostTargetProvider(postId));
        if (postId != oldWidget.entryTarget.postId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || widget.entryTarget.postId != postId) return;
            if (ref.read(_detailProvider).phase == ThreadDetailPhase.ready) {
              unawaited(ref.read(_detailProvider.notifier).retryFloors());
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _detailProvider;
    final actionsProvider = postActionControllerProvider(widget.threadId);
    final sessionScope = ref.watch(sessionScopeProvider);
    _entryTargetCoordinator.synchronize(
      threadId: widget.threadId,
      target: _entryTarget,
      sessionScope: sessionScope,
    );
    final targetPostId = _entryTarget.postId;
    final isPostTarget =
        targetPostId != null && _entryTargetCoordinator.allowsTargetEffects;
    ref.listen(sessionScopeProvider, (previous, next) {
      if (previous == null || previous == next) return;
      _composerDrafts.clear();
      _navigation.clear();
      _numberTarget = null;
      _targetAttempt += 1;
      _targetRevealed = false;
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
          (!isPostTarget || _targetRevealed) &&
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
    final controller = ref.read(provider.notifier);
    controller.canApplyPage = () => _prefetch.canApply;
    controller.beforeWindowApply = _quickScroll.preserveVisiblePosition;
    _prefetch.update(
      ids: state.floors.map((item) => item.id).toList(),
      ready:
          (!isPostTarget || _targetRevealed) &&
          state.phase == ThreadDetailPhase.ready &&
          !state.isLoadingFloors &&
          !state.isPrefetchingFloors &&
          !state.isRefreshing &&
          state.transientFailure == null,
      hasBefore: state.hasBefore,
      hasAfter: state.hasMore,
      load: (before) => controller.loadAdjacent(before: before),
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
    final target = targetPostId == null
        ? null
        : _numberTarget != null
        ? AsyncValue<ThreadPostTargetModel>.data(_numberTarget!)
        : ref.watch(threadPostTargetProvider(targetPostId));
    final resolvedTarget = resolvedThreadPostTarget(target);
    _applyEntryTarget(
      _entryTargetCoordinator.resolve(state: state, postTarget: resolvedTarget),
      provider,
    );
    final effectiveTarget = _entryTargetCoordinator.allowsTargetEffects
        ? resolvedTarget
        : null;
    _openReplyTargetWhenReady(state, effectiveTarget);
    final targetIndex = effectiveTarget == null
        ? -1
        : state.floors.indexWhere(
            (floor) => floor.id == effectiveTarget.floor.id,
          );
    final canLocateTarget =
        isPostTarget &&
        state.phase == ThreadDetailPhase.ready &&
        !state.isRefreshing &&
        !state.isLoadingFloors &&
        effectiveTarget != null &&
        effectiveTarget.focusedReplyId == null &&
        effectiveTarget.requestedPostId == targetPostId &&
        effectiveTarget.floor.id == targetPostId &&
        !effectiveTarget.floor.isDeleted &&
        effectiveTarget.threadId == widget.threadId &&
        state.selectedSubthreadId == effectiveTarget.subthreadId;
    final targetIssue = isPostTarget
        ? _targetIssue(state, target, effectiveTarget, targetIndex)
        : null;
    final readingBody = switch (state.phase) {
      ThreadDetailPhase.loading => const ThreadDetailLoadingState(),
      ThreadDetailPhase.failed => ThreadDetailFatalState(
        failure: state.failure,
        onRetry: () => ref.read(provider.notifier).loadInitial(),
      ),
      ThreadDetailPhase.ready => RefreshIndicator(
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
                _entryTargetCoordinator.allowsTargetEffects ? target : null,
                ref: ref,
                threadId: widget.threadId,
                subthreadScroll: _subthreadScroll,
                renderGeometry: _renderGeometry,
                quickScroll: _quickScroll,
                targetKey: _targetKey,
                itemListKey: _itemListKey,
                countKey: _countKey,
                onLocate: state.maxNumber > 0 ? _openNumber : null,
                onFilterChanged: _cancelNumberNavigation,
                onSelectSubthread: (id) =>
                    _selectSubthreadFromUser(id, provider),
                onCompose: _compose,
                onDeleteFloor: _deleteFloor,
                onToggleFloorPin: _toggleFloorPin,
                onDiscussion: _openDiscussion,
                onRequireLogin: _requireLogin,
                actions: actions,
                discussionAuthors: discussionAuthors,
                authenticated: session.isAuthenticated,
                viewerId: viewerId,
              ),
            ],
          ),
        ),
      ),
    };
    final readingWithTarget =
        isPostTarget &&
            state.phase != ThreadDetailPhase.failed &&
            effectiveTarget?.focusedReplyId == null
        ? DiscussionTargetCover(
            scope: (
              widget.threadId,
              targetPostId,
              sessionScope,
              _targetAttempt,
            ),
            targetId: targetPostId,
            loadingLabel: '正在定位目标楼层',
            revealedLabel: '已定位到目标楼层',
            targetKey: _targetKey,
            itemListKey: _itemListKey,
            scrollController: _subthreadScroll.controller,
            targetIndex: targetIndex,
            itemCount: state.floors.length,
            canLocate: canLocateTarget,
            isLoadingPage: state.isLoadingFloors || state.isPrefetchingFloors,
            hasMore: state.window != null,
            targetOffset: _navigation.targetOffset,
            onLoadMore: () => unawaited(
              ref
                  .read(provider.notifier)
                  .locateFloor(effectiveTarget!.floor.id),
            ),
            onRetry: _retryEntryTarget,
            onBack: _leaveDetail,
            issue: targetIssue,
            onRevealed: () {
              if (mounted && !_targetRevealed) {
                setState(() => _targetRevealed = true);
              }
            },
            onCovered: () {
              if (mounted && _targetRevealed) {
                setState(() => _targetRevealed = false);
              }
            },
            child: readingBody,
          )
        : readingBody;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      key: _renderGeometry.scaffoldKey,
      appBar: WenyouReadingAppBar(
        key: _renderGeometry.appBarKey,
        leading: BackButton(
          key: const Key('thread-detail-back'),
          onPressed: _leaveDetail,
        ),
        actions: isPostTarget && !_targetRevealed
            ? const []
            : [
                if (state.phase == ThreadDetailPhase.ready &&
                    state.maxNumber > 0)
                  DiscussionPositionButton(
                    reading: _quickScroll,
                    entryKey: _countKey,
                    onPressed: _openNumber,
                    replies: false,
                  ),
                ...buildThreadDetailAppBarActions(
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
              ],
      ),
      body: ReadingProgressViewport(
        controller: _quickScroll,
        hasMore: (!isPostTarget || _targetRevealed) && state.hasMore,
        loading:
            (!isPostTarget || _targetRevealed) && state.isPrefetchingFloors,
        loadFailed:
            (!isPostTarget || _targetRevealed) &&
            state.transientFailure != null &&
            state.retryAction == ThreadDetailRetryAction.loadMore,
        child: DiscussionSelectionScope(
          controller: _selection,
          child: readingWithTarget,
        ),
      ),
      bottomNavigationBar: state.phase == ThreadDetailPhase.ready
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyedSubtree(
                  key: _renderGeometry.bottomBarKey,
                  child: ExcludeSemantics(
                    excluding: isPostTarget && !_targetRevealed,
                    child: IgnorePointer(
                      ignoring: isPostTarget && !_targetRevealed,
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

  Widget? _targetIssue(
    ThreadDetailState state,
    AsyncValue<ThreadPostTargetModel>? targetState,
    ThreadPostTargetModel? target,
    int targetIndex,
  ) {
    if (state.phase != ThreadDetailPhase.ready ||
        targetState == null ||
        targetState.isLoading) {
      return null;
    }
    if (targetState.hasError ||
        (target != null &&
            (target.threadId != widget.threadId ||
                state.detail?.subthreadById(target.subthreadId) == null))) {
      return ThreadTargetPostStatus(
        targetState: targetState,
        expectedThreadId: widget.threadId,
        availableSubthreadIds: {
          for (final item in state.detail!.subthreads) item.id,
        },
        onRetry: _retryEntryTarget,
      );
    }
    if (target == null) return null;
    if (target.floor.isDeleted ||
        (targetIndex >= 0 && state.floors[targetIndex].isDeleted)) {
      return const WenyouStatusBanner(
        tone: WenyouStatusTone.neutral,
        message: '目标内容已不可见',
      );
    }
    if (target.requestedPostId != _entryTarget.postId ||
        (target.focusedReplyId == null &&
            target.floor.id != target.requestedPostId)) {
      return WenyouStatusBanner(
        tone: WenyouStatusTone.error,
        message: '目标内容定位失败，请重试。',
        action: TextButton(
          onPressed: _retryEntryTarget,
          child: const Text('重新确认'),
        ),
      );
    }
    final failure = state.transientFailure;
    if (!_targetRevealed && failure != null) {
      return WenyouStatusBanner(
        tone: WenyouStatusTone.error,
        message: failure.userMessage,
        detail: wenyouFailureDetail(failure),
        action: TextButton(
          onPressed: _retryEntryTarget,
          child: const Text('重试定位'),
        ),
      );
    }
    return null;
  }

  void _retryEntryTarget() {
    _targetAttempt += 1;
    _targetRevealed = false;
    _entryTargetCoordinator.rearmForRetry();
    final postId = widget.entryTarget.postId;
    if (postId != null) ref.invalidate(threadPostTargetProvider(postId));
    if (ref.read(_detailProvider).phase == ThreadDetailPhase.ready) {
      unawaited(ref.read(_detailProvider.notifier).retryFloors());
    }
    setState(() {});
  }

  Future<void> _refreshDetail() async {
    final routeTarget = widget.entryTarget.postId;
    if (routeTarget != null && _navigation.targetId == null) {
      ref.invalidate(threadPostTargetProvider(routeTarget));
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
    _cancelNumberNavigation();
    return ref.read(provider.notifier).selectSubthread(subthreadId);
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
    _prefetch.resume();
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
      _navigation.clear();
      _numberTarget = null;
      _retryEntryTarget();
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
    final targetId = _entryTarget.postId;
    final target = targetId == null
        ? null
        : resolvedThreadPostTarget(
            ref.read(threadPostTargetProvider(targetId)),
          );
    if (targetId == floor.id || target?.floor.id == floor.id) {
      setState(_cancelNumberNavigation);
      context.replace(
        AppRouteLocations.thread(widget.threadId, subthreadId: subthread.id),
      );
    }
    _quickScroll.preserveVisiblePosition();
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

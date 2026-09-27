import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_author_filter_restore.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_target_cover.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_targets.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_discussion_states.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_content.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_reply_filters.dart';

class PostRepliesPage extends ConsumerStatefulWidget {
  const PostRepliesPage({
    required this.threadId,
    required this.rootPostId,
    this.focusedReplyId,
    this.timeReference,
    super.key,
  });

  final String threadId;
  final String rootPostId;
  final String? focusedReplyId;
  final DateTime? timeReference;

  @override
  ConsumerState<PostRepliesPage> createState() => _PostRepliesPageState();
}

class _PostRepliesPageState extends ConsumerState<PostRepliesPage> {
  final _targetKey = GlobalKey();
  final _itemListKey = GlobalKey();
  final _scrollController = ScrollController();
  final _composerDrafts = <String, PostComposerDraft>{};
  final _composeObstructionKey = GlobalKey();
  late final _quickScroll = ReadingQuickScrollController(
    scrollController: _scrollController,
    onUserNavigation: () {
      _navigationRevision += 1;
      if (mounted) setState(() {});
    },
  );
  var _openingComposer = false;
  var _didInvalidateFocusedEntry = false;
  var _targetAttempt = 0;
  var _targetRevealed = false;
  var _targetCancelled = false;
  var _navigationRevision = 0;
  final _prefetchScheduler = DiscussionPrefetchScheduler();
  final _authorFilterRestore =
      DiscussionAuthorFilterRestoreCoordinator<PostDiscussionAuthor>(
        authorIdOf: (author) => author.userId,
      );

  String get threadId => widget.threadId;
  String get rootPostId => widget.rootPostId;
  String? get focusedReplyId => widget.focusedReplyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInvalidateFocusedEntry || focusedReplyId == null) return;
    _didInvalidateFocusedEntry = true;
    ref.invalidate(
      postDiscussionControllerProvider((
        rootPostId: rootPostId,
        focusedReplyId: focusedReplyId,
      )),
    );
  }

  @override
  void didUpdateWidget(covariant PostRepliesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedReplyId != widget.focusedReplyId ||
        oldWidget.rootPostId != widget.rootPostId ||
        oldWidget.threadId != widget.threadId) {
      _targetAttempt += 1;
      _targetRevealed = false;
      _targetCancelled = false;
      if (focusedReplyId != null) {
        ref.invalidate(
          postDiscussionControllerProvider((
            rootPostId: rootPostId,
            focusedReplyId: focusedReplyId,
          )),
        );
      }
    }
  }

  @override
  void dispose() {
    _quickScroll.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = (rootPostId: rootPostId, focusedReplyId: focusedReplyId);
    final provider = postDiscussionControllerProvider(target);
    final actionsProvider = postActionControllerProvider(threadId);
    final authorsProvider = postReplyDiscussionAuthorsProvider(rootPostId);
    ref.listen(sessionScopeProvider, (previous, next) {
      if (previous == null || previous == next) return;
      _composerDrafts.clear();
      _targetAttempt += 1;
      _targetRevealed = false;
      _targetCancelled = false;
      ref
        ..invalidate(provider)
        ..invalidate(actionsProvider)
        ..invalidate(authorsProvider);
    });
    final state = ref.watch(provider);
    final isTargetEntry = focusedReplyId != null && !_targetCancelled;
    _quickScroll.synchronize(
      contentRevision: (state.root, state.replies),
      scope: (
        threadId,
        rootPostId,
        state.order,
        state.authorId,
        ref.watch(sessionScopeProvider),
      ),
      enabled:
          (!isTargetEntry || _targetRevealed) &&
          state.phase == PostDiscussionPhase.ready &&
          state.root?.threadId == threadId &&
          MediaQuery.viewInsetsOf(context).bottom == 0,
    );
    _prefetchScheduler.schedule(
      shouldPrefetch:
          (!isTargetEntry || _targetRevealed) &&
          state.phase == PostDiscussionPhase.ready &&
          !state.isRefreshing &&
          !state.isPrefetchingReplies &&
          state.transientFailure == null &&
          state.hasMore,
      isMounted: () => mounted,
      prefetch: () => ref.read(provider.notifier).prefetchRemainingReplies(),
    );
    final actions = ref.watch(actionsProvider);
    final discussionAuthors = ref.watch(authorsProvider);
    _authorFilterRestore.scheduleIfMissing(
      scopeId: rootPostId,
      selectedAuthorId: state.authorId,
      authors: discussionAuthors,
      readCurrent: () => (
        selectedAuthorId: ref.read(provider).authorId,
        authors: ref.read(authorsProvider),
      ),
      clearAuthor: () => ref.read(provider.notifier).setAuthor(null),
      isMounted: () => mounted,
    );
    final threadContext = ref
        .watch(postThreadContextProvider(threadId))
        .valueOrNull;
    final session = ref.watch(sessionControllerProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    final routeCanPop = ModalRoute.of(context)?.canPop ?? false;
    final readyRoot =
        state.phase == PostDiscussionPhase.ready &&
            state.root?.threadId == threadId
        ? state.root
        : null;
    final targetIndex = focusedReplyId == null
        ? -1
        : state.replies.indexWhere((reply) => reply.id == focusedReplyId);
    final canLocateTarget =
        isTargetEntry &&
        state.phase == PostDiscussionPhase.ready &&
        readyRoot != null &&
        !state.isRefreshing;
    final targetIssue =
        isTargetEntry &&
            !_targetRevealed &&
            state.phase == PostDiscussionPhase.ready &&
            state.transientFailure != null
        ? WenyouStatusBanner(
            tone: WenyouStatusTone.error,
            message: state.transientFailure!.userMessage,
            detail: wenyouFailureDetail(state.transientFailure),
            action: TextButton(
              onPressed: () => _retryFocusedEntry(provider),
              child: const Text('重试定位'),
            ),
          )
        : null;
    final discussionBody = switch (state.phase) {
      PostDiscussionPhase.loading => WenyouPageBody(
        maxWidth: 600,
        child: WenyouDetailSkeleton(
          label: isTargetEntry ? '正在定位目标回复' : '正在加载楼中楼讨论',
        ),
      ),
      PostDiscussionPhase.failed => PostDiscussionFailure(
        failure: state.failure,
        onRetry: () => ref.read(provider.notifier).load(),
      ),
      PostDiscussionPhase.restricted => PostDiscussionFailure(
        failure: state.failure,
        onRetry: null,
      ),
      PostDiscussionPhase.ready =>
        readyRoot == null
            ? const PostRouteMismatch()
            : RefreshIndicator(
                onRefresh: () => _refreshDiscussion(provider),
                child: PostDiscussionList(
                  state: state,
                  actions: actions,
                  viewerId: viewerId,
                  authenticated: session.isAuthenticated,
                  focusedReplyId: isTargetEntry ? focusedReplyId : null,
                  targetKey: _targetKey,
                  itemListKey: _itemListKey,
                  scrollController: _scrollController,
                  quickScroll: _quickScroll,
                  canReport: threadContext?.canReport ?? false,
                  canManageThread: threadContext?.canManageThread ?? false,
                  discussionAuthors: discussionAuthors,
                  onRetryAuthors: () => ref.invalidate(authorsProvider),
                  onOrderChanged: (order) {
                    _cancelTargetForUserFilter();
                    _quickScroll.close();
                    ref.read(provider.notifier).setOrder(order);
                  },
                  onAuthorChanged: (author) {
                    _cancelTargetForUserFilter();
                    _quickScroll.close();
                    ref.read(provider.notifier).setAuthor(author);
                  },
                  onRetry: () =>
                      ref.read(provider.notifier).retryTransientFailure(),
                  timeReference: widget.timeReference,
                  onCompose: (target) =>
                      _compose(context, ref, provider, target),
                  onDelete: (post, root) => _delete(
                    context,
                    ref,
                    provider,
                    actionsProvider,
                    post,
                    root: root,
                  ),
                  onTogglePin: (post) =>
                      _togglePin(context, ref, provider, post),
                ),
              ),
    };
    final readingWithTarget =
        isTargetEntry &&
            state.phase != PostDiscussionPhase.failed &&
            state.phase != PostDiscussionPhase.restricted &&
            (readyRoot != null || state.phase == PostDiscussionPhase.loading)
        ? DiscussionTargetCover(
            scope: (
              threadId,
              rootPostId,
              focusedReplyId,
              ref.watch(sessionScopeProvider),
              _targetAttempt,
            ),
            targetId: focusedReplyId!,
            loadingLabel: '正在定位目标回复',
            revealedLabel: '已定位到目标回复',
            targetKey: _targetKey,
            itemListKey: _itemListKey,
            scrollController: _scrollController,
            targetIndex: targetIndex,
            itemCount: state.replies.length,
            canLocate: canLocateTarget,
            isLoadingPage: state.isPrefetchingReplies,
            hasMore: state.hasMore,
            navigationRevision: _navigationRevision,
            onLoadMore: () => unawaited(
              ref.read(provider.notifier).locateReply(focusedReplyId!),
            ),
            onRetry: () => _retryFocusedEntry(provider),
            onBack: () => _goBack(context),
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
            child: discussionBody,
          )
        : discussionBody;
    return PopScope<Object?>(
      canPop: routeCanPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToRoot(context);
      },
      child: Scaffold(
        appBar: WenyouReadingAppBar(
          leading: routeCanPop
              ? null
              : BackButton(onPressed: () => _goBack(context)),
          title: readyRoot == null
              ? const Text('楼中楼讨论')
              : PostDiscussionTitle(root: readyRoot),
          actions: [_returnToRootAction(context)],
        ),
        body: ReadingProgressViewport(
          controller: _quickScroll,
          hasMore: (!isTargetEntry || _targetRevealed) && state.hasMore,
          loading:
              (!isTargetEntry || _targetRevealed) && state.isPrefetchingReplies,
          loadFailed:
              (!isTargetEntry || _targetRevealed) &&
              state.transientFailure != null &&
              state.retryAction == PostDiscussionRetryAction.loadMore,
          bottomObstructionKey: _composeObstructionKey,
          child: readingWithTarget,
        ),
        // 保持测量节点稳定，避免切号期间 Scaffold 同时保留新旧发表入口。
        floatingActionButton: KeyedSubtree(
          key: _composeObstructionKey,
          child: ExcludeSemantics(
            excluding: isTargetEntry && !_targetRevealed,
            child: IgnorePointer(
              ignoring: isTargetEntry && !_targetRevealed,
              child: readyRoot == null
                  ? const SizedBox.shrink()
                  : WenyouComposerAction(
                      key: const Key('post-reply-compose'),
                      label: session.isAuthenticated ? '发表回复…' : '登录后发表回复',
                      icon: session.isAuthenticated
                          ? WenyouIconIds.actionReply
                          : WenyouIconIds.actionLogin,
                      onPressed: session.isAuthenticated
                          ? () => _compose(
                              context,
                              ref,
                              provider,
                              postReplyTarget(readyRoot, readyRoot),
                            )
                          : () => context.pushNamed(
                              'login',
                              queryParameters: {'returnTo': _location()},
                            ),
                    ),
            ),
          ),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      ),
    );
  }

  void _retryFocusedEntry(PostDiscussionControllerProvider provider) {
    if (!mounted) return;
    setState(() {
      _targetAttempt += 1;
      _targetRevealed = false;
      _targetCancelled = false;
    });
    unawaited(ref.read(provider.notifier).load());
  }

  Future<void> _refreshDiscussion(
    PostDiscussionControllerProvider provider,
  ) async {
    if (focusedReplyId != null && !_targetCancelled) {
      setState(() {
        _targetAttempt += 1;
        _targetRevealed = false;
      });
    }
    await ref.read(provider.notifier).refresh();
  }

  void _cancelTargetForUserFilter() {
    if (focusedReplyId == null || _targetCancelled) return;
    setState(() => _targetCancelled = true);
  }

  void _goBack(BuildContext context) =>
      Navigator.of(context).canPop() ? context.pop() : _goToRoot(context);

  void _goToRoot(BuildContext context) => context.go(
    AppRouteLocations.thread(threadId, postId: rootPostId),
    extra: WenyouRouteTransitionIntent.instantFallback,
  );

  Widget _returnToRootAction(BuildContext context) {
    return IconButton(
      tooltip: '返回原楼层',
      onPressed: () => _goToRoot(context),
      icon: const WenyouIcon(WenyouIconIds.contentLayers),
    );
  }

  String _location() {
    final query = <String, String>{'post': ?focusedReplyId};
    return Uri(
      pathSegments: ['', 'threads', threadId, 'posts', rootPostId, 'replies'],
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  Future<void> _compose(
    BuildContext context,
    WidgetRef ref,
    PostDiscussionControllerProvider provider,
    PostComposerTarget target,
  ) async {
    _quickScroll.close();
    if (_openingComposer) return;
    _openingComposer = true;
    final draftKey = postComposerDraftKey(target);
    final openedSessionScope = ref.read(sessionScopeProvider);
    try {
      final result = await showPostComposerSheet(
        context: context,
        target: target,
        initialDraft: _composerDrafts[draftKey],
        onDraftChanged: (draft) {
          if (!mounted) return;
          if (ref.read(sessionScopeProvider) != openedSessionScope) return;
          setPostComposerDraft(_composerDrafts, draftKey, draft);
        },
      );
      if (!mounted) return;
      if (ref.read(sessionScopeProvider) != openedSessionScope) return;
      if (result != null) {
        _composerDrafts.remove(draftKey);
        if (target.kind == PostComposerKind.createReply) {
          ref.invalidate(postReplyDiscussionAuthorsProvider(rootPostId));
        }
        await _refreshDiscussion(provider);
      }
    } finally {
      _openingComposer = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    PostDiscussionControllerProvider provider,
    AutoDisposeStateNotifierProvider<PostActionController, PostActionState>
    actionsProvider,
    PostItem post, {
    required bool root,
  }) async {
    final confirmed = await showWenyouConfirmationDialog(
      context: context,
      title: root ? '删除原楼层？' : '删除这条回复？',
      message: root ? '原楼层删除后，楼中楼讨论将不再可访问。' : '删除后无法恢复。',
      confirmLabel: '删除',
      cancelLabel: '取消',
      tone: WenyouConfirmationTone.destructive,
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await ref.read(actionsProvider.notifier).remove(post);
    if (!removed || !context.mounted) return;
    if (root) {
      context.go(AppRouteLocations.thread(threadId));
    } else {
      ref.invalidate(postReplyDiscussionAuthorsProvider(rootPostId));
      await _refreshDiscussion(provider);
    }
  }

  Future<void> _togglePin(
    BuildContext context,
    WidgetRef ref,
    PostDiscussionControllerProvider provider,
    PostItem post,
  ) async {
    final actionsProvider = postActionControllerProvider(threadId);
    final actions = ref.read(actionsProvider.notifier);
    final updated = await actions.setPinned(post, pinned: !post.isPinned);
    if (!context.mounted) return;
    if (updated) {
      showWenyouSnackBar(
        context,
        post.isPinned ? '已取消楼层置顶。' : '楼层已置顶。',
        tone: WenyouSnackBarTone.success,
      );
      await _refreshDiscussion(provider);
    } else if (ref.read(actionsProvider).failure?.httpStatus == 403) {
      ref.invalidate(postThreadContextProvider(threadId));
      await _refreshDiscussion(provider);
    }
  }
}

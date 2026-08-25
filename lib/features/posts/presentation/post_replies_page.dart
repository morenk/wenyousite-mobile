import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/navigation/wenyou_page_transitions.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/discussion_author_filter_restore.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_item_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_transient_target_frame.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_targets.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_discussion_states.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_reply_filters.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

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
  final _scrollController = ScrollController();
  final _composerDrafts = <String, String>{};
  final _targetReveal = DiscussionTargetRevealCoordinator();
  var _openingComposer = false;
  final _prefetchScheduler = DiscussionPrefetchScheduler();
  final _authorFilterRestore =
      DiscussionAuthorFilterRestoreCoordinator<PostDiscussionAuthor>(
        authorIdOf: (author) => author.userId,
      );

  String get threadId => widget.threadId;
  String get rootPostId => widget.rootPostId;
  String? get focusedReplyId => widget.focusedReplyId;

  @override
  void didUpdateWidget(covariant PostRepliesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedReplyId != widget.focusedReplyId) {
      _targetReveal.reset();
    }
  }

  @override
  void dispose() {
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
      ref
        ..invalidate(provider)
        ..invalidate(actionsProvider)
        ..invalidate(authorsProvider);
    });
    final state = ref.watch(provider);
    _prefetchScheduler.schedule(
      shouldPrefetch:
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
    _revealReplyWhenReady(state);
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
        body: switch (state.phase) {
          PostDiscussionPhase.loading => const WenyouPageBody(
            maxWidth: 600,
            child: WenyouDetailSkeleton(label: '正在加载楼中楼讨论'),
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
            state.root?.threadId != threadId
                ? const PostRouteMismatch()
                : NotificationListener<ScrollNotification>(
                    onNotification: _handleUserScroll,
                    child: NotificationListener<ScrollMetricsNotification>(
                      onNotification: _handleTargetLayoutChange,
                      child: RefreshIndicator(
                        onRefresh: () => ref.read(provider.notifier).refresh(),
                        child: _DiscussionList(
                          state: state,
                          actions: actions,
                          viewerId: viewerId,
                          authenticated: session.isAuthenticated,
                          focusedReplyId: focusedReplyId,
                          targetKey: _targetKey,
                          scrollController: _scrollController,
                          canReport: threadContext?.canReport ?? false,
                          canManageThread:
                              threadContext?.canManageThread ?? false,
                          discussionAuthors: discussionAuthors,
                          onRetryAuthors: () => ref.invalidate(authorsProvider),
                          onOrderChanged: ref.read(provider.notifier).setOrder,
                          onAuthorChanged: ref
                              .read(provider.notifier)
                              .setAuthor,
                          onLoadMore: () =>
                              ref.read(provider.notifier).loadMore(),
                          onRetry: () => ref
                              .read(provider.notifier)
                              .retryTransientFailure(),
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
                        ),
                      ),
                    ),
                  ),
        },
        floatingActionButton: readyRoot == null
            ? null
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
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      ),
    );
  }

  void _revealReplyWhenReady(PostDiscussionState state) {
    final replyId = focusedReplyId;
    if (replyId == null || state.phase != PostDiscussionPhase.ready) {
      return;
    }
    final scopeSignature =
        '$replyId:${state.order.name}:${state.authorId ?? ''}';
    final targetIndex = state.replies.indexWhere(
      (reply) => reply.id == replyId,
    );
    final signature =
        '$replyId:${state.order.name}:${state.authorId}:'
        '$targetIndex:${state.replies.length}';
    _targetReveal.schedule(
      targetId: replyId,
      scopeSignature: scopeSignature,
      contentSignature: signature,
      targetIndex: targetIndex,
      itemCount: state.replies.length,
      ready: targetIndex >= 0,
      targetKey: _targetKey,
      scrollController: _scrollController,
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
  }

  bool _handleTargetLayoutChange(ScrollMetricsNotification notification) {
    return _targetReveal.handleLayoutChange(
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
  }

  bool _handleUserScroll(ScrollNotification notification) =>
      _targetReveal.handleUserScroll(notification);

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
    if (_openingComposer) return;
    _openingComposer = true;
    final draftKey = postComposerDraftKey(target);
    final openedSessionScope = ref.read(sessionScopeProvider);
    try {
      final result = await showPostComposerSheet(
        context: context,
        target: target,
        initialDraft: _composerDrafts[draftKey],
        onDraftChanged: (content) {
          if (!mounted) return;
          if (ref.read(sessionScopeProvider) != openedSessionScope) return;
          if (content == target.initialContent) {
            _composerDrafts.remove(draftKey);
          } else {
            _composerDrafts[draftKey] = content;
          }
        },
      );
      if (!mounted) return;
      if (ref.read(sessionScopeProvider) != openedSessionScope) return;
      if (result != null) {
        _composerDrafts.remove(draftKey);
        if (target.kind == PostComposerKind.createReply) {
          ref.invalidate(postReplyDiscussionAuthorsProvider(rootPostId));
        }
        await ref.read(provider.notifier).refresh();
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(root ? '删除原楼层？' : '删除这条回复？'),
        content: Text(root ? '原楼层删除后，楼中楼讨论将不再可访问。' : '删除后无法恢复。'),
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
    if (confirmed != true || !context.mounted) return;
    final removed = await ref.read(actionsProvider.notifier).remove(post);
    if (!removed || !context.mounted) return;
    if (root) {
      context.go(AppRouteLocations.thread(threadId));
    } else {
      ref.invalidate(postReplyDiscussionAuthorsProvider(rootPostId));
      await ref.read(provider.notifier).refresh();
    }
  }
}

class _DiscussionList extends StatelessWidget {
  const _DiscussionList({
    required this.state,
    required this.actions,
    required this.viewerId,
    required this.authenticated,
    required this.focusedReplyId,
    required this.targetKey,
    required this.scrollController,
    required this.canReport,
    required this.canManageThread,
    required this.discussionAuthors,
    required this.onRetryAuthors,
    required this.onOrderChanged,
    required this.onAuthorChanged,
    required this.onLoadMore,
    required this.onRetry,
    required this.timeReference,
    required this.onCompose,
    required this.onDelete,
  });

  final PostDiscussionState state;
  final PostActionState actions;
  final String? viewerId;
  final bool authenticated;
  final String? focusedReplyId;
  final GlobalKey targetKey;
  final ScrollController scrollController;
  final bool canReport;
  final bool canManageThread;
  final AsyncValue<List<PostDiscussionAuthor>> discussionAuthors;
  final VoidCallback onRetryAuthors;
  final ValueChanged<PostReplyOrder> onOrderChanged;
  final ValueChanged<String?> onAuthorChanged;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final DateTime? timeReference;
  final ValueChanged<PostComposerTarget> onCompose;
  final void Function(PostItem post, bool root) onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final root = state.root!;
    final authors = discussionAuthors.valueOrNull ?? const [];
    final horizontal = wenyouHorizontalPagePadding(context);
    final leadingWidgets = <Widget>[
      if (actions.failure != null) ...[
        WenyouStatusBanner(
          message: actions.failure!.userMessage,
          detail: wenyouRequestDetail(actions.failure),
          tone: WenyouStatusTone.error,
        ),
        SizedBox(height: tokens.space12),
      ],
      DiscussionKeepAlive(
        child: _PostCard(
          key: const Key('post-discussion-root'),
          post: root,
          root: true,
          timeReference: timeReference,
          canEdit: root.isAuthoredBy(viewerId),
          canDelete: root.isAuthoredBy(viewerId) || canManageThread,
          pending: actions.pendingPostId == root.id,
          reportReturnTo:
              canReport && !root.isDeleted && !root.isAuthoredBy(viewerId)
              ? _reportLocation(root, root.id)
              : null,
          onReply: authenticated
              ? () => onCompose(postReplyTarget(root, root))
              : null,
          onEdit: () => onCompose(postEditTarget(root, '编辑原楼层')),
          onDelete: () => onDelete(root, true),
        ),
      ),
      SizedBox(height: tokens.space12),
      PostReplyFilters(
        state: state,
        replyCount: root.replyCount,
        authors: authors,
        authorsLoading: discussionAuthors.isLoading,
        authorsFailure: discussionAuthors.hasError
            ? mapApplicationFailure(discussionAuthors.error!, '回复者列表加载失败，请重试。')
            : null,
        onRetryAuthors: onRetryAuthors,
        onOrderChanged: onOrderChanged,
        onAuthorChanged: onAuthorChanged,
      ),
      SizedBox(height: tokens.space12),
      if (state.transientFailure != null) ...[
        WenyouStatusBanner(
          message: state.transientFailure!.userMessage,
          detail: wenyouRequestDetail(state.transientFailure),
          tone: WenyouStatusTone.error,
          action: TextButton(onPressed: onRetry, child: const Text('重试')),
        ),
        SizedBox(height: tokens.space12),
      ],
    ];
    return CustomScrollView(
      key: const Key('post-replies-list'),
      controller: scrollController,
      scrollCacheExtent: discussionScrollCacheExtent,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            tokens.space8,
            horizontal,
            0,
          ),
          sliver: SliverList.list(
            children: [
              for (final child in leadingWidgets)
                WenyouConstrainedWidth(child: child),
            ],
          ),
        ),
        if (state.replies.isEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            sliver: const SliverToBoxAdapter(
              child: WenyouConstrainedWidth(
                child: WenyouEmptyState(
                  icon: WenyouIconIds.metricReplies,
                  title: '还没有回复',
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            sliver: SliverList.builder(
              itemCount: state.replies.length,
              itemBuilder: (context, index) {
                final reply = state.replies[index];
                return DiscussionKeepAlive(
                  key: ValueKey('post-reply-item-${reply.id}'),
                  child: WenyouConstrainedWidth(
                    child: Column(
                      children: [
                        if (index > 0)
                          WenyouContentItemDivider(
                            key: ValueKey('post-reply-divider-${reply.id}'),
                          ),
                        _PostCard(
                          key: Key('post-reply-${reply.id}'),
                          post: reply,
                          timeReference: timeReference,
                          focused: reply.id == focusedReplyId,
                          targetFrameKey: reply.id == focusedReplyId
                              ? targetKey
                              : null,
                          canEdit: reply.isAuthoredBy(viewerId),
                          canDelete:
                              reply.isAuthoredBy(viewerId) || canManageThread,
                          pending: actions.pendingPostId == reply.id,
                          reportReturnTo:
                              canReport &&
                                  !reply.isDeleted &&
                                  !reply.isAuthoredBy(viewerId)
                              ? _reportLocation(root, reply.id)
                              : null,
                          onReply: authenticated
                              ? () => onCompose(postReplyTarget(root, reply))
                              : null,
                          onEdit: () =>
                              onCompose(postEditTarget(reply, '编辑回复')),
                          onDelete: () => onDelete(reply, false),
                        ),
                      ],
                    ),
                  ),
                );
              },
              findChildIndexCallback: (key) {
                final value = key is ValueKey<String> ? key.value : null;
                if (value == null || !value.startsWith('post-reply-item-')) {
                  return null;
                }
                final replyId = value.substring('post-reply-item-'.length);
                final index = state.replies.indexWhere(
                  (reply) => reply.id == replyId,
                );
                return index < 0 ? null : index;
              },
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontal,
            state.hasMore ? tokens.space12 : 0,
            horizontal,
            tokens.minimumTouchTarget + tokens.space32 + tokens.space16,
          ),
          sliver: SliverToBoxAdapter(
            child: WenyouConstrainedWidth(
              child: state.hasMore
                  ? OutlinedButton.icon(
                      key: const Key('post-replies-load-more'),
                      onPressed: state.isLoadingMore ? null : onLoadMore,
                      icon: state.isLoadingMore
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const WenyouIcon(WenyouIconIds.navigationExpand),
                      label: Text(state.isLoadingMore ? '正在加载' : '加载更多回复'),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  String _reportLocation(PostItem root, String postId) {
    return Uri(
      pathSegments: ['', 'threads', root.threadId, 'posts', root.id, 'replies'],
      queryParameters: {if (postId != root.id) 'post': postId},
    ).toString();
  }
}

class _PostCard extends ConsumerWidget {
  const _PostCard({
    required this.post,
    this.root = false,
    this.focused = false,
    this.canEdit = false,
    this.canDelete = false,
    this.pending = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.reportReturnTo,
    this.targetFrameKey,
    this.timeReference,
    super.key,
  });

  final PostItem post;
  final bool root;
  final bool focused;
  final bool canEdit;
  final bool canDelete;
  final bool pending;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? reportReturnTo;
  final Key? targetFrameKey;
  final DateTime? timeReference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final canTapReply = onReply != null && !pending && !post.isDeleted;
    Widget buildCard(VoidCallback openActions) => WenyouTransientTargetFrame(
      key: targetFrameKey,
      targetId: focused ? post.id : null,
      announcement: '已定位到目标回复',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space4,
          vertical: tokens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostAuthorLine(
              post: post,
              root: root,
              timeReference: timeReference,
            ),
            SizedBox(height: root ? tokens.space12 : tokens.space8),
            if (post.isDeleted)
              Text(
                root ? '该楼层已删除。' : '该回复已删除。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
              )
            else
              StickerPostMarkdown(
                postId: post.id,
                data: post.content,
                diceLabels: {
                  for (final roll in post.diceRolls)
                    roll.nodeId: '${roll.notation} = ${roll.total}',
                },
                diceSemantics: {
                  for (final roll in post.diceRolls)
                    roll.nodeId: formatWenyouDiceSemantics(
                      notation: roll.notation,
                      results: roll.results,
                      total: roll.total,
                    ),
                },
                diceDetails: {
                  for (final roll in post.diceRolls)
                    roll.nodeId.toLowerCase(): WenyouDiceRollDetail(
                      results: roll.results,
                      total: roll.total,
                    ),
                },
                bodyFontSize: 17,
                bodyHeight: 1.8,
                onTapText: canTapReply ? onReply : null,
                onLongPressNonText: openActions,
              ),
          ],
        ),
      ),
    );
    return PostCardActionMenu(
      canCopyText: !post.isDeleted,
      canEdit: canEdit,
      canDelete: canDelete,
      canReport: reportReturnTo != null,
      pending: pending,
      semanticLabel: root ? '楼层操作' : '回复操作',
      actionKeyPrefix: 'post-card-action-${post.id}',
      onSelected: (action) => _handleAction(action, context, ref),
      anchorBuilder: (context, handle) => Semantics(
        container: true,
        button: canTapReply,
        hint: canTapReply
            ? (root
                  ? '点击回复楼层，长按文字选择，长按其他区域打开楼层操作'
                  : '点击回复这条回复，长按文字选择，长按其他区域打开回复操作')
            : (root ? '长按文字选择，长按其他区域打开楼层操作' : '长按文字选择，长按其他区域打开回复操作'),
        onTap: canTapReply ? onReply : null,
        onLongPress: handle.open,
        child: GestureDetector(
          key: Key('post-card-${post.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: canTapReply ? onReply : null,
          onLongPress: handle.open,
          child: buildCard(handle.open),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    PostCardAction action,
    BuildContext context,
    WidgetRef ref,
  ) async {
    switch (action) {
      case PostCardAction.copyText:
        await copyPostCardValue(context, post.content, '内容已复制');
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.edit:
        onEdit?.call();
      case PostCardAction.delete:
        onDelete?.call();
      case PostCardAction.report:
        if (reportReturnTo == null) return;
        await showWenyouReportFlow(
          context: context,
          ref: ref,
          target: ReportTarget.post(post.id),
          targetLabel: root ? '这个楼层' : '这条回复',
          returnTo: reportReturnTo!,
        );
    }
  }

  String _publicLink() {
    final location = root
        ? AppRouteLocations.thread(post.threadId, postId: post.id)
        : Uri(
            pathSegments: [
              '',
              'threads',
              post.threadId,
              'posts',
              post.parentPostId ?? post.id,
              'replies',
            ],
            queryParameters: {'post': post.id},
          ).toString();
    return Uri.parse('https://wenyou.site').resolve(location).toString();
  }
}

class _PostAuthorLine extends StatelessWidget {
  const _PostAuthorLine({
    required this.post,
    required this.root,
    required this.timeReference,
  });

  final PostItem post;
  final bool root;
  final DateTime? timeReference;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final avatarSize = root ? 36.0 : 28.0;
    return Row(
      children: [
        WenyouAvatarButton(
          key: Key('post-author-avatar-${post.id}'),
          username: post.author.username,
          avatarUrl: post.author.avatarUrl,
          visualSize: avatarSize,
          onTap: () => context.push(AppRouteLocations.user(post.author.id)),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.author.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: root
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  SizedBox(width: tokens.space4),
                  WenyouLevelBadge(
                    key: Key('post-level-${post.id}'),
                    level: post.author.level,
                  ),
                ],
              ),
              SizedBox(height: tokens.space4 / 2),
              Semantics(
                label: [
                  if (root) '楼层 ${post.floorNumber ?? '-'}',
                  if (!root && post.replyToAuthor != null)
                    '回复 ${post.replyToAuthor!.username}'
                  else if (!root)
                    '回复',
                  '发布时间：${formatWenyouExactTime(post.createdAt)}',
                ].join('，'),
                excludeSemantics: true,
                child: Text(
                  [
                    if (root) '#${post.floorNumber ?? '-'}',
                    if (!root && post.replyToAuthor != null)
                      '回复 @${post.replyToAuthor!.username}'
                    else if (!root)
                      '回复',
                    formatWenyouRelativeTime(
                      post.createdAt,
                      now: timeReference,
                    ),
                  ].join(' · '),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

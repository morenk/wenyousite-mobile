import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_card_action_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

part 'post_reply_filters.dart';

class PostRepliesPage extends ConsumerWidget {
  const PostRepliesPage({
    required this.threadId,
    required this.rootPostId,
    this.focusedReplyId,
    this.reportsEnabled = false,
    super.key,
  });

  final String threadId;
  final String rootPostId;
  final String? focusedReplyId;
  final bool reportsEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = (rootPostId: rootPostId, focusedReplyId: focusedReplyId);
    final provider = postDiscussionControllerProvider(target);
    final actionsProvider = postActionControllerProvider(threadId);
    ref.listen(sessionControllerProvider.select((state) => state.status), (
      previous,
      next,
    ) {
      if (previous == null || previous == next) return;
      ref
        ..invalidate(provider)
        ..invalidate(actionsProvider);
    });
    final state = ref.watch(provider);
    final actions = ref.watch(actionsProvider);
    final session = ref.watch(sessionControllerProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    final readyRoot =
        state.phase == PostDiscussionPhase.ready &&
            state.root?.threadId == threadId
        ? state.root
        : null;
    return Scaffold(
      appBar: AppBar(
        title: readyRoot == null
            ? const Text('楼中楼讨论')
            : _DiscussionTitle(root: readyRoot),
        actions: [_returnToRootAction(context)],
      ),
      body: switch (state.phase) {
        PostDiscussionPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        PostDiscussionPhase.failed => _DiscussionFailure(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        PostDiscussionPhase.ready =>
          state.root?.threadId != threadId
              ? const _RouteMismatch()
              : RefreshIndicator(
                  onRefresh: () => ref.read(provider.notifier).refresh(),
                  child: _DiscussionList(
                    state: state,
                    actions: actions,
                    viewerId: viewerId,
                    authenticated: session.isAuthenticated,
                    focusedReplyId: focusedReplyId,
                    reportsEnabled: reportsEnabled,
                    onOrder: (order) =>
                        ref.read(provider.notifier).setOrder(order),
                    onAuthor: (authorId) =>
                        ref.read(provider.notifier).setAuthor(authorId),
                    onLoadMore: () => ref.read(provider.notifier).loadMore(),
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
                      _replyTarget(readyRoot, readyRoot),
                    )
                  : () => context.pushNamed(
                      'login',
                      queryParameters: {'returnTo': _location()},
                    ),
            ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
    );
  }

  Widget _returnToRootAction(BuildContext context) {
    return IconButton(
      tooltip: '返回原楼层',
      onPressed: () =>
          context.go(AppRouteLocations.thread(threadId, postId: rootPostId)),
      icon: const WenyouIcon(WenyouIconIds.contentLayers),
    );
  }

  String _location() {
    final query = <String, String>{
      if (reportsEnabled) 'reports': '1',
      'post': ?focusedReplyId,
    };
    return Uri(
      pathSegments: ['', 'threads', threadId, 'posts', rootPostId, 'replies'],
      queryParameters: query.isEmpty ? null : query,
    ).toString();
  }

  Future<void> _compose(
    BuildContext context,
    WidgetRef ref,
    AutoDisposeStateNotifierProvider<
      PostDiscussionController,
      PostDiscussionState
    >
    provider,
    PostComposerTarget target,
  ) async {
    final result = await showPostComposerSheet(
      context: context,
      target: target,
    );
    if (result != null) await ref.read(provider.notifier).refresh();
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AutoDisposeStateNotifierProvider<
      PostDiscussionController,
      PostDiscussionState
    >
    provider,
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
      await ref.read(provider.notifier).refresh();
    }
  }
}

class _DiscussionList extends StatelessWidget {
  static const _contentCacheExtent = 4000.0;

  const _DiscussionList({
    required this.state,
    required this.actions,
    required this.viewerId,
    required this.authenticated,
    required this.focusedReplyId,
    required this.reportsEnabled,
    required this.onOrder,
    required this.onAuthor,
    required this.onLoadMore,
    required this.onCompose,
    required this.onDelete,
  });

  final PostDiscussionState state;
  final PostActionState actions;
  final String? viewerId;
  final bool authenticated;
  final String? focusedReplyId;
  final bool reportsEnabled;
  final ValueChanged<PostReplyOrder> onOrder;
  final ValueChanged<String?> onAuthor;
  final VoidCallback onLoadMore;
  final ValueChanged<PostComposerTarget> onCompose;
  final void Function(PostItem post, bool root) onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final root = state.root!;
    final authors = <String, PostAuthor>{
      root.author.id: root.author,
      for (final reply in state.replies) reply.author.id: reply.author,
    };
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    final leadingWidgets = <Widget>[
      if (actions.failure != null) ...[
        WenyouStatusBanner(
          message: actions.failure!.userMessage,
          detail: _failureDetail(actions.failure),
          tone: WenyouStatusTone.error,
        ),
        SizedBox(height: tokens.space12),
      ],
      _PostCard(
        key: const Key('post-discussion-root'),
        post: root,
        root: true,
        canEdit: root.isAuthoredBy(viewerId),
        canDelete: root.isAuthoredBy(viewerId),
        pending: actions.pendingPostId == root.id,
        reportReturnTo: reportsEnabled && !root.isAuthoredBy(viewerId)
            ? _reportLocation(root, root.id)
            : null,
        onReply: authenticated
            ? () => onCompose(_replyTarget(root, root))
            : null,
        onEdit: () => onCompose(_editTarget(root, '编辑原楼层')),
        onDelete: () => onDelete(root, true),
      ),
      SizedBox(height: tokens.space12),
      _ReplyFilters(
        state: state,
        replyCount: root.replyCount,
        authors: authors.values.toList(growable: false),
        onOrder: onOrder,
        onAuthor: onAuthor,
      ),
      SizedBox(height: tokens.space12),
      if (state.transientFailure != null) ...[
        WenyouStatusBanner(
          message: state.transientFailure!.userMessage,
          detail: _failureDetail(state.transientFailure),
          tone: WenyouStatusTone.error,
          action: TextButton(onPressed: onLoadMore, child: const Text('重试')),
        ),
        SizedBox(height: tokens.space12),
      ],
    ];
    return CustomScrollView(
      key: const Key('post-replies-list'),
      scrollCacheExtent: const ScrollCacheExtent.pixels(_contentCacheExtent),
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
                  message: '成为这段讨论的第一位回复者。',
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
                return WenyouConstrainedWidth(
                  child: Column(
                    children: [
                      if (index > 0) Divider(height: tokens.space24),
                      _PostCard(
                        key: Key('post-reply-${reply.id}'),
                        post: reply,
                        focused: reply.id == focusedReplyId,
                        canEdit: reply.isAuthoredBy(viewerId),
                        canDelete: reply.isAuthoredBy(viewerId),
                        pending: actions.pendingPostId == reply.id,
                        reportReturnTo:
                            reportsEnabled && !reply.isAuthoredBy(viewerId)
                            ? _reportLocation(root, reply.id)
                            : null,
                        onReply: authenticated
                            ? () => onCompose(_replyTarget(root, reply))
                            : null,
                        onEdit: () => onCompose(_editTarget(reply, '编辑回复')),
                        onDelete: () => onDelete(reply, false),
                      ),
                    ],
                  ),
                );
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
      queryParameters: {'reports': '1', if (postId != root.id) 'post': postId},
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final canTapReply = onReply != null && !pending && !post.isDeleted;
    final card = Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space4,
        vertical: tokens.space12,
      ),
      decoration: BoxDecoration(
        color: focused ? tokens.accentedBackground : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostAuthorLine(post: post, root: root),
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
              bodyFontSize: root ? 17 : 16,
              bodyHeight: root ? 1.8 : 1.75,
              onTapText: canTapReply ? onReply : null,
            ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: canTapReply,
      hint: canTapReply
          ? (root ? '点击回复楼层，长按打开楼层操作' : '点击回复这条回复，长按打开回复操作')
          : (root ? '长按打开楼层操作' : '长按打开回复操作'),
      onTap: canTapReply ? onReply : null,
      child: GestureDetector(
        key: Key('post-card-${post.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: canTapReply ? onReply : null,
        onLongPress: () => _showActions(context, ref),
        child: card,
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showPostCardActionSheet(
      context: context,
      title: root ? '楼层操作' : '回复操作',
      authorName: post.author.username,
      canCopyText: !post.isDeleted,
      canReply: onReply != null,
      canEdit: canEdit,
      canDelete: canDelete,
      canReport: reportReturnTo != null,
      pending: pending,
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case PostCardAction.copyText:
        await copyPostCardValue(context, post.content, '内容已复制');
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.reply:
        onReply?.call();
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
  const _PostAuthorLine({required this.post, required this.root});

  final PostItem post;
  final bool root;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final avatarSize = root ? 36.0 : 28.0;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: WenyouIcon(WenyouIconIds.identityMember, color: tokens.mutedText),
    );
    return Row(
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: avatarSize,
            child: post.author.avatarUrl == null
                ? fallback
                : WenyouCachedImage(
                    imageUrl: post.author.avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => fallback,
                    errorWidget: (_, _, _) => fallback,
                  ),
          ),
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
              Text(
                [
                  if (root) '#${post.floorNumber ?? '-'}',
                  if (!root && post.replyToAuthor != null)
                    '回复 @${post.replyToAuthor!.username}'
                  else if (!root)
                    '回复',
                  formatWenyouRelativeTime(post.createdAt),
                ].join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscussionFailure extends StatelessWidget {
  const _DiscussionFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.metricReplies,
          title: failure?.httpStatus == 404 ? '楼层暂时不可见' : '楼中楼讨论没有加载完成',
          message: failure?.userMessage ?? '请稍后重试。',
          detail: _failureDetail(failure),
          action: FilledButton(onPressed: onRetry, child: const Text('重试')),
        ),
      ),
    );
  }
}

class _RouteMismatch extends StatelessWidget {
  const _RouteMismatch();

  @override
  Widget build(BuildContext context) {
    return const WenyouPageBody(
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: WenyouIconIds.actionUnlink,
          title: '楼层不属于当前主题',
          message: '请返回主题详情后重新打开。',
        ),
      ),
    );
  }
}

PostComposerTarget _replyTarget(PostItem root, PostItem target) {
  return (
    kind: PostComposerKind.createReply,
    threadId: root.threadId,
    subthreadId: root.subthreadId,
    postId: null,
    parentPostId: root.id,
    replyToPostId: target.id,
    version: null,
    initialContent: '',
    label: '回复 @${target.author.username}',
  );
}

PostComposerTarget _editTarget(PostItem post, String label) {
  return (
    kind: PostComposerKind.editPost,
    threadId: post.threadId,
    subthreadId: post.subthreadId,
    postId: post.id,
    parentPostId: post.parentPostId,
    replyToPostId: post.replyToPostId,
    version: post.version,
    initialContent: post.content,
    label: label,
  );
}

String? _failureDetail(ApiFailure? failure) {
  final requestId = failure?.requestId;
  return requestId == null ? null : '请求 ID：$requestId';
}

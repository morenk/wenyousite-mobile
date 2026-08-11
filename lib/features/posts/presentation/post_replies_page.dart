import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';

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
        title: const Text('楼中楼讨论'),
        actions: [
          IconButton(
            tooltip: '返回原楼层',
            onPressed: () => context.go(
              AppRouteLocations.thread(threadId, postId: rootPostId),
            ),
            icon: const Icon(Icons.layers_outlined),
          ),
        ],
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
      bottomNavigationBar: readyRoot == null
          ? null
          : WenyouComposerDock(
              key: const Key('post-reply-compose'),
              label: session.isAuthenticated ? '发表回复…' : '登录后发表回复',
              icon: session.isAuthenticated
                  ? Icons.reply_rounded
                  : Icons.login_rounded,
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
    return ListView(
      key: const Key('post-replies-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width <= 400
            ? tokens.space12
            : tokens.space24,
        tokens.space16,
        MediaQuery.sizeOf(context).width <= 400
            ? tokens.space12
            : tokens.space24,
        tokens.space32,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  root.threadTitle ?? '主题',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
                SizedBox(height: tokens.space4),
                Text(
                  root.subthreadTitle ?? '子贴',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.space12),
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
                  onEdit: () => onCompose(_editTarget(root, '编辑原楼层')),
                  onDelete: () => onDelete(root, true),
                ),
                SizedBox(height: tokens.space20),
                WenyouSectionHeader(
                  title: '楼中楼讨论',
                  subtitle: '共 ${root.replyCount} 条回复',
                ),
                SizedBox(height: tokens.space12),
                _ReplyFilters(
                  state: state,
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
                    action: TextButton(
                      onPressed: onLoadMore,
                      child: const Text('重试'),
                    ),
                  ),
                  SizedBox(height: tokens.space12),
                ],
                if (state.replies.isEmpty)
                  const WenyouEmptyState(
                    icon: Icons.forum_outlined,
                    title: '还没有回复',
                    message: '成为这段讨论的第一位回复者。',
                  )
                else
                  for (
                    var index = 0;
                    index < state.replies.length;
                    index++
                  ) ...[
                    if (index > 0) Divider(height: tokens.space24),
                    _PostCard(
                      key: Key('post-reply-${state.replies[index].id}'),
                      post: state.replies[index],
                      focused: state.replies[index].id == focusedReplyId,
                      canEdit: state.replies[index].isAuthoredBy(viewerId),
                      canDelete: state.replies[index].isAuthoredBy(viewerId),
                      pending: actions.pendingPostId == state.replies[index].id,
                      reportReturnTo:
                          reportsEnabled &&
                              !state.replies[index].isAuthoredBy(viewerId)
                          ? _reportLocation(root, state.replies[index].id)
                          : null,
                      onReply: authenticated
                          ? () => onCompose(
                              _replyTarget(root, state.replies[index]),
                            )
                          : null,
                      onEdit: () =>
                          onCompose(_editTarget(state.replies[index], '编辑回复')),
                      onDelete: () => onDelete(state.replies[index], false),
                    ),
                  ],
                if (state.hasMore) ...[
                  SizedBox(height: tokens.space12),
                  OutlinedButton.icon(
                    key: const Key('post-replies-load-more'),
                    onPressed: state.isLoadingMore ? null : onLoadMore,
                    icon: state.isLoadingMore
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more_rounded),
                    label: Text(state.isLoadingMore ? '正在加载' : '加载更多回复'),
                  ),
                ],
              ],
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

class _ReplyFilters extends StatelessWidget {
  const _ReplyFilters({
    required this.state,
    required this.authors,
    required this.onOrder,
    required this.onAuthor,
  });

  final PostDiscussionState state;
  final List<PostAuthor> authors;
  final ValueChanged<PostReplyOrder> onOrder;
  final ValueChanged<String?> onAuthor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedAuthor = authors
        .where((author) => author.id == state.authorId)
        .firstOrNull;
    return Row(
      children: [
        PopupMenuButton<PostReplyOrder>(
          key: const Key('post-replies-order'),
          initialValue: state.order,
          tooltip: '回复排序',
          onSelected: onOrder,
          itemBuilder: (context) => [
            for (final order in PostReplyOrder.values)
              PopupMenuItem(value: order, child: Text(order.label)),
          ],
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded, size: 20),
                  SizedBox(width: tokens.space4),
                  Text(state.order.label),
                  const Icon(Icons.arrow_drop_down_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        TextButton.icon(
          key: const Key('post-replies-author'),
          onPressed: () => _showAuthorFilter(context),
          icon: Icon(
            Icons.tune_rounded,
            size: 20,
            color: selectedAuthor == null ? tokens.mutedText : tokens.brand,
          ),
          label: Text(selectedAuthor?.username ?? '筛选'),
        ),
      ],
    );
  }

  Future<void> _showAuthorFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => RadioGroup<String>(
        groupValue: state.authorId ?? '',
        onChanged: (value) => Navigator.pop(context, value),
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('只看回复者')),
            const RadioListTile<String>(value: '', title: Text('全部回复者')),
            for (final author in authors)
              RadioListTile<String>(
                value: author.id,
                title: Text(author.username),
              ),
          ],
        ),
      ),
    );
    if (context.mounted && selected != null) {
      final authorId = selected.isEmpty ? null : selected;
      if (authorId != state.authorId) onAuthor(authorId);
    }
  }
}

class _PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
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
          if (post.replyToAuthor != null) ...[
            SizedBox(height: tokens.space8),
            Text(
              '回复 @${post.replyToAuthor!.username}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.brand),
            ),
          ],
          SizedBox(height: tokens.space12),
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
            ),
          if (!post.isDeleted &&
              (onReply != null ||
                  canEdit ||
                  canDelete ||
                  reportReturnTo != null)) ...[
            SizedBox(height: tokens.space12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: tokens.space4,
              runSpacing: tokens.space4,
              children: [
                if (onReply != null)
                  TextButton.icon(
                    onPressed: pending ? null : onReply,
                    icon: const Icon(Icons.reply_rounded),
                    label: const Text('回复'),
                  ),
                if (reportReturnTo != null)
                  WenyouReportButton(
                    key: Key('post-report-${post.id}'),
                    target: ReportTarget.post(post.id),
                    targetLabel: root ? '这个楼层' : '这条回复',
                    returnTo: reportReturnTo!,
                  ),
                if (canEdit)
                  TextButton.icon(
                    key: Key('post-edit-${post.id}'),
                    onPressed: pending ? null : onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('编辑'),
                  ),
                if (canDelete)
                  TextButton.icon(
                    key: Key('post-delete-${post.id}'),
                    onPressed: pending ? null : onDelete,
                    icon: pending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: const Text('删除'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PostAuthorLine extends StatelessWidget {
  const _PostAuthorLine({required this.post, required this.root});

  final PostItem post;
  final bool root;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return Row(
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: 40,
            child: post.author.avatarUrl == null
                ? fallback
                : CachedNetworkImage(
                    imageUrl: post.author.avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => fallback,
                    errorWidget: (_, _, _) => fallback,
                  ),
          ),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${post.author.username} · Lv.${post.author.level}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space4),
              Text(
                '${root ? '原楼层 #${post.floorNumber ?? '-'}' : '回复'} · '
                '${DateFormat('MM-dd HH:mm').format(post.createdAt.toLocal())}',
                style: Theme.of(context).textTheme.bodySmall,
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
          icon: Icons.forum_outlined,
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
          icon: Icons.link_off_rounded,
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

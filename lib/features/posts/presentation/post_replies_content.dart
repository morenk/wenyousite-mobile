import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/reading_quick_scroll.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_item_divider.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_transient_target_frame.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_targets.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_discussion_states.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_reply_filters.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/reports.dart';
import 'package:wenyousite_mobile/features/stickers/stickers.dart';

class PostDiscussionList extends StatelessWidget {
  const PostDiscussionList({
    required this.state,
    required this.actions,
    required this.viewerId,
    required this.authenticated,
    required this.focusedReplyId,
    required this.targetKey,
    required this.itemListKey,
    required this.scrollController,
    required this.quickScroll,
    required this.canReport,
    required this.canManageThread,
    required this.discussionAuthors,
    required this.onRetryAuthors,
    required this.onOrderChanged,
    required this.onAuthorChanged,
    required this.onRetry,
    required this.timeReference,
    required this.onCompose,
    required this.onDelete,
    required this.onTogglePin,
    super.key,
  });

  final PostDiscussionState state;
  final PostActionState actions;
  final String? viewerId;
  final bool authenticated;
  final String? focusedReplyId;
  final GlobalKey targetKey;
  final GlobalKey itemListKey;
  final ScrollController scrollController;
  final ReadingQuickScrollController quickScroll;
  final bool canReport;
  final bool canManageThread;
  final AsyncValue<List<PostDiscussionAuthor>> discussionAuthors;
  final VoidCallback onRetryAuthors;
  final ValueChanged<PostReplyOrder> onOrderChanged;
  final ValueChanged<String?> onAuthorChanged;
  final VoidCallback onRetry;
  final DateTime? timeReference;
  final ValueChanged<PostComposerTarget> onCompose;
  final void Function(PostItem post, bool root) onDelete;
  final ValueChanged<PostItem> onTogglePin;

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
          detail: wenyouFailureDetail(actions.failure),
          tone: WenyouStatusTone.error,
        ),
        SizedBox(height: tokens.space12),
      ],
      DiscussionKeepAlive(
        child: ReadingPositionAnchor(
          controller: quickScroll,
          label: '原楼层',
          child: _PostCard(
            key: const Key('post-discussion-root'),
            post: root,
            root: true,
            timeReference: timeReference,
            canEdit: root.isAuthoredBy(viewerId),
            canDelete: root.isAuthoredBy(viewerId) || canManageThread,
            canPin: canManageThread,
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
            onTogglePin: () => onTogglePin(root),
          ),
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
      if (state.transientFailure != null &&
          state.retryAction != PostDiscussionRetryAction.loadMore) ...[
        WenyouStatusBanner(
          message: state.transientFailure!.userMessage,
          detail: wenyouFailureDetail(state.transientFailure),
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
      physics: ReadingQuickScrollPhysics(
        controller: quickScroll,
        parent: const AlwaysScrollableScrollPhysics(),
      ),
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
              key: itemListKey,
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
                        ReadingPositionAnchor(
                          controller: quickScroll,
                          label: reply.floorNumber == null
                              ? '${reply.author.username}的回复附近'
                              : '第 ${reply.floorNumber} 楼回复附近',
                          child: _PostCard(
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
              child: PostDiscussionPaginationStatus(
                state: state,
                onRetry: onRetry,
              ),
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
    this.canPin = false,
    this.pending = false,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onTogglePin,
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
  final bool canPin;
  final bool pending;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePin;
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
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              )
            else
              StickerPostMarkdown(
                postId: post.id,
                data: post.content,
                mediaDisplays: post.mediaDisplays,
                diceLabels: _postDiceLabels(post.diceRolls),
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
      canPin: canPin && root && !post.isDeleted,
      isPinned: post.isPinned,
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
        await copyPostCardContent(
          context,
          '内容已复制',
          write: () => ref.read(readerMarkdownClipboardWriterProvider)(
            markdown: post.content,
            diceLabels: _postDiceLabels(post.diceRolls),
            scope: ref.read(sessionScopeProvider),
          ),
        );
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.togglePin:
        onTogglePin?.call();
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

Map<String, String> _postDiceLabels(Iterable<PostDiceRoll> rolls) => {
  for (final roll in rolls)
    roll.nodeId.toLowerCase(): '${roll.notation} = ${roll.total}',
};

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
                          ? Theme.of(context).textTheme.wenyouRowTitle
                          : Theme.of(context).textTheme.wenyouLabel,
                    ),
                  ),
                  SizedBox(width: tokens.space4),
                  WenyouLevelBadge(
                    key: Key('post-level-${post.id}'),
                    level: post.author.level,
                  ),
                  if (root && post.isPinned) ...[
                    SizedBox(width: tokens.space8),
                    const WenyouIcon(WenyouIconIds.statusPinned, size: 14),
                    SizedBox(width: tokens.space4),
                    Text(
                      '置顶',
                      key: Key('post-pinned-${post.id}'),
                      style: Theme.of(context).textTheme.wenyouCaption,
                    ),
                  ],
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
                  ).textTheme.wenyouCaption.copyWith(color: tokens.mutedText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

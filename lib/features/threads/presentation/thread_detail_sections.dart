import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_avatar_button.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_reply_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_time_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_transient_target_frame.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadDetailContent extends StatelessWidget {
  const ThreadDetailContent({
    required this.child,
    this.top = 0,
    this.bottom = 0,
    super.key,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final horizontal = wenyouHorizontalPagePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: WenyouConstrainedWidth(child: child),
    );
  }
}

class ThreadDetailLoadingState extends StatelessWidget {
  const ThreadDetailLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Align(
      alignment: Alignment.topCenter,
      child: ThreadDetailContent(
        top: 16,
        child: WenyouPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: tokens.space16),
              Text('正在打开主题', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: tokens.space4),
              Text(
                '正文和楼层会一起准备好。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThreadDetailFatalState extends StatelessWidget {
  const ThreadDetailFatalState({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final notFound = failure?.httpStatus == 404;
    return Align(
      alignment: Alignment.topCenter,
      child: ThreadDetailContent(
        top: 16,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: notFound
                ? WenyouIconIds.actionHide
                : WenyouIconIds.statusOffline,
            title: notFound ? '这个主题暂时不可见' : '主题详情加载失败',
            message: notFound
                ? '它可能已经删除、设为私密，或当前账号没有访问权限。'
                : (failure?.userMessage ?? '请检查网络后重试。'),
            detail: failure?.requestId == null
                ? null
                : '问题编号：${failure!.requestId}',
            action: OutlinedButton.icon(
              key: const Key('thread-detail-retry'),
              onPressed: onRetry,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh),
              label: const Text('重新加载'),
            ),
          ),
        ),
      ),
    );
  }
}

class ThreadDetailTransientFailure extends StatelessWidget {
  const ThreadDetailTransientFailure({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: failure.userMessage,
      detail: failure.requestId == null ? null : '问题编号：${failure.requestId}',
      action: TextButton.icon(
        key: const Key('thread-detail-transient-retry'),
        onPressed: onRetry,
        icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
        label: const Text('重试'),
      ),
    );
  }
}

class ThreadSubthreadBody extends StatelessWidget {
  const ThreadSubthreadBody({required this.subthread, super.key});

  final ThreadSubthreadModel subthread;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final body = subthread.body;
    return Semantics(
      container: true,
      label: '当前子贴正文',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (body == null || body.markdown.trim().isEmpty)
              Text(
                '这个子贴还没有正文。',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
              )
            else if (body.postId == null)
              WenyouMarkdown(
                key: Key('thread-body-${subthread.id}'),
                data: body.markdown,
                diceLabels: _diceLabels(body.diceRolls),
                diceSemantics: _diceSemantics(body.diceRolls),
                onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
              )
            else
              StickerPostMarkdown(
                key: Key('thread-body-${subthread.id}'),
                postId: body.postId!,
                data: body.markdown,
                diceLabels: _diceLabels(body.diceRolls),
                diceSemantics: _diceSemantics(body.diceRolls),
                onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
              ),
          ],
        ),
      ),
    );
  }
}

class ThreadTargetPostStatus extends StatelessWidget {
  const ThreadTargetPostStatus({
    required this.targetState,
    required this.expectedThreadId,
    required this.availableSubthreadIds,
    required this.onRetry,
    super.key,
  });

  final AsyncValue<ThreadPostTargetModel> targetState;
  final String expectedThreadId;
  final Set<String> availableSubthreadIds;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return targetState.when(
      loading: () => const WenyouStatusBanner(
        message: '正在定位搜索结果…',
        detail: '会自动切换到所属子贴并展示目标上下文。',
      ),
      error: (error, _) {
        final failure = error is ApiFailure ? error : null;
        return WenyouStatusBanner(
          tone: WenyouStatusTone.error,
          message: failure?.httpStatus == 404
              ? '目标内容已不可见'
              : (failure?.userMessage ?? '目标内容定位失败，请重试。'),
          detail: failure?.requestId == null
              ? null
              : '问题编号：${failure!.requestId}',
          action: TextButton.icon(
            key: const Key('thread-target-retry'),
            onPressed: onRetry,
            icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
            label: const Text('重试定位'),
          ),
        );
      },
      data: (target) {
        if (target.threadId != expectedThreadId) {
          return WenyouStatusBanner(
            tone: WenyouStatusTone.error,
            message: '目标内容不属于当前主题',
            detail: '请返回搜索结果后重新打开。',
            action: TextButton.icon(
              onPressed: onRetry,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
              label: const Text('重新确认'),
            ),
          );
        }
        if (!availableSubthreadIds.contains(target.subthreadId)) {
          return WenyouStatusBanner(
            tone: WenyouStatusTone.error,
            message: '目标内容所属子贴暂时不可见',
            detail: '请返回搜索结果后重新打开，或稍后重试。',
            action: TextButton.icon(
              onPressed: onRetry,
              icon: const WenyouIcon(WenyouIconIds.actionRefresh, size: 18),
              label: const Text('重新确认'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ThreadFloorsLoadingState extends StatelessWidget {
  const ThreadFloorsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: tokens.space12),
          const Expanded(child: Text('正在加载这个子贴的楼层…')),
        ],
      ),
    );
  }
}

class ThreadFloorCard extends ConsumerWidget {
  const ThreadFloorCard({
    required this.threadId,
    required this.floor,
    required this.canEdit,
    required this.canDelete,
    required this.pending,
    required this.onReply,
    required this.onDiscussion,
    required this.onEdit,
    required this.onDelete,
    this.reportReturnTo,
    this.isFocused = false,
    super.key,
  });

  final String threadId;
  final ThreadFloorModel floor;
  final bool isFocused;
  final bool canEdit;
  final bool canDelete;
  final bool pending;
  final VoidCallback onReply;
  final VoidCallback onDiscussion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? reportReturnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    return PostCardActionMenu(
      canCopyText: !floor.isDeleted,
      canReply: !floor.isDeleted,
      canEdit: !floor.isDeleted && canEdit,
      canDelete: !floor.isDeleted && canDelete,
      canReport: !floor.isDeleted && reportReturnTo != null,
      pending: pending,
      semanticLabel: '楼层操作',
      actionKeyPrefix: 'thread-floor-action-${floor.id}',
      onSelected: (action) => _handleAction(action, context, ref),
      anchorBuilder: (context, handle) => Semantics(
        key: Key('thread-floor-card-${floor.id}'),
        container: true,
        button: !pending && !floor.isDeleted,
        label: floor.floorNumber == null
            ? '回复楼层'
            : '回复第 ${floor.floorNumber} 楼',
        hint: '点击回复，长按打开楼层操作',
        onTap: pending || floor.isDeleted ? null : onReply,
        onLongPress: handle.open,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: pending || floor.isDeleted ? null : onReply,
          onLongPress: handle.open,
          child: WenyouTransientTargetFrame(
            targetId: isFocused ? floor.id : null,
            announcement: '已定位到目标楼层',
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space4,
                vertical: tokens.space12,
              ),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AuthorLine(
                          key: Key('thread-floor-author-${floor.id}'),
                          author: floor.author,
                          time: floor.createdAt,
                          compact: true,
                          avatarKey: Key(
                            'thread-floor-author-avatar-${floor.id}',
                          ),
                        ),
                      ),
                      SizedBox(width: tokens.space8),
                      Text(
                        floor.floorNumber == null
                            ? '楼层'
                            : '#${floor.floorNumber}',
                        key: Key('thread-floor-number-${floor.id}'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space8),
                  if (floor.isDeleted)
                    Text(
                      '该楼层已删除。',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
                    )
                  else
                    StickerPostMarkdown(
                      postId: floor.id,
                      data: floor.body.markdown,
                      diceLabels: _diceLabels(floor.body.diceRolls),
                      diceSemantics: _diceSemantics(floor.body.diceRolls),
                      onInternalLink: (uri) =>
                          _showInternalLinkNotice(context, uri),
                      onTapText: pending ? null : onReply,
                    ),
                  if (floor.replyCount > 0) ...[
                    SizedBox(height: tokens.space4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: Key('thread-floor-discussion-${floor.id}'),
                        onPressed: pending ? null : onDiscussion,
                        style: TextButton.styleFrom(
                          foregroundColor: tokens.mutedText,
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.space8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WenyouIcon(WenyouIconIds.metricComments, size: 16),
                            SizedBox(width: tokens.space4),
                            Text(
                              '${floor.replyCount} 条回复',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(width: tokens.space4),
                            const WenyouIcon(
                              WenyouIconIds.navigationNext,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (floor.replies.isNotEmpty) ...[
                      SizedBox(height: tokens.space4),
                      _FloorInlineReplyPreview(
                        floorId: floor.id,
                        replies: floor.replies,
                        replyCount: floor.replyCount,
                        pending: pending,
                        onDiscussion: onDiscussion,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
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
        await copyPostCardValue(context, floor.body.markdown, '内容已复制');
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.reply:
        onReply();
      case PostCardAction.edit:
        onEdit();
      case PostCardAction.delete:
        onDelete();
      case PostCardAction.report:
        if (reportReturnTo == null) return;
        await showWenyouReportFlow(
          context: context,
          ref: ref,
          target: ReportTarget.post(floor.id),
          targetLabel: '这个楼层',
          returnTo: reportReturnTo!,
        );
    }
  }

  String _publicLink() => Uri.parse(
    'https://wenyou.site',
  ).resolve('/threads/$threadId?post=${floor.id}').toString();
}

class _FloorInlineReplyPreview extends StatelessWidget {
  const _FloorInlineReplyPreview({
    required this.floorId,
    required this.replies,
    required this.replyCount,
    required this.pending,
    required this.onDiscussion,
  });

  static const _previewLimit = 5;
  static const _collapseContentLength = 500;
  static const _collapsedHeight = 320.0;

  final String floorId;
  final List<ThreadReplyModel> replies;
  final int replyCount;
  final bool pending;
  final VoidCallback onDiscussion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final visibleReplies = replies.take(_previewLimit).toList(growable: false);
    final contentLength = visibleReplies.fold<int>(
      0,
      (sum, reply) => sum + reply.body.markdown.length,
    );
    final collapsed = contentLength > _collapseContentLength;
    final replyCards = <Widget>[
      for (var index = 0; index < visibleReplies.length; index++) ...[
        if (index > 0) SizedBox(height: tokens.space4),
        _FloorInlineReplyCard(
          floorId: floorId,
          reply: visibleReplies[index],
          enabled: !pending,
          onDiscussion: onDiscussion,
        ),
      ],
    ];
    if (!collapsed) {
      return Column(
        key: Key('thread-floor-reply-preview-$floorId'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: replyCards,
      );
    }
    return SizedBox(
      key: Key('thread-floor-reply-preview-collapsed-$floorId'),
      height: _collapsedHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: replyCards,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 104,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [tokens.panel.withValues(alpha: 0), tokens.panel],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: tokens.space8,
            right: tokens.space8,
            bottom: tokens.space4,
            child: FilledButton.tonalIcon(
              key: Key('thread-floor-reply-preview-expand-$floorId'),
              onPressed: pending ? null : onDiscussion,
              icon: const WenyouIcon(WenyouIconIds.navigationExpand),
              label: Text('展开全部 $replyCount 条回复'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorInlineReplyCard extends StatelessWidget {
  const _FloorInlineReplyCard({
    required this.floorId,
    required this.reply,
    required this.enabled,
    required this.onDiscussion,
  });

  final String floorId;
  final ThreadReplyModel reply;
  final bool enabled;
  final VoidCallback onDiscussion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouDiscussionReplyCard(
      key: Key('thread-floor-reply-$floorId-${reply.id}'),
      semanticsLabel: '${reply.author.username} 的楼中楼回复',
      enabled: enabled,
      onTap: onDiscussion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorLine(
            author: reply.author,
            time: reply.createdAt,
            compact: true,
            avatarKey: Key('thread-floor-reply-author-avatar-${reply.id}'),
          ),
          if (reply.replyToUsername case final username?) ...[
            SizedBox(height: tokens.space4),
            Text(
              '回复 @$username',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
            ),
          ],
          SizedBox(height: tokens.space8),
          if (reply.isDeleted)
            Text(
              '该回复已删除。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
            )
          else
            StickerPostMarkdown(
              postId: reply.id,
              data: reply.body.markdown,
              diceLabels: _diceLabels(reply.body.diceRolls),
              diceSemantics: _diceSemantics(reply.body.diceRolls),
              onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
              onTapText: enabled ? onDiscussion : null,
              bodyFontSize: 17,
              bodyHeight: 1.8,
            ),
        ],
      ),
    );
  }
}

class ThreadFloorsFooter extends StatelessWidget {
  const ThreadFloorsFooter({
    required this.state,
    required this.onLoadMore,
    super.key,
  });

  final ThreadDetailState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    if (state.isLoadingFloors || state.floors.isEmpty) {
      return const SizedBox.shrink();
    }
    if (state.transientFailure != null &&
        state.retryAction == ThreadDetailRetryAction.loadMore) {
      return ThreadDetailTransientFailure(
        failure: state.transientFailure!,
        onRetry: onLoadMore,
      );
    }
    if (!state.hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space12),
        child: Text(
          '已经读完这个子贴的全部楼层',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return OutlinedButton.icon(
      key: const Key('thread-floors-load-more'),
      onPressed: state.isLoadingMore ? null : onLoadMore,
      icon: state.isLoadingMore
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const WenyouIcon(WenyouIconIds.navigationExpand),
      label: Text(state.isLoadingMore ? '正在加载' : '加载更多楼层'),
    );
  }
}

class _AuthorLine extends StatelessWidget {
  const _AuthorLine({
    required this.author,
    required this.time,
    this.compact = false,
    this.avatarKey,
    super.key,
  });

  final ThreadAuthorModel author;
  final DateTime time;
  final bool compact;
  final Key? avatarKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 32.0 : 36.0;
    return Row(
      children: [
        WenyouAvatarButton(
          key: avatarKey,
          username: author.username,
          avatarUrl: author.avatarUrl,
          visualSize: size,
          onTap: () => context.push(AppRouteLocations.user(author.id)),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  author.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              SizedBox(width: tokens.space4),
              WenyouLevelBadge(level: author.level),
              SizedBox(width: tokens.space8),
              WenyouTimeText(
                value: time,
                semanticsPrefix: '发布时间：',
                maxLines: 1,
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

PostComposerTarget threadDetailBodyTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
) {
  final body = subthread.body;
  return (
    kind: PostComposerKind.upsertBody,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: body?.postId,
    parentPostId: null,
    replyToPostId: null,
    version: body?.version,
    initialContent: body?.markdown ?? '',
    label: body == null ? '添加子贴正文' : '编辑子贴正文',
  );
}

PostComposerTarget threadDetailReplyFloorTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
) {
  return (
    kind: PostComposerKind.createReply,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: null,
    parentPostId: floor.id,
    replyToPostId: floor.id,
    version: null,
    initialContent: '',
    label: '回复 @${floor.author.username}',
  );
}

PostComposerTarget threadDetailFloorTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
) {
  return (
    kind: PostComposerKind.createFloor,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: null,
    parentPostId: null,
    replyToPostId: null,
    version: null,
    initialContent: '',
    label: '发表楼层',
  );
}

PostComposerTarget threadDetailEditFloorTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
) {
  return (
    kind: PostComposerKind.editPost,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: floor.id,
    parentPostId: null,
    replyToPostId: null,
    version: floor.version,
    initialContent: floor.body.markdown,
    label: '编辑 #${floor.floorNumber ?? '-'} 楼',
  );
}

PostItem threadFloorAsPost(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
) {
  return PostItem(
    id: floor.id,
    threadId: detail.id,
    subthreadId: subthread.id,
    author: PostAuthor(
      id: floor.author.id,
      username: floor.author.username,
      level: floor.author.level,
      avatarUrl: floor.author.avatarUrl,
    ),
    content: floor.body.markdown,
    version: floor.version,
    createdAt: floor.createdAt,
    updatedAt: floor.createdAt,
    isBody: false,
    isDeleted: floor.isDeleted,
    floorNumber: floor.floorNumber,
    replyCount: floor.replyCount,
    threadTitle: detail.title,
    subthreadTitle: subthread.title,
    diceRolls: floor.body.diceRolls
        .map(
          (roll) => PostDiceRoll(
            nodeId: roll.nodeId,
            notation: roll.notation,
            results: roll.results,
            total: roll.total,
          ),
        )
        .toList(growable: false),
  );
}

Map<String, String> _diceLabels(List<ThreadDiceRollModel> rolls) {
  return {
    for (final roll in rolls)
      roll.nodeId.toLowerCase(): '${roll.notation} = ${roll.total}',
  };
}

Map<String, String> _diceSemantics(List<ThreadDiceRollModel> rolls) {
  return {
    for (final roll in rolls)
      roll.nodeId.toLowerCase(): formatWenyouDiceSemantics(
        notation: roll.notation,
        results: roll.results,
        total: roll.total,
      ),
  };
}

void _showInternalLinkNotice(BuildContext context, Uri uri) {
  openInternalWenyouLink(context, uri);
}

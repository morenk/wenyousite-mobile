part of 'thread_detail_page.dart';

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.child, this.top = 0, this.bottom = 0});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final horizontal = MediaQuery.sizeOf(context).width <= 400
        ? tokens.space12
        : tokens.space24;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}

class _DetailLoadingState extends StatelessWidget {
  const _DetailLoadingState();

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Align(
      alignment: Alignment.topCenter,
      child: _DetailContent(
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

class _DetailFatalState extends StatelessWidget {
  const _DetailFatalState({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final notFound = failure?.httpStatus == 404;
    return Align(
      alignment: Alignment.topCenter,
      child: _DetailContent(
        top: 16,
        child: WenyouPanel(
          child: WenyouEmptyState(
            icon: notFound
                ? Icons.visibility_off_outlined
                : Icons.cloud_off_outlined,
            title: notFound ? '这个主题暂时不可见' : '主题详情没有加载完成',
            message: notFound
                ? '它可能已经删除、设为私密，或当前账号没有访问权限。'
                : (failure?.userMessage ?? '请检查网络后重试。'),
            detail: failure?.requestId == null
                ? null
                : '请求 ID：${failure!.requestId}',
            action: OutlinedButton.icon(
              key: const Key('thread-detail-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新加载'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTransientFailure extends StatelessWidget {
  const _DetailTransientFailure({required this.failure, required this.onRetry});

  final ApiFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return WenyouStatusBanner(
      tone: WenyouStatusTone.error,
      message: failure.userMessage,
      detail: failure.requestId == null ? null : '请求 ID：${failure.requestId}',
      action: TextButton.icon(
        key: const Key('thread-detail-transient-retry'),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('重试'),
      ),
    );
  }
}

class _ThreadOverview extends ConsumerWidget {
  const _ThreadOverview({
    required this.detail,
    required this.categoryName,
    required this.onRequireAuthentication,
    required this.onPlayerExited,
  });

  final ThreadDetailModel detail;
  final String categoryName;
  final VoidCallback onRequireAuthentication;
  final Future<void> Function() onPlayerExited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final interactionTarget = ThreadInteractionTarget(
      threadId: detail.id,
      isLiked: detail.isLiked,
      likeCount: detail.likeCount,
      isBookmarked: detail.isBookmarked,
      bookmarkId: detail.bookmarkId,
    );
    final interactionState = ref.watch(
      threadInteractionControllerProvider(interactionTarget),
    );
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorLine(author: detail.owner, time: detail.updatedAt),
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space8,
            runSpacing: tokens.space4,
            children: [
              if (detail.isPinned)
                const _DetailPill(
                  icon: Icons.push_pin_rounded,
                  label: '置顶',
                  accent: true,
                ),
              _DetailPill(icon: Icons.folder_open_rounded, label: categoryName),
              _DetailPill(
                icon: _statusIcon(detail.status),
                label: detail.status.label,
                accent: detail.status == ThreadDetailStatus.recruiting,
              ),
              if (detail.isPrivate)
                const _DetailPill(
                  icon: Icons.lock_outline_rounded,
                  label: '私密',
                ),
            ],
          ),
          SizedBox(height: tokens.space12),
          Semantics(
            header: true,
            child: Text(
              detail.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (detail.tags.isNotEmpty) ...[
            SizedBox(height: tokens.space12),
            Wrap(
              spacing: tokens.space8,
              runSpacing: tokens.space4,
              children: [
                for (final tag in detail.tags)
                  WenyouTagChip(
                    key: Key('thread-detail-tag-${tag.id}'),
                    name: tag.name,
                    onPressed: () => context.pushNamed(
                      'tag-threads',
                      pathParameters: {'tagId': tag.id},
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: tokens.space16),
          Divider(color: tokens.border),
          SizedBox(height: tokens.space12),
          Wrap(
            spacing: tokens.space16,
            runSpacing: tokens.space8,
            children: [
              _DetailStat(
                icon: Icons.people_outline_rounded,
                label: '${detail.memberCount} 成员',
              ),
              _DetailStat(
                icon: Icons.theater_comedy_outlined,
                label: '${detail.playerCount} 玩家',
              ),
              _DetailStat(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${detail.postCount} 楼层',
              ),
              _DetailStat(
                icon: Icons.visibility_outlined,
                label: '${detail.viewCount} 浏览',
              ),
              _DetailStat(
                icon: Icons.favorite_border_rounded,
                label: '${interactionState.likeCount} 喜欢',
              ),
              if (detail.tipTotal != '0')
                _DetailStat(
                  icon: Icons.local_gas_station_outlined,
                  label: '${WenyouAmount.format(detail.tipTotal)}L 加油',
                  accent: true,
                ),
            ],
          ),
          SizedBox(height: tokens.space12),
          Divider(color: tokens.border),
          SizedBox(height: tokens.space12),
          ThreadInteractionActions(
            target: interactionTarget,
            onRequireAuthentication: onRequireAuthentication,
          ),
          ThreadSubscriptionControls(
            threadId: detail.id,
            viewerUserId: detail.currentUserId,
            hasAutomaticUpdates: detail.hasAutomaticUpdates,
          ),
          ThreadMembershipControls(
            threadId: detail.id,
            canExitPlayer:
                detail.isCurrentUserPlayer && !detail.isCurrentUserOwner,
            onExited: onPlayerExited,
          ),
        ],
      ),
    );
  }

  static IconData _statusIcon(ThreadDetailStatus status) {
    return switch (status) {
      ThreadDetailStatus.recruiting => Icons.group_add_outlined,
      ThreadDetailStatus.closed => Icons.lock_outline_rounded,
      ThreadDetailStatus.finished => Icons.check_circle_outline_rounded,
      ThreadDetailStatus.unknown => Icons.help_outline_rounded,
    };
  }
}

class _SubthreadSection extends StatelessWidget {
  const _SubthreadSection({
    required this.detail,
    required this.selectedSubthreadId,
    required this.onSelected,
  });

  final ThreadDetailModel detail;
  final String selectedSubthreadId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WenyouSectionHeader(title: '子贴', subtitle: '切换不同章节，正文与楼层会同步更新'),
          SizedBox(height: tokens.space12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (
                  var index = 0;
                  index < detail.subthreads.length;
                  index++
                ) ...[
                  if (index > 0) SizedBox(width: tokens.space8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: tokens.minimumTouchTarget,
                    ),
                    child: ChoiceChip(
                      key: Key(
                        'thread-subthread-${detail.subthreads[index].id}',
                      ),
                      selected:
                          detail.subthreads[index].id == selectedSubthreadId,
                      onSelected: (_) =>
                          onSelected(detail.subthreads[index].id),
                      label: Text(
                        '${detail.subthreads[index].title} · '
                        '${detail.subthreads[index].postCount}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubthreadBody extends StatelessWidget {
  const _SubthreadBody({
    required this.subthread,
    required this.canEdit,
    required this.onEdit,
  });

  final ThreadSubthreadModel subthread;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final body = subthread.body;
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WenyouSectionHeader(
            title: subthread.title,
            subtitle:
                '${subthread.postingPolicyLabel} · '
                '${subthread.postCount} 条内容',
            trailing: canEdit
                ? TextButton.icon(
                    key: const Key('thread-body-edit'),
                    onPressed: onEdit,
                    icon: Icon(
                      body == null
                          ? Icons.note_add_outlined
                          : Icons.edit_outlined,
                    ),
                    label: Text(body == null ? '添加正文' : '编辑正文'),
                  )
                : null,
          ),
          SizedBox(height: tokens.space16),
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
              onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
            )
          else
            StickerPostMarkdown(
              key: Key('thread-body-${subthread.id}'),
              postId: body.postId!,
              data: body.markdown,
              diceLabels: _diceLabels(body.diceRolls),
              onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
            ),
        ],
      ),
    );
  }
}

class _TargetPostStatus extends StatelessWidget {
  const _TargetPostStatus({
    required this.targetState,
    required this.expectedThreadId,
    required this.availableSubthreadIds,
    required this.onRetry,
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
              : '请求 ID：${failure!.requestId}',
          action: TextButton.icon(
            key: const Key('thread-target-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
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
              icon: const Icon(Icons.refresh_rounded, size: 18),
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
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('重新确认'),
            ),
          );
        }
        return WenyouStatusBanner(
          tone: WenyouStatusTone.accent,
          message: target.focusedReplyId == null ? '已定位到匹配楼层' : '已定位到匹配的楼中楼回复',
          detail: '目标上下文置顶并使用强调底色；其余楼层保持原有顺序。',
        );
      },
    );
  }
}

class _FloorsLoadingState extends StatelessWidget {
  const _FloorsLoadingState();

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

class _FloorCard extends StatelessWidget {
  const _FloorCard({
    required this.floor,
    required this.canEdit,
    required this.canDelete,
    required this.pending,
    required this.showDiscussion,
    required this.onDiscussion,
    required this.onEdit,
    required this.onDelete,
    this.reportReturnTo,
    this.isFocused = false,
    super.key,
  });

  final ThreadFloorModel floor;
  final bool isFocused;
  final bool canEdit;
  final bool canDelete;
  final bool pending;
  final bool showDiscussion;
  final VoidCallback onDiscussion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? reportReturnTo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      label: floor.floorNumber == null ? '楼层' : '第 ${floor.floorNumber} 楼',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space4,
          vertical: tokens.space12,
        ),
        decoration: BoxDecoration(
          color: isFocused ? tokens.accentedBackground : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _AuthorLine(
                    author: floor.author,
                    time: floor.createdAt,
                    compact: true,
                  ),
                ),
                SizedBox(width: tokens.space8),
                _DetailPill(
                  icon: Icons.layers_outlined,
                  label: floor.floorNumber == null
                      ? '楼层'
                      : '#${floor.floorNumber}',
                  accent: true,
                ),
              ],
            ),
            SizedBox(height: tokens.space12),
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
                onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
              ),
            if (floor.replies.isNotEmpty) ...[
              SizedBox(height: tokens.space16),
              _InlineReplies(floor: floor),
            ] else if (floor.replyCount > 0) ...[
              SizedBox(height: tokens.space12),
              Text(
                '共 ${floor.replyCount} 条回复',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (!floor.isDeleted &&
                (showDiscussion ||
                    canEdit ||
                    canDelete ||
                    reportReturnTo != null)) ...[
              SizedBox(height: tokens.space12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: tokens.space4,
                runSpacing: tokens.space4,
                children: [
                  if (showDiscussion)
                    TextButton.icon(
                      key: Key('thread-floor-discussion-${floor.id}'),
                      onPressed: pending ? null : onDiscussion,
                      icon: const Icon(Icons.forum_outlined),
                      label: Text(
                        floor.replyCount == 0
                            ? '回复'
                            : '查看 ${floor.replyCount} 条回复',
                      ),
                    ),
                  if (reportReturnTo != null)
                    WenyouReportButton(
                      key: Key('thread-floor-report-${floor.id}'),
                      target: ReportTarget.post(floor.id),
                      targetLabel: '这个楼层',
                      returnTo: reportReturnTo!,
                    ),
                  if (canEdit)
                    TextButton.icon(
                      key: Key('thread-floor-edit-${floor.id}'),
                      onPressed: pending ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('编辑'),
                    ),
                  if (canDelete)
                    TextButton.icon(
                      key: Key('thread-floor-delete-${floor.id}'),
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
      ),
    );
  }
}

class _InlineReplies extends StatelessWidget {
  const _InlineReplies({required this.floor});

  final ThreadFloorModel floor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radius12),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '楼中楼 · ${floor.replyCount}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (var index = 0; index < floor.replies.length; index++) ...[
              SizedBox(height: tokens.space12),
              if (index > 0) ...[
                Divider(color: tokens.border),
                SizedBox(height: tokens.space12),
              ],
              _InlineReply(reply: floor.replies[index]),
            ],
            if (floor.replyCount > floor.replies.length) ...[
              SizedBox(height: tokens.space12),
              Text(
                '本页展示前 ${floor.replies.length} 条，'
                '共 ${floor.replyCount} 条回复。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineReply extends StatelessWidget {
  const _InlineReply({required this.reply});

  final ThreadReplyModel reply;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${reply.author.username} · Lv.${reply.author.level}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Text(
              _formatTime(reply.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        if (reply.replyToUsername != null) ...[
          SizedBox(height: tokens.space4),
          Text(
            '回复 @${reply.replyToUsername}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.brand),
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
            bodyFontSize: 16,
            bodyHeight: 1.75,
            onInternalLink: (uri) => _showInternalLinkNotice(context, uri),
          ),
      ],
    );
  }
}

class _FloorsFooter extends StatelessWidget {
  const _FloorsFooter({required this.state, required this.onLoadMore});

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
      return _DetailTransientFailure(
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
          : const Icon(Icons.expand_more_rounded),
      label: Text(state.isLoadingMore ? '正在加载' : '加载更多楼层'),
    );
  }
}

class _AuthorLine extends StatelessWidget {
  const _AuthorLine({
    required this.author,
    required this.time,
    this.compact = false,
  });

  final ThreadAuthorModel author;
  final DateTime time;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 36.0 : 44.0;
    final fallback = ColoredBox(
      color: tokens.softPanel,
      child: Icon(Icons.person_rounded, color: tokens.mutedText),
    );
    return Row(
      children: [
        Semantics(
          image: true,
          label: '${author.username} 的头像',
          child: ClipOval(
            child: SizedBox.square(
              dimension: size,
              child: author.avatarUrl == null
                  ? fallback
                  : CachedNetworkImage(
                      imageUrl: author.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => fallback,
                      errorWidget: (_, _, _) => fallback,
                    ),
            ),
          ),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: tokens.space4),
              Text(
                'Lv.${author.level} · ${_formatTime(time)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent ? tokens.accentedBackground : tokens.softPanel,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space8,
          vertical: tokens.space4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: accent ? tokens.brand : tokens.mutedText,
            ),
            SizedBox(width: tokens.space4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final color = accent ? tokens.brand : tokens.mutedText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: tokens.space4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

PostComposerTarget _bodyTarget(
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

PostComposerTarget _floorTarget(
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

PostComposerTarget _editFloorTarget(
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

PostItem _floorAsPost(
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

void _showInternalLinkNotice(BuildContext context, Uri uri) {
  openInternalWenyouLink(context, uri);
}

String _formatTime(DateTime value) {
  return DateFormat('MM-dd HH:mm').format(value.toLocal());
}

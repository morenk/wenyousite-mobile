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
      child: WenyouConstrainedWidth(child: child),
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

class _ThreadOverview extends StatelessWidget {
  const _ThreadOverview({
    required this.detail,
    required this.categoryName,
    required this.selectedSubthreadId,
    required this.onSubthreadSelected,
    required this.onRequireAuthentication,
    required this.onPlayerExited,
  });

  final ThreadDetailModel detail;
  final String categoryName;
  final String? selectedSubthreadId;
  final ValueChanged<String> onSubthreadSelected;
  final VoidCallback onRequireAuthentication;
  final Future<void> Function() onPlayerExited;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final interactionTarget = ThreadInteractionTarget(
      threadId: detail.id,
      isLiked: detail.isLiked,
      likeCount: detail.likeCount,
      isBookmarked: detail.isBookmarked,
      bookmarkId: detail.bookmarkId,
    );
    return Card(
      key: const Key('thread-detail-overview'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: tokens.space8,
                  runSpacing: tokens.space4,
                  children: [
                    if (detail.isPinned) const _ThreadContextBadge(label: '置顶'),
                    _ThreadContextBadge(label: categoryName, outlined: true),
                    _ThreadContextBadge(label: detail.status.label),
                    if (detail.isPrivate)
                      const _ThreadContextBadge(label: '私密'),
                    for (final tag in detail.tags)
                      WenyouTagLink(
                        key: Key('thread-detail-tag-${tag.id}'),
                        name: tag.name,
                        onPressed: () => context.pushNamed(
                          'tag-threads',
                          pathParameters: {'tagId': tag.id},
                        ),
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
                SizedBox(height: tokens.space8),
                _ThreadMetadata(detail: detail),
                ThreadMembershipControls(
                  threadId: detail.id,
                  canExitPlayer:
                      detail.isCurrentUserPlayer && !detail.isCurrentUserOwner,
                  onExited: onPlayerExited,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: tokens.border),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space8,
              vertical: tokens.space4,
            ),
            child: detail.subthreads.isNotEmpty && selectedSubthreadId != null
                ? _SubthreadNavigator(
                    subthreads: detail.subthreads,
                    selectedSubthreadId: selectedSubthreadId!,
                    onSelected: onSubthreadSelected,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ThreadInteractionActions(
                          target: interactionTarget,
                          onRequireAuthentication: onRequireAuthentication,
                          compact: true,
                        ),
                        ThreadSubscriptionControls(
                          threadId: detail.id,
                          viewerUserId: detail.currentUserId,
                          hasAutomaticUpdates: detail.hasAutomaticUpdates,
                          compact: true,
                        ),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ThreadInteractionActions(
                          target: interactionTarget,
                          onRequireAuthentication: onRequireAuthentication,
                          compact: true,
                        ),
                        ThreadSubscriptionControls(
                          threadId: detail.id,
                          viewerUserId: detail.currentUserId,
                          hasAutomaticUpdates: detail.hasAutomaticUpdates,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ThreadContextBadge extends StatelessWidget {
  const _ThreadContextBadge({required this.label, this.outlined = false});

  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : tokens.accentedBackground,
          border: outlined ? Border.all(color: tokens.border) : null,
          borderRadius: BorderRadius.circular(tokens.radiusPill),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space12,
            vertical: tokens.space4,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: outlined ? tokens.text : tokens.brand,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadMetadata extends StatelessWidget {
  const _ThreadMetadata({required this.detail});

  final ThreadDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: tokens.space12,
      runSpacing: tokens.space4,
      children: [
        Text(
          detail.owner.username,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        WenyouLevelBadge(level: detail.owner.level),
        Text(
          formatWenyouRelativeTime(detail.updatedAt),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
        _ThreadMetric(
          icon: Icons.visibility_outlined,
          label: '${detail.viewCount} 浏览',
        ),
        _ThreadMetric(
          icon: Icons.group_outlined,
          label: '${detail.playerCount} 位玩家',
        ),
        _ThreadMetric(
          icon: Icons.layers_outlined,
          label: '${detail.postCount} 楼',
        ),
        if (detail.tipTotal != '0')
          _ThreadMetric(
            icon: Icons.local_gas_station_outlined,
            label: '${detail.tipTotal} 升温油',
          ),
      ],
    );
  }
}

class _ThreadMetric extends StatelessWidget {
  const _ThreadMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: tokens.mutedText),
        SizedBox(width: tokens.space4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
    );
  }
}

class _SubthreadNavigator extends StatefulWidget {
  const _SubthreadNavigator({
    required this.subthreads,
    required this.selectedSubthreadId,
    required this.onSelected,
    required this.trailing,
  });

  final List<ThreadSubthreadModel> subthreads;
  final String selectedSubthreadId;
  final ValueChanged<String> onSelected;
  final Widget trailing;

  @override
  State<_SubthreadNavigator> createState() => _SubthreadNavigatorState();
}

class _SubthreadNavigatorState extends State<_SubthreadNavigator> {
  var _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedIndex = widget.subthreads.indexWhere(
      (subthread) => subthread.id == widget.selectedSubthreadId,
    );
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final selected = widget.subthreads[safeIndex];
    final canCycle = widget.subthreads.length > 1;
    final previousIndex =
        (safeIndex - 1 + widget.subthreads.length) % widget.subthreads.length;
    final nextIndex = (safeIndex + 1) % widget.subthreads.length;
    return Row(
      children: [
        IconButton(
          key: const Key('thread-subthread-previous'),
          onPressed: canCycle
              ? () => widget.onSelected(widget.subthreads[previousIndex].id)
              : null,
          tooltip: canCycle
              ? '上一个子贴：${widget.subthreads[previousIndex].title}'
              : '没有其他子贴',
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(width: tokens.space4),
        Expanded(
          child: OutlinedButton(
            key: const Key('thread-subthread-menu'),
            onPressed: () => _showSubthreads(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, tokens.minimumTouchTarget),
              padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showDirectoryIcon = constraints.maxWidth >= 128;
                final showPostCount = constraints.maxWidth >= 176;
                return Row(
                  children: [
                    if (showDirectoryIcon) ...[
                      const Icon(Icons.format_list_bulleted_rounded, size: 18),
                      SizedBox(width: tokens.space8),
                    ],
                    Expanded(
                      child: Text(
                        selected.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showPostCount) ...[
                      SizedBox(width: tokens.space4),
                      Text(
                        '${selected.postCount} 楼',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.mutedText,
                        ),
                      ),
                    ],
                    SizedBox(width: tokens.space4),
                    Icon(
                      _menuOpen
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(width: tokens.space4),
        IconButton(
          key: const Key('thread-subthread-next'),
          onPressed: canCycle
              ? () => widget.onSelected(widget.subthreads[nextIndex].id)
              : null,
          tooltip: canCycle
              ? '下一个子贴：${widget.subthreads[nextIndex].title}'
              : '没有其他子贴',
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        SizedBox(width: tokens.space4),
        widget.trailing,
      ],
    );
  }

  Future<void> _showSubthreads(BuildContext context) async {
    setState(() => _menuOpen = true);
    String? selected;
    try {
      selected = await showModalBottomSheet<String>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          final tokens = sheetContext.wenyouTokens;
          return SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.72,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.space16,
                      0,
                      tokens.space16,
                      tokens.space12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '主题目录',
                            style: Theme.of(sheetContext).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '共 ${widget.subthreads.length} 个子贴',
                          style: Theme.of(sheetContext).textTheme.bodySmall
                              ?.copyWith(color: tokens.mutedText),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: tokens.border),
                  Flexible(
                    child: ListView.separated(
                      key: const Key('thread-subthread-directory'),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.all(tokens.space12),
                      itemCount: widget.subthreads.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: tokens.space4),
                      itemBuilder: (context, index) {
                        final subthread = widget.subthreads[index];
                        final isSelected =
                            subthread.id == widget.selectedSubthreadId;
                        return ListTile(
                          key: Key('thread-subthread-${subthread.id}'),
                          minTileHeight: tokens.minimumTouchTarget,
                          selected: isSelected,
                          selectedColor: tokens.brand,
                          selectedTileColor: tokens.accentedBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              tokens.radius12,
                            ),
                          ),
                          leading: SizedBox.square(
                            dimension: 24,
                            child: isSelected
                                ? const Icon(Icons.check_rounded, size: 20)
                                : null,
                          ),
                          title: Text(subthread.title),
                          trailing: Text(
                            '${subthread.postCount} 楼',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: tokens.mutedText),
                          ),
                          onTap: () => Navigator.pop(context, subthread.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _menuOpen = false);
    }
    if (!mounted) return;
    if (selected != null && selected != widget.selectedSubthreadId) {
      widget.onSelected(selected);
    }
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
    return Semantics(
      container: true,
      label: '当前子贴正文',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canEdit)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: const Key('thread-body-edit'),
                  onPressed: onEdit,
                  tooltip: body == null ? '添加正文' : '编辑正文',
                  icon: Icon(
                    body == null
                        ? Icons.note_add_outlined
                        : Icons.edit_outlined,
                  ),
                ),
              ),
            if (canEdit) SizedBox(height: tokens.space4),
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

class _FloorCard extends ConsumerWidget {
  const _FloorCard({
    required this.threadId,
    required this.floor,
    required this.authenticated,
    required this.viewerId,
    required this.canManageThread,
    required this.reportsEnabled,
    required this.pendingPostId,
    required this.canEdit,
    required this.canDelete,
    required this.pending,
    required this.showDiscussion,
    required this.onDiscussion,
    required this.onEdit,
    required this.onDelete,
    required this.onReplyToReply,
    required this.onEditReply,
    required this.onDeleteReply,
    this.reportReturnTo,
    this.isFocused = false,
    super.key,
  });

  final String threadId;
  final ThreadFloorModel floor;
  final bool authenticated;
  final String? viewerId;
  final bool canManageThread;
  final bool reportsEnabled;
  final String? pendingPostId;
  final bool isFocused;
  final bool canEdit;
  final bool canDelete;
  final bool pending;
  final bool showDiscussion;
  final VoidCallback onDiscussion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<ThreadReplyModel> onReplyToReply;
  final ValueChanged<ThreadReplyModel> onEditReply;
  final ValueChanged<ThreadReplyModel> onDeleteReply;
  final String? reportReturnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    return Semantics(
      container: true,
      label: floor.floorNumber == null ? '楼层' : '第 ${floor.floorNumber} 楼',
      hint: '长按打开楼层操作',
      child: GestureDetector(
        key: Key('thread-floor-card-${floor.id}'),
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _showActions(context, ref),
        child: Container(
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
                      key: Key('thread-floor-author-${floor.id}'),
                      author: floor.author,
                      time: floor.createdAt,
                      compact: true,
                    ),
                  ),
                  SizedBox(width: tokens.space8),
                  Tooltip(
                    message: '楼层操作',
                    child: TextButton(
                      key: Key('thread-floor-actions-${floor.id}'),
                      onPressed: pending
                          ? null
                          : () => _showActions(context, ref),
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.mutedText,
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            floor.floorNumber == null
                                ? '楼层'
                                : '#${floor.floorNumber}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(width: tokens.space4),
                          const Icon(Icons.more_horiz_rounded, size: 18),
                        ],
                      ),
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
                  onInternalLink: (uri) =>
                      _showInternalLinkNotice(context, uri),
                ),
              if (floor.replies.isNotEmpty) ...[
                SizedBox(height: tokens.space12),
                _InlineReplies(
                  threadId: threadId,
                  floor: floor,
                  authenticated: authenticated,
                  viewerId: viewerId,
                  canManageThread: canManageThread,
                  reportsEnabled: reportsEnabled,
                  pendingPostId: pendingPostId,
                  onReply: onReplyToReply,
                  onEdit: onEditReply,
                  onDelete: onDeleteReply,
                ),
              ],
              if (showDiscussion) ...[
                SizedBox(height: tokens.space4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: Key('thread-floor-discussion-${floor.id}'),
                    onPressed: pending ? null : onDiscussion,
                    style: TextButton.styleFrom(
                      foregroundColor: tokens.mutedText,
                      padding: EdgeInsets.symmetric(horizontal: tokens.space8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          floor.replyCount == 0
                              ? Icons.reply_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 16,
                        ),
                        SizedBox(width: tokens.space4),
                        Text(
                          floor.replyCount == 0
                              ? '回复'
                              : '${floor.replyCount} 条回复',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (floor.replyCount > 0) ...[
                          SizedBox(width: tokens.space4),
                          const Icon(Icons.chevron_right_rounded, size: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showPostCardActionSheet(
      context: context,
      title: '楼层操作',
      authorName: floor.author.username,
      canCopyText: !floor.isDeleted,
      canReply: showDiscussion,
      canEdit: !floor.isDeleted && canEdit,
      canDelete: !floor.isDeleted && canDelete,
      canReport: !floor.isDeleted && reportReturnTo != null,
      pending: pending,
      replyLabel: floor.replyCount > 0 ? '查看回复' : '回复',
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case PostCardAction.copyText:
        await copyPostCardValue(context, floor.body.markdown, '内容已复制');
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.reply:
        onDiscussion();
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

class _InlineReplies extends StatelessWidget {
  const _InlineReplies({
    required this.threadId,
    required this.floor,
    required this.authenticated,
    required this.viewerId,
    required this.canManageThread,
    required this.reportsEnabled,
    required this.pendingPostId,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  final String threadId;
  final ThreadFloorModel floor;
  final bool authenticated;
  final String? viewerId;
  final bool canManageThread;
  final bool reportsEnabled;
  final String? pendingPostId;
  final ValueChanged<ThreadReplyModel> onReply;
  final ValueChanged<ThreadReplyModel> onEdit;
  final ValueChanged<ThreadReplyModel> onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: tokens.border, width: 2)),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: tokens.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < floor.replies.length; index++) ...[
              if (index > 0) ...[
                Divider(height: tokens.space24, color: tokens.border),
              ],
              _InlineReply(
                threadId: threadId,
                floorId: floor.id,
                reply: floor.replies[index],
                authenticated: authenticated,
                viewerId: viewerId,
                canManageThread: canManageThread,
                reportsEnabled: reportsEnabled,
                pending: pendingPostId == floor.replies[index].id,
                onReply: () => onReply(floor.replies[index]),
                onEdit: () => onEdit(floor.replies[index]),
                onDelete: () => onDelete(floor.replies[index]),
              ),
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

class _InlineReply extends ConsumerWidget {
  const _InlineReply({
    required this.threadId,
    required this.floorId,
    required this.reply,
    required this.authenticated,
    required this.viewerId,
    required this.canManageThread,
    required this.reportsEnabled,
    required this.pending,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

  final String threadId;
  final String floorId;
  final ThreadReplyModel reply;
  final bool authenticated;
  final String? viewerId;
  final bool canManageThread;
  final bool reportsEnabled;
  final bool pending;
  final VoidCallback onReply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.wenyouTokens;
    final ownReply = reply.author.id == viewerId;
    return Semantics(
      container: true,
      hint: '长按打开回复操作',
      child: GestureDetector(
        key: Key('thread-inline-reply-${reply.id}'),
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _showActions(context, ref, ownReply: ownReply),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: tokens.space4,
              runSpacing: tokens.space4 / 2,
              children: [
                Text(
                  reply.author.username,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                WenyouLevelBadge(
                  key: Key('thread-reply-level-${reply.id}'),
                  level: reply.author.level,
                ),
                if (reply.replyToUsername != null)
                  Text(
                    '回复 @${reply.replyToUsername}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                  ),
                Text(
                  formatWenyouRelativeTime(reply.createdAt),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
                ),
              ],
            ),
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
        ),
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref, {
    required bool ownReply,
  }) async {
    final action = await showPostCardActionSheet(
      context: context,
      title: '回复操作',
      authorName: reply.author.username,
      canCopyText: !reply.isDeleted,
      canReply: !reply.isDeleted && authenticated,
      canEdit: !reply.isDeleted && ownReply,
      canDelete: !reply.isDeleted && (ownReply || canManageThread),
      canReport: !reply.isDeleted && reportsEnabled && !ownReply,
      pending: pending,
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case PostCardAction.copyText:
        await copyPostCardValue(context, reply.body.markdown, '内容已复制');
      case PostCardAction.copyLink:
        await copyPostCardValue(context, _publicLink(), '楼层链接已复制');
      case PostCardAction.reply:
        onReply();
      case PostCardAction.edit:
        onEdit();
      case PostCardAction.delete:
        onDelete();
      case PostCardAction.report:
        await showWenyouReportFlow(
          context: context,
          ref: ref,
          target: ReportTarget.post(reply.id),
          targetLabel: '这条回复',
          returnTo: '/threads/$threadId?post=${reply.id}',
        );
    }
  }

  String _publicLink() => Uri.parse('https://wenyou.site')
      .resolve('/threads/$threadId/posts/$floorId/replies?post=${reply.id}')
      .toString();
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
    super.key,
  });

  final ThreadAuthorModel author;
  final DateTime time;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final size = compact ? 32.0 : 36.0;
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
              Text(
                formatWenyouRelativeTime(time),
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

PostComposerTarget _replyTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
  ThreadReplyModel reply,
) {
  return (
    kind: PostComposerKind.createReply,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: null,
    parentPostId: floor.id,
    replyToPostId: reply.id,
    version: null,
    initialContent: '',
    label: '回复 @${reply.author.username}',
  );
}

PostComposerTarget _editReplyTarget(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
  ThreadReplyModel reply,
) {
  return (
    kind: PostComposerKind.editPost,
    threadId: detail.id,
    subthreadId: subthread.id,
    postId: reply.id,
    parentPostId: floor.id,
    replyToPostId: null,
    version: reply.version,
    initialContent: reply.body.markdown,
    label: '编辑回复',
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

PostItem _replyAsPost(
  ThreadDetailModel detail,
  ThreadSubthreadModel subthread,
  ThreadFloorModel floor,
  ThreadReplyModel reply,
) {
  return PostItem(
    id: reply.id,
    threadId: detail.id,
    subthreadId: subthread.id,
    author: PostAuthor(
      id: reply.author.id,
      username: reply.author.username,
      level: reply.author.level,
      avatarUrl: reply.author.avatarUrl,
    ),
    content: reply.body.markdown,
    version: reply.version,
    createdAt: reply.createdAt,
    updatedAt: reply.createdAt,
    isBody: false,
    isDeleted: reply.isDeleted,
    parentPostId: floor.id,
    threadTitle: detail.title,
    subthreadTitle: subthread.title,
    diceRolls: reply.body.diceRolls
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

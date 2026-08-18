import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class MomentDetailPage extends ConsumerStatefulWidget {
  const MomentDetailPage({required this.momentId, super.key});

  final String momentId;

  @override
  ConsumerState<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends ConsumerState<MomentDetailPage> {
  static const _contentCacheExtent = 4000.0;

  var _commentComposerOpen = false;
  MomentCommentDraft? _commentDraft;
  MomentComment? _commentDraftReplyTo;

  @override
  Widget build(BuildContext context) {
    final provider = momentDetailControllerProvider(widget.momentId);
    final state = ref.watch(provider);
    final session = ref.watch(sessionControllerProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    ref.listen(provider.select((value) => value.transientFailure), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.userMessage)));
      }
    });
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      appBar: AppBar(
        leading: BackButton(
          key: const Key('moment-detail-back'),
          onPressed: _leaveDetail,
        ),
        title: const Text('动态详情'),
        actions: _momentAppBarActions(state, provider),
      ),
      body: switch (state.phase) {
        MomentLoadPhase.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        MomentLoadPhase.failed => _MomentDetailFailure(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        MomentLoadPhase.ready => RefreshIndicator(
          onRefresh: () => ref.read(provider.notifier).load(),
          child: CustomScrollView(
            key: const PageStorageKey('moment-detail-scroll'),
            scrollCacheExtent: const ScrollCacheExtent.pixels(
              _contentCacheExtent,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: MomentContentPadding(
                  top: context.wenyouTokens.space16,
                  child: _MomentDetailPanel(
                    detail: state.detail!,
                    pendingAction: state.pendingMomentAction,
                    onLike: () => _authenticated(
                      () => ref.read(provider.notifier).toggleLike(),
                    ),
                    onBookmark: () => _authenticated(
                      () => ref.read(provider.notifier).toggleBookmark(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MomentContentPadding(
                  top: context.wenyouTokens.space12,
                  child: _CommentFilters(
                    state: state,
                    onOrder: (order) =>
                        ref.read(provider.notifier).selectCommentOrder(order),
                    onAuthor: (authorId) => ref
                        .read(provider.notifier)
                        .selectCommentAuthor(authorId),
                  ),
                ),
              ),
              if (state.comments.isEmpty)
                SliverToBoxAdapter(
                  child: MomentContentPadding(
                    top: context.wenyouTokens.space12,
                    child: const WenyouEmptyState(
                      icon: WenyouIconIds.metricComments,
                      title: '还没有评论',
                      message: '可以留下第一条评论。',
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return MomentContentPadding(
                      top: index == 0 ? context.wenyouTokens.space12 : 0,
                      child: Column(
                        children: [
                          if (index > 0)
                            Divider(height: context.wenyouTokens.space24),
                          _MomentRootCommentPanel(
                            root: comment,
                            replyPage: state.replyPages[comment.id],
                            busyCommentIds: state.busyCommentIds,
                            viewerId: viewerId,
                            returnTo: '/moments/${widget.momentId}',
                            onReply: (target) => _authenticated(
                              () => _openCommentComposer(target),
                            ),
                            onDelete: (target) =>
                                _deleteComment(context, provider, target),
                            onReport: (target) =>
                                _reportComment(context, target),
                            onLoadReplies: () => ref
                                .read(provider.notifier)
                                .loadReplies(comment.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (state.hasMoreComments || state.isLoadingMoreComments)
                SliverToBoxAdapter(
                  child: MomentContentPadding(
                    top: context.wenyouTokens.space12,
                    child: Center(
                      child: state.isLoadingMoreComments
                          ? const CircularProgressIndicator()
                          : OutlinedButton.icon(
                              key: const Key('moment-comments-load-more'),
                              onPressed: () => ref
                                  .read(provider.notifier)
                                  .loadMoreComments(),
                              icon: const WenyouIcon(
                                WenyouIconIds.navigationExpand,
                              ),
                              label: const Text('加载更多评论'),
                            ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      context.wenyouTokens.minimumTouchTarget +
                      context.wenyouTokens.space32 +
                      context.wenyouTokens.space16,
                ),
              ),
            ],
          ),
        ),
      },
      floatingActionButton:
          state.phase == MomentLoadPhase.ready && !_commentComposerOpen
          ? WenyouComposerAction(
              key: const Key('moment-comment-dock'),
              label: session.isAuthenticated ? '发表评论…' : '登录后发表评论',
              icon: session.isAuthenticated
                  ? WenyouIconIds.metricComments
                  : WenyouIconIds.actionLogin,
              onPressed: () => _authenticated(() => _openCommentComposer()),
            )
          : null,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
    );
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && mounted) context.go(AppRouteLocations.moments);
      },
      child: scaffold,
    );
  }

  void _leaveDetail() {
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    } else {
      context.go(AppRouteLocations.moments);
    }
  }

  List<Widget> _momentAppBarActions(
    MomentDetailState state,
    AutoDisposeStateNotifierProvider<MomentDetailController, MomentDetailState>
    provider,
  ) {
    return [
      if (state.detail case final detail? when !detail.canEdit)
        WenyouTipButton(
          key: const Key('moment-detail-tip'),
          target: TipTarget.moment(
            id: detail.card.id,
            recipientUserId: detail.card.author.id,
          ),
          recipientName: detail.card.author.username,
          returnTo: '/moments/${detail.card.id}',
          iconOnly: true,
          onSuccess: (_) => ref.read(provider.notifier).load(),
        ),
      if (state.detail case final detail? when !detail.canEdit)
        WenyouReportButton(
          key: const Key('moment-detail-report'),
          target: ReportTarget.moment(detail.card.id),
          targetLabel: '这条动态',
          returnTo: '/moments/${detail.card.id}',
          iconOnly: true,
        ),
      if (state.detail?.canEdit ?? false)
        IconButton(
          key: const Key('moment-detail-edit'),
          onPressed: () async {
            final result = await context.pushNamed<MomentDetail>(
              'moment-edit',
              pathParameters: {'momentId': widget.momentId},
            );
            if (result != null && mounted) {
              await ref.read(provider.notifier).load();
            }
          },
          tooltip: '编辑动态',
          icon: const WenyouIcon(WenyouIconIds.actionEdit),
        ),
    ];
  }

  void _authenticated(VoidCallback action) {
    if (ref.read(sessionControllerProvider).isAuthenticated) {
      action();
    } else {
      _openLogin();
    }
  }

  void _openLogin() {
    context.push(
      AppRouteLocations.login(
        returnTo: AppRouteLocations.moment(widget.momentId),
      ),
    );
  }

  Future<void> _openCommentComposer([MomentComment? replyTo]) async {
    if (!ref.read(sessionControllerProvider).isAuthenticated) {
      _openLogin();
      return;
    }
    final provider = momentDetailControllerProvider(widget.momentId);
    var currentReplyTo = replyTo ?? _commentDraftReplyTo;
    setState(() => _commentComposerOpen = true);
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: false,
        useSafeArea: false,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        sheetAnimationStyle: AnimationStyle.noAnimation,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => Consumer(
            builder: (context, sheetRef, _) {
              final state = sheetRef.watch(provider);
              return Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    width: double.infinity,
                    child: MomentCommentComposer(
                      replyTo: currentReplyTo,
                      initialDraft: _commentDraft ?? const MomentCommentDraft(),
                      onDraftChanged: (draft) {
                        _commentDraft = draft.isEmpty ? null : draft;
                      },
                      isSending: state.isSendingComment,
                      onCancelReply: () =>
                          setSheetState(() => currentReplyTo = null),
                      onClose: () => Navigator.of(sheetContext).pop(),
                      onSend: (input) async {
                        final created = await sheetRef
                            .read(provider.notifier)
                            .sendComment(input);
                        if (created != null) {
                          _commentDraft = null;
                          _commentDraftReplyTo = null;
                        }
                        return created != null;
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        _commentDraftReplyTo = _commentDraft == null ? null : currentReplyTo;
        setState(() => _commentComposerOpen = false);
      }
    }
  }

  Future<void> _deleteComment(
    BuildContext context,
    AutoDisposeStateNotifierProvider<MomentDetailController, MomentDetailState>
    provider,
    MomentComment comment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除评论？'),
        content: const Text('评论会显示为已删除，楼中楼结构会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('moment-comment-delete-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(provider.notifier).removeComment(comment.id);
    }
  }

  Future<void> _reportComment(BuildContext context, MomentComment comment) {
    return showWenyouReportFlow(
      context: context,
      ref: ref,
      target: ReportTarget.momentComment(comment.id),
      targetLabel: '这条评论',
      returnTo: '/moments/${widget.momentId}',
    );
  }
}

class _MomentDetailPanel extends StatelessWidget {
  const _MomentDetailPanel({
    required this.detail,
    required this.pendingAction,
    required this.onLike,
    required this.onBookmark,
  });

  final MomentDetail detail;
  final MomentInteractionAction? pendingAction;
  final VoidCallback onLike;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final card = detail.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MomentAuthorLine(
                author: card.author,
                createdAt: card.createdAt,
                onTap: () => context.pushNamed(
                  'user-profile',
                  pathParameters: {'userId': card.author.id},
                ),
              ),
              SizedBox(height: tokens.space16),
              Text(
                card.title,
                style: Theme.of(context).textTheme.wenyouDetailTitle,
              ),
            ],
          ),
        ),
        if (detail.images.isNotEmpty) ...[
          SizedBox(height: tokens.space16),
          MomentGallery(
            images: detail.images,
            coverMedia: detail.card.coverMedia,
          ),
        ],
        if (detail.content.isNotEmpty) ...[
          SizedBox(height: tokens.space12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space8),
            child: WenyouInternalReferenceText(
              content: detail.content,
              selectable: true,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ),
        ],
        SizedBox(height: tokens.space16),
        const Divider(height: 1),
        Row(
          children: [
            Expanded(
              child: _DetailAction(
                key: const Key('moment-detail-like'),
                icon: card.viewerLiked
                    ? WenyouIconIds.actionLike
                    : WenyouIconIds.actionLike,
                label: '${card.likeCount} 点赞',
                selected: card.viewerLiked,
                kind: WenyouInteractionKind.like,
                pending: pendingAction == MomentInteractionAction.like,
                onPressed: pendingAction == null ? onLike : null,
              ),
            ),
            Expanded(
              child: _DetailAction(
                key: const Key('moment-detail-bookmark'),
                icon: card.viewerBookmarked
                    ? WenyouIconIds.actionBookmark
                    : WenyouIconIds.actionBookmark,
                label: '${card.bookmarkCount} 收藏',
                selected: card.viewerBookmarked,
                kind: WenyouInteractionKind.bookmark,
                pending: pendingAction == MomentInteractionAction.bookmark,
                onPressed: pendingAction == null ? onBookmark : null,
              ),
            ),
            Expanded(
              child: _DetailAction(
                icon: WenyouIconIds.metricComments,
                label: '${card.commentCount} 评论',
              ),
            ),
          ],
        ),
        if (card.tipTotal != '0') ...[
          SizedBox(height: tokens.space8),
          Text(
            '已获得 ${WenyouAmount.format(card.tipTotal)} 升加油',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.label,
    this.selected = false,
    this.kind,
    this.pending = false,
    this.onPressed,
    super.key,
  });

  final String icon;
  final String label;
  final bool selected;
  final WenyouInteractionKind? kind;
  final bool pending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (kind case final interactionKind?) {
      return WenyouInteractionToggle(
        kind: interactionKind,
        selected: selected,
        pending: pending,
        onPressed: onPressed,
        semanticLabel: label,
        supporting: Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        expand: true,
      );
    }
    return TextButton.icon(
      onPressed: onPressed,
      icon: WenyouIcon(
        icon,
        size: 20,
        color: selected ? context.wenyouTokens.focus : null,
      ),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _CommentFilters extends StatelessWidget {
  const _CommentFilters({
    required this.state,
    required this.onOrder,
    required this.onAuthor,
  });

  final MomentDetailState state;
  final ValueChanged<MomentCommentOrder> onOrder;
  final ValueChanged<String?> onAuthor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final selectedAuthor = state.commentAuthors
        .where((author) => author.id == state.commentAuthorId)
        .firstOrNull;
    return Row(
      children: [
        PopupMenuButton<MomentCommentOrder>(
          key: const Key('moment-comment-order'),
          initialValue: state.commentOrder,
          tooltip: '评论排序',
          onSelected: onOrder,
          itemBuilder: (context) => [
            for (final order in MomentCommentOrder.values)
              PopupMenuItem(
                value: order,
                child: Text(
                  order == MomentCommentOrder.newest ? '最新在前' : '最早在前',
                ),
              ),
          ],
          child: _CompactFilterButton(
            icon: WenyouIconIds.actionSort,
            label: state.commentOrder == MomentCommentOrder.newest
                ? '最新在前'
                : '最早在前',
          ),
        ),
        const Spacer(),
        TextButton.icon(
          key: const Key('moment-comment-author-filter'),
          onPressed: () => _showAuthorFilter(context),
          icon: WenyouIcon(
            WenyouIconIds.actionFilter,
            size: 20,
            color: selectedAuthor == null
                ? tokens.mutedText
                : tokens.brandForeground,
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
        groupValue: state.commentAuthorId ?? '',
        onChanged: (value) => Navigator.pop(context, value),
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('只看某位作者')),
            const RadioListTile<String>(value: '', title: Text('全部作者')),
            for (final author in state.commentAuthors)
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
      if (authorId != state.commentAuthorId) onAuthor(authorId);
    }
  }
}

class _CompactFilterButton extends StatelessWidget {
  const _CompactFilterButton({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WenyouIcon(icon, size: 20),
            SizedBox(width: tokens.space4),
            Text(label),
            const WenyouIcon(WenyouIconIds.navigationExpand, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MomentRootCommentPanel extends StatelessWidget {
  const _MomentRootCommentPanel({
    required this.root,
    required this.replyPage,
    required this.busyCommentIds,
    required this.viewerId,
    required this.returnTo,
    required this.onReply,
    required this.onDelete,
    required this.onReport,
    required this.onLoadReplies,
  });

  final MomentRootComment root;
  final MomentReplyPageState? replyPage;
  final Set<String> busyCommentIds;
  final String? viewerId;
  final String returnTo;
  final ValueChanged<MomentComment> onReply;
  final ValueChanged<MomentComment> onDelete;
  final Future<void> Function(MomentComment) onReport;
  final VoidCallback onLoadReplies;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final replies = replyPage?.items ?? root.replies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MomentCommentBody(
          comment: root,
          busy: busyCommentIds.contains(root.id),
          onReply: () => onReply(root),
          onDelete: root.canDelete ? () => onDelete(root) : null,
          onReport: () => onReport(root),
          reportReturnTo: root.author.id == viewerId ? null : returnTo,
        ),
        if (replies.isNotEmpty) ...[
          SizedBox(height: tokens.space12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: tokens.border, width: 2)),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: tokens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < replies.length; index++) ...[
                    MomentCommentBody(
                      comment: replies[index],
                      compact: true,
                      busy: busyCommentIds.contains(replies[index].id),
                      onReply: () => onReply(replies[index]),
                      onDelete: replies[index].canDelete
                          ? () => onDelete(replies[index])
                          : null,
                      onReport: () => onReport(replies[index]),
                      reportReturnTo: replies[index].author.id == viewerId
                          ? null
                          : returnTo,
                    ),
                    if (index + 1 < replies.length)
                      Divider(height: tokens.space20),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (root.replyCount > replies.length ||
            (replyPage?.hasMore ?? false) ||
            (replyPage?.isLoading ?? false)) ...[
          SizedBox(height: tokens.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: Key('moment-replies-${root.id}'),
              onPressed: replyPage?.isLoading ?? false ? null : onLoadReplies,
              icon: replyPage?.isLoading ?? false
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const WenyouIcon(WenyouIconIds.actionReply),
              label: Text('查看全部 ${root.replyCount} 条回复'),
            ),
          ),
        ],
        if (replyPage?.failure != null)
          WenyouStatusBanner(
            message: replyPage!.failure!.userMessage,
            tone: WenyouStatusTone.error,
            action: TextButton(
              onPressed: onLoadReplies,
              child: const Text('重试'),
            ),
          ),
      ],
    );
  }
}

class _MomentDetailFailure extends StatelessWidget {
  const _MomentDetailFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final notFound =
        failure?.httpStatus == 404 || failure?.businessCode == 40415;
    return MomentContentPadding(
      top: 16,
      child: WenyouPanel(
        child: WenyouEmptyState(
          icon: notFound
              ? WenyouIconIds.navigationMoments
              : WenyouIconIds.statusOffline,
          title: notFound ? '动态不存在' : '动态详情加载失败',
          message: notFound
              ? '这条动态可能已被删除或不可见。'
              : (failure?.userMessage ?? '请稍后重试。'),
          detail: failure?.requestId == null
              ? null
              : '问题编号：${failure!.requestId}',
          action: notFound
              ? null
              : OutlinedButton.icon(
                  key: const Key('moment-detail-retry'),
                  onPressed: onRetry,
                  icon: const WenyouIcon(WenyouIconIds.actionRefresh),
                  label: const Text('重新加载'),
                ),
        ),
      ),
    );
  }
}

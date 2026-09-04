import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/bookmark_folder_catalog.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_bookmark_folder_picker.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_composer_sheet.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_reply_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_scroll_policy.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_overflow_content.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_transient_target_frame.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_composer.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_comment_navigation.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_comment_body.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_detail_interaction_bar.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class MomentDetailPage extends ConsumerStatefulWidget {
  const MomentDetailPage({
    required this.momentId,
    this.targetCommentId,
    super.key,
  });

  final String momentId;
  final String? targetCommentId;

  @override
  ConsumerState<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends ConsumerState<MomentDetailPage> {
  static const _contentCacheExtent = 4000.0;

  final _scrollController = ScrollController();
  final _targetKey = GlobalKey();
  final _targetReveal = DiscussionTargetRevealCoordinator();
  var _commentComposerOpen = false;
  MomentCommentDraft? _commentDraft;
  MomentComment? _commentDraftReplyTo;

  MomentCommentContextScope? get _targetScope {
    final commentId = widget.targetCommentId?.trim();
    if (commentId == null || commentId.isEmpty) return null;
    return (momentId: widget.momentId, commentId: commentId);
  }

  String get _location => AppRouteLocations.moment(
    widget.momentId,
    commentId: _targetScope?.commentId,
  );

  @override
  void didUpdateWidget(covariant MomentDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.momentId != widget.momentId ||
        oldWidget.targetCommentId != widget.targetCommentId) {
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
    final provider = momentDetailControllerProvider(widget.momentId);
    final state = ref.watch(provider);
    final targetScope = _targetScope;
    final targetValue = targetScope == null
        ? null
        : ref.watch(momentCommentContextProvider(targetScope));
    final projection = projectMomentCommentNavigation(
      comments: state.comments,
      replyPages: state.replyPages,
      order: state.commentOrder,
      context: targetValue?.valueOrNull,
    );
    final session = ref.watch(sessionControllerProvider);
    final sessionScope = ref.watch(sessionScopeProvider);
    final viewerId = ref.read(sessionControllerProvider.notifier).currentUserId;
    ref.listen(provider.select((value) => value.transientFailure), (
      previous,
      next,
    ) {
      if (next != null && next != previous) {
        showWenyouSnackBar(
          context,
          next.userMessage,
          pacing: WenyouSnackBarPacing.extended,
        );
      }
    });
    _revealTargetWhenReady(
      state,
      projection,
      '${sessionScope.accountId ?? 'guest'}:${sessionScope.generation}',
    );
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final scaffold = Scaffold(
      appBar: WenyouReadingAppBar(
        leading: BackButton(
          key: const Key('moment-detail-back'),
          onPressed: _leaveDetail,
        ),
        title: const Text('动态'),
        actions: _momentAppBarActions(state, provider),
      ),
      body: switch (state.phase) {
        MomentLoadPhase.loading => const Align(
          alignment: Alignment.topCenter,
          child: WenyouContentFrame(
            top: 16,
            child: WenyouDetailSkeleton(label: '正在加载动态详情'),
          ),
        ),
        MomentLoadPhase.failed => MomentDetailFailure(
          failure: state.failure,
          onRetry: () => ref.read(provider.notifier).load(),
        ),
        MomentLoadPhase.ready => NotificationListener<ScrollNotification>(
          onNotification: _targetReveal.handleUserScroll,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) => _targetReveal.handleLayoutChange(
              isMounted: () => mounted,
              requestRebuild: () => setState(() {}),
            ),
            child: RefreshIndicator(
              onRefresh: () => _refresh(provider),
              child: CustomScrollView(
                key: const PageStorageKey('moment-detail-scroll'),
                controller: _scrollController,
                scrollCacheExtent: const ScrollCacheExtent.pixels(
                  _contentCacheExtent,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: WenyouContentFrame(
                      top: context.wenyouTokens.space16,
                      child: _MomentDetailPanel(
                        detail: state.detail!,
                        pendingAction: state.pendingMomentAction,
                        onTip: state.detail!.canEdit
                            ? null
                            : () => unawaited(
                                showWenyouTipFlow(
                                  context: context,
                                  ref: ref,
                                  target: TipTarget.moment(
                                    id: state.detail!.card.id,
                                    recipientUserId:
                                        state.detail!.card.author.id,
                                  ),
                                  recipientName:
                                      state.detail!.card.author.username,
                                  returnTo: _location,
                                  onSuccess: (_) =>
                                      ref.read(provider.notifier).load(),
                                ),
                              ),
                        onLike: () => _authenticated(
                          () => ref.read(provider.notifier).toggleLike(),
                        ),
                        onBookmark: () => _authenticated(() {
                          unawaited(
                            _toggleBookmark(
                              ref.read(provider.notifier),
                              wasBookmarked:
                                  state.detail!.card.viewerBookmarked,
                              canInteract: state.detail!.card.canInteract,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: WenyouContentFrame(
                      top: context.wenyouTokens.space12,
                      child: _CommentOrderControls(
                        state: state,
                        onOrderChanged: (order) => ref
                            .read(provider.notifier)
                            .selectCommentOrder(order),
                      ),
                    ),
                  ),
                  if (targetValue != null && targetValue.asData == null)
                    SliverToBoxAdapter(
                      child: WenyouContentFrame(
                        top: context.wenyouTokens.space12,
                        child: MomentCommentTargetStatus(
                          value: targetValue,
                          onRetry: () => ref.invalidate(
                            momentCommentContextProvider(targetScope!),
                          ),
                        ),
                      ),
                    ),
                  if (projection.comments.isEmpty)
                    SliverToBoxAdapter(
                      child: WenyouContentFrame(
                        top: context.wenyouTokens.space12,
                        child: const WenyouEmptyState(
                          icon: WenyouIconIds.metricComments,
                          title: '还没有评论',
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: projection.comments.length,
                      itemBuilder: (context, index) {
                        final comment = projection.comments[index];
                        return WenyouContentFrame(
                          top: index == 0 ? context.wenyouTokens.space12 : 0,
                          child: Column(
                            children: [
                              if (index > 0)
                                Divider(height: context.wenyouTokens.space24),
                              _MomentRootCommentPanel(
                                root: comment,
                                replyPage: projection.replyPages[comment.id],
                                busyCommentIds: state.busyCommentIds,
                                viewerId: viewerId,
                                returnTo: _location,
                                targetCommentId: projection.targetId,
                                targetKey: _targetKey,
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
                      child: WenyouContentFrame(
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

  void _revealTargetWhenReady(
    MomentDetailState state,
    MomentCommentNavigationProjection projection,
    String sessionSignature,
  ) {
    final targetId = projection.targetId;
    if (targetId == null) return;
    _targetReveal.schedule(
      targetId: targetId,
      scopeSignature: '${widget.momentId}:$targetId:$sessionSignature',
      contentSignature:
          '${state.commentOrder.name}:${projection.contentSignature}',
      targetIndex: projection.targetRootIndex,
      itemCount: projection.comments.length,
      ready:
          state.phase == MomentLoadPhase.ready &&
          projection.targetRootIndex >= 0,
      targetKey: _targetKey,
      scrollController: _scrollController,
      isMounted: () => mounted,
      requestRebuild: () => setState(() {}),
    );
  }

  Future<void> _refresh(
    AutoDisposeStateNotifierProvider<MomentDetailController, MomentDetailState>
    provider,
  ) async {
    _targetReveal.reset();
    _invalidateTargetContext();
    await ref.read(provider.notifier).load();
  }

  void _invalidateTargetContext() {
    final scope = _targetScope;
    if (scope != null) ref.invalidate(momentCommentContextProvider(scope));
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
        WenyouReportButton(
          key: const Key('moment-detail-report'),
          target: ReportTarget.moment(detail.card.id),
          targetLabel: '这条动态',
          returnTo: _location,
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

  Future<void> _toggleBookmark(
    MomentDetailController controller, {
    required bool wasBookmarked,
    required bool canInteract,
  }) async {
    if (wasBookmarked) {
      await controller.toggleBookmark();
      return;
    }
    if (!canInteract) return;
    final folder = await showBookmarkFolderPicker(
      context: context,
      catalog: ref.read(
        bookmarkFolderCatalogProvider(BookmarkFolderContentKind.moment),
      ),
      onConfirm: (folderId) async {
        final succeeded = await controller.toggleBookmark(folderId: folderId);
        if (succeeded) return;
        throw controller.momentActionFailure ??
            const ApiFailure(userMessage: '收藏失败，请稍后重试。');
      },
    );
    if (!mounted || folder == null) return;
    showWenyouSnackBar(context, '已收藏到“${folder.name}”。');
  }

  void _openLogin() {
    context.push(AppRouteLocations.login(returnTo: _location));
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
      await showWenyouComposerSheet<void>(
        context: context,
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
                          _invalidateTargetContext();
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
      final removed = await ref
          .read(provider.notifier)
          .removeComment(comment.id);
      if (removed) _invalidateTargetContext();
    }
  }

  Future<void> _reportComment(BuildContext context, MomentComment comment) {
    return showWenyouReportFlow(
      context: context,
      ref: ref,
      target: ReportTarget.momentComment(comment.id),
      targetLabel: '这条评论',
      returnTo: _location,
    );
  }
}

class _MomentDetailPanel extends StatelessWidget {
  const _MomentDetailPanel({
    required this.detail,
    required this.pendingAction,
    required this.onLike,
    required this.onBookmark,
    this.onTip,
  });

  final MomentDetail detail;
  final MomentInteractionAction? pendingAction;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback? onTip;

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
              Text(
                card.title,
                style: Theme.of(context).textTheme.wenyouDetailTitle,
              ),
              SizedBox(height: tokens.space12),
              MomentAuthorLine(
                author: card.author,
                createdAt: card.createdAt,
                onTap: () => context.pushNamed(
                  'user-profile',
                  pathParameters: {'userId': card.author.id},
                ),
              ),
            ],
          ),
        ),
        if (detail.images.isNotEmpty) ...[
          SizedBox(height: tokens.space16),
          MomentGallery(
            momentId: detail.card.id,
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
              ).textTheme.wenyouBody.copyWith(height: 1.7),
            ),
          ),
        ],
        SizedBox(height: tokens.space16),
        const Divider(height: 1),
        MomentDetailInteractionBar(
          card: card,
          pendingAction: pendingAction,
          onLike: onLike,
          onBookmark: onBookmark,
          onTip: onTip,
        ),
      ],
    );
  }
}

class _CommentOrderControls extends StatelessWidget {
  const _CommentOrderControls({
    required this.state,
    required this.onOrderChanged,
  });

  final MomentDetailState state;
  final ValueChanged<MomentCommentOrder> onOrderChanged;

  @override
  Widget build(BuildContext context) {
    return WenyouDiscussionListControls<MomentCommentOrder>.orderOnly(
      countLabel:
          '${state.detail?.card.commentCount ?? state.comments.length} 条评论',
      countKey: const Key('moment-comments-count'),
      orderKey: const Key('moment-comments-order'),
      order: state.commentOrder,
      orderOptions: [
        for (final order in MomentCommentOrder.values)
          WenyouDiscussionOrderOption(
            value: order,
            label: order == MomentCommentOrder.newest ? '最新在前' : '最早在前',
            summaryLabel: order == MomentCommentOrder.newest ? '倒序' : '正序',
          ),
      ],
      enabled: !state.isRefreshing && !state.isLoadingMoreComments,
      onOrderChanged: onOrderChanged,
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
    required this.targetCommentId,
    required this.targetKey,
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
  final String? targetCommentId;
  final GlobalKey targetKey;
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
        _targetFrame(
          root,
          MomentCommentBody(
            comment: root,
            busy: busyCommentIds.contains(root.id),
            onReply: () => onReply(root),
            onDelete: root.canDelete ? () => onDelete(root) : null,
            onReport: () => onReport(root),
            reportReturnTo: root.author.id == viewerId ? null : returnTo,
          ),
        ),
        if (replies.isNotEmpty) ...[
          SizedBox(height: tokens.space12),
          WenyouDiscussionReplyGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < replies.length; index++) ...[
                  _targetFrame(
                    replies[index],
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
                  ),
                  if (index + 1 < replies.length)
                    Divider(height: 1, color: tokens.border),
                ],
              ],
            ),
          ),
        ],
        if (root.replyCount > replies.length ||
            (replyPage?.hasMore ?? false) ||
            (replyPage?.isLoading ?? false)) ...[
          SizedBox(height: tokens.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: WenyouOverflowAction(
              key: Key('moment-replies-${root.id}'),
              label: '展开楼中楼（${root.replyCount} 条）',
              icon: WenyouIconIds.navigationNext,
              backgroundColor: tokens.panel,
              appearance: WenyouOverflowActionAppearance.quiet,
              loading: replyPage?.isLoading ?? false,
              onPressed: replyPage?.isLoading ?? false ? null : onLoadReplies,
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

  Widget _targetFrame(MomentComment comment, Widget child) {
    if (comment.id != targetCommentId) return child;
    return WenyouTransientTargetFrame(
      key: targetKey,
      targetId: comment.id,
      announcement: '已定位到目标评论',
      child: child,
    );
  }
}

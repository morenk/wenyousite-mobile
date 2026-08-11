import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_route_locations.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';
import 'package:wenyousite_mobile/features/stickers/presentation/sticker_widgets.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';
import 'package:wenyousite_mobile/features/wallet/presentation/wallet_widgets.dart';

class MomentDetailPage extends ConsumerStatefulWidget {
  const MomentDetailPage({required this.momentId, super.key});

  final String momentId;

  @override
  ConsumerState<MomentDetailPage> createState() => _MomentDetailPageState();
}

class _MomentDetailPageState extends ConsumerState<MomentDetailPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态详情'),
        actions: [
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
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
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
          child: ListView(
            key: const PageStorageKey('moment-detail-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom:
                  context.wenyouTokens.minimumTouchTarget +
                  context.wenyouTokens.space32 +
                  context.wenyouTokens.space16,
            ),
            children: [
              MomentContentPadding(
                top: context.wenyouTokens.space16,
                child: _MomentDetailPanel(
                  detail: state.detail!,
                  busy: state.busyMomentAction,
                  onLike: () => _authenticated(
                    () => ref.read(provider.notifier).toggleLike(),
                  ),
                  onBookmark: () => _authenticated(
                    () => ref.read(provider.notifier).toggleBookmark(),
                  ),
                ),
              ),
              MomentContentPadding(
                top: context.wenyouTokens.space12,
                child: _CommentFilters(
                  state: state,
                  onOrder: (order) =>
                      ref.read(provider.notifier).selectCommentOrder(order),
                  onAuthor: (authorId) =>
                      ref.read(provider.notifier).selectCommentAuthor(authorId),
                ),
              ),
              if (state.comments.isEmpty)
                MomentContentPadding(
                  top: context.wenyouTokens.space12,
                  child: const WenyouEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '还没有评论',
                    message: '可以留下第一条评论。',
                  ),
                )
              else
                for (var index = 0; index < state.comments.length; index++)
                  MomentContentPadding(
                    top: index == 0 ? context.wenyouTokens.space12 : 0,
                    child: Column(
                      children: [
                        if (index > 0)
                          Divider(height: context.wenyouTokens.space24),
                        _MomentRootCommentPanel(
                          root: state.comments[index],
                          replyPage: state.replyPages[state.comments[index].id],
                          busyCommentIds: state.busyCommentIds,
                          viewerId: viewerId,
                          returnTo: '/moments/${widget.momentId}',
                          onReply: (comment) => _authenticated(
                            () => _openCommentComposer(comment),
                          ),
                          onDelete: (comment) =>
                              _deleteComment(context, provider, comment),
                          onLoadReplies: () => ref
                              .read(provider.notifier)
                              .loadReplies(state.comments[index].id),
                        ),
                      ],
                    ),
                  ),
              if (state.hasMoreComments || state.isLoadingMoreComments)
                MomentContentPadding(
                  top: context.wenyouTokens.space12,
                  child: Center(
                    child: state.isLoadingMoreComments
                        ? const CircularProgressIndicator()
                        : OutlinedButton.icon(
                            key: const Key('moment-comments-load-more'),
                            onPressed: () =>
                                ref.read(provider.notifier).loadMoreComments(),
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('加载更多评论'),
                          ),
                  ),
                ),
            ],
          ),
        ),
      },
      floatingActionButton: state.phase == MomentLoadPhase.ready
          ? WenyouComposerAction(
              key: const Key('moment-comment-dock'),
              label: session.isAuthenticated ? '发表评论…' : '登录后发表评论',
              icon: session.isAuthenticated
                  ? Icons.chat_bubble_outline_rounded
                  : Icons.login_rounded,
              onPressed: () => _authenticated(() => _openCommentComposer()),
            )
          : null,
    );
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
    var currentReplyTo = replyTo;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Consumer(
          builder: (context, sheetRef, _) {
            final state = sheetRef.watch(provider);
            final tokens = context.wenyouTokens;
            final horizontal = MediaQuery.sizeOf(context).width <= 400
                ? tokens.space12
                : tokens.space24;
            return AnimatedPadding(
              duration: tokens.feedbackDuration,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  tokens.space12,
                  horizontal,
                  tokens.space16,
                ),
                child: WenyouConstrainedWidth(
                  child: _MomentCommentComposer(
                    replyTo: currentReplyTo,
                    isSending: state.isSendingComment,
                    onCancelReply: () =>
                        setSheetState(() => currentReplyTo = null),
                    onClose: () => Navigator.of(sheetContext).pop(),
                    onSend: (input) async {
                      final created = await sheetRef
                          .read(provider.notifier)
                          .sendComment(input);
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
}

class _MomentDetailPanel extends StatelessWidget {
  const _MomentDetailPanel({
    required this.detail,
    required this.busy,
    required this.onLike,
    required this.onBookmark,
  });

  final MomentDetail detail;
  final bool busy;
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
                style: Theme.of(context).textTheme.headlineSmall,
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
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${card.likeCount} 点赞',
                selected: card.viewerLiked,
                onPressed: busy ? null : onLike,
              ),
            ),
            Expanded(
              child: _DetailAction(
                key: const Key('moment-detail-bookmark'),
                icon: card.viewerBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: '${card.bookmarkCount} 收藏',
                selected: card.viewerBookmarked,
                onPressed: busy ? null : onBookmark,
              ),
            ),
            Expanded(
              child: _DetailAction(
                icon: Icons.chat_bubble_outline_rounded,
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
    this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
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
            icon: Icons.swap_vert_rounded,
            label: state.commentOrder == MomentCommentOrder.newest
                ? '最新在前'
                : '最早在前',
          ),
        ),
        const Spacer(),
        TextButton.icon(
          key: const Key('moment-comment-author-filter'),
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

  final IconData icon;
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
            Icon(icon, size: 20),
            SizedBox(width: tokens.space4),
            Text(label),
            const Icon(Icons.arrow_drop_down_rounded, size: 20),
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
    required this.onLoadReplies,
  });

  final MomentRootComment root;
  final MomentReplyPageState? replyPage;
  final Set<String> busyCommentIds;
  final String? viewerId;
  final String returnTo;
  final ValueChanged<MomentComment> onReply;
  final ValueChanged<MomentComment> onDelete;
  final VoidCallback onLoadReplies;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final replies = replyPage?.items ?? root.replies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MomentCommentBody(
          comment: root,
          busy: busyCommentIds.contains(root.id),
          onReply: () => onReply(root),
          onDelete: root.canDelete ? () => onDelete(root) : null,
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
                children: [
                  for (var index = 0; index < replies.length; index++) ...[
                    _MomentCommentBody(
                      comment: replies[index],
                      compact: true,
                      busy: busyCommentIds.contains(replies[index].id),
                      onReply: () => onReply(replies[index]),
                      onDelete: replies[index].canDelete
                          ? () => onDelete(replies[index])
                          : null,
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
                  : const Icon(Icons.subdirectory_arrow_right_rounded),
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

class _MomentCommentBody extends StatelessWidget {
  const _MomentCommentBody({
    required this.comment,
    required this.busy,
    required this.onReply,
    this.onDelete,
    this.reportReturnTo,
    this.compact = false,
  });

  final MomentComment comment;
  final bool busy;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final String? reportReturnTo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MomentAuthorLine(
          author: comment.author,
          createdAt: comment.createdAt,
          onTap: () => context.pushNamed(
            'user-profile',
            pathParameters: {'userId': comment.author.id},
          ),
        ),
        SizedBox(height: tokens.space8),
        if (comment.deleted)
          Text(
            '该评论已删除',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.mutedText),
          )
        else ...[
          if (comment.replyToComment != null)
            Text(
              '回复 @${comment.replyToComment!.author.username}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.focus),
            ),
          if (comment.content != null)
            WenyouInternalReferenceText(
              content: comment.content!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (comment.media != null) ...[
            SizedBox(height: tokens.space8),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => openMomentGallery(context, [comment.media!], 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: compact ? 180 : 240,
                    maxHeight: compact ? 180 : 240,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: comment.media!.bestContentUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const CircularProgressIndicator(),
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ],
          if (comment.sticker != null) ...[
            SizedBox(height: tokens.space8),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 160,
                  maxHeight: 160,
                ),
                child: CachedNetworkImage(
                  imageUrl: comment.sticker!.mediumUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
        SizedBox(height: tokens.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: comment.deleted ? null : onReply,
              child: const Text('回复'),
            ),
            if (!comment.deleted && reportReturnTo != null)
              WenyouReportButton(
                key: Key('moment-comment-report-${comment.id}'),
                target: ReportTarget.momentComment(comment.id),
                targetLabel: '这条评论',
                returnTo: reportReturnTo!,
              ),
            if (onDelete != null)
              TextButton(
                onPressed: busy ? null : onDelete,
                child: const Text('删除'),
              ),
          ],
        ),
      ],
    );
  }
}

class _MomentCommentComposer extends ConsumerStatefulWidget {
  const _MomentCommentComposer({
    required this.replyTo,
    required this.isSending,
    required this.onCancelReply,
    required this.onClose,
    required this.onSend,
  });

  final MomentComment? replyTo;
  final bool isSending;
  final VoidCallback onCancelReply;
  final VoidCallback onClose;
  final Future<bool> Function(MomentCommentInput input) onSend;

  @override
  ConsumerState<_MomentCommentComposer> createState() =>
      _MomentCommentComposerState();
}

class _MomentCommentComposerState
    extends ConsumerState<_MomentCommentComposer> {
  final _textController = TextEditingController();
  UploadedEditorImage? _image;
  UserSticker? _sticker;
  MediaUploadProgress? _progress;
  CancelToken? _cancelToken;
  var _closing = false;

  @override
  void dispose() {
    _cancelToken?.cancel('comment composer disposed');
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final uploading = _progress != null;
    return PopScope<Object?>(
      canPop: _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.replyTo == null ? '发表评论' : '回复评论',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                key: const Key('moment-comment-close'),
                onPressed: uploading || widget.isSending ? null : _requestClose,
                tooltip: '关闭评论编辑器',
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (widget.replyTo != null) ...[
            SizedBox(height: tokens.space8),
            InputChip(
              label: Text('回复 @${widget.replyTo!.author.username}'),
              onDeleted: widget.onCancelReply,
            ),
          ],
          SizedBox(height: tokens.space12),
          TextField(
            key: const Key('moment-comment-input'),
            controller: _textController,
            minLines: 2,
            maxLines: 6,
            maxLength: 500,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '评论内容',
              hintText: '写下你的想法，也可以只发送图片或表情',
              alignLabelWithHint: true,
            ),
          ),
          if (_image != null || _sticker != null) ...[
            SizedBox(height: tokens.space8),
            _SelectedCommentAsset(
              image: _image,
              sticker: _sticker,
              onRemove: () => setState(() {
                _image = null;
                _sticker = null;
              }),
            ),
          ],
          if (_progress != null) ...[
            SizedBox(height: tokens.space8),
            LinearProgressIndicator(value: _progress!.fraction),
            SizedBox(height: tokens.space4),
            Text(_progressLabel(_progress!)),
          ],
          SizedBox(height: tokens.space8),
          Row(
            children: [
              IconButton(
                key: const Key('moment-comment-image'),
                onPressed: uploading || widget.isSending ? null : _pickImage,
                tooltip: '添加一张图片',
                icon: const Icon(Icons.image_outlined),
              ),
              IconButton(
                key: const Key('moment-comment-sticker'),
                onPressed: uploading || widget.isSending ? null : _pickSticker,
                tooltip: '添加一个表情',
                icon: const Icon(Icons.add_reaction_outlined),
              ),
              const Spacer(),
              FilledButton.icon(
                key: const Key('moment-comment-send'),
                onPressed: uploading || widget.isSending ? null : _send,
                icon: widget.isSending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text('发送'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _requestClose() async {
    if (_closing || widget.isSending || _progress != null) return;
    var confirmed = true;
    final hasDraft =
        _textController.text.trim().isNotEmpty ||
        _image != null ||
        _sticker != null;
    if (hasDraft) {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('放弃这条评论？'),
              content: const Text('尚未发送的文字、图片或表情会丢失。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('继续编辑'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('放弃评论'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!confirmed || !mounted) return;
    setState(() => _closing = true);
    widget.onClose();
  }

  Future<void> _pickImage() async {
    try {
      final input = await ref.read(editorImagePickerProvider).pickFromGallery();
      if (input == null || !mounted) return;
      final cancelToken = CancelToken();
      _cancelToken = cancelToken;
      setState(() {
        _sticker = null;
        _progress = const MediaUploadProgress(
          stage: MediaUploadStage.preparing,
        );
      });
      final image = await ref
          .read(mediaUploadRepositoryProvider)
          .uploadImage(
            input,
            cancelToken: cancelToken,
            onProgress: (progress) {
              if (mounted) setState(() => _progress = progress);
            },
          );
      if (!mounted) return;
      setState(() {
        _image = image;
        _progress = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _progress = null);
      final message = error is ApiFailure
          ? error.userMessage
          : '评论图片没有上传成功，请重试。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      _cancelToken = null;
    }
  }

  Future<void> _pickSticker() async {
    final sticker = await showStickerPicker(context);
    if (sticker == null || !mounted) return;
    setState(() {
      _image = null;
      _sticker = sticker;
    });
  }

  Future<void> _send() async {
    final sent = await widget.onSend(
      MomentCommentInput(
        content: _textController.text,
        mediaId: _image?.mediaId,
        stickerAssetId: _sticker?.asset.id,
        replyToCommentId: widget.replyTo?.id,
      ),
    );
    if (!sent || !mounted) return;
    _textController.clear();
    setState(() {
      _image = null;
      _sticker = null;
      _closing = true;
    });
    widget.onClose();
  }

  String _progressLabel(MediaUploadProgress progress) {
    return switch (progress.stage) {
      MediaUploadStage.preparing => '正在准备图片…',
      MediaUploadStage.uploading when progress.fraction != null =>
        '正在上传 ${(progress.fraction! * 100).round()}%',
      MediaUploadStage.uploading => '正在上传图片…',
      MediaUploadStage.confirming => '正在确认图片…',
      MediaUploadStage.processing => '图片正在安全处理中…',
    };
  }
}

class _SelectedCommentAsset extends StatelessWidget {
  const _SelectedCommentAsset({
    required this.image,
    required this.sticker,
    required this.onRemove,
  });

  final UploadedEditorImage? image;
  final UserSticker? sticker;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final url = image?.url ?? sticker!.asset.thumbnailUrl;
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          SizedBox.square(
            dimension: 112,
            child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton.filledTonal(
              onPressed: onRemove,
              tooltip: '移除附件',
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
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
              ? Icons.auto_awesome_outlined
              : Icons.cloud_off_outlined,
          title: notFound ? '动态不存在' : '动态详情没有加载完成',
          message: notFound
              ? '这条动态可能已被删除或不可见。'
              : (failure?.userMessage ?? '请稍后重试。'),
          detail: failure?.requestId == null
              ? null
              : '请求 ID：${failure!.requestId}',
          action: notFound
              ? null
              : OutlinedButton.icon(
                  key: const Key('moment-detail-retry'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新加载'),
                ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/data/editor_image_picker.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/moments/application/moment_controllers.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';
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
  MomentComment? _replyTo;

  @override
  Widget build(BuildContext context) {
    final provider = momentDetailControllerProvider(widget.momentId);
    final state = ref.watch(provider);
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
            padding: EdgeInsets.only(bottom: context.wenyouTokens.space32),
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
                  child: const WenyouPanel(
                    child: WenyouEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: '还没有评论',
                      message: '可以留下第一条评论。',
                    ),
                  ),
                )
              else
                for (final root in state.comments)
                  MomentContentPadding(
                    top: context.wenyouTokens.space12,
                    child: _MomentRootCommentPanel(
                      root: root,
                      replyPage: state.replyPages[root.id],
                      busyCommentIds: state.busyCommentIds,
                      onReply: (comment) => _authenticated(
                        () => setState(() => _replyTo = comment),
                      ),
                      onDelete: (comment) =>
                          _deleteComment(context, provider, comment),
                      onLoadReplies: () =>
                          ref.read(provider.notifier).loadReplies(root.id),
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
              MomentContentPadding(
                top: context.wenyouTokens.space12,
                child: ref.watch(sessionControllerProvider).isAuthenticated
                    ? _MomentCommentComposer(
                        replyTo: _replyTo,
                        isSending: state.isSendingComment,
                        onCancelReply: () => setState(() => _replyTo = null),
                        onSend: (input) async {
                          final created = await ref
                              .read(provider.notifier)
                              .sendComment(input);
                          if (created != null && mounted) {
                            setState(() => _replyTo = null);
                            return true;
                          }
                          return false;
                        },
                      )
                    : WenyouPanel(
                        child: WenyouEmptyState(
                          icon: Icons.login_rounded,
                          title: '登录后参与评论',
                          message: '登录后可以回复、点赞与收藏动态。',
                          action: FilledButton.icon(
                            key: const Key('moment-detail-login'),
                            onPressed: _openLogin,
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('去登录'),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      },
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
      Uri(
        path: '/auth/login',
        queryParameters: {'returnTo': '/moments/${widget.momentId}'},
      ).toString(),
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
    return WenyouPanel(
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
          Text(card.title, style: Theme.of(context).textTheme.headlineSmall),
          if (detail.content.isNotEmpty) ...[
            SizedBox(height: tokens.space12),
            SelectableText(
              detail.content,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ],
          if (detail.images.isNotEmpty) ...[
            SizedBox(height: tokens.space16),
            MomentGallery(images: detail.images),
          ],
          SizedBox(height: tokens.space16),
          const Divider(),
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
      ),
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
    return WenyouPanel(
      padding: EdgeInsets.all(tokens.space12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: tokens.space12,
        runSpacing: tokens.space8,
        children: [
          SegmentedButton<MomentCommentOrder>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: MomentCommentOrder.newest,
                label: Text('最新'),
              ),
              ButtonSegment(
                value: MomentCommentOrder.oldest,
                label: Text('最早'),
              ),
            ],
            selected: {state.commentOrder},
            onSelectionChanged: (selection) => onOrder(selection.single),
          ),
          DropdownButton<String?>(
            key: const Key('moment-comment-author-filter'),
            value: state.commentAuthorId,
            hint: const Text('全部作者'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('全部作者')),
              ...state.commentAuthors.map(
                (author) => DropdownMenuItem<String?>(
                  value: author.id,
                  child: Text(author.username),
                ),
              ),
            ],
            onChanged: onAuthor,
          ),
        ],
      ),
    );
  }
}

class _MomentRootCommentPanel extends StatelessWidget {
  const _MomentRootCommentPanel({
    required this.root,
    required this.replyPage,
    required this.busyCommentIds,
    required this.onReply,
    required this.onDelete,
    required this.onLoadReplies,
  });

  final MomentRootComment root;
  final MomentReplyPageState? replyPage;
  final Set<String> busyCommentIds;
  final ValueChanged<MomentComment> onReply;
  final ValueChanged<MomentComment> onDelete;
  final VoidCallback onLoadReplies;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final replies = replyPage?.items ?? root.replies;
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MomentCommentBody(
            comment: root,
            busy: busyCommentIds.contains(root.id),
            onReply: () => onReply(root),
            onDelete: root.canDelete ? () => onDelete(root) : null,
          ),
          if (replies.isNotEmpty) ...[
            SizedBox(height: tokens.space12),
            Container(
              padding: EdgeInsets.all(tokens.space12),
              decoration: BoxDecoration(
                color: tokens.softPanel,
                borderRadius: BorderRadius.circular(tokens.radius12),
              ),
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
                    ),
                    if (index + 1 < replies.length) const Divider(),
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
      ),
    );
  }
}

class _MomentCommentBody extends StatelessWidget {
  const _MomentCommentBody({
    required this.comment,
    required this.busy,
    required this.onReply,
    this.onDelete,
    this.compact = false,
  });

  final MomentComment comment;
  final bool busy;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
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
            Text(
              comment.content!,
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
    required this.onSend,
  });

  final MomentComment? replyTo;
  final bool isSending;
  final VoidCallback onCancelReply;
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
    return WenyouPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('发表评论', style: Theme.of(context).textTheme.titleMedium),
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
    });
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

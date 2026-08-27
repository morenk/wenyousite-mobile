import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_clipboard_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_cached_image.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_content_action_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_reply_card.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/moments/presentation/moment_widgets.dart';

class MomentCommentBody extends StatelessWidget {
  const MomentCommentBody({
    required this.comment,
    required this.busy,
    this.onReply,
    this.onDelete,
    this.onReport,
    this.reportReturnTo,
    this.compact = false,
    super.key,
  });

  final MomentComment comment;
  final bool busy;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final Future<void> Function()? onReport;
  final String? reportReturnTo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final canReply = !comment.deleted && onReply != null && !busy;
    Widget buildContent(VoidCallback openActions) => Column(
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
              selectable: true,
              onTapText: canReply ? onReply : null,
              onLongPressNonText: openActions,
            ),
          if (comment.media != null) ...[
            SizedBox(height: tokens.space8),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => openMomentGallery(context, [comment.media!], 0),
                onLongPress: openActions,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: compact ? 180 : 240,
                    maxHeight: compact ? 180 : 240,
                  ),
                  child: WenyouCachedImage(
                    imageUrl: comment.media!.bestContentUrl,
                    fallbackImageUrls: comment.media!.contentUrls
                        .skip(1)
                        .toList(growable: false),
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const CircularProgressIndicator(),
                    errorWidget: (_, _, _) =>
                        const WenyouIcon(WenyouIconIds.statusImageUnavailable),
                  ),
                ),
              ),
            ),
          ],
          if (comment.sticker != null) ...[
            SizedBox(height: tokens.space8),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: openActions,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 160,
                    maxHeight: 160,
                  ),
                  child: WenyouCachedImage(
                    imageUrl: comment.sticker!.mediumUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );

    Widget buildCommentCard(VoidCallback openActions) {
      final content = buildContent(openActions);
      if (compact) {
        return WenyouDiscussionReplyCard(
          key: Key('moment-comment-card-${comment.id}'),
          semanticsLabel: '${comment.author.username} 的楼中楼回复',
          enabled: canReply,
          onTap: canReply ? onReply : null,
          onLongPress: openActions,
          tapHint: '点击回复，长按文字选择，长按其他区域打开回复操作',
          child: content,
        );
      }

      return Semantics(
        key: Key('moment-comment-card-${comment.id}'),
        container: true,
        button: canReply,
        label: '${comment.author.username} 的评论',
        hint: canReply ? '点击回复这条评论，长按文字选择，长按其他区域打开评论操作' : '长按文字选择，长按其他区域打开评论操作',
        onTap: canReply ? onReply : null,
        onLongPress: openActions,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: canReply ? onReply : null,
          onLongPress: openActions,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space12,
            ),
            child: content,
          ),
        ),
      );
    }

    return PostCardActionMenu(
      canCopyText: !comment.deleted && comment.content?.isNotEmpty == true,
      canCopyLink: false,
      canEdit: false,
      canDelete: !comment.deleted && onDelete != null,
      canReport: !comment.deleted && reportReturnTo != null,
      pending: busy,
      semanticLabel: compact ? '回复操作' : '评论操作',
      actionKeyPrefix: 'moment-comment-action-${comment.id}',
      onSelected: (action) => _handleAction(action, context),
      anchorBuilder: (context, handle) => buildCommentCard(handle.open),
    );
  }

  Future<void> _handleAction(
    PostCardAction action,
    BuildContext context,
  ) async {
    switch (action) {
      case PostCardAction.copyText:
        await copyPostCardValue(
          context,
          MarkdownClipboardText.project(comment.content!),
          '内容已复制',
        );
      case PostCardAction.copyLink:
        return;
      case PostCardAction.edit:
        return;
      case PostCardAction.delete:
        onDelete?.call();
      case PostCardAction.report:
        await onReport?.call();
    }
  }
}

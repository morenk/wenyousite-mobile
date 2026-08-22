import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_controls.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';

class PostReplyFilters extends StatelessWidget {
  const PostReplyFilters({
    required this.state,
    required this.replyCount,
    required this.authors,
    required this.onApply,
    this.authorsLoading = false,
    this.authorsFailure,
    this.onRetryAuthors,
    super.key,
  });

  final PostDiscussionState state;
  final int replyCount;
  final List<PostDiscussionAuthor> authors;
  final void Function(PostReplyOrder order, String? authorId) onApply;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;

  @override
  Widget build(BuildContext context) {
    return WenyouDiscussionControls<PostReplyOrder>(
      countLabel: '$replyCount 条回复',
      countKey: const Key('post-replies-count'),
      settingsKey: const Key('post-replies-settings'),
      sheetKey: const Key('post-replies-settings-sheet'),
      order: state.order,
      defaultOrder: PostReplyOrder.oldest,
      orderOptions: [
        for (final value in PostReplyOrder.values)
          WenyouDiscussionOrderOption(
            value: value,
            label: value.label,
            summaryLabel: value == PostReplyOrder.oldest ? '最早在前' : '最新在前',
          ),
      ],
      authorId: state.authorId,
      authors: [
        for (final author in authors)
          WenyouDiscussionAuthorOption(
            id: author.userId,
            label: author.username,
            supportingLabel: author.role.label,
          ),
      ],
      authorsLoading: authorsLoading,
      authorsFailure: authorsFailure,
      onRetryAuthors: onRetryAuthors,
      orderSectionLabel: '回复顺序',
      authorSectionLabel: '只看回复者',
      allAuthorsLabel: '全部回复者',
      onApply: (selection) => onApply(selection.order, selection.authorId),
    );
  }
}

class PostDiscussionTitle extends StatelessWidget {
  const PostDiscussionTitle({required this.root, super.key});

  final PostItem root;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final floorLabel = root.floorNumber == null
        ? null
        : '#${root.floorNumber}楼';
    final contextLabel = [
      root.subthreadTitle ?? '楼中楼讨论',
      ?floorLabel,
    ].join(' · ');
    return Column(
      key: const Key('post-replies-reading-title'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          root.threadTitle ?? '楼中楼讨论',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          contextLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
      ],
    );
  }
}

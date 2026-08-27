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
    required this.onOrderChanged,
    required this.onAuthorChanged,
    this.authorsLoading = false,
    this.authorsFailure,
    this.onRetryAuthors,
    super.key,
  });

  final PostDiscussionState state;
  final int replyCount;
  final List<PostDiscussionAuthor> authors;
  final ValueChanged<PostReplyOrder> onOrderChanged;
  final ValueChanged<String?> onAuthorChanged;
  final bool authorsLoading;
  final ApiFailure? authorsFailure;
  final VoidCallback? onRetryAuthors;

  @override
  Widget build(BuildContext context) {
    return WenyouDiscussionListControls<PostReplyOrder>(
      countLabel: '$replyCount 条回复',
      countKey: const Key('post-replies-count'),
      authorKey: const Key('post-replies-author'),
      orderKey: const Key('post-replies-order'),
      order: state.order,
      orderOptions: [
        for (final value in PostReplyOrder.values)
          WenyouDiscussionOrderOption(
            value: value,
            label: value.label,
            summaryLabel: value == PostReplyOrder.oldest ? '正序' : '倒序',
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
      onOrderChanged: onOrderChanged,
      onAuthorChanged: onAuthorChanged,
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

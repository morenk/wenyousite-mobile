import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_discussion_controls.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_detail_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadFloorFilters extends StatelessWidget {
  const ThreadFloorFilters({
    required this.state,
    required this.floorCount,
    required this.authors,
    required this.onOrderChanged,
    required this.onAuthorChanged,
    required this.onRetryAuthors,
    super.key,
  });

  final ThreadDetailState state;
  final int floorCount;
  final AsyncValue<List<PostDiscussionAuthor>> authors;
  final ValueChanged<ThreadFloorOrder> onOrderChanged;
  final ValueChanged<String?> onAuthorChanged;
  final VoidCallback onRetryAuthors;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return DecoratedBox(
      key: const Key('thread-floor-controls'),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: WenyouContentFrame(
        top: tokens.space4,
        bottom: tokens.space4,
        child: WenyouDiscussionListControls<ThreadFloorOrder>(
          countLabel: '$floorCount 层',
          countKey: const Key('thread-floors-count'),
          authorKey: const Key('thread-floors-author'),
          orderKey: const Key('thread-floors-order'),
          order: state.floorOrder,
          orderOptions: [
            for (final value in ThreadFloorOrder.values)
              WenyouDiscussionOrderOption(value: value, label: value.label),
          ],
          authorId: state.floorAuthorId,
          authors: [
            for (final author in authors.valueOrNull ?? const [])
              WenyouDiscussionAuthorOption(
                id: author.userId,
                label: author.username,
                supportingLabel: author.role.label,
              ),
          ],
          enabled: !state.isLoadingFloors && !state.isLoadingMore,
          authorsLoading: authors.isLoading,
          authorsFailure: authors.hasError
              ? mapApplicationFailure(authors.error!, '发言者列表加载失败，请重试。')
              : null,
          onRetryAuthors: onRetryAuthors,
          onOrderChanged: onOrderChanged,
          onAuthorChanged: onAuthorChanged,
        ),
      ),
    );
  }
}

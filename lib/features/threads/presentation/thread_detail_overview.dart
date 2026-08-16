import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/relative_time.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_level_badge.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_tag_link.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_subthread_navigator.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_membership_controls.dart';

class ThreadDetailOverview extends StatelessWidget {
  const ThreadDetailOverview({
    required this.detail,
    required this.categoryName,
    required this.selectedSubthreadId,
    required this.onSubthreadSelected,
    required this.onRequireAuthentication,
    required this.onPlayerExited,
    super.key,
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
    return Column(
      key: const Key('thread-detail-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                key: const Key('thread-detail-context-row'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ThreadContextLabel(label: categoryName),
                    SizedBox(width: tokens.space12),
                    _ThreadContextLabel(
                      label: detail.status.label,
                      emphasized: true,
                    ),
                    if (detail.isPinned) ...[
                      SizedBox(width: tokens.space12),
                      const _ThreadContextLabel(label: '置顶'),
                    ],
                    if (detail.isPrivate) ...[
                      SizedBox(width: tokens.space12),
                      const _ThreadContextLabel(label: '私密'),
                    ],
                    for (final tag in detail.tags) ...[
                      SizedBox(width: tokens.space12),
                      WenyouTagLink(
                        key: Key('thread-detail-tag-${tag.id}'),
                        name: tag.name,
                        onPressed: () => context.pushNamed(
                          'tag-threads',
                          pathParameters: {'tagId': tag.id},
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: tokens.space4),
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
        SizedBox(height: tokens.space12),
        Divider(height: 1, color: tokens.border),
        Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.space4),
          child: detail.subthreads.isNotEmpty && selectedSubthreadId != null
              ? ThreadSubthreadNavigator(
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
        Divider(height: 1, color: tokens.border),
      ],
    );
  }
}

class _ThreadContextLabel extends StatelessWidget {
  const _ThreadContextLabel({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: label,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: emphasized ? tokens.brandForeground : tokens.mutedText,
          fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
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
    final metrics = [
      '${detail.viewCount} 浏览',
      '${detail.playerCount} 玩家',
      '${detail.postCount} 楼',
      if (detail.tipTotal != '0') '${detail.tipTotal} 升温油',
    ].join(' · ');
    return Row(
      children: [
        Flexible(
          child: Text(
            detail.owner.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        SizedBox(width: tokens.space4),
        WenyouLevelBadge(level: detail.owner.level),
        SizedBox(width: tokens.space8),
        Text(
          formatWenyouRelativeTime(detail.updatedAt),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
        ),
        SizedBox(width: tokens.space8),
        Expanded(
          child: Text(
            metrics,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.mutedText),
          ),
        ),
      ],
    );
  }
}

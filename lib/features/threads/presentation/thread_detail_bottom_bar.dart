import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/compact_action_count.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_compact_action_content.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reply_action_bar.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

class ThreadDetailBottomBar extends StatelessWidget {
  const ThreadDetailBottomBar({
    required this.detail,
    required this.authenticated,
    required this.canCompose,
    required this.onRequireAuthentication,
    required this.onCompose,
    this.onTip,
    this.onCountsChanged,
    super.key,
  });
  final ThreadDetailModel detail;
  final bool authenticated;
  final bool canCompose;
  final VoidCallback onRequireAuthentication;
  final VoidCallback onCompose;
  final VoidCallback? onTip;
  final VoidCallback? onCountsChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return WenyouReplyActionBar(
      key: const Key('thread-detail-bottom-bar'),
      children: [
        ThreadInteractionActions(
          target: ThreadInteractionTarget(
            threadId: detail.id,
            isLiked: detail.isLiked,
            likeCount: detail.likeCount,
            isBookmarked: detail.isBookmarked,
            bookmarkId: detail.bookmarkId,
          ),
          onRequireAuthentication: onRequireAuthentication,
          compact: true,
          bookmarkCount: detail.bookmarkCount,
          onBookmarkChanged: onCountsChanged,
        ),
        ThreadSubscriptionControls(
          threadId: detail.id,
          hasAutomaticUpdates: detail.hasAutomaticUpdates,
          compact: true,
          subscriberCount: detail.subscriberCount,
          onThreadSubscriptionChanged: onCountsChanged,
        ),
        if (!detail.isCurrentUserOwner)
          WenyouCompactActionButton(
            key: const Key('thread-detail-tip'),
            label: '为创作者加油，累计 ${WenyouAmount.format(detail.tipTotal)} 升',
            onPressed: onTip,
            icon: WenyouIcon(
              WenyouIconIds.actionTip,
              size: 20,
              color: tokens.mutedText,
            ),
            supporting: Text(
              formatCompactActionCount(int.parse(detail.tipTotal)),
              style: Theme.of(context).textTheme.wenyouUtilityCaption.copyWith(
                color: tokens.mutedText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        if (canCompose) ...[
          Expanded(
            child: WenyouReplyFieldAction(
              key: const Key('thread-floor-compose'),
              fieldKey: const Key('thread-floor-compose-field'),
              authenticated: authenticated,
              onPressed: authenticated ? onCompose : onRequireAuthentication,
            ),
          ),
        ] else
          const Spacer(),
      ],
    );
  }
}

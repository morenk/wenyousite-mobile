import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadDetailBottomBar extends StatelessWidget {
  const ThreadDetailBottomBar({
    required this.detail,
    required this.authenticated,
    required this.canCompose,
    required this.onRequireAuthentication,
    required this.onCompose,
    super.key,
  });

  final ThreadDetailModel detail;
  final bool authenticated;
  final bool canCompose;
  final VoidCallback onRequireAuthentication;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final target = ThreadInteractionTarget(
      threadId: detail.id,
      isLiked: detail.isLiked,
      likeCount: detail.likeCount,
      isBookmarked: detail.isBookmarked,
      bookmarkId: detail.bookmarkId,
    );
    return Material(
      key: const Key('thread-detail-bottom-bar'),
      color: tokens.panel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.fromLTRB(
            wenyouHorizontalPagePadding(context),
            0,
            wenyouHorizontalPagePadding(context),
            0,
          ),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: tokens.wideContainerMaxWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    ThreadInteractionActions(
                      target: target,
                      onRequireAuthentication: onRequireAuthentication,
                      compact: true,
                    ),
                    ThreadSubscriptionControls(
                      threadId: detail.id,
                      hasAutomaticUpdates: detail.hasAutomaticUpdates,
                      compact: true,
                    ),
                    if (canCompose) ...[
                      SizedBox(width: tokens.space4),
                      Expanded(
                        child: _ReplyFieldAction(
                          key: const Key('thread-floor-compose'),
                          authenticated: authenticated,
                          onPressed: authenticated
                              ? onCompose
                              : onRequireAuthentication,
                        ),
                      ),
                    ] else
                      const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyFieldAction extends StatelessWidget {
  const _ReplyFieldAction({
    required this.authenticated,
    required this.onPressed,
    super.key,
  });

  final bool authenticated;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Tooltip(
      message: authenticated ? '回复一下' : '登录后回复',
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size.square(tokens.minimumTouchTarget),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.standard,
          foregroundColor: tokens.mutedText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusControl),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            key: const Key('thread-floor-compose-field'),
            decoration: BoxDecoration(
              color: tokens.softPanel,
              border: Border.all(color: tokens.border),
              borderRadius: BorderRadius.circular(tokens.radiusControl),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space8,
                vertical: tokens.space8,
              ),
              child: Text(
                '回复一下',
                semanticsLabel: authenticated ? '回复一下' : '回复一下，登录后发表',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.wenyouCompactBody.copyWith(color: tokens.mutedText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

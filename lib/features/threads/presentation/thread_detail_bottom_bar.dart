import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/social/domain/thread_interaction_models.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_interaction_actions.dart';
import 'package:wenyousite_mobile/features/social/presentation/thread_subscription_controls.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

class ThreadBodyFloorDivider extends StatelessWidget {
  const ThreadBodyFloorDivider({
    required this.order,
    required this.enabled,
    required this.onToggle,
    super.key,
  });

  final ThreadFloorOrder order;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final next = order == ThreadFloorOrder.oldest
        ? ThreadFloorOrder.newest
        : ThreadFloorOrder.oldest;
    return SizedBox(
      key: const Key('thread-body-floor-divider'),
      height: tokens.minimumTouchTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: Divider(height: 1, color: tokens.border)),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: wenyouHorizontalPagePadding(context),
              ),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: IconButton(
                  key: const Key('thread-floor-order'),
                  onPressed: enabled ? onToggle : null,
                  tooltip: '${order.label}，点击切换为${next.label}',
                  icon: const WenyouIcon(WenyouIconIds.actionSort),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            tokens.space8,
            wenyouHorizontalPagePadding(context),
            tokens.space8,
          ),
          child: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: tokens.wideContainerMaxWidth,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final iconOnlyCompose =
                      constraints.maxWidth < 336 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.3;
                  final composeLabel = authenticated ? '发表楼层' : '登录后发表';
                  final composeIcon = authenticated
                      ? WenyouIconIds.actionAddComment
                      : WenyouIconIds.actionLogin;
                  final composeAction = authenticated
                      ? onCompose
                      : onRequireAuthentication;
                  return SizedBox(
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
                          viewerUserId: detail.currentUserId,
                          hasAutomaticUpdates: detail.hasAutomaticUpdates,
                          compact: true,
                        ),
                        if (canCompose) ...[
                          SizedBox(width: tokens.space8),
                          Expanded(
                            child: iconOnlyCompose
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      key: const Key('thread-floor-compose'),
                                      tooltip: composeLabel,
                                      onPressed: composeAction,
                                      style: IconButton.styleFrom(
                                        minimumSize: Size.square(
                                          tokens.minimumTouchTarget,
                                        ),
                                        foregroundColor: tokens.text,
                                        backgroundColor:
                                            tokens.accentedBackground,
                                      ),
                                      icon: WenyouIcon(composeIcon, size: 20),
                                    ),
                                  )
                                : WenyouComposerAction(
                                    key: const Key('thread-floor-compose'),
                                    label: composeLabel,
                                    icon: composeIcon,
                                    onPressed: composeAction,
                                  ),
                          ),
                        ] else
                          const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

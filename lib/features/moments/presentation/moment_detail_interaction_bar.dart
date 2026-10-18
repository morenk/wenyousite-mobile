import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/formatters/compact_action_count.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_compact_action_content.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_interaction_toggle.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_reply_action_bar.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/wallet/domain/wallet_models.dart';

class MomentDetailInteractionBar extends StatelessWidget {
  const MomentDetailInteractionBar({
    required this.card,
    required this.pendingAction,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    this.onTip,
    this.authenticated = true,
    super.key,
  });

  final MomentCard card;
  final bool authenticated;
  final MomentInteractionAction? pendingAction;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onComment;
  final VoidCallback? onTip;

  @override
  Widget build(BuildContext context) {
    final exactTipTotal = WenyouAmount.format(card.tipTotal);
    final visibleTipTotal = formatCompactActionCount(int.parse(card.tipTotal));
    return RepaintBoundary(
      key: const Key('moment-detail-actions'),
      child: WenyouReplyActionBar(
        children: [
          _DetailAction(
            key: const Key('moment-detail-like'),
            icon: WenyouIconIds.actionLike,
            value: formatCompactActionCount(card.likeCount),
            semanticLabel:
                '${card.viewerLiked ? '取消点赞' : '点赞'}，${card.likeCount} 次点赞',
            selected: card.viewerLiked,
            kind: WenyouInteractionKind.like,
            pending: pendingAction == MomentInteractionAction.like,
            onPressed:
                pendingAction == null && (card.canInteract || card.viewerLiked)
                ? onLike
                : null,
          ),
          _DetailAction(
            key: const Key('moment-detail-bookmark'),
            icon: WenyouIconIds.actionBookmark,
            value: formatCompactActionCount(card.bookmarkCount),
            semanticLabel:
                '${card.viewerBookmarked ? '取消收藏' : '收藏'}，${card.bookmarkCount} 次收藏',
            selected: card.viewerBookmarked,
            kind: WenyouInteractionKind.bookmark,
            pending: pendingAction == MomentInteractionAction.bookmark,
            onPressed:
                pendingAction == null &&
                    (card.canInteract || card.viewerBookmarked)
                ? onBookmark
                : null,
          ),
          _DetailAction(
            key: const Key('moment-detail-tip'),
            icon: onTip == null
                ? WenyouIconIds.metricTips
                : WenyouIconIds.actionTip,
            value: visibleTipTotal,
            semanticLabel: onTip == null
                ? '累计获得 $exactTipTotal 升加油'
                : '为${card.author.username}加油，累计 $exactTipTotal 升',
            onPressed: card.canInteract ? onTip : null,
          ),
          if (card.canInteract) ...[
            SizedBox(width: context.wenyouTokens.space4),
            Expanded(
              child: WenyouReplyFieldAction(
                key: const Key('moment-comment-dock'),
                fieldKey: const Key('moment-comment-field'),
                authenticated: authenticated,
                semanticLabel:
                    '回复一下，${card.commentCount} 条评论${authenticated ? '' : '，登录后发表'}',
                onPressed: onComment,
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.value,
    required this.semanticLabel,
    this.selected = false,
    this.kind,
    this.pending = false,
    this.onPressed,
    super.key,
  });

  final String icon;
  final String value;
  final String semanticLabel;
  final bool selected;
  final WenyouInteractionKind? kind;
  final bool pending;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final valueText = Text(
      value,
      maxLines: 1,
      style: Theme.of(context).textTheme.wenyouUtilityCaption.copyWith(
        color: selected ? tokens.text : tokens.mutedText,
        fontWeight: FontWeight.w400,
      ),
    );
    if (kind case final interactionKind?) {
      final enabled = onPressed != null && !pending;
      return Semantics(
        button: true,
        enabled: enabled,
        toggled: selected,
        label: semanticLabel,
        onTap: enabled ? onPressed : null,
        excludeSemantics: true,
        child: WenyouInteractionToggle(
          kind: interactionKind,
          selected: selected,
          pending: pending,
          onPressed: onPressed,
          semanticLabel: semanticLabel,
          supporting: valueText,
          stackSupporting: true,
          padding: EdgeInsets.zero,
        ),
      );
    }
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: tokens.minimumTouchTarget,
        minHeight: tokens.minimumTouchTarget,
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: WenyouCompactActionContent(
          icon: WenyouIcon(icon, size: 20, color: tokens.mutedText),
          supporting: valueText,
        ),
      ),
    );
    if (onPressed == null) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: content,
      );
    }
    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radiusControl),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(tokens.radiusControl),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return tokens.mutedText.withValues(
                alpha: WenyouIconControlContract.pressedStateLayerOpacity,
              );
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return tokens.mutedText.withValues(
                alpha: WenyouIconControlContract.hoverStateLayerOpacity,
              );
            }
            return null;
          }),
          child: content,
        ),
      ),
    );
  }
}

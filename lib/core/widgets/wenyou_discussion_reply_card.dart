import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Shared interaction surface for inline reply previews in discussion lists.
///
/// Feature modules own the reply content and actions; this widget keeps the
/// spacing, hit area and semantics aligned without turning each reply into a
/// separate card.
class WenyouDiscussionReplyCard extends StatelessWidget {
  const WenyouDiscussionReplyCard({
    required this.semanticsLabel,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.tapHint = '点击查看完整讨论',
    super.key,
  });

  final String semanticsLabel;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final String tapHint;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final canTap = enabled && onTap != null;
    return Semantics(
      container: true,
      button: canTap,
      label: semanticsLabel,
      hint: canTap ? tapHint : (onLongPress == null ? null : '长按打开操作'),
      onTap: canTap ? onTap : null,
      onLongPress: onLongPress,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onTap : null,
          onLongPress: onLongPress,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.minimumTouchTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space8),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Groups nested replies under a single visual guide instead of carding every
/// individual reply.
class WenyouDiscussionReplyGroup extends StatelessWidget {
  const WenyouDiscussionReplyGroup({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Padding(
      padding: EdgeInsets.only(left: tokens.space12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: tokens.border, width: 2)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: tokens.space12),
          child: child,
        ),
      ),
    );
  }
}

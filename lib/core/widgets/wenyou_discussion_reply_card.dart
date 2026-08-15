import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Shared surface for inline reply previews in discussion-like lists.
///
/// Feature modules own the reply content and actions; this widget keeps the
/// spacing, hit area, semantics and soft-panel treatment aligned.
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
      child: Material(
        color: tokens.softPanel,
        borderRadius: BorderRadius.circular(tokens.radius12),
        child: InkWell(
          onTap: canTap ? onTap : null,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: Padding(padding: EdgeInsets.all(tokens.space12), child: child),
        ),
      ),
    );
  }
}

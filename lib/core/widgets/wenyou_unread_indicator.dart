import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouUnreadDot extends StatelessWidget {
  const WenyouUnreadDot({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
      ),
      child: const SizedBox.square(dimension: 8),
    );
  }
}

class WenyouUnreadCountBadge extends StatelessWidget {
  const WenyouUnreadCountBadge({required this.count, this.child, super.key})
    : assert(count >= 0, 'count must be non-negative');

  final int count;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.wenyouTokens;
    return Badge.count(
      count: count,
      maxCount: 99,
      isLabelVisible: count > 0,
      backgroundColor: theme.colorScheme.error,
      textColor: theme.colorScheme.onError,
      largeSize: WenyouElementContract.unreadCountHeight,
      padding: EdgeInsets.symmetric(horizontal: tokens.space4),
      textStyle: theme.textTheme.labelSmall?.copyWith(
        fontSize: WenyouElementContract.unreadCountFontSize,
        height: 1,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: child,
    );
  }
}

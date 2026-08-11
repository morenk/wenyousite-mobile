import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

class WenyouLevelBadge extends StatelessWidget {
  const WenyouLevelBadge({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      label: '用户等级 $level',
      child: Container(
        constraints: const BoxConstraints(minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.accentedBackground.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Lv.$level',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: tokens.brand,
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

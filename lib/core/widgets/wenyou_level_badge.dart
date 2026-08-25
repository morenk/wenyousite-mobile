import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

WenyouLevelTier? wenyouLevelTier(BuildContext context, int level) {
  return Theme.of(context).brightness == Brightness.dark
      ? WenyouDarkLevelContract.resolve(level)
      : WenyouLevelContract.resolve(level);
}

class WenyouLevelBadge extends StatelessWidget {
  const WenyouLevelBadge({required this.level, super.key});

  final int level;

  @override
  Widget build(BuildContext context) {
    final tier = wenyouLevelTier(context, level);
    if (tier == null) return const SizedBox.shrink();
    return Semantics(
      label: '用户等级 $level',
      child: Container(
        constraints: const BoxConstraints(minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: tier.surface,
          border: Border.all(color: tier.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Align(
          widthFactor: 1,
          alignment: Alignment.center,
          child: Text(
            'Lv.$level',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tier.foreground,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

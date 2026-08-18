import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// 阅读态与编辑态共用的骰子原子节点。
class WenyouDiceNode extends StatelessWidget {
  const WenyouDiceNode({
    required this.label,
    required this.semanticLabel,
    required this.settled,
    required this.style,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final bool settled;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style.copyWith(
      color: settled
          ? WenyouFoundationPalette.onAccent
          : WenyouFoundationPalette.warning,
      fontFamily: WenyouFoundationTypography.utility,
      fontFamilyFallback: WenyouFoundationTypography.chineseFallback,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final fontSize =
        effectiveStyle.fontSize ??
        DefaultTextStyle.of(context).style.fontSize ??
        14;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: settled
              ? WenyouFoundationPalette.accent
              : WenyouFoundationPalette.warningSoft,
          borderRadius: BorderRadius.circular(fontSize * 0.3),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: fontSize * 0.3,
            vertical: fontSize * 0.08,
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: effectiveStyle,
            strutStyle: StrutStyle.fromTextStyle(
              effectiveStyle,
              forceStrutHeight: true,
            ),
          ),
        ),
      ),
    );
  }
}

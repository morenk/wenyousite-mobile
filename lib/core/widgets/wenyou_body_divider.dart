import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// The author-controlled thematic break used inside rich body content.
class WenyouBodyDivider extends StatelessWidget {
  const WenyouBodyDivider({
    this.fontSize = 17,
    this.includeSemantics = true,
    super.key,
  });

  final double fontSize;
  final bool includeSemantics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final divider = Padding(
      padding: EdgeInsets.symmetric(
        vertical: fontSize * WenyouElementContract.dividerOuterSpacingEm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.hasBoundedWidth
              ? constraints.maxWidth *
                    WenyouElementContract.dividerInlineSizeFraction
              : fontSize * WenyouElementContract.dividerInlineSizeEm;
          return Align(
            child: SizedBox(
              key: const Key('wenyou-body-divider'),
              width: width,
              height: WenyouElementContract.dividerMarkerDiameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    key: const Key('wenyou-body-divider-line'),
                    width: double.infinity,
                    height: WenyouElementContract.dividerLineThickness,
                    child: ColoredBox(color: tokens.border),
                  ),
                  SizedBox.square(
                    key: const Key('wenyou-body-divider-marker'),
                    dimension: WenyouElementContract.dividerMarkerDiameter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.brandForeground,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return includeSemantics ? Semantics(label: '分隔线', child: divider) : divider;
  }
}

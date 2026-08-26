import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum WenyouContentItemDividerVariant { line, sectionBand }

/// Separates sibling discussion items without looking like authored Markdown.
class WenyouContentItemDivider extends StatelessWidget {
  const WenyouContentItemDivider({
    this.variant = WenyouContentItemDividerVariant.line,
    super.key,
  });

  final WenyouContentItemDividerVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return switch (variant) {
      WenyouContentItemDividerVariant.line => Divider(
        height: tokens.space24,
        thickness: 1,
        color: tokens.input,
      ),
      WenyouContentItemDividerVariant.sectionBand => SizedBox(
        height: tokens.space8,
        child: ColoredBox(color: tokens.softPanel),
      ),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Separates sibling discussion items without looking like authored Markdown.
class WenyouContentItemDivider extends StatelessWidget {
  const WenyouContentItemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Divider(
      height: tokens.space24,
      thickness: 1,
      color: WenyouFoundationPalette.input,
    );
  }
}

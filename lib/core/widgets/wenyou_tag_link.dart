import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// A lightweight topic-tag link for reading surfaces.
///
/// Editing surfaces should keep using [InputChip] so destructive affordances
/// remain explicit. In feeds and details a tag is navigation metadata, not a
/// separate card, so only the `#name` label is visible.
class WenyouTagLink extends StatelessWidget {
  const WenyouTagLink({required this.name, required this.onPressed, super.key});

  final String name;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: onPressed == null ? tokens.mutedText : tokens.brand,
      fontWeight: FontWeight.w600,
    );
    final label = '#$name';

    if (onPressed == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.minimumTouchTarget,
            minHeight: tokens.minimumTouchTarget,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space4),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(label, style: textStyle),
            ),
          ),
        ),
      );
    }

    return Semantics(
      link: true,
      label: '查看 $label 标签下的主题',
      excludeSemantics: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: tokens.brand,
          minimumSize: Size(
            tokens.minimumTouchTarget,
            tokens.minimumTouchTarget,
          ),
          padding: EdgeInsets.symmetric(horizontal: tokens.space4),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          textStyle: textStyle,
        ),
        child: Text(label),
      ),
    );
  }
}

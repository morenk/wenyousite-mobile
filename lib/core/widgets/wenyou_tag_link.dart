import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Foundation `elements.metadata.topicTag` for reading surfaces.
class WenyouTagLink extends StatelessWidget {
  const WenyouTagLink({required this.name, required this.onPressed, super.key});

  final String name;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: tokens.mutedText,
      fontWeight: FontWeight.w500,
    );
    final label = '#$name';

    if (onPressed == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space8,
              vertical: tokens.space4,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ),
      );
    }

    return Semantics(
      link: true,
      label: '查看 $label 标签下的主题',
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.mutedText,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: tokens.border),
          minimumSize: Size(
            tokens.minimumTouchTarget,
            tokens.minimumTouchTarget,
          ),
          padding: EdgeInsets.symmetric(horizontal: tokens.space8),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius12),
          ),
          textStyle: textStyle,
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

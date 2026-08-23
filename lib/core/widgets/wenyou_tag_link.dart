import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

// Mirrors the Web topic-tag profile while the surrounding Material tap target
// continues to use Foundation's 48dp mobile minimum.
const _topicTagVisualMinimumHeight = 32.0;
const _topicTagHorizontalPadding = 10.0;

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
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: _topicTagVisualMinimumHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _topicTagHorizontalPadding,
              ),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
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
          minimumSize: const Size(0, _topicTagVisualMinimumHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: _topicTagHorizontalPadding,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
          textStyle: textStyle,
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

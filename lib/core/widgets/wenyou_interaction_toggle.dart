import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum WenyouInteractionKind { like, bookmark }

class WenyouInteractionToggle extends StatelessWidget {
  const WenyouInteractionToggle({
    required this.kind,
    required this.selected,
    required this.semanticLabel,
    this.pending = false,
    this.onPressed,
    this.supporting,
    this.iconSize = 20,
    this.padding,
    this.expand = false,
    this.interactive = true,
    super.key,
  });

  final WenyouInteractionKind kind;
  final bool selected;
  final bool pending;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Widget? supporting;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final bool expand;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final visualSelected = interactive && selected;
    final foreground = visualSelected
        ? kind == WenyouInteractionKind.like
              ? tokens.like
              : tokens.bookmark
        : tokens.mutedText;
    final enabled = interactive && onPressed != null && !pending;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            WenyouInteractionIcon(
              kind: kind,
              selected: visualSelected,
              size: iconSize,
              color: foreground,
            ),
            if (pending)
              Positioned(
                right: -4,
                top: -4,
                child: SizedBox.square(
                  dimension: 9,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: foreground,
                  ),
                ),
              ),
          ],
        ),
        if (supporting != null) ...[
          SizedBox(width: tokens.space4),
          DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.wenyouCaption.copyWith(
              color: visualSelected ? tokens.text : tokens.mutedText,
            ),
            child: supporting!,
          ),
        ],
      ],
    );
    return Semantics(
      button: interactive,
      enabled: interactive ? enabled : null,
      toggled: interactive ? selected : null,
      label: semanticLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: interactive && onPressed == null && !pending
            ? WenyouIconControlContract.disabledContentOpacity
            : 1,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.radius12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(tokens.radius12),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return foreground.withValues(
                  alpha: WenyouIconControlContract.pressedStateLayerOpacity,
                );
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return foreground.withValues(
                  alpha: WenyouIconControlContract.hoverStateLayerOpacity,
                );
              }
              return null;
            }),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: tokens.minimumTouchTarget,
                minHeight: tokens.minimumTouchTarget,
              ),
              child: Padding(
                padding:
                    padding ?? EdgeInsets.symmetric(horizontal: tokens.space8),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WenyouInteractionIcon extends StatelessWidget {
  const WenyouInteractionIcon({
    required this.kind,
    required this.selected,
    required this.color,
    this.size = 20,
    super.key,
  });

  final WenyouInteractionKind kind;
  final bool selected;
  final Color color;
  final double size;

  String get semanticId => kind == WenyouInteractionKind.like
      ? WenyouIconIds.actionLike
      : WenyouIconIds.actionBookmark;

  @override
  Widget build(BuildContext context) {
    return WenyouIcon(
      semanticId,
      size: size,
      color: color,
      variant: selected ? WenyouIconVariant.filled : WenyouIconVariant.outline,
    );
  }
}

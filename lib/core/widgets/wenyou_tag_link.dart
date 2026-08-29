import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// Lightweight topic-tag navigation for public reading surfaces.
///
/// Interactive instances retain Foundation's 48dp mobile target and explicit
/// link semantics.
class WenyouTagLink extends StatelessWidget {
  const WenyouTagLink({required this.name, required this.onPressed, super.key});

  final String name;
  final VoidCallback? onPressed;

  static double preferredWidth(
    BuildContext context,
    String name, {
    required bool interactive,
  }) {
    final tokens = context.wenyouTokens;
    final painter = TextPainter(
      text: TextSpan(
        text: '${WenyouElementContract.topicTagPrefix}$name',
        style: _textStyle(context),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final contentWidth = painter.width + tokens.space8;
    return interactive
        ? math.max(tokens.minimumTouchTarget, contentWidth)
        : contentWidth;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    final textStyle = _textStyle(context);
    final label = '${WenyouElementContract.topicTagPrefix}$name';

    if (onPressed == null) {
      return Semantics(
        label: label,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.accentedBackground,
            border: Border.all(color: tokens.brandSurface),
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
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
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: tokens.onAccentedBackground,
          backgroundColor: tokens.accentedBackground,
          minimumSize: Size(
            tokens.minimumTouchTarget,
            tokens.minimumTouchTarget,
          ),
          padding: EdgeInsets.symmetric(horizontal: tokens.space4),
          side: BorderSide(color: tokens.brandSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: textStyle,
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

TextStyle? _textStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall?.copyWith(
      color: context.wenyouTokens.onAccentedBackground,
      fontWeight: FontWeight.w600,
    );

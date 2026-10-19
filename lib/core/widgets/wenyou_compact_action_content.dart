import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

/// 底栏图标上置、数字下置；无数字时保留同高空行，对齐图标。
class WenyouCompactActionContent extends StatelessWidget {
  const WenyouCompactActionContent({
    required this.icon,
    this.supporting,
    super.key,
  });

  final Widget icon;
  final Widget? supporting;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20, child: Center(child: icon)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.wenyouTokens.space4,
          ),
          child:
              supporting ??
              ExcludeSemantics(
                child: Text(
                  ' ',
                  style: Theme.of(context).textTheme.wenyouUtilityCaption,
                ),
              ),
        ),
      ],
    );
  }
}

class WenyouCompactActionButton extends StatelessWidget {
  const WenyouCompactActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.supporting,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final Widget? supporting;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wenyouTokens;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.square(tokens.minimumTouchTarget),
            foregroundColor: tokens.mutedText,
            visualDensity: VisualDensity.standard,
          ),
          child: WenyouCompactActionContent(icon: icon, supporting: supporting),
        ),
      ),
    );
  }
}

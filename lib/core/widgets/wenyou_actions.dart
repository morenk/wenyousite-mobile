import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_async_button.dart';

/// 主操作保留按钮层级；大字号时将次要操作另起一行，避免挤压文字。
class WenyouPrimaryActionRow extends StatelessWidget {
  const WenyouPrimaryActionRow({
    required this.primary,
    this.secondary = const [],
    super.key,
  });
  final Widget primary;
  final List<Widget> secondary;

  @override
  Widget build(BuildContext context) {
    final gap = context.wenyouTokens.space8;
    if (MediaQuery.textScalerOf(context).scale(16) > 20) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (secondary.isNotEmpty) ...[
            SizedBox(height: gap),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: gap,
              children: secondary,
            ),
          ],
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: primary),
        for (final action in secondary) ...[SizedBox(width: gap), action],
      ],
    );
  }
}

class WenyouAsyncIconButton extends StatelessWidget {
  const WenyouAsyncIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.semanticLabel,
    this.tone = WenyouAsyncButtonTone.normal,
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingLabel;
  final String? semanticLabel;
  final WenyouAsyncButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final callback = isLoading ? null : onPressed;
    return Semantics(
      container: true,
      button: true,
      liveRegion: isLoading,
      label: isLoading
          ? (loadingLabel ?? '${semanticLabel ?? label}，处理中')
          : (semanticLabel ?? label),
      enabled: callback != null,
      excludeSemantics: true,
      onTap: callback,
      child: IconButton(
        style: tone == WenyouAsyncButtonTone.destructive
            ? ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? null
                      : scheme.error,
                ),
              )
            : null,
        tooltip: label,
        onPressed: callback,
        icon: isLoading
            ? ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tone == WenyouAsyncButtonTone.destructive
                        ? scheme.error
                        : scheme.primary,
                  ),
                ),
              )
            : WenyouIcon(icon),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_async_button.dart';

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

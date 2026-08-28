import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

class WenyouAsyncIconButton extends StatelessWidget {
  const WenyouAsyncIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: isLoading ? '$label，处理中' : label,
      child: IconButton(
        tooltip: label,
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? ExcludeSemantics(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                ),
              )
            : WenyouIcon(icon),
      ),
    );
  }
}

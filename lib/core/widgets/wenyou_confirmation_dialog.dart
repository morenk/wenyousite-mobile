import 'package:flutter/material.dart';

enum WenyouConfirmationTone { normal, destructive }

Future<bool> showWenyouConfirmationDialog({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  String cancelLabel = '取消',
  String? message,
  WenyouConfirmationTone tone = WenyouConfirmationTone.normal,
  Key? confirmKey,
  Key? cancelKey,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            key: cancelKey,
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            key: confirmKey,
            style: tone == WenyouConfirmationTone.destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

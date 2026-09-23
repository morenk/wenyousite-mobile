import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_async_button.dart';

enum WenyouConfirmationTone { normal, destructive }

/// 需要等待写入结果的确认复用此策略；调用方持有业务状态和关闭时机。
class WenyouPendingConfirmationDialog extends StatelessWidget {
  const WenyouPendingConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.pending = false,
    this.tone = WenyouConfirmationTone.normal,
    this.feedback,
    this.confirmKey,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;
  final bool pending;
  final WenyouConfirmationTone tone;
  final Widget? feedback;
  final Key? confirmKey;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !pending,
    child: AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (feedback != null) ...[
              SizedBox(height: context.wenyouTokens.space12),
              feedback!,
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: pending ? null : onCancel,
          child: const Text('取消'),
        ),
        WenyouAsyncButton(
          key: confirmKey,
          label: confirmLabel,
          isLoading: pending,
          tone: tone == WenyouConfirmationTone.destructive
              ? WenyouAsyncButtonTone.destructive
              : WenyouAsyncButtonTone.normal,
          onPressed: pending ? null : onConfirm,
        ),
      ],
    ),
  );
}

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

import 'package:flutter/material.dart';

enum WenyouEditConflictChoice { useLatest, keepCurrent }

/// 仅返回选择；版本读取、覆盖、草稿清理与取消均由业务页面处理。
Future<WenyouEditConflictChoice?> showWenyouEditConflictDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String useLatestLabel,
  required String keepCurrentLabel,
  Key? useLatestKey,
  Key? keepCurrentKey,
  String? continueEditingLabel,
}) => showDialog<WenyouEditConflictChoice>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      if (continueEditingLabel != null)
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(continueEditingLabel),
        ),
      TextButton(
        key: useLatestKey,
        onPressed: () =>
            Navigator.pop(dialogContext, WenyouEditConflictChoice.useLatest),
        child: Text(useLatestLabel),
      ),
      FilledButton(
        key: keepCurrentKey,
        onPressed: () =>
            Navigator.pop(dialogContext, WenyouEditConflictChoice.keepCurrent),
        child: Text(keepCurrentLabel),
      ),
    ],
  ),
);

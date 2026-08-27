import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

Future<BookmarkFolderItem?> showWenyouBookmarkFolderCreateDialog({
  required BuildContext context,
  required Future<BookmarkFolderItem?> Function(String name) onCreate,
  required ApiFailure? Function() readFailure,
}) {
  final formKey = GlobalKey<FormState>();
  var folderName = '';
  var submitting = false;
  String? submissionError;
  String? requestId;
  return showDialog<BookmarkFolderItem>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> submit() async {
          if (submitting || !(formKey.currentState?.validate() ?? false)) {
            return;
          }
          setState(() => submitting = true);
          final folder = await onCreate(folderName);
          if (!dialogContext.mounted) return;
          if (folder != null) {
            Navigator.of(dialogContext).pop(folder);
            return;
          }
          final failure = readFailure();
          setState(() {
            submitting = false;
            submissionError = failure?.userMessage ?? '新建收藏夹失败，请稍后重试。';
            requestId = failure?.requestId;
          });
        }

        return AlertDialog(
          title: const Text('新建收藏夹'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('bookmark-folder-name'),
                  autofocus: true,
                  enabled: !submitting,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: '收藏夹名称'),
                  onChanged: (value) => folderName = value,
                  onFieldSubmitted: (_) => submit(),
                  validator: (value) {
                    final normalized = value?.trim() ?? '';
                    if (normalized.isEmpty) return '请输入收藏夹名称。';
                    if (normalized.length > 24) return '名称不能超过 24 个字符。';
                    return null;
                  },
                ),
                if (submissionError != null) ...[
                  const SizedBox(height: 8),
                  Text(submissionError!),
                  if (requestId != null) Text('问题编号：$requestId'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              key: const Key('bookmark-folder-submit'),
              onPressed: submitting ? null : submit,
              child: submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('新建'),
            ),
          ],
        );
      },
    ),
  );
}

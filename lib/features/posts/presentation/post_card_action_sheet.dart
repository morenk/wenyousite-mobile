import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

enum PostCardAction { copyText, copyLink, reply, edit, delete, report }

Future<PostCardAction?> showPostCardActionSheet({
  required BuildContext context,
  required String title,
  required String authorName,
  required bool canCopyText,
  required bool canReply,
  required bool canEdit,
  required bool canDelete,
  required bool canReport,
  required bool pending,
  String replyLabel = '回复',
}) {
  return showModalBottomSheet<PostCardAction>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(title), subtitle: Text(authorName)),
            if (canCopyText)
              ListTile(
                leading: const WenyouIcon(WenyouIconIds.actionCopy),
                title: const Text('复制'),
                onTap: () => Navigator.pop(context, PostCardAction.copyText),
              ),
            ListTile(
              leading: const WenyouIcon(WenyouIconIds.editorLink),
              title: const Text('复制楼层链接'),
              onTap: () => Navigator.pop(context, PostCardAction.copyLink),
            ),
            if (canReply)
              ListTile(
                enabled: !pending,
                leading: const WenyouIcon(WenyouIconIds.actionReply),
                title: Text(replyLabel),
                onTap: pending
                    ? null
                    : () => Navigator.pop(context, PostCardAction.reply),
              ),
            if (canEdit)
              ListTile(
                enabled: !pending,
                leading: const WenyouIcon(WenyouIconIds.actionEdit),
                title: const Text('编辑'),
                onTap: pending
                    ? null
                    : () => Navigator.pop(context, PostCardAction.edit),
              ),
            if (canDelete)
              ListTile(
                enabled: !pending,
                leading: const WenyouIcon(WenyouIconIds.actionDelete),
                title: const Text('删除'),
                onTap: pending
                    ? null
                    : () => Navigator.pop(context, PostCardAction.delete),
              ),
            if (canReport)
              ListTile(
                leading: const WenyouIcon(WenyouIconIds.actionReport),
                title: const Text('举报'),
                onTap: () => Navigator.pop(context, PostCardAction.report),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> copyPostCardValue(
  BuildContext context,
  String value,
  String successMessage,
) async {
  try {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('复制失败，请稍后重试。')));
  }
}

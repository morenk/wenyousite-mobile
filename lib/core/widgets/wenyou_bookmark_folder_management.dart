import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/models/bookmark_folder_models.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum BookmarkFolderManagementAction { rename, delete }

Future<BookmarkFolderManagementAction?> showWenyouBookmarkFolderManageSheet({
  required BuildContext context,
  required BookmarkFolderItem folder,
}) {
  return showModalBottomSheet<BookmarkFolderManagementAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: context.wenyouTokens.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('管理收藏夹'),
              subtitle: Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              key: const Key('bookmark-folder-rename'),
              minTileHeight: context.wenyouTokens.minimumTouchTarget,
              leading: const WenyouIcon(WenyouIconIds.actionEdit),
              title: const Text('重命名'),
              onTap: () => Navigator.of(
                context,
              ).pop(BookmarkFolderManagementAction.rename),
            ),
            ListTile(
              key: const Key('bookmark-folder-delete'),
              minTileHeight: context.wenyouTokens.minimumTouchTarget,
              leading: WenyouIcon(
                WenyouIconIds.actionDelete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                '删除收藏夹',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => Navigator.of(
                context,
              ).pop(BookmarkFolderManagementAction.delete),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<BookmarkFolderItem?> showWenyouBookmarkFolderRenameDialog({
  required BuildContext context,
  required BookmarkFolderItem folder,
  required Future<BookmarkFolderItem?> Function(String name) onRename,
  required ApiFailure? Function() readFailure,
}) {
  return showDialog<BookmarkFolderItem>(
    context: context,
    builder: (_) => _BookmarkFolderRenameDialog(
      folder: folder,
      onRename: onRename,
      readFailure: readFailure,
    ),
  );
}

class _BookmarkFolderRenameDialog extends StatefulWidget {
  const _BookmarkFolderRenameDialog({
    required this.folder,
    required this.onRename,
    required this.readFailure,
  });

  final BookmarkFolderItem folder;
  final Future<BookmarkFolderItem?> Function(String name) onRename;
  final ApiFailure? Function() readFailure;

  @override
  State<_BookmarkFolderRenameDialog> createState() =>
      _BookmarkFolderRenameDialogState();
}

class _BookmarkFolderRenameDialogState
    extends State<_BookmarkFolderRenameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  UserFacingFailure? _failure;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.folder.name)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.folder.name.length,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _failure = null;
    });
    final renamed = await widget.onRename(_controller.text);
    if (!mounted) return;
    if (renamed != null) {
      Navigator.of(context).pop(renamed);
      return;
    }
    setState(() {
      _submitting = false;
      _failure = UserFacingFailure.fromApi(
        widget.readFailure(),
        objectName: '收藏夹',
        operationName: '重命名',
        retainContent: true,
        treatAsWrite: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('重命名收藏夹'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              key: const Key('bookmark-folder-rename-name'),
              controller: _controller,
              autofocus: true,
              enabled: !_submitting,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '收藏夹名称',
                helperText: '名称需为 1–24 个字符',
              ),
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return '请输入收藏夹名称。';
                if (name.runes.length > 24) return '名称不能超过 24 个字符。';
                return null;
              },
            ),
            if (_failure != null) ...[
              const SizedBox(height: 8),
              Text(
                _failure!.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              if (_failure!.problemDetail case final detail?) Text(detail),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('bookmark-folder-rename-submit'),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }
}

Future<BookmarkFolderDeleteResult?> showWenyouBookmarkFolderDeleteDialog({
  required BuildContext context,
  required Future<BookmarkFolderDeleteResult?> Function() onDelete,
  required ApiFailure? Function() readFailure,
}) {
  return showDialog<BookmarkFolderDeleteResult>(
    context: context,
    builder: (dialogContext) {
      var deleting = false;
      UserFacingFailure? failure;
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> submit() async {
            if (deleting) return;
            setState(() {
              deleting = true;
              failure = null;
            });
            final result = await onDelete();
            if (!dialogContext.mounted) return;
            if (result != null) {
              Navigator.of(dialogContext).pop(result);
              return;
            }
            setState(() {
              deleting = false;
              failure = UserFacingFailure.fromApi(
                readFailure(),
                objectName: '收藏夹',
                operationName: '删除',
                retainContent: true,
                treatAsWrite: true,
              );
            });
          }

          return AlertDialog(
            title: const Text('删除收藏夹'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '收藏夹内的收藏会移到默认收藏夹，收藏内容不会删除。',
                  key: Key('bookmark-folder-delete-consequence'),
                ),
                if (failure != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    failure!.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (failure!.problemDetail case final detail?) Text(detail),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: deleting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const Key('bookmark-folder-delete-confirm'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: deleting ? null : submit,
                child: deleting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('删除收藏夹'),
              ),
            ],
          );
        },
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/wenyou_text_styles.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';

enum BookmarkManageAction { move, remove }

Future<BookmarkManageAction?> showWenyouBookmarkManageSheet({
  required BuildContext context,
  required String? folderName,
  required bool canMove,
  required Key moveKey,
  required Key removeKey,
  String? moveUnavailableReason,
}) {
  return showModalBottomSheet<BookmarkManageAction>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: context.wenyouTokens.space8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: WenyouIcon(
                  WenyouIconIds.contentFolderOpen,
                  color: context.wenyouTokens.mutedText,
                ),
                title: Text(
                  '当前所在收藏夹',
                  style: Theme.of(context).textTheme.wenyouCaption.copyWith(
                    color: context.wenyouTokens.mutedText,
                  ),
                ),
                subtitle: Text(
                  folderName ?? '当前收藏夹',
                  style: Theme.of(context).textTheme.wenyouCompactBody,
                ),
              ),
              ListTile(
                key: moveKey,
                enabled: canMove,
                minTileHeight: context.wenyouTokens.minimumTouchTarget,
                leading: const WenyouIcon(WenyouIconIds.actionMove),
                title: const Text('移动到其他收藏夹'),
                subtitle: !canMove && moveUnavailableReason != null
                    ? Text(moveUnavailableReason)
                    : null,
                onTap: canMove
                    ? () => Navigator.of(context).pop(BookmarkManageAction.move)
                    : null,
              ),
              ListTile(
                key: removeKey,
                minTileHeight: context.wenyouTokens.minimumTouchTarget,
                leading: const WenyouIcon(WenyouIconIds.actionRemoveBookmark),
                title: const Text('取消收藏'),
                onTap: () =>
                    Navigator.of(context).pop(BookmarkManageAction.remove),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

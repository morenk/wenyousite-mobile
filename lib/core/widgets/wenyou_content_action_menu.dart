import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_modal_action_menu.dart';

enum PostCardAction { copyText, copyLink, reply, edit, delete, report }

void _ignorePopoverAction() {}

class PostCardActionMenu extends StatelessWidget {
  const PostCardActionMenu({
    required this.anchorBuilder,
    required this.onSelected,
    required this.canCopyText,
    required this.canReply,
    required this.canEdit,
    required this.canDelete,
    required this.canReport,
    required this.pending,
    this.canCopyLink = true,
    this.copyLinkLabel = '复制链接',
    this.replyLabel = '回复',
    this.semanticLabel = '内容操作',
    this.actionKeyPrefix,
    super.key,
  });

  final WenyouPopoverAnchorBuilder anchorBuilder;
  final ValueChanged<PostCardAction> onSelected;
  final bool canCopyText;
  final bool canReply;
  final bool canEdit;
  final bool canDelete;
  final bool canReport;
  final bool pending;
  final bool canCopyLink;
  final String copyLinkLabel;
  final String replyLabel;
  final String semanticLabel;
  final String? actionKeyPrefix;

  Key? _actionKey(String action) =>
      actionKeyPrefix == null ? null : ValueKey('$actionKeyPrefix-$action');

  @override
  Widget build(BuildContext context) {
    final actions = <WenyouPopoverAction<PostCardAction>>[
      if (canCopyText)
        WenyouPopoverAction(
          value: PostCardAction.copyText,
          icon: WenyouIconIds.actionCopy,
          label: '复制',
          semanticsLabel: '复制内容',
          key: _actionKey('copy'),
        ),
      if (canCopyLink)
        WenyouPopoverAction(
          value: PostCardAction.copyLink,
          icon: WenyouIconIds.editorLink,
          label: '链接',
          semanticsLabel: copyLinkLabel,
          key: _actionKey('link'),
        ),
      if (canReply)
        WenyouPopoverAction(
          value: PostCardAction.reply,
          icon: WenyouIconIds.actionReply,
          label: replyLabel,
          enabled: !pending,
          key: _actionKey('reply'),
        ),
      if (canEdit)
        WenyouPopoverAction(
          value: PostCardAction.edit,
          icon: WenyouIconIds.actionEdit,
          label: '编辑',
          enabled: !pending,
          key: _actionKey('edit'),
        ),
      if (canDelete)
        WenyouPopoverAction(
          value: PostCardAction.delete,
          icon: WenyouIconIds.actionDelete,
          label: '删除',
          enabled: !pending,
          tone: WenyouPopoverActionTone.destructive,
          key: _actionKey('delete'),
        ),
      if (canReport)
        WenyouPopoverAction(
          value: PostCardAction.report,
          icon: WenyouIconIds.actionReport,
          label: '举报',
          tone: WenyouPopoverActionTone.destructive,
          key: _actionKey('report'),
        ),
    ];
    if (actions.isEmpty) {
      return anchorBuilder(
        context,
        const WenyouPopoverHandle(
          isOpen: false,
          open: _ignorePopoverAction,
          close: _ignorePopoverAction,
          toggle: _ignorePopoverAction,
        ),
      );
    }
    return WenyouModalActionMenu<PostCardAction>(
      actions: actions,
      semanticLabel: semanticLabel,
      onSelected: onSelected,
      anchorBuilder: anchorBuilder,
    );
  }
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

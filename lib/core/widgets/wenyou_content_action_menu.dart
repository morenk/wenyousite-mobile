import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_anchored_popover.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_modal_action_menu.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';

enum PostCardAction { copyText, copyLink, edit, delete, report }

void _ignorePopoverAction() {}

class PostCardActionMenu extends StatelessWidget {
  const PostCardActionMenu({
    required this.anchorBuilder,
    required this.onSelected,
    required this.canCopyText,
    required this.canEdit,
    required this.canDelete,
    required this.canReport,
    required this.pending,
    this.canCopyLink = true,
    this.copyLinkLabel = '复制链接',
    this.semanticLabel = '内容操作',
    this.actionKeyPrefix,
    super.key,
  });

  final WenyouPopoverAnchorBuilder anchorBuilder;
  final ValueChanged<PostCardAction> onSelected;
  final bool canCopyText;
  final bool canEdit;
  final bool canDelete;
  final bool canReport;
  final bool pending;
  final bool canCopyLink;
  final String copyLinkLabel;
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
          label: '复制内容',
          semanticsLabel: '复制内容',
          key: _actionKey('copy'),
        ),
      if (canCopyLink)
        WenyouPopoverAction(
          value: PostCardAction.copyLink,
          icon: WenyouIconIds.editorLink,
          label: '复制链接',
          semanticsLabel: copyLinkLabel,
          key: _actionKey('link'),
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
  final messenger = ScaffoldMessenger.maybeOf(context);
  while (context.mounted) {
    try {
      await Clipboard.setData(ClipboardData(text: value));
    } on Object {
      await WidgetsBinding.instance.endOfFrame;
      if (!context.mounted) return;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('复制失败'),
          content: const Text('内容没有复制成功，你可以留在当前页面重试。'),
          actions: [
            TextButton(
              key: const Key('copy-failure-close'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('关闭'),
            ),
            FilledButton(
              key: const Key('copy-failure-retry'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
      if (retry != true) return;
      continue;
    }

    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted || messenger?.mounted != true) return;
    try {
      messenger!.showWenyouSnackBar(successMessage);
    } on Object catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'wenyou content actions',
          context: ErrorDescription(
            'while showing feedback after copying content',
          ),
        ),
      );
    }
    return;
  }
}

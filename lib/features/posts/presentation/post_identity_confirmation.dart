import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_confirmation_dialog.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

Future<bool> confirmPostIdentity(
  BuildContext context,
  PostIdentitySelection selection, {
  bool force = false,
}) async {
  if (!force && selection.mode == PostIdentityMode.account) return true;
  if (!await selection.refresh()) {
    if (context.mounted) showWenyouSnackBar(context, '发表身份加载失败，草稿已保留。');
    return false;
  }
  if (!context.mounted) return false;
  if (!force && !selection.changed) return true;
  final identity = selection.identity!;
  final name = identity.hasRp ? identity.displayName : identity.accountName;
  final confirmed = await showWenyouConfirmationDialog(
    context: context,
    title: '发表身份发生变化',
    message: identity.hasRp
        ? '草稿已保留。确认以「$name」发表吗？'
        : '当前无法使用原帖内身份。草稿已保留，要改用站内身份「$name」吗？',
    confirmLabel: '确认身份',
    cancelLabel: '继续编辑',
    useRootNavigator: false,
  );
  if (!context.mounted || !confirmed) return false;
  selection.confirmCurrent();
  return true;
}

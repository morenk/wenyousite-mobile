import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_snack_bar.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_selection.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';

Future<bool> preparePostIdentity(
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
  final unavailable =
      selection.mode == PostIdentityMode.rp &&
      selection.collection?.find(selection.identityId)?.hasRp != true;
  selection.useCurrentIdentity();
  // 资料更新直接使用同一角色；角色失效只更新编辑器，不代替用户换号发言。
  if (unavailable) {
    showWenyouSnackBar(context, '帖内身份已不可用，草稿已保留。');
  }
  return !unavailable;
}

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_mention_target.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card.dart';

/// 当前阅读范围提供身份卡入口；卡片通过真实账号打开主页。
class ThreadIdentityReadingScope extends InheritedWidget {
  const ThreadIdentityReadingScope({
    required this.threadId,
    required this.available,
    this.ownerId,
    required super.child,
    super.key,
  });
  final String threadId;
  final bool available;
  final String? ownerId;
  String? roleLabelFor(String userId) => userId == ownerId ? '楼主' : null;

  static ThreadIdentityReadingScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThreadIdentityReadingScope>();

  void open(
    BuildContext context,
    String userId, {
    RpIdentity? historical,
    String? identityId,
    bool fromPost = true,
    String? roleLabel,
  }) {
    if (!available || (fromPost && historical == null)) {
      openInternalWenyouLink(context, Uri(path: '/users/$userId'));
      return;
    }
    showThreadIdentityCard(
      context: context,
      threadId: threadId,
      userId: userId,
      historical: historical,
      identityId: identityId,
      fromPost: fromPost,
      roleLabel: roleLabel,
    );
  }

  @override
  bool updateShouldNotify(ThreadIdentityReadingScope oldWidget) =>
      threadId != oldWidget.threadId ||
      available != oldWidget.available ||
      ownerId != oldWidget.ownerId;
}

/// 角色链接读取精确 ID；显式账号提及直接进入主页。
void openThreadReadingLink(BuildContext context, Uri uri) {
  final scope = ThreadIdentityReadingScope.maybeOf(context);
  final target = MarkdownMentionTarget.parse(uri.toString());
  if (scope?.available == true && target != null && !target.isAccount) {
    scope!.open(
      context,
      target.userId,
      identityId: target.identityId,
      fromPost: false,
    );
  } else {
    openInternalWenyouLink(context, uri);
  }
}

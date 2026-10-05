import 'package:flutter/material.dart';
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

/// 帖内用户链接先展示身份卡，其他站内链接保持既有导航行为。
void openThreadReadingLink(BuildContext context, Uri uri) {
  final scope = ThreadIdentityReadingScope.maybeOf(context);
  if (scope?.available == true &&
      !uri.hasAuthority &&
      uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 'users') {
    scope!.open(context, uri.pathSegments.last, fromPost: false);
  } else {
    openInternalWenyouLink(context, uri);
  }
}

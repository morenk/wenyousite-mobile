import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/core/navigation/internal_link.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_models.dart';
import 'package:wenyousite_mobile/features/thread_identity/identity_ports.dart';
import 'package:wenyousite_mobile/features/thread_identity/presentation/thread_identity_card.dart';

/// 当前阅读范围提供账号动作；身份卡不持有其他页面的可变筛选状态。
class ThreadIdentityReadingScope extends InheritedWidget {
  const ThreadIdentityReadingScope({
    required this.threadId,
    required this.available,
    this.ownerId,
    required super.child,
    this.onMention,
    this.onFilter,
    super.key,
  });
  final String threadId;
  final bool available;
  final String? ownerId;
  String? roleLabelFor(String userId) => userId == ownerId ? '楼主' : null;
  final ValueChanged<ThreadIdentityState>? onMention;
  final ValueChanged<String>? onFilter;

  static ThreadIdentityReadingScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThreadIdentityReadingScope>();

  void open(
    BuildContext context,
    String userId, {
    RpIdentity? historical,
    bool fromPost = true,
    String? roleLabel,
  }) {
    showThreadIdentityCard(
      context: context,
      threadId: threadId,
      userId: userId,
      historical: historical,
      fromPost: fromPost,
      roleLabel: roleLabel,
      onMention: onMention,
      onOnlyThisUser: onFilter == null ? null : () => onFilter!(userId),
    );
  }

  @override
  bool updateShouldNotify(ThreadIdentityReadingScope oldWidget) =>
      threadId != oldWidget.threadId ||
      available != oldWidget.available ||
      ownerId != oldWidget.ownerId ||
      onMention != oldWidget.onMention ||
      onFilter != oldWidget.onFilter;
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

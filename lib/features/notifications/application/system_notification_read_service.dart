import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';

/// 系统通知点击不依赖通知列表已加载，也不能借汇总卡片执行全部已读。
class SystemNotificationReadService {
  SystemNotificationReadService({
    required this.isCurrent,
    required this.setRead,
    required this.synchronize,
  });

  final bool Function(SessionScope) isCurrent;
  final Future<void> Function(String) setRead;
  final Future<void> Function() synchronize;
  final _pending = <(SessionScope, String), Future<bool>>{};

  Future<bool> markRead(String id, SessionScope scope) {
    if (!isCurrent(scope)) return Future.value(false);
    final key = (scope, id);
    return _pending[key] ??= _markRead(id, scope).whenComplete(() {
      _pending.remove(key);
    });
  }

  Future<bool> _markRead(String id, SessionScope scope) async {
    try {
      await setRead(id);
    } on Object {
      // 调用方保留错误和显式重试；失败不改本地列表或角标。
      return false;
    }
    if (!isCurrent(scope)) return false;
    await synchronize();
    return isCurrent(scope);
  }
}

final systemNotificationReadServiceProvider =
    Provider<SystemNotificationReadService>(
      (ref) {
        var disposed = false;
        ref.onDispose(() => disposed = true);
        final repository = ref.watch(notificationRepositoryProvider);
        return SystemNotificationReadService(
          isCurrent: (scope) =>
              !disposed &&
              ref.read(sessionControllerProvider).isAuthenticated &&
              ref.read(sessionControllerProvider.notifier).scope == scope,
          setRead: (id) => repository.setReadStatus(id, isRead: true),
          synchronize: () async {
            // 已加载列表重新读服务端；未打开过的列表不为回执额外加载。
            if (ref.exists(notificationListControllerProvider)) {
              unawaited(
                ref.read(notificationListControllerProvider.notifier).load(),
              );
            }
            await ref
                .read(notificationUnreadControllerProvider.notifier)
                .refresh(force: true);
          },
        );
      },
      dependencies: [
        notificationRepositoryProvider,
        notificationListControllerProvider,
        notificationUnreadControllerProvider,
      ],
    );

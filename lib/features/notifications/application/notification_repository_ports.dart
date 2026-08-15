import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

export 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart'
    show NotificationFilter, NotificationFilters;

abstract interface class NotificationRepository {
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  });

  Future<int> fetchUnreadCount();

  Future<void> setReadStatus(String id, {required bool isRead});

  Future<void> remove(String id);

  Future<void> markAllRead();
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return const _UnboundNotificationRepository();
});

class _UnboundNotificationRepository implements NotificationRepository {
  const _UnboundNotificationRepository();

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) {
    return Future.error(_unboundError());
  }

  @override
  Future<int> fetchUnreadCount() {
    return Future.error(_unboundError());
  }

  @override
  Future<void> markAllRead() {
    return Future.error(_unboundError());
  }

  @override
  Future<void> remove(String id) {
    return Future.error(_unboundError());
  }

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) {
    return Future.error(_unboundError());
  }
}

StateError _unboundError() => StateError('通知仓储尚未在应用组合根绑定。');

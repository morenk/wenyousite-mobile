import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

void main() {
  test('筛选与分页使用各自服务端游标', () async {
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('all-1')],
          cursor: 'all-1',
          hasMore: true,
        ),
        (NotificationFilters.byId('subscription'), null): CursorPage(
          items: [_item('update-1')],
          cursor: 'update-1',
          hasMore: true,
        ),
        (NotificationFilters.byId('subscription'), 'update-1'): CursorPage(
          items: [_item('update-2')],
          hasMore: false,
        ),
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    await controller.selectFilter(NotificationFilters.byId('subscription'));
    await controller.loadMore();

    expect(controller.state.filter, NotificationFilters.byId('subscription'));
    expect(controller.state.items.map((item) => item.id), [
      'update-1',
      'update-2',
    ]);
    expect(repository.requests, [
      (NotificationFilters.all, null),
      (NotificationFilters.byId('subscription'), null),
      (NotificationFilters.byId('subscription'), 'update-1'),
    ]);
  });

  test('单条已读乐观更新；失败回滚并重新校准角标', () async {
    final pending = Completer<void>();
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('notification-1')],
          hasMore: false,
        ),
      },
      unreadCount: 3,
      setReadOperation: (_) => pending.future,
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    await unread.refresh();
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    final operation = controller.markRead('notification-1');
    expect(controller.state.items.single.isRead, isTrue);
    expect(unread.state.count, 2);
    pending.completeError(
      const ApiFailure(userMessage: '标记失败', requestId: 'read-request'),
    );
    expect(await operation, isFalse);
    await _settle();

    expect(controller.state.items.single.isRead, isFalse);
    expect(controller.state.actionFailure?.requestId, 'read-request');
    expect(unread.state.count, 3);
  });

  test('删除未读尾项后回退游标并同步角标', () async {
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('notification-1'), _item('notification-2')],
          cursor: 'notification-2',
          hasMore: true,
        ),
      },
      unreadCount: 2,
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    await unread.refresh();
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.remove('notification-2'), isTrue);

    expect(controller.state.items.single.id, 'notification-1');
    expect(controller.state.cursor, 'notification-1');
    expect(unread.state.count, 1);
    expect(repository.removedIds, ['notification-2']);
  });

  test('全部已读失败恢复列表并保留请求 ID', () async {
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('notification-1')],
          hasMore: false,
        ),
      },
      unreadCount: 1,
      markAllFailure: const ApiFailure(
        userMessage: '全部已读失败',
        requestId: 'all-read-request',
      ),
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    await unread.refresh();
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    expect(await controller.markAllRead(), isFalse);
    await _settle();

    expect(controller.state.items.single.isRead, isFalse);
    expect(controller.state.actionFailure?.requestId, 'all-read-request');
    expect(unread.state.count, 1);
  });

  test('当前筛选没有未读项时仍可清除全局未读', () async {
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('already-read', isRead: true)],
          hasMore: false,
        ),
      },
      unreadCount: 3,
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    await unread.refresh();
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    expect(controller.state.hasUnread, isFalse);
    expect(await controller.markAllRead(), isTrue);
    expect(repository.markAllCalls, 1);
    expect(unread.state.count, 0);
  });
}

class _FakeRepository implements NotificationRepository {
  _FakeRepository({
    required this.pages,
    this.unreadCount = 0,
    this.setReadOperation,
    this.markAllFailure,
  });

  final Map<(NotificationFilter, String?), CursorPage<NotificationListItem>>
  pages;
  final int unreadCount;
  final Future<void> Function(String id)? setReadOperation;
  final ApiFailure? markAllFailure;
  final List<(NotificationFilter, String?)> requests = [];
  final List<String> removedIds = [];
  int markAllCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) async {
    requests.add((filter, cursor));
    return pages[(filter, cursor)]!;
  }

  @override
  Future<int> fetchUnreadCount() async => unreadCount;

  @override
  Future<void> markAllRead() async {
    if (markAllFailure != null) throw markAllFailure!;
    markAllCalls += 1;
  }

  @override
  Future<void> remove(String id) async => removedIds.add(id);

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {
    await setReadOperation?.call(id);
  }
}

NotificationListItem _item(String id, {bool isRead = false}) {
  return NotificationListItem(
    id: id,
    kind: NotificationKind.reply,
    content: '骰子猫回复了你',
    target: const NotificationTarget(kind: NotificationTargetKind.none),
    isRead: isRead,
    createdAt: DateTime.utc(2026, 8, 10),
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

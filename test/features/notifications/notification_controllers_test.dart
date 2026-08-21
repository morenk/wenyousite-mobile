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

  test('加载更多按通知 ID 去重并保留已有顺序', () async {
    final repository = _FakeRepository(
      pages: {
        (NotificationFilters.all, null): CursorPage(
          items: [_item('notification-1'), _item('notification-2')],
          cursor: 'next-page',
          hasMore: true,
        ),
        (NotificationFilters.all, 'next-page'): CursorPage(
          items: [_item('notification-2'), _item('notification-3')],
          hasMore: false,
        ),
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    await controller.loadMore();

    expect(controller.state.items.map((item) => item.id), [
      'notification-1',
      'notification-2',
      'notification-3',
    ]);
  });

  test('失效游标从当前筛选首页重载', () async {
    var firstPageCalls = 0;
    final subscription = NotificationFilters.byId('subscription');
    final repository = _FakeRepository(
      fetchPageOperation: (filter, cursor) async {
        if (filter == NotificationFilters.all) {
          return const CursorPage(items: [], hasMore: false);
        }
        if (cursor == 'expired-cursor') {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
            requestId: 'invalid-cursor-request',
          );
        }
        firstPageCalls += 1;
        return firstPageCalls == 1
            ? CursorPage(
                items: [_item('stale-notification')],
                cursor: 'expired-cursor',
                hasMore: true,
              )
            : CursorPage(items: [_item('fresh-notification')], hasMore: false);
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();
    await controller.selectFilter(subscription);

    await controller.loadMore();

    expect(controller.state.filter, subscription);
    expect(controller.state.items.single.id, 'fresh-notification');
    expect(controller.state.hasMore, isFalse);
    expect(repository.requests, [
      (NotificationFilters.all, null),
      (subscription, null),
      (subscription, 'expired-cursor'),
      (subscription, null),
    ]);
  });

  test('筛选切换后丢弃旧筛选迟到响应', () async {
    final stalePage = Completer<CursorPage<NotificationListItem>>();
    final subscription = NotificationFilters.byId('subscription');
    final repository = _FakeRepository(
      fetchPageOperation: (filter, cursor) {
        if (filter == NotificationFilters.all) return stalePage.future;
        return Future.value(
          CursorPage(items: [_item('fresh-notification')], hasMore: false),
        );
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    await controller.selectFilter(subscription);
    stalePage.complete(
      CursorPage(items: [_item('stale-notification')], hasMore: false),
    );
    await _settle();

    expect(controller.state.filter, subscription);
    expect(controller.state.items.single.id, 'fresh-notification');
  });

  test('普通分页失败保留列表并携带问题编号', () async {
    final repository = _FakeRepository(
      fetchPageOperation: (filter, cursor) async {
        if (cursor == null) {
          return CursorPage(
            items: [_item('notification-1')],
            cursor: 'next-page',
            hasMore: true,
          );
        }
        throw const ApiFailure(
          userMessage: '加载失败',
          requestId: 'load-more-request',
        );
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    await controller.loadMore();

    expect(controller.state.items.single.id, 'notification-1');
    expect(controller.state.cursor, 'next-page');
    expect(controller.state.loadMoreFailure?.requestId, 'load-more-request');
  });

  test('同一分页在途时忽略重复加载请求', () async {
    final pendingPage = Completer<CursorPage<NotificationListItem>>();
    final repository = _FakeRepository(
      fetchPageOperation: (filter, cursor) {
        if (cursor == null) {
          return Future.value(
            CursorPage(
              items: [_item('notification-1')],
              cursor: 'next-page',
              hasMore: true,
            ),
          );
        }
        return pendingPage.future;
      },
    );
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();

    final first = controller.loadMore();
    final second = controller.loadMore();
    expect(
      repository.requests.where((request) => request.$2 == 'next-page'),
      hasLength(1),
    );
    pendingPage.complete(
      CursorPage(items: [_item('notification-2')], hasMore: false),
    );
    await Future.wait([first, second]);

    expect(controller.state.items.map((item) => item.id), [
      'notification-1',
      'notification-2',
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
    this.pages = const {},
    this.unreadCount = 0,
    this.setReadOperation,
    this.markAllFailure,
    this.fetchPageOperation,
  });

  final Map<(NotificationFilter, String?), CursorPage<NotificationListItem>>
  pages;
  final int unreadCount;
  final Future<void> Function(String id)? setReadOperation;
  final ApiFailure? markAllFailure;
  final Future<CursorPage<NotificationListItem>> Function(
    NotificationFilter filter,
    String? cursor,
  )?
  fetchPageOperation;
  final List<(NotificationFilter, String?)> requests = [];
  final List<String> removedIds = [];
  int markAllCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) async {
    requests.add((filter, cursor));
    if (fetchPageOperation != null) {
      return fetchPageOperation!(filter, cursor);
    }
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

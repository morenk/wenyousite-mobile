import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

void main() {
  for (final action in ['read', 'remove', 'all']) {
    for (final fails in [false, true]) {
      test('$action 的迟到${fails ? '失败' : '成功'}不覆盖新筛选', () async {
        final repository = _Repository();
        final unread = NotificationUnreadController(
          repository,
          autoStart: false,
        );
        final controller = NotificationListController(repository, unread);
        addTearDown(unread.dispose);
        addTearDown(controller.dispose);
        await _settle();
        final pending = switch (action) {
          'read' => controller.markRead('old'),
          'remove' => controller.remove('old'),
          _ => controller.markAllRead(),
        };
        await controller.selectFilter(NotificationFilters.byId('subscription'));
        final current = controller.state;
        if (fails) {
          repository.write.completeError(const ApiFailure(userMessage: '操作失败'));
        } else {
          repository.write.complete();
        }
        expect(await pending, isFalse);
        expect(controller.state, same(current));
        expect(controller.state.items.single.id, 'fresh');
        expect(controller.state.actionFailure, isNull);
      });
    }
  }

  test('销毁后的对话框与重试入口不再读取状态或发送请求', () async {
    final repository = _Repository();
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    await _settle();
    controller.dispose();
    unread.dispose();
    expect(await controller.remove('old'), isFalse);
    expect(await controller.markRead('old'), isFalse);
    expect(await controller.markAllRead(), isFalse);
    await controller.load();
    await controller.loadMore();
    await controller.selectFilter(NotificationFilters.byId('subscription'));
    controller.clearActionFailure();
    await unread.refresh();
    unread.clear();
    unread.decrement();
    expect(repository.writeCalls, 0);
    expect(repository.pageCalls, 1);
  });

  test('清除未读数后更早的在途读取不能恢复旧角标', () async {
    final repository = _Repository();
    final unread = NotificationUnreadController(repository, autoStart: false);
    addTearDown(unread.dispose);
    final oldCount = Completer<int>();
    repository.countRequest = () => oldCount.future;
    final pending = unread.refresh();
    unread.clear();
    oldCount.complete(12);
    await pending;
    expect(unread.state.count, 0);
    expect(unread.state.isLoading, isFalse);
  });

  test('写入后的强制校准覆盖更早的未读数读取', () async {
    final repository = _Repository();
    final unread = NotificationUnreadController(repository, autoStart: false);
    addTearDown(unread.dispose);
    final oldCount = Completer<int>();
    repository.countRequest = () => oldCount.future;
    final pending = unread.refresh();
    repository.countRequest = () async => 2;
    await unread.refresh(force: true);
    oldCount.complete(12);
    await pending;
    expect(unread.state.count, 2);
  });

  test('删除唯一条目仍原样保存服务端游标并用它翻页', () async {
    final repository = _Repository();
    final unread = NotificationUnreadController(repository, autoStart: false);
    final controller = NotificationListController(repository, unread);
    addTearDown(unread.dispose);
    addTearDown(controller.dispose);
    await _settle();
    final pending = controller.remove('old');
    repository.write.complete();
    expect(await pending, isTrue);
    expect(controller.state.items, isEmpty);
    expect(controller.state.cursor, 'old');
    await controller.loadMore();
    expect(repository.lastCursor, 'old');
  });
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

class _Repository implements NotificationRepository {
  final write = Completer<void>();
  Future<int> Function()? countRequest;
  var writeCalls = 0;
  var pageCalls = 0;
  String? lastCursor;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) async {
    pageCalls++;
    lastCursor = cursor;
    return CursorPage(
      items: [_item(filter == NotificationFilters.all ? 'old' : 'fresh')],
      cursor: 'old',
      hasMore: true,
    );
  }

  @override
  Future<int> fetchUnreadCount() => countRequest?.call() ?? Future.value(0);

  Future<void> _write() {
    writeCalls++;
    return write.future;
  }

  @override
  Future<void> remove(String id) => _write();

  @override
  Future<void> markAllRead() => _write();

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) => _write();
}

NotificationListItem _item(String id) => NotificationListItem(
  id: id,
  recipientUserId: 'viewer',
  kind: NotificationKind.reply,
  content: '回复了你',
  target: const NotificationTarget(kind: NotificationTargetKind.none),
  isRead: false,
  createdAt: DateTime.utc(2026, 9, 7),
);

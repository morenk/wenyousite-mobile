import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/notifications/presentation/notifications_page.dart';

void main() {
  testWidgets('游客看到安全登录引导且保留通知回跳', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后查看通知'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-login')));
    await tester.pumpAndSettle();
    expect(find.text('登录回跳=/notifications'), findsOneWidget);
  });

  testWidgets('通知展示结构化文案、未读数并精确进入楼层', (tester) async {
    final repository = _FakeRepository(items: [_item('notification-1')]);
    final router = _router();
    addTearDown(router.dispose);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('骰子猫 回复了你：雾港见'), findsOneWidget);
    expect(find.text('1 条未读'), findsOneWidget);
    expect(find.byKey(const Key('notification-mark-all-read')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('notification-notification-1')));
    await tester.pumpAndSettle();

    expect(find.text('主题=thread-1，帖子=post-7'), findsOneWidget);
    expect(repository.readIds, ['notification-1']);
  });

  testWidgets('筛选、全部已读、删除和局部错误均可操作', (tester) async {
    final repository = _FakeRepository(
      items: [_item('notification-1')],
      failLoadMore: true,
      hasMore: true,
    );
    final router = _router();
    addTearDown(router.dispose);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('notification-filter-updates')));
    await tester.pumpAndSettle();
    expect(repository.filters.last, NotificationFilter.updates);

    await tester.tap(find.byKey(const Key('notification-load-more')));
    await tester.pumpAndSettle();
    expect(find.text('请求 ID：notification-more-request'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notification-mark-all-read')));
    await tester.pumpAndSettle();
    expect(repository.markAllCalls, 1);
    expect(find.byKey(const Key('notification-mark-all-read')), findsNothing);

    await tester.tap(
      find.byKey(const Key('notification-remove-notification-1')),
    );
    await tester.pumpAndSettle();
    expect(repository.removedIds, ['notification-1']);
    expect(find.text('这个分类暂无通知'), findsOneWidget);
  });

  testWidgets('删除目标与动态目标不会猜测不存在的路由', (tester) async {
    final repository = _FakeRepository(
      items: [
        _item(
          'deleted',
          target: const NotificationTarget(
            kind: NotificationTargetKind.post,
            threadId: 'thread-1',
            postId: 'post-7',
            deletedHint: '该内容已删除',
          ),
        ),
        _item(
          'moment',
          target: const NotificationTarget(
            kind: NotificationTargetKind.moment,
            momentId: 'moment-1',
          ),
        ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);
    final container = await _authenticatedContainer(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('notification-deleted')));
    await tester.pumpAndSettle();
    expect(find.text('该内容已删除'), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('notification-moment')),
    );
    await tester.tap(find.byKey(const ValueKey('notification-moment')));
    await tester.pump();
    expect(find.text('动态详情将在动态模块开放后接入。'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 通知列表无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakeRepository(items: [_item('notification-1')]);
      final router = _router();
      addTearDown(router.dispose);
      final container = await _authenticatedContainer(repository);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/notifications',
    routes: [
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (_, state) => Scaffold(
          body: Text('登录回跳=${state.uri.queryParameters['returnTo']}'),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId',
        name: 'thread-detail',
        builder: (_, state) => Scaffold(
          body: Text(
            '主题=${state.pathParameters['threadId']}，帖子=${state.uri.queryParameters['post']}',
          ),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (_, state) =>
            Scaffold(body: Text('用户=${state.pathParameters['userId']}')),
      ),
    ],
  );
}

Future<ProviderContainer> _authenticatedContainer(
  NotificationRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      notificationRepositoryProvider.overrideWithValue(repository),
      notificationUnreadControllerProvider.overrideWith((ref) {
        final controller = NotificationUnreadController(
          repository,
          autoStart: false,
        );
        controller.refresh();
        return controller;
      }),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  return container;
}

class _FakeRepository implements NotificationRepository {
  _FakeRepository({
    this.items = const [],
    this.hasMore = false,
    this.failLoadMore = false,
  });

  final List<NotificationListItem> items;
  final bool hasMore;
  final bool failLoadMore;
  final List<NotificationFilter> filters = [];
  final List<String> readIds = [];
  final List<String> removedIds = [];
  int markAllCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
  }) async {
    filters.add(filter);
    if (cursor != null && failLoadMore) {
      throw const ApiFailure(
        userMessage: '更多通知加载失败',
        requestId: 'notification-more-request',
      );
    }
    return CursorPage(
      items: cursor == null ? items : const [],
      cursor: hasMore && items.isNotEmpty ? items.last.id : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<int> fetchUnreadCount() async =>
      items.where((item) => !item.isRead).length;

  @override
  Future<void> markAllRead() async => markAllCalls += 1;

  @override
  Future<void> remove(String id) async => removedIds.add(id);

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {
    readIds.add(id);
  }
}

NotificationListItem _item(
  String id, {
  NotificationTarget target = const NotificationTarget(
    kind: NotificationTargetKind.post,
    threadId: 'thread-1',
    postId: 'post-7',
  ),
}) {
  return NotificationListItem(
    id: id,
    kind: NotificationKind.reply,
    content: '旧文案',
    payload: const NotificationPayload(
      action: 'reply',
      actorName: '骰子猫',
      preview: '雾港见',
    ),
    target: target,
    actor: const NotificationActor(id: 'actor-1', username: '骰子猫', level: 4),
    isRead: false,
    createdAt: DateTime.now(),
  );
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}

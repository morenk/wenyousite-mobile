import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/message_center_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_controllers.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_filters.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('游客看到安全登录引导且保留通知回跳', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [directMessagesEnabledProvider.overrideWithValue(false)],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后查看消息'), findsOneWidget);
    expect(find.text('登录后查看消息'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-login')));
    await tester.pumpAndSettle();
    expect(find.text('登录回跳=/notifications'), findsOneWidget);
  });

  testWidgets('Foundation 分类和结构化层级生效，并精确进入主楼层', (tester) async {
    final repository = _FakeRepository(items: [_item('notification-1')]);
    final router = _router();
    final container = await _authenticatedContainer(repository);
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await _pumpAuthenticated(tester, container, router);

    expect(find.text('全部'), findsOneWidget);
    expect(find.text('互动'), findsNothing);
    expect(find.text('订阅'), findsNothing);
    expect(find.text('系统'), findsNothing);
    expect(find.byKey(const Key('notification-filter-menu')), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('回复与提及'), findsNothing);
    expect(find.text('骰子猫 回复了你', findRichText: true), findsOneWidget);
    expect(find.text('雾港见'), findsOneWidget);
    expect(find.byKey(const Key('notification-unread-summary')), findsNothing);
    final unreadDecoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byKey(
                      const ValueKey('notification-unread-notification-1'),
                    ),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(unreadDecoration.color, WenyouFoundationPalette.destructive);

    await tester.tap(find.byKey(const ValueKey('notification-notification-1')));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1，帖子=post-7'), findsOneWidget);
    expect(repository.readIds, ['notification-1']);
  });

  testWidgets('消息中心主栏目与紧凑通知筛选无布局溢出', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakeRepository(items: [_item('notification-1')]);
    final container = await _authenticatedContainer(
      repository,
      directMessagesEnabled: true,
      directUnread: 2,
    );
    addTearDown(container.dispose);
    const visualKey = Key('notification-tabs-visual');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: visualKey,
            child: MessageCenterPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceChip), findsNothing);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/notification_tabs_360.png'),
    );
  });

  testWidgets('楼中楼通知直接进入父楼层回复页', (tester) async {
    final repository = _FakeRepository(
      items: [
        _item(
          'nested-reply',
          recipientUserId: 'subscriber-user',
          replyTargetUserId: 'target-user',
          replyTargetName: '阿忠',
          target: const NotificationTarget(
            kind: NotificationTargetKind.post,
            threadId: 'thread-1',
            postId: 'reply-9',
            parentPostId: 'floor-2',
          ),
        ),
      ],
    );
    final router = _router();
    final container = await _authenticatedContainer(repository);
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await _pumpAuthenticated(tester, container, router);

    expect(find.text('骰子猫 回复了阿忠', findRichText: true), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('notification-nested-reply')));
    await tester.pumpAndSettle();
    expect(find.text('回复页=thread-1/floor-2/reply-9'), findsOneWidget);
  });

  testWidgets('私聊页签写入 URL，消息内容区可左右滑动切栏', (tester) async {
    final repository = _FakeRepository();
    final router = _router(initialLocation: '/messages');
    final container = await _authenticatedContainer(
      repository,
      directMessagesEnabled: true,
      directUnread: 4,
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await _pumpAuthenticated(tester, container, router);

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/notifications?section=directMessages',
    );
    expect(find.text('私聊 4'), findsOneWidget);
    expect(find.text('暂无私聊会话'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('message-section-swipe')),
      const Offset(100, 0),
    );
    await tester.pump();
    final sectionSlide = find.descendant(
      of: find.byKey(const Key('message-section-swipe')),
      matching: find.byType(SlideTransition),
    );
    expect(
      tester.widget<SlideTransition>(sectionSlide).position.value.dx,
      isNegative,
    );
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/notifications',
    );
    expect(repository.filters, [NotificationFilters.all]);

    await tester.drag(
      find.byKey(const Key('message-section-swipe')),
      const Offset(-100, 0),
    );
    await tester.pump();
    expect(
      tester.widget<SlideTransition>(sectionSlide).position.value.dx,
      isPositive,
    );
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/notifications?section=directMessages',
    );
    expect(repository.filters, [NotificationFilters.all]);
  });

  testWidgets('能力关闭时非法私聊 section 回退并规范化 URL', (tester) async {
    final repository = _FakeRepository();
    final router = _router(
      initialLocation: '/notifications?section=directMessages',
    );
    final container = await _authenticatedContainer(repository);
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await _pumpAuthenticated(tester, container, router);

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/notifications',
    );
    expect(find.text('私聊'), findsNothing);
    expect(find.text('暂无通知'), findsOneWidget);
  });

  testWidgets('分类切换、全局全部已读和删除确认均可操作', (tester) async {
    final repository = _FakeRepository(
      items: [_item('notification-1', isRead: true)],
      unreadCount: 3,
    );
    final router = _router();
    final container = await _authenticatedContainer(repository);
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await _pumpAuthenticated(tester, container, router);

    await tester.tap(find.byKey(const Key('notification-filter-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-filter-subscription')));
    await tester.pumpAndSettle();
    expect(repository.filters.last, NotificationFilters.byId('subscription'));

    expect(find.byKey(const Key('notification-mark-all-read')), findsOneWidget);
    await tester.tap(find.byKey(const Key('notification-mark-all-read')));
    await tester.pumpAndSettle();
    expect(repository.markAllCalls, 1);

    await tester.tap(
      find.byKey(const Key('notification-remove-notification-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('删除这条通知？'), findsOneWidget);
    expect(find.text('删除后无法恢复。'), findsOneWidget);
    expect(repository.removedIds, isEmpty);
    await tester.tap(find.byKey(const Key('notification-remove-confirm')));
    await tester.pumpAndSettle();
    expect(repository.removedIds, ['notification-1']);
  });
}

Future<void> _pumpAuthenticated(
  WidgetTester tester,
  ProviderContainer container,
  GoRouter router,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

GoRouter _router({String initialLocation = '/notifications'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/notifications',
        builder: (_, state) => MessageCenterPage(
          requestedSection: state.uri.queryParameters['section'],
        ),
      ),
      GoRoute(
        path: '/messages',
        redirect: (_, _) => '/notifications?section=directMessages',
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
        builder: (_, state) => Scaffold(
          body: Text(
            '主题=${state.pathParameters['threadId']}，帖子=${state.uri.queryParameters['post']}',
          ),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/posts/:postId/replies',
        builder: (_, state) => Scaffold(
          body: Text(
            '回复页=${state.pathParameters['threadId']}/${state.pathParameters['postId']}/${state.uri.queryParameters['post']}',
          ),
        ),
      ),
    ],
  );
}

Future<ProviderContainer> _authenticatedContainer(
  NotificationRepository repository, {
  bool directMessagesEnabled = false,
  int directUnread = 0,
}) async {
  final directRepository = _FakeDirectMessageRepository(directUnread);
  final container = ProviderContainer(
    overrides: [
      directMessagesEnabledProvider.overrideWithValue(directMessagesEnabled),
      directMessageRepositoryProvider.overrideWithValue(directRepository),
      directUnreadControllerProvider.overrideWith((ref) {
        final controller = DirectUnreadController(
          directRepository,
          autoStart: false,
        );
        controller.refresh();
        return controller;
      }),
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
  _FakeRepository({this.items = const [], int? unreadCount})
    : unreadCount = unreadCount ?? items.where((item) => !item.isRead).length;

  final List<NotificationListItem> items;
  final int unreadCount;
  final List<NotificationFilter> filters = [];
  final List<String> readIds = [];
  final List<String> removedIds = [];
  int markAllCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilters.all,
    String? cursor,
  }) async {
    filters.add(filter);
    return CursorPage(items: items, hasMore: false);
  }

  @override
  Future<int> fetchUnreadCount() async => unreadCount;

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
  bool isRead = false,
  String recipientUserId = 'viewer-user',
  String replyTargetUserId = 'viewer-user',
  String replyTargetName = '当前用户',
  NotificationTarget target = const NotificationTarget(
    kind: NotificationTargetKind.post,
    threadId: 'thread-1',
    postId: 'post-7',
  ),
}) {
  return NotificationListItem(
    id: id,
    recipientUserId: recipientUserId,
    kind: NotificationKind.reply,
    content: '旧文案',
    payload: NotificationPayload(
      action: 'reply',
      actorName: '骰子猫',
      replyTargetUserId: replyTargetUserId,
      replyTargetName: replyTargetName,
      preview: '雾港见',
    ),
    target: target,
    actor: const NotificationActor(id: 'actor-1', username: '骰子猫', level: 4),
    isRead: isRead,
    createdAt: DateTime.now(),
  );
}

class _FakeDirectMessageRepository implements DirectMessageRepository {
  const _FakeDirectMessageRepository(this.unread);

  final int unread;

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async =>
      DirectUnreadCounts(unreadMessages: unread, pendingRequests: 0);

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) async => const CursorPage(items: [], hasMore: false);

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversation> fetchConversation(String conversationId) =>
      throw UnimplementedError();

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversationLookup> findByUser(String userId) =>
      throw UnimplementedError();

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) => throw UnimplementedError();

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) => throw UnimplementedError();

  @override
  Future<DirectRecallResult> recall(String messageId) =>
      throw UnimplementedError();

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) => throw UnimplementedError();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_messages_page.dart';

void main() {
  testWidgets('私信中心展示三类列表、精简预览并进入稳定会话路由', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('direct-messages-unread-summary')),
      findsNothing,
    );
    expect(find.text('小油'), findsOneWidget);
    expect(find.text('你好'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

    await tester.tap(find.text('请求 1'));
    await tester.pumpAndSettle();
    expect(repository.views.last, DirectConversationView.requests);
    expect(find.text('想和你聊聊'), findsOneWidget);
    expect(find.text('[消息请求] 想和你聊聊'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('direct-conversation-request-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('会话=request-1'), findsOneWidget);
  });

  testWidgets('分页失败保留既有会话和请求 ID并可原位重试', (tester) async {
    final repository = _FakeRepository(failLoadMoreOnce: true);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('direct-messages-load-more')));
    await tester.pumpAndSettle();
    expect(find.text('小油'), findsOneWidget);
    expect(find.text('请求 ID：list-more-request'), findsOneWidget);

    await tester.tap(find.byKey(const Key('direct-messages-load-more-retry')));
    await tester.pumpAndSettle();
    expect(find.text('第二位用户'), findsOneWidget);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 私信中心无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakeRepository();
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repository),
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

  testWidgets('未覆盖未读控制器时能力覆盖仍使用同一 Riverpod 容器', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          directMessagesEnabledProvider.overrideWithValue(true),
          directMessageRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

List<Override> _overrides(_FakeRepository repository) {
  return [
    directMessagesEnabledProvider.overrideWithValue(true),
    directMessageRepositoryProvider.overrideWithValue(repository),
    directUnreadControllerProvider.overrideWith((ref) {
      final controller = DirectUnreadController(repository, autoStart: false);
      controller.refresh();
      return controller;
    }),
  ];
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/messages',
    routes: [
      GoRoute(path: '/messages', builder: (_, _) => const DirectMessagesPage()),
      GoRoute(
        path: '/messages/:conversationId',
        name: 'direct-conversation',
        builder: (_, state) => Scaffold(
          body: Text('会话=${state.pathParameters['conversationId']}'),
        ),
      ),
    ],
  );
}

class _FakeRepository implements DirectMessageRepository {
  _FakeRepository({this.failLoadMoreOnce = false});

  bool failLoadMoreOnce;
  final List<DirectConversationView> views = [];

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) async {
    views.add(view);
    if (cursor != null && failLoadMoreOnce) {
      failLoadMoreOnce = false;
      throw const ApiFailure(
        userMessage: '更多会话加载失败',
        requestId: 'list-more-request',
      );
    }
    if (view == DirectConversationView.requests) {
      return CursorPage(items: [_requestConversation()], hasMore: false);
    }
    if (view == DirectConversationView.archived) {
      return const CursorPage(items: [], hasMore: false);
    }
    if (cursor != null) {
      return CursorPage(
        items: [_acceptedConversation(id: 'conversation-2', name: '第二位用户')],
        hasMore: false,
      );
    }
    return CursorPage(
      items: [_acceptedConversation()],
      cursor: 'conversation-1',
      hasMore: true,
    );
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    return const DirectUnreadCounts(unreadMessages: 2, pendingRequests: 1);
  }

  @override
  Future<DirectConversationLookup> findByUser(String userId) =>
      throw UnimplementedError();

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
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) => throw UnimplementedError();

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) => throw UnimplementedError();

  @override
  Future<DirectRecallResult> recall(String messageId) =>
      throw UnimplementedError();
}

final _now = DateTime.now().subtract(const Duration(minutes: 1));

DirectConversation _acceptedConversation({
  String id = 'conversation-1',
  String name = '小油',
}) {
  return DirectConversation(
    id: id,
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: DirectMessageUser(
      id: 'user-$id',
      username: name,
      isDeactivated: false,
    ),
    lastMessage: DirectMessagePreview(
      id: 'message-$id',
      senderId: 'user-1',
      content: '你好',
      hasImage: false,
      hasSticker: false,
      isRecalled: false,
      createdAt: _now,
    ),
    unreadCount: id == 'conversation-1' ? 2 : 0,
    lastMessageAt: _now,
    createdAt: _now,
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectConversation _requestConversation() {
  return DirectConversation(
    id: 'request-1',
    status: DirectConversationStatus.pending,
    requestDirection: DirectRequestDirection.incoming,
    otherUser: const DirectMessageUser(
      id: 'request-user',
      username: '请求用户',
      isDeactivated: false,
    ),
    lastMessage: DirectMessagePreview(
      id: 'request-message',
      senderId: 'request-user',
      content: '想和你聊聊',
      hasImage: false,
      hasSticker: false,
      isRecalled: false,
      createdAt: _now,
    ),
    unreadCount: 0,
    lastMessageAt: _now,
    createdAt: _now,
    canSend: false,
    canAccept: true,
    canDecline: true,
    isBlocked: false,
  );
}

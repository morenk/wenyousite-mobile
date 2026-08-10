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
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';

void main() {
  testWidgets('已接受会话可发送、撤回并切换归档状态', (tester) async {
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

    expect(find.text('你好'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('direct-message-composer-field')),
      '发送内容',
    );
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pumpAndSettle();

    expect(repository.sentDrafts.single.content, '发送内容');
    expect(find.text('发送内容'), findsOneWidget);

    final recall = find.byKey(const ValueKey('direct-message-recall-sent-1'));
    await tester.ensureVisible(recall);
    await tester.tap(recall);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('direct-conversation-recall-confirm')),
    );
    await tester.pumpAndSettle();
    expect(repository.recalledIds, ['sent-1']);
    expect(find.text('你撤回了一条消息'), findsOneWidget);

    await tester.tap(find.byKey(const Key('direct-conversation-archive')));
    await tester.pumpAndSettle();
    expect(repository.archiveValues, [true]);
    expect(find.byIcon(Icons.unarchive_outlined), findsOneWidget);
  });

  testWidgets('陌生消息请求图片默认隐藏，接受后才开放发送', (tester) async {
    final repository = _FakeRepository(
      conversation: _incomingRequest(),
      messages: [_incomingImageMessage()],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('点击查看陌生人图片'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-composer-field')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('direct-conversation-accept')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.requestActions, [true]);
    expect(
      find.byKey(const Key('direct-message-composer-field')),
      findsOneWidget,
    );
    expect(find.text('点击查看陌生人图片'), findsNothing);
  });

  testWidgets('接受请求遇到邮箱验证错误保留首条消息与验证入口', (tester) async {
    final repository = _FakeRepository(
      conversation: _incomingRequest(),
      messages: [_incomingTextMessage()],
      failAcceptOnce: true,
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('direct-conversation-accept')));
    await tester.pumpAndSettle();

    expect(find.text('你好'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-conversation-verify-email')),
      findsOneWidget,
    );
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 会话与输入器无布局溢出', (tester) async {
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
}

List<Override> _overrides(_FakeRepository repository) {
  return [
    directMessagesEnabledProvider.overrideWithValue(true),
    directMessageRepositoryProvider.overrideWithValue(repository),
    directConversationControllerProvider.overrideWith((ref, conversationId) {
      return DirectConversationController(
        conversationId,
        repository,
        pollInterval: Duration.zero,
      );
    }),
    directUnreadControllerProvider.overrideWith((ref) {
      return DirectUnreadController(repository, autoStart: false);
    }),
  ];
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/messages/conversation-1',
    routes: [
      GoRoute(
        path: '/messages/:conversationId',
        builder: (_, state) => DirectConversationPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (_, state) =>
            Scaffold(body: Text('用户=${state.pathParameters['userId']}')),
      ),
      GoRoute(
        path: '/me/security/verify-email',
        name: 'verify-email',
        builder: (_, _) => const Scaffold(body: Text('验证邮箱')),
      ),
    ],
  );
}

class _FakeRepository implements DirectMessageRepository {
  _FakeRepository({
    DirectConversation? conversation,
    List<DirectMessage>? messages,
    this.failAcceptOnce = false,
  }) : conversation = conversation ?? _acceptedConversation(),
       messages = messages ?? [_incomingTextMessage()];

  DirectConversation conversation;
  final List<DirectMessage> messages;
  bool failAcceptOnce;
  final List<DirectMessageDraft> sentDrafts = [];
  final List<String> recalledIds = [];
  final List<bool> archiveValues = [];
  final List<bool> requestActions = [];

  @override
  Future<DirectConversation> fetchConversation(String conversationId) async {
    return conversation;
  }

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) async {
    return CursorPage(
      items: after == null ? messages : const [],
      hasMore: false,
    );
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) async {
    sentDrafts.add(draft);
    final message = DirectMessage(
      id: 'sent-1',
      conversationId: conversationId,
      senderId: 'user-1',
      recipientId: 'user-2',
      content: draft.content,
      createdAt: DateTime.now(),
    );
    messages.add(message);
    return message;
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    requestActions.add(accept);
    if (accept && failAcceptOnce) {
      failAcceptOnce = false;
      throw const ApiFailure(
        userMessage: '请先完成邮箱验证。',
        businessCode: 40107,
        requestId: 'verify-request',
      );
    }
    conversation = accept ? _acceptedConversation() : _declinedConversation();
    if (!accept) messages.clear();
    return conversation;
  }

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) async {
    archiveValues.add(archived);
    conversation = conversation.copyWith(
      archivedAt: archived ? DateTime.now() : null,
    );
    return conversation;
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async {
    recalledIds.add(messageId);
    return const DirectRecallResult(conversationCanceled: false);
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    return const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0);
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) async {}

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversationLookup> findByUser(String userId) =>
      throw UnimplementedError();

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();
}

DirectMessageUser _user() {
  return const DirectMessageUser(
    id: 'user-2',
    username: '小油',
    isDeactivated: false,
  );
}

DirectConversation _acceptedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectConversation _incomingRequest() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.pending,
    requestDirection: DirectRequestDirection.incoming,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: true,
    canDecline: true,
    isBlocked: false,
  );
}

DirectConversation _declinedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.declined,
    requestDirection: DirectRequestDirection.none,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectMessage _incomingTextMessage() {
  return DirectMessage(
    id: 'incoming-1',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    content: '你好',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

DirectMessage _incomingImageMessage() {
  return DirectMessage(
    id: 'incoming-image',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    media: const DirectMessageMedia(
      id: 'media-1',
      url: 'https://cdn.wenyou.site/private-image.png',
      isSticker: false,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

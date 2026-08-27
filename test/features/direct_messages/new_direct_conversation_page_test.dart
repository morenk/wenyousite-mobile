import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/new_direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

void main() {
  testWidgets('能力关闭时不加载联系人且展示收敛状态', (tester) async {
    final repository = _FakeDirectMessageRepository();
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          directMessagesEnabledProvider.overrideWithValue(false),
          stickersEnabledProvider.overrideWithValue(false),
          directMessageRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('私聊功能当前未开放'), findsOneWidget);
    expect(repository.lookupCalls, 0);
  });

  testWidgets('新联系人首条消息使用稳定请求标识并进入会话', (tester) async {
    final repository = _FakeDirectMessageRepository();
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    expect(find.text('这会先作为消息请求'), findsOneWidget);
    await _replaceComposerText(tester, '你好，想和你聊聊');
    await tester.pump();
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pumpAndSettle();

    expect(repository.createdDrafts.single.content, '你好，想和你聊聊');
    expect(
      repository.createdDrafts.single.clientRequestId,
      '00000000-0000-4000-8000-000000000001',
    );
    expect(find.text('会话=conversation-new'), findsOneWidget);
  });

  testWidgets('已有联系直接重定向到原会话且不重复创建', (tester) async {
    final repository = _FakeDirectMessageRepository(
      existingConversation: _conversation(id: 'conversation-existing'),
    );
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(_app(repository, router));
    await tester.pumpAndSettle();

    expect(find.text('会话=conversation-existing'), findsOneWidget);
    expect(repository.createdDrafts, isEmpty);
  });

  testWidgets('已互关用户直接建立私聊且不显示消息请求提示', (tester) async {
    final repository = _FakeDirectMessageRepository();
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      _app(
        repository,
        router,
        publicUserRepository: _FakePublicUserRepository(mutual: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已互相关注'), findsOneWidget);
    expect(find.text('这会先作为消息请求'), findsNothing);
    expect(find.byKey(const Key('direct-message-new-notice')), findsNothing);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 新私聊页面无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakeDirectMessageRepository();
      final router = _router();
      addTearDown(router.dispose);

      await tester.pumpWidget(_app(repository, router, stickersEnabled: true));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _replaceComposerText(WidgetTester tester, String text) async {
  final editor = find.byKey(const Key('direct-message-composer-field'));
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.idle();
}

Widget _app(
  _FakeDirectMessageRepository repository,
  GoRouter router, {
  PublicUserRepository? publicUserRepository,
  bool stickersEnabled = false,
}) {
  return ProviderScope(
    overrides: [
      directMessagesEnabledProvider.overrideWithValue(true),
      stickersEnabledProvider.overrideWithValue(stickersEnabled),
      directMessageRepositoryProvider.overrideWithValue(repository),
      publicUserRepositoryProvider.overrideWithValue(
        publicUserRepository ?? _FakePublicUserRepository(),
      ),
      directConversationTargetControllerProvider.overrideWith((ref, userId) {
        return DirectConversationTargetController(
          userId,
          repository,
          ref.watch(publicUserRepositoryProvider),
          requestIdFactory: () => '00000000-0000-4000-8000-000000000001',
        );
      }),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/messages/new/user-2',
    routes: [
      GoRoute(
        path: '/messages/new/:userId',
        builder: (_, state) =>
            NewDirectConversationPage(userId: state.pathParameters['userId']!),
      ),
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

class _FakeDirectMessageRepository implements DirectMessageRepository {
  _FakeDirectMessageRepository({this.existingConversation});

  final DirectConversation? existingConversation;
  final List<DirectMessageDraft> createdDrafts = [];
  int lookupCalls = 0;

  @override
  Future<DirectConversationLookup> findByUser(String userId) async {
    lookupCalls += 1;
    return DirectConversationLookup(
      contactState: existingConversation == null
          ? DirectContactState.fresh
          : DirectContactState.accepted,
      canInitiate: existingConversation == null,
      conversation: existingConversation,
    );
  }

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) async {
    createdDrafts.add(draft);
    final conversation = _conversation(id: 'conversation-new');
    return DirectConversationStart(
      conversation: conversation,
      message: DirectMessage(
        id: 'message-new',
        conversationId: conversation.id,
        senderId: 'user-1',
        recipientId: recipientId,
        content: draft.content,
        createdAt: DateTime.utc(2026, 8, 10, 8),
      ),
    );
  }

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
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
  Future<DirectUnreadCounts> fetchUnreadCounts() => throw UnimplementedError();

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

class _FakePublicUserRepository implements PublicUserRepository {
  _FakePublicUserRepository({this.mutual = false});

  final bool mutual;

  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) =>
      throw UnimplementedError();

  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    return PublicUserProfileModel(
      id: userId,
      username: '小油',
      level: 3,
      followingCount: 0,
      followerCount: 0,
      receivedTipTotal: '0',
      receivedTipCount: 0,
      showRecentReplies: false,
      showPlayedThreads: false,
      showBookmarks: false,
      isFollowing: mutual,
      isFollowedBy: mutual,
      isBlocked: false,
      isBlockedBy: false,
      isDeactivated: false,
    );
  }

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchBookmarks(
    String userId, {
    String? cursor,
    int limit = 10,
  }) => throw UnimplementedError();

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchCreatedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) => throw UnimplementedError();

  @override
  Future<CursorPage<PublicUserThreadModel>> fetchPlayedThreads(
    String userId, {
    String? cursor,
    int limit = 10,
  }) => throw UnimplementedError();

  @override
  Future<List<PublicUserReplyModel>> fetchRecentReplies(String userId) =>
      throw UnimplementedError();
}

DirectConversation _conversation({required String id}) {
  return DirectConversation(
    id: id,
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: const DirectMessageUser(
      id: 'user-2',
      username: '小油',
      isDeactivated: false,
    ),
    unreadCount: 0,
    createdAt: DateTime.utc(2026, 8, 10),
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

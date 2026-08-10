import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/public_user_models.dart';

void main() {
  test('会话列表游标失效后从首屏重载且不保留重复项', () async {
    final repository = _FakeDirectMessageRepository();
    repository.listPages.add(
      CursorPage(
        items: [_conversation(id: 'conversation-1')],
        cursor: 'conversation-1',
        hasMore: true,
      ),
    );
    repository.listFailures.add(
      const ApiFailure(userMessage: '游标失效', businessCode: 40007),
    );
    repository.listPages.add(
      CursorPage(items: [_conversation(id: 'conversation-2')], hasMore: false),
    );
    final controller = DirectConversationListController(
      DirectConversationView.inbox,
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    await controller.loadMore();

    expect(controller.state.items.single.id, 'conversation-2');
    expect(repository.listCursors, [null, 'conversation-1', null]);
    expect(controller.state.hasMore, isFalse);
  });

  test('初始展示最后一条收到消息后标记已读并校准角标', () async {
    final repository = _FakeDirectMessageRepository(
      conversation: _conversation(unreadCount: 1),
      initialMessages: [_message(id: 'incoming-1', incoming: true)],
    );
    var unreadRefreshes = 0;
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
      onUnreadChanged: () async => unreadRefreshes++,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    await Future<void>.delayed(Duration.zero);

    expect(repository.markedReadIds, ['incoming-1']);
    expect(controller.state.conversation?.unreadCount, 0);
    expect(unreadRefreshes, 1);
  });

  test('消息不包含当前会话另一参与者时整页拒绝展示', () async {
    final repository = _FakeDirectMessageRepository(
      initialMessages: [
        DirectMessage(
          id: 'foreign-message',
          conversationId: 'conversation-1',
          senderId: 'user-3',
          recipientId: 'user-4',
          content: '不应显示',
          createdAt: _now,
        ),
      ],
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();

    expect(controller.state.phase, DirectConversationPhase.failed);
    expect(controller.state.messages, isEmpty);
    expect(controller.state.failure?.userMessage, contains('参与者'));
  });

  test('发送失败保留同一 clientRequestId，重试成功后才清草稿', () async {
    final repository = _FakeDirectMessageRepository(
      sendFailures: 1,
      initialMessages: [_message(id: 'incoming-1', incoming: true)],
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
      requestIdFactory: () => _requestId,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();

    expect(await controller.send(content: '  你好\r\n世界  '), isFalse);
    expect(controller.state.failedDraft?.clientRequestId, _requestId);
    expect(await controller.retrySend(), isTrue);

    expect(repository.sentDrafts, hasLength(2));
    expect(
      repository.sentDrafts.map((draft) => draft.clientRequestId).toSet(),
      {_requestId},
    );
    expect(repository.sentDrafts.last.content, '你好\n世界');
    expect(controller.state.failedDraft, isNull);
    expect(controller.state.messages.last.id, 'sent-1');
  });

  test('增量轮询按 after 合并新消息并对最新收到消息标记已读', () async {
    final repository = _FakeDirectMessageRepository(
      conversation: _conversation(unreadCount: 1),
      initialMessages: [_message(id: 'message-1', incoming: false)],
      incrementalMessages: [_message(id: 'message-2', incoming: true)],
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();

    await controller.pollLatest();
    await Future<void>.delayed(Duration.zero);

    expect(repository.afterAnchors, ['message-1']);
    expect(controller.state.messages.map((message) => message.id), [
      'message-1',
      'message-2',
    ]);
    expect(repository.markedReadIds, ['message-2']);
  });

  test('十分钟内撤回只替换目标消息，待处理首条撤回则取消会话', () async {
    final own = _message(id: 'message-1', incoming: false);
    final repository = _FakeDirectMessageRepository(initialMessages: [own]);
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();

    expect(
      await controller.recall(
        'message-1',
        now: own.createdAt.add(const Duration(minutes: 9)),
      ),
      isTrue,
    );
    expect(controller.state.messages.single.isRecalled, isTrue);

    repository.recallResult = const DirectRecallResult(
      conversationCanceled: true,
    );
    repository.initialMessages = [_message(id: 'message-2', incoming: false)];
    await controller.refresh();
    expect(
      await controller.recall(
        'message-2',
        now: _now.add(const Duration(minutes: 9)),
      ),
      isTrue,
    );
    expect(controller.state.conversationCanceled, isTrue);
    expect(controller.state.messages, isEmpty);
  });

  test('接受请求的邮箱错误保留会话，成功重试再切到可发送态', () async {
    final repository = _FakeDirectMessageRepository(
      conversation: _incomingRequest(),
      initialMessages: [_message(id: 'request-1', incoming: true)],
      handleFailures: 1,
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();

    expect(await controller.handleRequest(accept: true), isFalse);
    expect(controller.state.conversation?.isIncomingRequest, isTrue);
    expect(controller.state.transientFailure?.businessCode, 40107);
    expect(await controller.handleRequest(accept: true), isTrue);
    expect(controller.state.conversation?.canSend, isTrue);
  });

  test('发起私聊并发读取联系状态与用户，失败重试复用幂等键', () async {
    final repository = _FakeDirectMessageRepository(createFailures: 1);
    final userRepository = _FakePublicUserRepository();
    final controller = DirectConversationTargetController(
      'user-2',
      repository,
      userRepository,
      autoStart: false,
      requestIdFactory: () => _requestId,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.user?.username, '小油');
    expect(await controller.start(content: '你好'), isNull);
    final result = await controller.retryStart();

    expect(result?.conversation.id, 'conversation-1');
    expect(repository.createdDrafts, hasLength(2));
    expect(
      repository.createdDrafts.map((draft) => draft.clientRequestId).toSet(),
      {_requestId},
    );
  });
}

class _FakeDirectMessageRepository implements DirectMessageRepository {
  _FakeDirectMessageRepository({
    DirectConversation? conversation,
    List<DirectMessage>? initialMessages,
    this.incrementalMessages = const [],
    this.sendFailures = 0,
    this.createFailures = 0,
    this.handleFailures = 0,
  }) : conversation = conversation ?? _conversation(),
       initialMessages = initialMessages ?? [_message(id: 'message-1')];

  DirectConversation conversation;
  List<DirectMessage> initialMessages;
  final List<DirectMessage> incrementalMessages;
  int sendFailures;
  int createFailures;
  int handleFailures;
  DirectRecallResult recallResult = const DirectRecallResult(
    conversationCanceled: false,
  );
  final List<CursorPage<DirectConversation>> listPages = [];
  final List<ApiFailure> listFailures = [];
  final List<String?> listCursors = [];
  final List<String> afterAnchors = [];
  final List<String> markedReadIds = [];
  final List<DirectMessageDraft> sentDrafts = [];
  final List<DirectMessageDraft> createdDrafts = [];

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) async {
    listCursors.add(cursor);
    if (listFailures.isNotEmpty && listCursors.length == 2) {
      throw listFailures.removeAt(0);
    }
    return listPages.removeAt(0);
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    return const DirectUnreadCounts(unreadMessages: 1, pendingRequests: 0);
  }

  @override
  Future<DirectConversationLookup> findByUser(String userId) async {
    return const DirectConversationLookup(
      contactState: DirectContactState.fresh,
      canInitiate: true,
    );
  }

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) async {
    createdDrafts.add(draft);
    if (createFailures > 0) {
      createFailures--;
      throw const ApiFailure(
        userMessage: '超时，请重试',
        requestId: 'create-request',
      );
    }
    return DirectConversationStart(
      conversation: conversation,
      message: _message(id: 'created-1', incoming: false),
    );
  }

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
    if (after != null) {
      afterAnchors.add(after);
      return CursorPage(items: incrementalMessages, hasMore: false);
    }
    return CursorPage(items: initialMessages, hasMore: false);
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) async {
    sentDrafts.add(draft);
    if (sendFailures > 0) {
      sendFailures--;
      throw const ApiFailure(
        userMessage: '连接超时，请使用原请求重试',
        requestId: 'send-request',
      );
    }
    return _message(id: 'sent-1', incoming: false, content: draft.content);
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    if (handleFailures > 0) {
      handleFailures--;
      throw const ApiFailure(userMessage: '请先完成邮箱验证。', businessCode: 40107);
    }
    conversation = _conversation();
    return conversation;
  }

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) async {
    conversation = conversation.copyWith(archivedAt: archived ? _now : null);
    return conversation;
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) async {
    markedReadIds.add(throughMessageId);
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async => recallResult;
}

class _FakePublicUserRepository implements PublicUserRepository {
  @override
  Future<PublicUserProfileModel> fetchUser(String userId) async {
    return PublicUserProfileModel(
      id: userId,
      username: '小油',
      level: 2,
      followingCount: 0,
      followerCount: 0,
      receivedTipTotal: '0',
      receivedTipCount: 0,
      showRecentReplies: false,
      showPlayedThreads: false,
      showBookmarks: false,
      isFollowing: false,
      isFollowedBy: false,
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

const _requestId = '123e4567-e89b-42d3-a456-426614174000';
final _now = DateTime.utc(2026, 8, 10, 8);

DirectMessageUser _otherUser() {
  return const DirectMessageUser(
    id: 'user-2',
    username: '小油',
    isDeactivated: false,
  );
}

DirectConversation _conversation({
  String id = 'conversation-1',
  int unreadCount = 0,
}) {
  return DirectConversation(
    id: id,
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: _otherUser(),
    unreadCount: unreadCount,
    createdAt: _now.subtract(const Duration(days: 1)),
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
    otherUser: _otherUser(),
    unreadCount: 0,
    createdAt: _now.subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: true,
    canDecline: true,
    isBlocked: false,
  );
}

DirectMessage _message({
  required String id,
  bool incoming = true,
  String? content = '你好',
}) {
  final minute = switch (id) {
    'message-1' || 'incoming-1' || 'request-1' => 0,
    'message-2' => 1,
    'sent-1' || 'created-1' => 10,
    _ => 2,
  };
  return DirectMessage(
    id: id,
    conversationId: 'conversation-1',
    senderId: incoming ? 'user-2' : 'user-1',
    recipientId: incoming ? 'user-1' : 'user-2',
    content: content,
    createdAt: _now.add(Duration(minutes: minute)),
  );
}

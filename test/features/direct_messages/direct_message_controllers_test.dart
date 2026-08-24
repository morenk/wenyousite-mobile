import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
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
    expect(controller.state.failure?.userMessage, contains('会话成员'));
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

  test('发送立即插入乐观消息且等待网络时不锁定会话', () async {
    final completion = Completer<DirectMessage>();
    final repository = _FakeDirectMessageRepository(
      initialMessages: [_message(id: 'message-1', incoming: true)],
      sendCompletions: [completion],
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

    final result = controller.send(content: '立即显示');

    expect(controller.state.isMutating, isFalse);
    expect(controller.state.messages.last.id, 'optimistic:$_requestId');
    expect(
      controller.state.messages.last.deliveryState,
      DirectMessageDeliveryState.sending,
    );
    completion.complete(
      _message(id: 'server-1', incoming: false, content: '立即显示'),
    );
    expect(await result, isTrue);
    expect(controller.state.messages.map((message) => message.id), [
      'message-1',
      'server-1',
    ]);
  });

  test('图片点发送后立即插入本地气泡，上传完成后再提交同一幂等请求', () async {
    final upload = Completer<UploadedEditorImage>();
    final gateway = _PendingUploadGateway(upload);
    final repository = _FakeDirectMessageRepository();
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
      requestIdFactory: () => _requestId,
      mediaUploadGateway: gateway,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final input = MediaUploadInput(
      filename: 'local.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [1, 2, 3]),
    );

    final result = controller.send(content: '本地图片', mediaInput: input);

    final optimistic = controller.state.messages.last;
    expect(optimistic.id, 'optimistic:$_requestId');
    expect(optimistic.content, '本地图片');
    expect(
      controller.state.pendingMedia[optimistic.id]?.input.bytes,
      input.bytes,
    );
    expect(repository.sentDrafts, isEmpty);
    expect(gateway.input?.purpose, MediaUploadPurpose.directMessage);

    upload.complete(
      const UploadedEditorImage(
        mediaId: 'uploaded-media',
        url: 'https://cdn.example.com/uploaded.webp',
      ),
    );
    expect(await result, isTrue);
    expect(repository.sentDrafts.single.clientRequestId, _requestId);
    expect(repository.sentDrafts.single.mediaId, 'uploaded-media');
    expect(controller.state.pendingMedia, isEmpty);
  });

  test('失败消息就地保留且不阻止新消息，重试复用原幂等键', () async {
    var requestIndex = 0;
    const requestIds = [_requestId, '223e4567-e89b-42d3-a456-426614174001'];
    final repository = _FakeDirectMessageRepository(
      sendFailures: 1,
      initialMessages: [_message(id: 'message-1', incoming: true)],
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
      requestIdFactory: () => requestIds[requestIndex++],
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();

    expect(await controller.send(content: '第一条'), isFalse);
    final failed = controller.state.messages.last;
    expect(failed.deliveryState, DirectMessageDeliveryState.failed);
    expect(controller.state.sendFailures, contains(failed.id));

    expect(await controller.send(content: '第二条'), isTrue);
    expect(
      controller.state.messages.any(
        (message) =>
            message.id == failed.id &&
            message.deliveryState == DirectMessageDeliveryState.failed,
      ),
      isTrue,
    );
    expect(await controller.retryMessage(failed.id), isTrue);
    expect(repository.sentDrafts.map((draft) => draft.clientRequestId), [
      _requestId,
      requestIds[1],
      _requestId,
    ]);
    expect(
      controller.state.messages.any((message) => message.isOptimistic),
      isFalse,
    );
    expect(controller.state.sendFailures, isEmpty);
  });

  test('乐观消息不作为增量轮询 after 锚点', () async {
    final completion = Completer<DirectMessage>();
    final repository = _FakeDirectMessageRepository(
      initialMessages: [_message(id: 'message-1', incoming: false)],
      sendCompletions: [completion],
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

    final sendResult = controller.send(content: '等待确认');
    await controller.pollLatest();

    expect(repository.afterAnchors, ['message-1']);
    completion.complete(
      _message(id: 'server-1', incoming: false, content: '等待确认'),
    );
    expect(await sendResult, isTrue);
  });

  test('最近窗口刷新保留已加载历史和本地失败消息', () async {
    final older = _message(id: 'older-1', incoming: true);
    final latest = _message(id: 'message-1', incoming: false);
    final repository = _FakeDirectMessageRepository(
      initialMessages: [older, latest],
      sendFailures: 1,
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
    expect(await controller.send(content: '未发送'), isFalse);
    repository.initialMessages = [latest];

    await controller.refresh();

    expect(
      controller.state.messages.map((message) => message.id),
      contains('older-1'),
    );
    expect(
      controller.state.messages.any(
        (message) =>
            message.id == 'optimistic:$_requestId' &&
            message.deliveryState == DirectMessageDeliveryState.failed,
      ),
      isTrue,
    );
  });

  test('暂停轮询忽略请求，恢复后立即增量同步', () async {
    final repository = _FakeDirectMessageRepository(
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

    controller.pausePolling();
    await controller.pollLatest();
    expect(repository.afterAnchors, isEmpty);

    controller.resumePolling();
    await Future<void>.delayed(Duration.zero);
    expect(repository.afterAnchors, ['message-1']);
    expect(controller.state.messages.last.id, 'message-2');
  });

  test('活跃会话未读为零时增量收到新消息仍标记已读', () async {
    final repository = _FakeDirectMessageRepository(
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

    expect(repository.markedReadIds, ['message-2']);
  });

  test('已读请求在途时收到更新消息会在完成后继续追赶', () async {
    final firstMark = Completer<void>();
    final repository = _FakeDirectMessageRepository(
      conversation: _conversation(unreadCount: 1),
      initialMessages: [_message(id: 'incoming-1', incoming: true)],
      markReadCompletions: [firstMark],
    );
    final controller = DirectConversationController(
      'conversation-1',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);

    await controller.loadInitial();
    expect(repository.markedReadIds, ['incoming-1']);
    repository.incrementalMessages = [
      _message(id: 'message-2', incoming: true),
    ];
    await controller.pollLatest();
    expect(repository.markedReadIds, ['incoming-1']);

    firstMark.complete();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(repository.markedReadIds, ['incoming-1', 'message-2']);
  });

  test('发送与刷新交错时保留并完成乐观消息', () async {
    final sendCompletion = Completer<DirectMessage>();
    final refreshCompletion = Completer<CursorPage<DirectMessage>>();
    final repository = _FakeDirectMessageRepository(
      initialMessages: [_message(id: 'message-1', incoming: false)],
      sendCompletions: [sendCompletion],
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
    repository.fetchMessageCompletions = [refreshCompletion];

    final refreshResult = controller.refresh();
    final sendResult = controller.send(content: '交错消息');
    refreshCompletion.complete(
      CursorPage(
        items: [_message(id: 'message-1', incoming: false)],
        hasMore: false,
      ),
    );
    await refreshResult;
    expect(
      controller.state.messages.last.deliveryState,
      DirectMessageDeliveryState.sending,
    );

    sendCompletion.complete(
      _message(id: 'server-1', incoming: false, content: '交错消息'),
    );
    expect(await sendResult, isTrue);
    expect(controller.state.messages.map((message) => message.id), [
      'message-1',
      'server-1',
    ]);
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

  test('接受请求失败保留会话，成功重试再切到可发送态', () async {
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
    expect(controller.state.transientFailure?.userMessage, '请求暂时没有完成。');
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
    this.sendCompletions = const [],
    this.markReadCompletions = const [],
  }) : conversation = conversation ?? _conversation(),
       initialMessages = initialMessages ?? [_message(id: 'message-1')];

  DirectConversation conversation;
  List<DirectMessage> initialMessages;
  List<DirectMessage> incrementalMessages;
  int sendFailures;
  int createFailures;
  int handleFailures;
  int sendSuccesses = 0;
  final List<Completer<DirectMessage>> sendCompletions;
  List<Completer<CursorPage<DirectMessage>>> fetchMessageCompletions = [];
  final List<Completer<void>> markReadCompletions;
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
    if (fetchMessageCompletions.isNotEmpty) {
      return fetchMessageCompletions.removeAt(0).future;
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
    if (sendCompletions.isNotEmpty) {
      return sendCompletions.removeAt(0).future;
    }
    return _message(
      id: 'sent-${++sendSuccesses}',
      incoming: false,
      content: draft.content,
    );
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    if (handleFailures > 0) {
      handleFailures--;
      throw const ApiFailure(userMessage: '请求暂时没有完成。');
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
    if (markReadCompletions.isNotEmpty) {
      await markReadCompletions.removeAt(0).future;
    }
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async => recallResult;
}

class _FakePublicUserRepository implements PublicUserRepository {
  @override
  Future<PublicUserActivitySummary> fetchActivitySummary(String userId) =>
      throw UnimplementedError();

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

class _PendingUploadGateway implements MediaUploadGateway {
  _PendingUploadGateway(this.completion);

  final Completer<UploadedEditorImage> completion;
  MediaUploadInput? input;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    this.input = input;
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 1,
        totalBytes: input.bytes.length,
      ),
    );
    return _PendingUploadOperation(completion.future);
  }
}

class _PendingUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  const _PendingUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
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

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      CreateDirectConversationDto(
        (builder) => builder
          ..recipientId = 'user-2'
          ..content = '你好'
          ..clientRequestId = _requestId,
      ),
    );
    registerFallbackValue(
      CreateDirectMessageDto(
        (builder) => builder
          ..content = '你好'
          ..clientRequestId = _requestId,
      ),
    );
    registerFallbackValue(
      HandleDirectRequestDto(
        (builder) => builder.action = HandleDirectRequestDtoActionEnum.ACCEPT,
      ),
    );
    registerFallbackValue(
      SetDirectConversationArchiveDto((builder) => builder.archived = true),
    );
    registerFallbackValue(
      MarkDirectConversationReadDto(
        (builder) => builder.throughMessageId = 'message-1',
      ),
    );
  });

  test('三类列表、未读、联系状态、详情和消息分页精确读取', () async {
    final api = _MockDirectMessagesApi();
    when(
      () => api.directConversationsFindAll(
        view: 'REQUESTS',
        cursor: 'conversation-before',
        limit: 20,
      ),
    ).thenAnswer((_) async => _conversationListResponse());
    when(
      api.directConversationsUnread,
    ).thenAnswer((_) async => _unreadResponse());
    when(
      () => api.directConversationsFindByUser(userId: 'user-2'),
    ).thenAnswer((_) async => _lookupResponse());
    when(
      () => api.directConversationsFindById(id: 'conversation-1'),
    ).thenAnswer((_) async => _conversationResponse());
    when(
      () => api.directConversationsMessages(
        id: 'conversation-1',
        after: 'message-before',
        limit: 30,
      ),
    ).thenAnswer((_) async => _messagesResponse());
    final repository = ApiDirectMessageRepository(api);

    final list = await repository.fetchConversations(
      view: DirectConversationView.requests,
      cursor: 'conversation-before',
    );
    final unread = await repository.fetchUnreadCounts();
    final lookup = await repository.findByUser('user-2');
    final conversation = await repository.fetchConversation('conversation-1');
    final messages = await repository.fetchMessages(
      conversationId: 'conversation-1',
      after: 'message-before',
    );

    expect(list.items.single.id, 'conversation-1');
    expect(unread.total, 3);
    expect(lookup.contactState, DirectContactState.accepted);
    expect(conversation.otherUser.username, '小油');
    expect(messages.items.single.content, '你好');
  });

  test('创建、发送、处理请求、归档、已读和撤回使用生成 DTO', () async {
    final api = _MockDirectMessagesApi();
    when(
      () => api.directConversationsCreate(
        createDirectConversationDto: any(named: 'createDirectConversationDto'),
      ),
    ).thenAnswer((_) async => _createResponse());
    when(
      () => api.directConversationsSend(
        id: 'conversation-1',
        createDirectMessageDto: any(named: 'createDirectMessageDto'),
      ),
    ).thenAnswer((_) async => _sendResponse());
    when(
      () => api.directConversationsHandleRequest(
        id: 'conversation-1',
        handleDirectRequestDto: any(named: 'handleDirectRequestDto'),
      ),
    ).thenAnswer((_) async => _handleResponse());
    when(
      () => api.directConversationsArchive(
        id: 'conversation-1',
        setDirectConversationArchiveDto: any(
          named: 'setDirectConversationArchiveDto',
        ),
      ),
    ).thenAnswer((_) async => _archiveResponse());
    when(
      () => api.directConversationsMarkRead(
        id: 'conversation-1',
        markDirectConversationReadDto: any(
          named: 'markDirectConversationReadDto',
        ),
      ),
    ).thenAnswer((_) async => _markReadResponse());
    when(
      () => api.directMessagesRecall(id: 'message-1'),
    ).thenAnswer((_) async => _recallResponse());
    final repository = ApiDirectMessageRepository(api);
    final draft = DirectMessageDraft.normalized(
      clientRequestId: _requestId,
      content: '  你好\r\n世界  ',
      mediaId: 'media-1',
    );

    final created = await repository.createConversation(
      recipientId: 'user-2',
      draft: draft,
    );
    final sent = await repository.sendMessage(
      conversationId: 'conversation-1',
      draft: draft,
    );
    final accepted = await repository.handleRequest(
      conversationId: 'conversation-1',
      accept: true,
    );
    final archived = await repository.setArchived(
      conversationId: 'conversation-1',
      archived: true,
    );
    await repository.markRead(
      conversationId: 'conversation-1',
      throughMessageId: 'message-1',
    );
    final recalled = await repository.recall('message-1');

    expect(created.conversation.id, 'conversation-1');
    expect(sent.id, 'message-1');
    expect(accepted.status, DirectConversationStatus.accepted);
    expect(archived.archivedAt, isNotNull);
    expect(recalled.conversationCanceled, isFalse);

    final createPayload =
        verify(
              () => api.directConversationsCreate(
                createDirectConversationDto: captureAny(
                  named: 'createDirectConversationDto',
                ),
              ),
            ).captured.single
            as CreateDirectConversationDto;
    final sendPayload =
        verify(
              () => api.directConversationsSend(
                id: 'conversation-1',
                createDirectMessageDto: captureAny(
                  named: 'createDirectMessageDto',
                ),
              ),
            ).captured.single
            as CreateDirectMessageDto;
    final actionPayload =
        verify(
              () => api.directConversationsHandleRequest(
                id: 'conversation-1',
                handleDirectRequestDto: captureAny(
                  named: 'handleDirectRequestDto',
                ),
              ),
            ).captured.single
            as HandleDirectRequestDto;
    final archivePayload =
        verify(
              () => api.directConversationsArchive(
                id: 'conversation-1',
                setDirectConversationArchiveDto: captureAny(
                  named: 'setDirectConversationArchiveDto',
                ),
              ),
            ).captured.single
            as SetDirectConversationArchiveDto;
    final readPayload =
        verify(
              () => api.directConversationsMarkRead(
                id: 'conversation-1',
                markDirectConversationReadDto: captureAny(
                  named: 'markDirectConversationReadDto',
                ),
              ),
            ).captured.single
            as MarkDirectConversationReadDto;
    expect(createPayload.recipientId, 'user-2');
    expect(createPayload.content, '你好\n世界');
    expect(createPayload.mediaId, 'media-1');
    expect(createPayload.clientRequestId, _requestId);
    expect(sendPayload.clientRequestId, _requestId);
    expect(actionPayload.action, HandleDirectRequestDtoActionEnum.ACCEPT);
    expect(archivePayload.archived, isTrue);
    expect(readPayload.throughMessageId, 'message-1');
  });

  test('未读总数与分项不一致时拒绝伪造角标', () async {
    final api = _MockDirectMessagesApi();
    when(
      api.directConversationsUnread,
    ).thenAnswer((_) async => _unreadResponse(total: 99));

    await expectLater(
      ApiDirectMessageRepository(api).fetchUnreadCounts(),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('互动受限时允许后端同时返回既有会话供安全状态展示', () async {
    final api = _MockDirectMessagesApi();
    when(() => api.directConversationsFindByUser(userId: 'user-2')).thenAnswer(
      (_) async => _lookupResponse(
        contactState:
            DirectConversationLookupResponseDtoContactStateEnum.UNAVAILABLE,
        canInitiate: false,
      ),
    );

    final result = await ApiDirectMessageRepository(api).findByUser('user-2');

    expect(result.contactState, DirectContactState.unavailable);
    expect(result.canInitiate, isFalse);
    expect(result.conversation?.id, 'conversation-1');
  });

  test('消息所属会话不匹配或撤回后仍泄漏正文时拒绝展示', () async {
    final api = _MockDirectMessagesApi();
    when(
      () => api.directConversationsMessages(id: 'conversation-1', limit: 30),
    ).thenAnswer(
      (_) async => _messagesResponse(
        message: _messageDto(conversationId: 'other-conversation'),
      ),
    );
    final repository = ApiDirectMessageRepository(api);

    await expectLater(
      repository.fetchMessages(conversationId: 'conversation-1'),
      throwsA(isA<ApiFailure>()),
    );

    when(
      () => api.directConversationsMessages(id: 'conversation-1', limit: 30),
    ).thenAnswer(
      (_) async => _messagesResponse(
        message: _messageDto(recalledAt: _now, content: '不应泄漏'),
      ),
    );
    await expectLater(
      repository.fetchMessages(conversationId: 'conversation-1'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('发送空响应保留为不明确失败而非伪装成功', () async {
    final api = _MockDirectMessagesApi();
    when(
      () => api.directConversationsSend(
        id: 'conversation-1',
        createDirectMessageDto: any(named: 'createDirectMessageDto'),
      ),
    ).thenAnswer(
      (_) async => Response<DirectConversationsSend201Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/direct-conversations/conversation-1/messages',
        ),
      ),
    );

    await expectLater(
      ApiDirectMessageRepository(api).sendMessage(
        conversationId: 'conversation-1',
        draft: DirectMessageDraft.normalized(
          clientRequestId: _requestId,
          content: '你好',
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('表情消息优先于兼容 media 且要求相同资产 ID', () async {
    final api = _MockDirectMessagesApi();
    when(
      () => api.directConversationsMessages(id: 'conversation-1', limit: 30),
    ).thenAnswer((_) async => _messagesResponse(message: _stickerMessageDto()));
    final repository = ApiDirectMessageRepository(api);

    final page = await repository.fetchMessages(
      conversationId: 'conversation-1',
    );

    expect(page.items.single.media?.isSticker, isTrue);
    expect(page.items.single.media?.animated, isTrue);
  });
}

class _MockDirectMessagesApi extends Mock implements DirectMessagesApi {}

const _requestId = '123e4567-e89b-42d3-a456-426614174000';
final _now = DateTime.utc(2026, 8, 10, 8);

DirectMessageUserResponseDto _userDto() {
  return DirectMessageUserResponseDto(
    (builder) => builder
      ..id = 'user-2'
      ..username = '小油'
      ..avatar = 'https://cdn.wenyou.site/avatar.png'
      ..isDeactivated = false,
  );
}

DirectMessagePreviewResponseDto _previewDto() {
  return DirectMessagePreviewResponseDto(
    (builder) => builder
      ..id = 'message-1'
      ..senderId = 'user-1'
      ..contentPreview = '你好'
      ..hasImage = false
      ..hasSticker = false
      ..isRecalled = false
      ..createdAt = _now,
  );
}

DirectConversationResponseDto _conversationDto({
  DirectConversationResponseDtoStatusEnum status =
      DirectConversationResponseDtoStatusEnum.ACCEPTED,
  DirectConversationResponseDtoRequestDirectionEnum direction =
      DirectConversationResponseDtoRequestDirectionEnum.NONE,
  int unread = 2,
  bool archived = false,
}) {
  return DirectConversationResponseDto((builder) {
    builder
      ..id = 'conversation-1'
      ..status = status
      ..requestDirection = direction
      ..otherUser.replace(_userDto())
      ..lastMessage.replace(_previewDto())
      ..unreadCount = status == DirectConversationResponseDtoStatusEnum.ACCEPTED
          ? unread
          : 0
      ..lastMessageAt = _now
      ..createdAt = _now.subtract(const Duration(days: 1))
      ..canSend = status == DirectConversationResponseDtoStatusEnum.ACCEPTED
      ..canAccept =
          status == DirectConversationResponseDtoStatusEnum.PENDING &&
          direction ==
              DirectConversationResponseDtoRequestDirectionEnum.INCOMING
      ..canDecline =
          status == DirectConversationResponseDtoStatusEnum.PENDING &&
          direction ==
              DirectConversationResponseDtoRequestDirectionEnum.INCOMING
      ..isBlocked = false;
    if (archived) builder.archivedAt = _now;
  });
}

DirectMessageResponseDto _messageDto({
  String conversationId = 'conversation-1',
  String? content = '你好',
  DateTime? recalledAt,
}) {
  return DirectMessageResponseDto((builder) {
    builder
      ..id = 'message-1'
      ..conversationId = conversationId
      ..senderId = 'user-1'
      ..recipientId = 'user-2'
      ..createdAt = _now;
    if (content != null) builder.content = content;
    if (recalledAt != null) builder.recalledAt = recalledAt;
  });
}

DirectMessageResponseDto _stickerMessageDto() {
  final sticker = DirectMessageStickerResponseDto(
    (builder) => builder
      ..id = 'sticker-1'
      ..url = 'https://cdn.wenyou.site/sticker.gif'
      ..thumbnailUrl = 'https://cdn.wenyou.site/sticker-thumb.png'
      ..animated = true
      ..frameCount = 12
      ..durationMs = 800,
  );
  final media = DirectMessageMediaResponseDto(
    (builder) => builder
      ..id = 'sticker-1'
      ..url = 'https://cdn.wenyou.site/sticker.gif'
      ..thumbnailUrl = 'https://cdn.wenyou.site/sticker-thumb.png',
  );
  return DirectMessageResponseDto(
    (builder) => builder
      ..id = 'message-1'
      ..conversationId = 'conversation-1'
      ..senderId = 'user-1'
      ..recipientId = 'user-2'
      ..media.replace(media)
      ..sticker.replace(sticker)
      ..createdAt = _now,
  );
}

Response<DirectConversationsFindAll200Response> _conversationListResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/direct-conversations'),
    data: DirectConversationsFindAll200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta.hasMore = false)
        ..data.add(_conversationDto()),
    ),
  );
}

Response<DirectConversationsUnread200Response> _unreadResponse({
  int total = 3,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/direct-conversations/unread'),
    data: DirectConversationsUnread200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..unreadMessageCount = 2
            ..pendingRequestCount = 1
            ..total = total,
        ),
    ),
  );
}

Response<DirectConversationsFindByUser200Response> _lookupResponse({
  DirectConversationLookupResponseDtoContactStateEnum contactState =
      DirectConversationLookupResponseDtoContactStateEnum.ACCEPTED,
  bool canInitiate = true,
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/by-user/user-2',
    ),
    data: DirectConversationsFindByUser200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..contactState = contactState
            ..canInitiate = canInitiate
            ..conversation.replace(_conversationDto()),
        ),
    ),
  );
}

Response<DirectConversationsFindById200Response> _conversationResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1',
    ),
    data: DirectConversationsFindById200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_conversationDto()),
    ),
  );
}

Response<DirectConversationsMessages200Response> _messagesResponse({
  DirectMessageResponseDto? message,
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1/messages',
    ),
    data: DirectConversationsMessages200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta.hasMore = false)
        ..data.add(message ?? _messageDto()),
    ),
  );
}

Response<DirectConversationsCreate201Response> _createResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/direct-conversations'),
    data: DirectConversationsCreate201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..conversation.replace(_conversationDto())
            ..message.replace(_messageDto()),
        ),
    ),
  );
}

Response<DirectConversationsSend201Response> _sendResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1/messages',
    ),
    data: DirectConversationsSend201Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_messageDto()),
    ),
  );
}

Response<DirectConversationsHandleRequest200Response> _handleResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1/request',
    ),
    data: DirectConversationsHandleRequest200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_conversationDto()),
    ),
  );
}

Response<DirectConversationsArchive200Response> _archiveResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1/archive',
    ),
    data: DirectConversationsArchive200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_conversationDto(archived: true)),
    ),
  );
}

Response<DirectConversationsMarkRead200Response> _markReadResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/direct-conversations/conversation-1/read',
    ),
    data: DirectConversationsMarkRead200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已标记为已读'),
    ),
  );
}

Response<DirectMessagesRecall200Response> _recallResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/direct-messages/message-1'),
    data: DirectMessagesRecall200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..message = '消息已撤回'
            ..conversationCanceled = false,
        ),
    ),
  );
}

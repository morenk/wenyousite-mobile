import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_failure_messages.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

export 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart'
    show DirectMessageRepository, directMessageRepositoryProvider;

class ApiDirectMessageRepository implements DirectMessageRepository {
  ApiDirectMessageRepository(this._api);

  final DirectMessagesApi _api;

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final envelope = (await _api.directConversationsFindAll(
        view: view.wireValue,
        cursor: cursor,
        limit: limit.clamp(1, 50),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '私聊会话加载失败，请稍后重试。');
      }
      return _conversationPage(
        envelope.data,
        cursor: envelope.meta.cursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    try {
      final dto = (await _api.directConversationsUnread()).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '私聊未读数加载失败，请稍后重试。');
      }
      final unread = _nonNegativeInteger(dto.unreadMessageCount, '未读消息数');
      final pending = _nonNegativeInteger(dto.pendingRequestCount, '消息请求数');
      final total = _nonNegativeInteger(dto.total, '私聊总未读数');
      if (total != unread + pending) {
        throw const ApiFailure(userMessage: '私聊未读数不一致，请重新加载。');
      }
      return DirectUnreadCounts(
        unreadMessages: unread,
        pendingRequests: pending,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectConversationLookup> findByUser(String userId) async {
    final targetId = _requiredText(userId, '目标用户 ID');
    try {
      final dto = (await _api.directConversationsFindByUser(
        userId: targetId,
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '联系状态加载失败，请稍后重试。');
      }
      final state = _contactState(dto.contactState);
      final conversation = dto.conversation == null
          ? null
          : _conversation(dto.conversation!);
      if (conversation != null && conversation.otherUser.id != targetId) {
        throw const ApiFailure(userMessage: '私聊对象已经发生变化，请重新打开。');
      }
      if (state == DirectContactState.fresh && conversation != null) {
        throw const ApiFailure(userMessage: '联系状态与会话信息不一致，请重新加载。');
      }
      if (state != DirectContactState.fresh &&
          state != DirectContactState.unavailable &&
          state != DirectContactState.unknown &&
          conversation == null) {
        throw const ApiFailure(userMessage: '联系状态缺少对应会话，请重新加载。');
      }
      return DirectConversationLookup(
        contactState: state,
        canInitiate: dto.canInitiate,
        conversation: conversation,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) async {
    final targetId = _requiredText(recipientId, '接收用户 ID');
    _validateDraft(draft);
    try {
      final dto = (await _api.directConversationsCreate(
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createDirectConversationDto: CreateDirectConversationDto((builder) {
          builder
            ..recipientId = targetId
            ..clientRequestId = draft.clientRequestId;
          if (draft.content != null) builder.content = draft.content;
          if (draft.mediaId != null) builder.mediaId = draft.mediaId;
          if (draft.stickerAssetId != null) {
            builder.stickerAssetId = draft.stickerAssetId;
          }
        }),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '首条消息失败，请重试。');
      }
      final conversation = _conversation(dto.conversation);
      final message = _message(dto.message);
      _validateSentTarget(
        conversation: conversation,
        message: message,
        targetUserId: targetId,
      );
      return DirectConversationStart(
        conversation: conversation,
        message: message,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectConversation> fetchConversation(String conversationId) async {
    final id = _requiredText(conversationId, '会话 ID');
    try {
      final dto = (await _api.directConversationsFindById(id: id)).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '私聊会话加载失败，请稍后重试。');
      }
      final conversation = _conversation(dto);
      if (conversation.id != id) {
        throw const ApiFailure(userMessage: '私聊会话已经发生变化，请重新打开。');
      }
      return conversation;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) async {
    final id = _requiredText(conversationId, '会话 ID');
    if (cursor != null && after != null) {
      throw const ApiFailure(userMessage: '不能同时加载历史消息和增量消息。');
    }
    try {
      final envelope = (await _api.directConversationsMessages(
        id: id,
        cursor: cursor,
        after: after,
        limit: limit.clamp(1, 50),
      )).data;
      if (envelope == null) {
        throw const ApiFailure(userMessage: '私聊消息加载失败，请稍后重试。');
      }
      final ids = <String>{};
      final items = envelope.data
          .map((dto) {
            final message = _message(dto);
            if (message.conversationId != id) {
              throw const ApiFailure(userMessage: '消息不属于当前会话，请重新加载。');
            }
            if (!ids.add(message.id)) {
              throw const ApiFailure(userMessage: '私聊消息暂时无法显示，请重新加载。');
            }
            return message;
          })
          .toList(growable: false);
      for (var index = 1; index < items.length; index++) {
        if (_compareMessages(items[index - 1], items[index]) > 0) {
          throw const ApiFailure(userMessage: '私聊消息暂时无法显示，请重新加载。');
        }
      }
      final pageCursor = _pageCursor(
        envelope.meta.cursor,
        envelope.meta.hasMore,
      );
      return CursorPage(
        items: List.unmodifiable(items),
        cursor: pageCursor,
        hasMore: envelope.meta.hasMore,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) async {
    final id = _requiredText(conversationId, '会话 ID');
    _validateDraft(draft);
    try {
      final dto = (await _api.directConversationsSend(
        id: id,
        extra: ApiRequestPolicy.idempotentCreate.extra,
        createDirectMessageDto: CreateDirectMessageDto((builder) {
          builder.clientRequestId = draft.clientRequestId;
          if (draft.content != null) builder.content = draft.content;
          if (draft.mediaId != null) builder.mediaId = draft.mediaId;
          if (draft.stickerAssetId != null) {
            builder.stickerAssetId = draft.stickerAssetId;
          }
        }),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '发送失败，请重试。');
      }
      final message = _message(dto);
      if (message.conversationId != id) {
        throw const ApiFailure(userMessage: '私聊消息已经发生变化，请重新加载。');
      }
      return message;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    final id = _requiredText(conversationId, '会话 ID');
    try {
      final dto = (await _api.directConversationsHandleRequest(
        id: id,
        handleDirectRequestDto: HandleDirectRequestDto(
          (builder) => builder.action = accept
              ? HandleDirectRequestDtoActionEnum.ACCEPT
              : HandleDirectRequestDtoActionEnum.DECLINE,
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '消息请求失败，请重新加载。');
      }
      final result = _conversation(dto);
      if (result.id != id ||
          result.status !=
              (accept
                  ? DirectConversationStatus.accepted
                  : DirectConversationStatus.declined)) {
        throw const ApiFailure(userMessage: '消息请求已经发生变化，请重新加载。');
      }
      return result;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) async {
    final id = _requiredText(conversationId, '会话 ID');
    try {
      final dto = (await _api.directConversationsArchive(
        id: id,
        setDirectConversationArchiveDto: SetDirectConversationArchiveDto(
          (builder) => builder.archived = archived,
        ),
      )).data?.data;
      if (dto == null) {
        throw const ApiFailure(userMessage: '归档失败，请重新加载。');
      }
      final result = _conversation(dto);
      if (result.id != id || (result.archivedAt != null) != archived) {
        throw const ApiFailure(userMessage: '会话归档状态已经发生变化，请重新加载。');
      }
      return result;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) async {
    final id = _requiredText(conversationId, '会话 ID');
    final messageId = _requiredText(throughMessageId, '已读消息 ID');
    try {
      final result = (await _api.directConversationsMarkRead(
        id: id,
        markDirectConversationReadDto: MarkDirectConversationReadDto(
          (builder) => builder.throughMessageId = messageId,
        ),
      )).data?.data;
      if (result == null || result.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '已读状态更新失败，请重新加载。');
      }
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async {
    final id = _requiredText(messageId, '消息 ID');
    try {
      final result = (await _api.directMessagesRecall(id: id)).data?.data;
      if (result == null || result.message.trim().isEmpty) {
        throw const ApiFailure(userMessage: '撤回失败，请重新加载。');
      }
      return DirectRecallResult(
        conversationCanceled: result.conversationCanceled,
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(
        error,
        featureMessages: directMessageFailureMessages,
      );
    }
  }

  CursorPage<DirectConversation> _conversationPage(
    Iterable<DirectConversationResponseDto> values, {
    required String? cursor,
    required bool hasMore,
  }) {
    final ids = <String>{};
    final items = values
        .map((dto) {
          final item = _conversation(dto);
          if (!ids.add(item.id)) {
            _contractViolation('DM_DUPLICATE_CONVERSATION');
          }
          return item;
        })
        .toList(growable: false);
    return CursorPage(
      items: List.unmodifiable(items),
      cursor: _pageCursor(cursor, hasMore),
      hasMore: hasMore,
    );
  }

  DirectConversation _conversation(DirectConversationResponseDto dto) {
    final id = _requiredText(dto.id, '会话 ID');
    final status = _status(dto.status);
    final direction = _direction(dto.requestDirection);
    final user = _user(dto.otherUser);
    final unread = _nonNegativeInteger(dto.unreadCount, '会话未读数');
    if (status != DirectConversationStatus.accepted && unread != 0) {
      _contractViolation('DM_REQUEST_UNREAD_COUNT');
    }
    if (status == DirectConversationStatus.pending &&
        direction == DirectRequestDirection.none) {
      _contractViolation('DM_REQUEST_DIRECTION_MISSING');
    }
    if (status != DirectConversationStatus.pending &&
        direction != DirectRequestDirection.none &&
        direction != DirectRequestDirection.unknown) {
      _contractViolation('DM_STATUS_DIRECTION_MISMATCH');
    }
    if (dto.canSend && status != DirectConversationStatus.accepted) {
      _contractViolation('DM_SEND_PERMISSION_MISMATCH');
    }
    if (dto.canAccept &&
        (status != DirectConversationStatus.pending ||
            direction != DirectRequestDirection.incoming)) {
      _contractViolation('DM_ACCEPT_PERMISSION_MISMATCH');
    }
    final preview = dto.lastMessage == null ? null : _preview(dto.lastMessage!);
    if (dto.lastMessageAt == null && preview != null) {
      _contractViolation('DM_LAST_MESSAGE_TIME_MISSING');
    }
    return DirectConversation(
      id: id,
      status: status,
      requestDirection: direction,
      otherUser: user,
      lastMessage: preview,
      unreadCount: unread,
      archivedAt: dto.archivedAt,
      lastMessageAt: dto.lastMessageAt,
      createdAt: dto.createdAt,
      canSend: dto.canSend,
      canAccept: dto.canAccept,
      canDecline: dto.canDecline,
      isBlocked: dto.isBlocked,
    );
  }

  DirectMessageUser _user(DirectMessageUserResponseDto dto) {
    return DirectMessageUser(
      id: _requiredText(dto.id, '私聊用户 ID'),
      username: _requiredText(dto.username, '私聊用户名'),
      avatarUrl: _safeUrl(dto.avatar, '用户头像'),
      isDeactivated: dto.isDeactivated,
    );
  }

  DirectMessagePreview _preview(DirectMessagePreviewResponseDto dto) {
    final content = _optionalText(dto.contentPreview);
    if (!dto.isRecalled &&
        content == null &&
        !dto.hasImage &&
        !dto.hasSticker) {
      _contractViolation('DM_PREVIEW_CONTENT_MISSING');
    }
    if (dto.hasSticker && !dto.hasImage) {
      _contractViolation('DM_PREVIEW_STICKER_MISMATCH');
    }
    return DirectMessagePreview(
      id: _requiredText(dto.id, '预览消息 ID'),
      senderId: _requiredText(dto.senderId, '预览发送者 ID'),
      content: content,
      hasImage: dto.hasImage,
      hasSticker: dto.hasSticker,
      isRecalled: dto.isRecalled,
      createdAt: dto.createdAt,
    );
  }

  DirectMessage _message(DirectMessageResponseDto dto) {
    final id = _requiredText(dto.id, '消息 ID');
    final conversationId = _requiredText(dto.conversationId, '消息会话 ID');
    final senderId = _requiredText(dto.senderId, '消息发送者 ID');
    final recipientId = _requiredText(dto.recipientId, '消息接收者 ID');
    if (senderId == recipientId) {
      _contractViolation('DM_PARTICIPANT_MISMATCH');
    }
    final content = _optionalText(dto.content);
    final sticker = dto.sticker;
    final media = sticker != null
        ? _sticker(sticker)
        : dto.media == null
        ? null
        : _media(dto.media!);
    if (sticker != null && dto.media != null && dto.media!.id != sticker.id) {
      _contractViolation('DM_STICKER_MEDIA_MISMATCH');
    }
    if (dto.recalledAt != null &&
        (content != null || dto.media != null || sticker != null)) {
      _contractViolation('DM_RECALLED_CONTENT_PRESENT');
    }
    if (dto.recalledAt == null && content == null && media == null) {
      _contractViolation('DM_MESSAGE_CONTENT_MISSING');
    }
    if (media?.isSticker == true && content != null) {
      _contractViolation('DM_STICKER_CONTENT_MISMATCH');
    }
    return DirectMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      media: media,
      recalledAt: dto.recalledAt,
      createdAt: dto.createdAt,
    );
  }

  DirectMessageMedia _media(DirectMessageMediaResponseDto dto) {
    return DirectMessageMedia(
      id: _requiredText(dto.id, '图片 ID'),
      url: _requiredSafeUrl(dto.url, '私聊图片'),
      thumbnailUrl: _safeUrl(dto.thumbnailUrl, '私聊图片缩略图'),
      mediumUrl: _safeUrl(dto.mediumUrl, '私聊图片中图'),
      contentType: _optionalText(dto.contentType),
      width: _optionalPositiveInteger(dto.width, '图片宽度'),
      height: _optionalPositiveInteger(dto.height, '图片高度'),
      isSticker: false,
      animated: dto.animated,
    );
  }

  DirectMessageMedia _sticker(DirectMessageStickerResponseDto dto) {
    _nonNegativeInteger(dto.frameCount, '表情帧数');
    _nonNegativeInteger(dto.durationMs, '表情时长');
    return DirectMessageMedia(
      id: _requiredText(dto.id, '表情 ID'),
      url: _requiredSafeUrl(dto.url, '私聊表情'),
      thumbnailUrl: _safeUrl(dto.thumbnailUrl, '私聊表情缩略图'),
      mediumUrl: _safeUrl(dto.mediumUrl, '私聊表情中图'),
      contentType: _optionalText(dto.contentType),
      width: _optionalPositiveInteger(dto.width, '表情宽度'),
      height: _optionalPositiveInteger(dto.height, '表情高度'),
      isSticker: true,
      animated: dto.animated,
    );
  }

  DirectConversationStatus _status(
    DirectConversationResponseDtoStatusEnum value,
  ) {
    if (value == DirectConversationResponseDtoStatusEnum.PENDING) {
      return DirectConversationStatus.pending;
    }
    if (value == DirectConversationResponseDtoStatusEnum.ACCEPTED) {
      return DirectConversationStatus.accepted;
    }
    if (value == DirectConversationResponseDtoStatusEnum.DECLINED) {
      return DirectConversationStatus.declined;
    }
    if (value == DirectConversationResponseDtoStatusEnum.CANCELED) {
      return DirectConversationStatus.canceled;
    }
    return DirectConversationStatus.unknown;
  }

  DirectRequestDirection _direction(
    DirectConversationResponseDtoRequestDirectionEnum value,
  ) {
    if (value == DirectConversationResponseDtoRequestDirectionEnum.NONE) {
      return DirectRequestDirection.none;
    }
    if (value == DirectConversationResponseDtoRequestDirectionEnum.INCOMING) {
      return DirectRequestDirection.incoming;
    }
    if (value == DirectConversationResponseDtoRequestDirectionEnum.OUTGOING) {
      return DirectRequestDirection.outgoing;
    }
    return DirectRequestDirection.unknown;
  }

  DirectContactState _contactState(
    DirectConversationLookupResponseDtoContactStateEnum value,
  ) {
    if (value == DirectConversationLookupResponseDtoContactStateEnum.NEW) {
      return DirectContactState.fresh;
    }
    if (value == DirectConversationLookupResponseDtoContactStateEnum.PENDING) {
      return DirectContactState.pending;
    }
    if (value == DirectConversationLookupResponseDtoContactStateEnum.ACCEPTED) {
      return DirectContactState.accepted;
    }
    if (value == DirectConversationLookupResponseDtoContactStateEnum.DECLINED) {
      return DirectContactState.declined;
    }
    if (value == DirectConversationLookupResponseDtoContactStateEnum.CANCELED) {
      return DirectContactState.canceled;
    }
    if (value ==
        DirectConversationLookupResponseDtoContactStateEnum.UNAVAILABLE) {
      return DirectContactState.unavailable;
    }
    return DirectContactState.unknown;
  }

  void _validateDraft(DirectMessageDraft draft) {
    DirectMessageDraft.normalized(
      clientRequestId: draft.clientRequestId,
      content: draft.content,
      mediaId: draft.mediaId,
      stickerAssetId: draft.stickerAssetId,
    );
  }

  void _validateSentTarget({
    required DirectConversation conversation,
    required DirectMessage message,
    required String targetUserId,
  }) {
    if (conversation.otherUser.id != targetUserId ||
        message.conversationId != conversation.id ||
        message.recipientId != targetUserId ||
        message.senderId == targetUserId) {
      _contractViolation('DM_START_TARGET_MISMATCH', userMessage: '发送失败，请重试。');
    }
  }

  String? _pageCursor(String? value, bool hasMore) {
    final normalized = _optionalText(value);
    if (hasMore && normalized == null) {
      _contractViolation('DM_CURSOR_MISSING');
    }
    return normalized;
  }

  int _compareMessages(DirectMessage left, DirectMessage right) {
    final byTime = left.createdAt.compareTo(right.createdAt);
    return byTime != 0 ? byTime : left.id.compareTo(right.id);
  }

  int _nonNegativeInteger(num value, String field) {
    if (!value.isFinite || value < 0 || value.toInt() != value) {
      _contractViolation('DM_INVALID_NON_NEGATIVE_INTEGER');
    }
    return value.toInt();
  }

  int? _optionalPositiveInteger(num? value, String field) {
    if (value == null) return null;
    if (!value.isFinite || value <= 0 || value.toInt() != value) {
      _contractViolation('DM_INVALID_POSITIVE_INTEGER');
    }
    return value.toInt();
  }

  String _requiredText(String? value, String field) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      _contractViolation('DM_REQUIRED_TEXT_MISSING');
    }
    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _requiredSafeUrl(String value, String field) {
    final result = _safeUrl(value, field);
    if (result == null) {
      _contractViolation('DM_REQUIRED_URL_MISSING');
    }
    return result;
  }

  String? _safeUrl(String? value, String field) {
    final normalized = _optionalText(value);
    if (normalized == null) return null;
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _contractViolation('DM_UNSAFE_URL');
    }
    return uri.toString();
  }

  Never _contractViolation(
    String diagnosticCode, {
    String userMessage = '私聊加载失败，请重新加载。',
  }) {
    throw ApiFailure.contractViolation(
      userMessage: userMessage,
      diagnosticCode: diagnosticCode,
    );
  }
}

final apiDirectMessageRepositoryProvider = Provider<DirectMessageRepository>((
  ref,
) {
  return ApiDirectMessageRepository(
    ref.watch(wenyouApiProvider).getDirectMessagesApi(),
  );
});

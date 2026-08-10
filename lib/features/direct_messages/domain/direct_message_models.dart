import 'package:wenyousite_mobile/core/network/api_failure.dart';

const directMessageMaxLength = 1000;

String normalizeDirectMessageContent(String value) {
  return value.replaceAll(RegExp(r'\r\n?'), '\n').trim();
}

String? validateDirectMessagePayload({
  String? content,
  String? mediaId,
  String? stickerAssetId,
}) {
  final normalized = normalizeDirectMessageContent(content ?? '');
  final normalizedMediaId = mediaId?.trim() ?? '';
  final normalizedStickerId = stickerAssetId?.trim() ?? '';
  if (normalized.isEmpty &&
      normalizedMediaId.isEmpty &&
      normalizedStickerId.isEmpty) {
    return '请输入消息或选择一张图片';
  }
  if (normalized.length > directMessageMaxLength) {
    return '消息不能超过 1000 个字符';
  }
  if (normalizedStickerId.isNotEmpty &&
      (normalized.isNotEmpty || normalizedMediaId.isNotEmpty)) {
    return '表情必须作为独立消息发送';
  }
  return null;
}

enum DirectConversationView {
  inbox('INBOX', '会话'),
  requests('REQUESTS', '请求'),
  archived('ARCHIVED', '归档');

  const DirectConversationView(this.wireValue, this.label);

  final String wireValue;
  final String label;
}

enum DirectConversationStatus { pending, accepted, declined, canceled, unknown }

enum DirectRequestDirection { none, incoming, outgoing, unknown }

enum DirectContactState {
  fresh,
  pending,
  accepted,
  declined,
  canceled,
  unavailable,
  unknown,
}

class DirectMessageDraft {
  const DirectMessageDraft({
    required this.clientRequestId,
    this.content,
    this.mediaId,
    this.stickerAssetId,
  });

  factory DirectMessageDraft.normalized({
    required String clientRequestId,
    String? content,
    String? mediaId,
    String? stickerAssetId,
  }) {
    final normalizedContent = normalizeDirectMessageContent(content ?? '');
    final normalizedMedia = mediaId?.trim();
    final normalizedSticker = stickerAssetId?.trim();
    final validation = validateDirectMessagePayload(
      content: normalizedContent,
      mediaId: normalizedMedia,
      stickerAssetId: normalizedSticker,
    );
    if (validation != null) throw ApiFailure(userMessage: validation);
    final requestId = clientRequestId.trim();
    if (!_uuidV4.hasMatch(requestId)) {
      throw const ApiFailure(userMessage: '消息请求标识无效，请重新发送。');
    }
    return DirectMessageDraft(
      clientRequestId: requestId,
      content: normalizedContent.isEmpty ? null : normalizedContent,
      mediaId: normalizedMedia == null || normalizedMedia.isEmpty
          ? null
          : normalizedMedia,
      stickerAssetId: normalizedSticker == null || normalizedSticker.isEmpty
          ? null
          : normalizedSticker,
    );
  }

  final String clientRequestId;
  final String? content;
  final String? mediaId;
  final String? stickerAssetId;

  bool samePayload({String? content, String? mediaId, String? stickerAssetId}) {
    final normalizedContent = normalizeDirectMessageContent(content ?? '');
    final normalizedMedia = mediaId?.trim();
    final normalizedSticker = stickerAssetId?.trim();
    return this.content ==
            (normalizedContent.isEmpty ? null : normalizedContent) &&
        this.mediaId ==
            (normalizedMedia == null || normalizedMedia.isEmpty
                ? null
                : normalizedMedia) &&
        this.stickerAssetId ==
            (normalizedSticker == null || normalizedSticker.isEmpty
                ? null
                : normalizedSticker);
  }
}

class DirectMessageUser {
  const DirectMessageUser({
    required this.id,
    required this.username,
    required this.isDeactivated,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final bool isDeactivated;
}

class DirectMessageMedia {
  const DirectMessageMedia({
    required this.id,
    required this.url,
    required this.isSticker,
    this.thumbnailUrl,
    this.mediumUrl,
    this.contentType,
    this.width,
    this.height,
    this.animated = false,
  });

  final String id;
  final String url;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final String? contentType;
  final int? width;
  final int? height;
  final bool isSticker;
  final bool animated;

  String get displayUrl => mediumUrl ?? thumbnailUrl ?? url;
}

class DirectMessagePreview {
  const DirectMessagePreview({
    required this.id,
    required this.senderId,
    required this.hasImage,
    required this.hasSticker,
    required this.isRecalled,
    required this.createdAt,
    this.content,
  });

  final String id;
  final String senderId;
  final String? content;
  final bool hasImage;
  final bool hasSticker;
  final bool isRecalled;
  final DateTime createdAt;

  String get displayText {
    if (isRecalled) return '消息已撤回';
    final value = normalizeDirectMessageContent(content ?? '');
    if (value.isNotEmpty) return value;
    if (hasSticker) return '[表情]';
    if (hasImage) return '[图片]';
    return '暂无消息';
  }
}

class DirectConversation {
  const DirectConversation({
    required this.id,
    required this.status,
    required this.requestDirection,
    required this.otherUser,
    required this.unreadCount,
    required this.createdAt,
    required this.canSend,
    required this.canAccept,
    required this.canDecline,
    required this.isBlocked,
    this.lastMessage,
    this.archivedAt,
    this.lastMessageAt,
  });

  final String id;
  final DirectConversationStatus status;
  final DirectRequestDirection requestDirection;
  final DirectMessageUser otherUser;
  final DirectMessagePreview? lastMessage;
  final int unreadCount;
  final DateTime? archivedAt;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final bool canSend;
  final bool canAccept;
  final bool canDecline;
  final bool isBlocked;

  bool get isIncomingRequest =>
      status == DirectConversationStatus.pending &&
      requestDirection == DirectRequestDirection.incoming;

  bool get isOutgoingRequest =>
      status == DirectConversationStatus.pending &&
      requestDirection == DirectRequestDirection.outgoing;

  DirectConversation copyWith({
    DirectConversationStatus? status,
    DirectRequestDirection? requestDirection,
    int? unreadCount,
    Object? archivedAt = _unset,
    bool? canSend,
    bool? canAccept,
    bool? canDecline,
    bool? isBlocked,
    Object? lastMessage = _unset,
    Object? lastMessageAt = _unset,
  }) {
    return DirectConversation(
      id: id,
      status: status ?? this.status,
      requestDirection: requestDirection ?? this.requestDirection,
      otherUser: otherUser,
      lastMessage: identical(lastMessage, _unset)
          ? this.lastMessage
          : lastMessage as DirectMessagePreview?,
      unreadCount: unreadCount ?? this.unreadCount,
      archivedAt: identical(archivedAt, _unset)
          ? this.archivedAt
          : archivedAt as DateTime?,
      lastMessageAt: identical(lastMessageAt, _unset)
          ? this.lastMessageAt
          : lastMessageAt as DateTime?,
      createdAt: createdAt,
      canSend: canSend ?? this.canSend,
      canAccept: canAccept ?? this.canAccept,
      canDecline: canDecline ?? this.canDecline,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.createdAt,
    this.content,
    this.media,
    this.recalledAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String? content;
  final DirectMessageMedia? media;
  final DateTime? recalledAt;
  final DateTime createdAt;

  bool get isRecalled => recalledAt != null;
  bool isMine(String otherUserId) => senderId != otherUserId;

  DirectMessage asRecalled(DateTime timestamp) {
    return DirectMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      recipientId: recipientId,
      recalledAt: timestamp,
      createdAt: createdAt,
    );
  }
}

class DirectUnreadCounts {
  const DirectUnreadCounts({
    required this.unreadMessages,
    required this.pendingRequests,
  });

  final int unreadMessages;
  final int pendingRequests;
  int get total => unreadMessages + pendingRequests;
}

class DirectConversationLookup {
  const DirectConversationLookup({
    required this.contactState,
    required this.canInitiate,
    this.conversation,
  });

  final DirectContactState contactState;
  final bool canInitiate;
  final DirectConversation? conversation;
}

class DirectConversationStart {
  const DirectConversationStart({
    required this.conversation,
    required this.message,
  });

  final DirectConversation conversation;
  final DirectMessage message;
}

class DirectRecallResult {
  const DirectRecallResult({required this.conversationCanceled});

  final bool conversationCanceled;
}

enum DirectConversationListPhase { loading, ready, failed }

class DirectConversationListState {
  const DirectConversationListState({
    required this.phase,
    required this.view,
    this.items = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.failure,
    this.transientFailure,
  });

  const DirectConversationListState.loading(DirectConversationView view)
    : this(phase: DirectConversationListPhase.loading, view: view);

  final DirectConversationListPhase phase;
  final DirectConversationView view;
  final List<DirectConversation> items;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;

  DirectConversationListState copyWith({
    DirectConversationListPhase? phase,
    List<DirectConversation>? items,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    Object? failure = _unset,
    Object? transientFailure = _unset,
  }) {
    return DirectConversationListState(
      phase: phase ?? this.phase,
      view: view,
      items: items ?? this.items,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
    );
  }
}

class DirectUnreadState {
  const DirectUnreadState({
    this.counts = const DirectUnreadCounts(
      unreadMessages: 0,
      pendingRequests: 0,
    ),
    this.isLoading = false,
    this.failure,
  });

  final DirectUnreadCounts counts;
  final bool isLoading;
  final ApiFailure? failure;
}

enum DirectConversationPhase { loading, ready, failed }

enum DirectConversationAction {
  sending,
  accepting,
  declining,
  archiving,
  markingRead,
  recalling,
}

class DirectConversationState {
  const DirectConversationState({
    required this.phase,
    this.conversation,
    this.messages = const [],
    this.cursor,
    this.hasMore = false,
    this.isLoadingOlder = false,
    this.isRefreshing = false,
    this.failure,
    this.transientFailure,
    this.action,
    this.actionTargetId,
    this.failedDraft,
    this.conversationCanceled = false,
  });

  const DirectConversationState.loading()
    : this(phase: DirectConversationPhase.loading);

  final DirectConversationPhase phase;
  final DirectConversation? conversation;
  final List<DirectMessage> messages;
  final String? cursor;
  final bool hasMore;
  final bool isLoadingOlder;
  final bool isRefreshing;
  final ApiFailure? failure;
  final ApiFailure? transientFailure;
  final DirectConversationAction? action;
  final String? actionTargetId;
  final DirectMessageDraft? failedDraft;
  final bool conversationCanceled;

  bool get isMutating => action != null;

  DirectConversationState copyWith({
    DirectConversationPhase? phase,
    Object? conversation = _unset,
    List<DirectMessage>? messages,
    Object? cursor = _unset,
    bool? hasMore,
    bool? isLoadingOlder,
    bool? isRefreshing,
    Object? failure = _unset,
    Object? transientFailure = _unset,
    Object? action = _unset,
    Object? actionTargetId = _unset,
    Object? failedDraft = _unset,
    bool? conversationCanceled,
  }) {
    return DirectConversationState(
      phase: phase ?? this.phase,
      conversation: identical(conversation, _unset)
          ? this.conversation
          : conversation as DirectConversation?,
      messages: messages ?? this.messages,
      cursor: identical(cursor, _unset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      transientFailure: identical(transientFailure, _unset)
          ? this.transientFailure
          : transientFailure as ApiFailure?,
      action: identical(action, _unset)
          ? this.action
          : action as DirectConversationAction?,
      actionTargetId: identical(actionTargetId, _unset)
          ? this.actionTargetId
          : actionTargetId as String?,
      failedDraft: identical(failedDraft, _unset)
          ? this.failedDraft
          : failedDraft as DirectMessageDraft?,
      conversationCanceled: conversationCanceled ?? this.conversationCanceled,
    );
  }
}

enum DirectConversationTargetPhase { loading, ready, failed }

class DirectConversationTargetState {
  const DirectConversationTargetState({
    required this.phase,
    this.user,
    this.lookup,
    this.failure,
    this.isSending = false,
    this.failedDraft,
  });

  const DirectConversationTargetState.loading()
    : this(phase: DirectConversationTargetPhase.loading);

  final DirectConversationTargetPhase phase;
  final DirectMessageUser? user;
  final DirectConversationLookup? lookup;
  final ApiFailure? failure;
  final bool isSending;
  final DirectMessageDraft? failedDraft;

  DirectConversationTargetState copyWith({
    DirectConversationTargetPhase? phase,
    Object? user = _unset,
    Object? lookup = _unset,
    Object? failure = _unset,
    bool? isSending,
    Object? failedDraft = _unset,
  }) {
    return DirectConversationTargetState(
      phase: phase ?? this.phase,
      user: identical(user, _unset) ? this.user : user as DirectMessageUser?,
      lookup: identical(lookup, _unset)
          ? this.lookup
          : lookup as DirectConversationLookup?,
      failure: identical(failure, _unset)
          ? this.failure
          : failure as ApiFailure?,
      isSending: isSending ?? this.isSending,
      failedDraft: identical(failedDraft, _unset)
          ? this.failedDraft
          : failedDraft as DirectMessageDraft?,
    );
  }
}

final _uuidV4 = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

const _unset = Object();

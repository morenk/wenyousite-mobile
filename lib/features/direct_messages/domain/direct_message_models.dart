import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';

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
    if (validation != null) throw DomainValidationException(validation);
    final requestId = clientRequestId.trim();
    if (!_uuidV4.hasMatch(requestId)) {
      throw const DomainValidationException('消息请求标识无效，请重新发送。');
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

final _uuidV4 = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

const _unset = Object();

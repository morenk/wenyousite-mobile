import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

abstract interface class DirectMessageRepository {
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  });

  Future<DirectUnreadCounts> fetchUnreadCounts();

  Future<DirectConversationLookup> findByUser(String userId);

  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  });

  Future<DirectConversation> fetchConversation(String conversationId);

  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  });

  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  });

  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  });

  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  });

  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  });

  Future<DirectRecallResult> recall(String messageId);
}

final directMessageRepositoryProvider = Provider<DirectMessageRepository>((
  ref,
) {
  return const _UnboundDirectMessageRepository();
});

class _UnboundDirectMessageRepository implements DirectMessageRepository {
  const _UnboundDirectMessageRepository();

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) => Future.error(_error());

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() => Future.error(_error());

  @override
  Future<DirectConversationLookup> findByUser(String userId) {
    return Future.error(_error());
  }

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) => Future.error(_error());

  @override
  Future<DirectConversation> fetchConversation(String conversationId) {
    return Future.error(_error());
  }

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) => Future.error(_error());

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) => Future.error(_error());

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) => Future.error(_error());

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) => Future.error(_error());

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) => Future.error(_error());

  @override
  Future<DirectRecallResult> recall(String messageId) => Future.error(_error());
}

StateError _error() => StateError('私聊仓储尚未在应用组合根绑定。');

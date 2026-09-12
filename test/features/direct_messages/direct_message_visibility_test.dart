import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

void main() {
  for (final polling in [true, false]) {
    test('${polling ? '轮询' : '刷新'}收到不可访问后清除旧会话和历史消息', () async {
      final repository = _Repository();
      final controller = DirectConversationController(
        'conversation',
        repository,
        autoStart: false,
        pollInterval: Duration.zero,
      );
      addTearDown(controller.dispose);
      await controller.loadInitial();
      expect(controller.state.messages, hasLength(1));
      repository.blocked = true;
      if (polling) {
        await controller.pollLatest();
      } else {
        await controller.refresh();
      }
      expect(controller.state.phase, DirectConversationPhase.failed);
      expect(controller.state.conversation, isNull);
      expect(controller.state.messages, isEmpty);
      expect(controller.state.failure?.httpStatus, 404);
    });
  }
}

class _Repository extends Fake implements DirectMessageRepository {
  bool blocked = false;
  @override
  Future<DirectConversation> fetchConversation(String conversationId) async =>
      DirectConversation(
        id: conversationId,
        status: DirectConversationStatus.accepted,
        requestDirection: DirectRequestDirection.none,
        otherUser: const DirectMessageUser(
          id: 'other',
          username: '测试',
          isDeactivated: false,
        ),
        unreadCount: 0,
        createdAt: DateTime.utc(2026),
        canSend: true,
        canAccept: false,
        canDecline: false,
        isBlocked: false,
      );
  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) async {
    if (blocked) {
      throw const ApiFailure(httpStatus: 404, reason: FailureReason.notFound);
    }
    return CursorPage(
      items: [
        DirectMessage(
          id: 'message',
          conversationId: conversationId,
          senderId: 'self',
          recipientId: 'other',
          createdAt: DateTime.utc(2026),
          content: '历史内容',
        ),
      ],
      hasMore: false,
    );
  }
}

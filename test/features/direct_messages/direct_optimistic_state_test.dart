import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';

const failure = ApiFailure(userMessage: '操作失败', businessCode: 40300);

void main() {
  test('归档期间会话不可访问，迟到写入不能恢复会话或抛空值异常', () async {
    final repository = _Repository();
    final gate = Completer<DirectConversation>();
    when(
      () => repository.fetchConversation('conversation'),
    ).thenAnswer((_) async => conversation());
    when(
      () => repository.fetchMessages(conversationId: 'conversation'),
    ).thenAnswer(
      (_) async => const CursorPage(items: <DirectMessage>[], hasMore: false),
    );
    when(
      () => repository.fetchMessages(
        conversationId: 'conversation',
        after: null,
        limit: 50,
      ),
    ).thenThrow(const ApiFailure(userMessage: '会话不可访问', httpStatus: 403));
    when(
      () => repository.setArchived(
        conversationId: 'conversation',
        archived: true,
      ),
    ).thenAnswer((_) => gate.future);
    final controller = DirectConversationController(
      'conversation',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final operation = controller.toggleArchive();
    await controller.pollLatest();
    gate.complete(conversation().copyWith(archivedAt: DateTime.utc(2026)));
    expect(await operation, isFalse);
    expect(controller.state.phase, DirectConversationPhase.failed);
    expect(controller.state.conversation, isNull);
  });

  test('归档立即更新，迟到刷新不能覆盖，失败只恢复归档字段', () async {
    final repository = _Repository();
    final gate = Completer<DirectConversation>();
    final stale = Completer<DirectConversation>();
    var reads = 0;
    when(() => repository.fetchConversation('conversation')).thenAnswer(
      (_) => ++reads == 1 ? Future.value(conversation()) : stale.future,
    );
    when(
      () => repository.fetchMessages(conversationId: 'conversation'),
    ).thenAnswer(
      (_) async => const CursorPage(items: <DirectMessage>[], hasMore: false),
    );
    when(
      () => repository.setArchived(
        conversationId: 'conversation',
        archived: true,
      ),
    ).thenAnswer((_) => gate.future);
    final controller = DirectConversationController(
      'conversation',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final refresh = controller.refresh();
    final operation = controller.toggleArchive();
    final during = controller.state.conversation!;
    stale.complete(conversation());
    await refresh;
    expect(controller.state.conversation!.archivedAt, isNotNull);
    gate.completeError(failure);
    expect(await operation, isFalse);
    expect(during.archivedAt, isNotNull);
    expect(controller.state.conversation!.archivedAt, isNull);
  });

  test('已读立即清本会话角标，失败恢复且不动请求数', () async {
    final repository = _Repository();
    final gate = Completer<void>();
    when(repository.fetchUnreadCounts).thenAnswer(
      (_) async =>
          const DirectUnreadCounts(unreadMessages: 5, pendingRequests: 2),
    );
    when(
      () => repository.fetchConversation('conversation'),
    ).thenAnswer((_) async => conversation());
    when(
      () => repository.fetchMessages(conversationId: 'conversation'),
    ).thenAnswer(
      (_) async => CursorPage(
        items: [
          DirectMessage(
            id: 'message',
            conversationId: 'conversation',
            senderId: 'other',
            recipientId: 'me',
            content: '已阅读',
            createdAt: DateTime.utc(2026),
          ),
        ],
        hasMore: false,
      ),
    );
    when(
      () => repository.markRead(
        conversationId: 'conversation',
        throughMessageId: 'message',
      ),
    ).thenAnswer((_) => gate.future);
    final unread = DirectUnreadController(repository, autoStart: false);
    addTearDown(unread.dispose);
    await unread.refresh();
    final controller = DirectConversationController(
      'conversation',
      repository,
      autoStart: false,
      pollInterval: Duration.zero,
      onOptimisticRead: unread.beginRead,
    );
    addTearDown(controller.dispose);
    await controller.loadInitial();
    final during = controller.state.conversation!.unreadCount;
    final duringCounts = unread.state.counts;
    gate.completeError(failure);
    await Future<void>.delayed(Duration.zero);
    expect(during, 0);
    expect(duringCounts.unreadMessages, 3);
    expect(duringCounts.pendingRequests, 2);
    expect(controller.state.conversation!.unreadCount, 2);
    expect(unread.state.counts.unreadMessages, 5);
  });

  test('角标忽略旧读取，结算后采用包含新消息的最新计数', () async {
    final repository = _Repository();
    final stale = Completer<DirectUnreadCounts>();
    var reads = 0;
    when(repository.fetchUnreadCounts).thenAnswer((_) {
      reads++;
      if (reads == 2) return stale.future;
      return Future.value(
        DirectUnreadCounts(
          unreadMessages: reads == 1 ? 5 : 4,
          pendingRequests: 2,
        ),
      );
    });
    final controller = DirectUnreadController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.refresh();
    final refresh = controller.refresh();
    final finish = controller.beginRead(conversation());
    stale.complete(
      const DirectUnreadCounts(unreadMessages: 9, pendingRequests: 2),
    );
    await refresh;
    expect(controller.state.counts.unreadMessages, 3);
    await controller.refresh();
    expect(reads, 2);
    finish(true);
    finish(false); // 重复结算不能把已确认阅读加回来。
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.counts.unreadMessages, 4);
    expect(controller.state.counts.pendingRequests, 2);
  });

  test('阅读陌生请求不会扣普通消息和请求角标', () async {
    final repository = _Repository();
    when(repository.fetchUnreadCounts).thenAnswer(
      (_) async =>
          const DirectUnreadCounts(unreadMessages: 5, pendingRequests: 2),
    );
    final controller = DirectUnreadController(repository, autoStart: false);
    addTearDown(controller.dispose);
    await controller.refresh();
    final finish = controller.beginRead(
      conversation().copyWith(
        status: DirectConversationStatus.pending,
        requestDirection: DirectRequestDirection.incoming,
      ),
    );
    expect(controller.state.counts.total, 7);
    finish(true);
    await Future<void>.delayed(Duration.zero);
  });
}

class _Repository extends Mock implements DirectMessageRepository {}

DirectConversation conversation() => DirectConversation(
  id: 'conversation',
  status: DirectConversationStatus.accepted,
  requestDirection: DirectRequestDirection.none,
  otherUser: const DirectMessageUser(
    id: 'other',
    username: '对方',
    isDeactivated: false,
  ),
  unreadCount: 2,
  createdAt: DateTime.utc(2026),
  canSend: true,
  canAccept: false,
  canDecline: false,
  isBlocked: false,
);

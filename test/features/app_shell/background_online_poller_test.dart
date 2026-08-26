import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/application/background_online_reminders.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/features/app_shell/application/background_online_poller.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_repository_ports.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/notifications/application/notification_repository_ports.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';

void main() {
  late _NotificationRepository notifications;
  late _DirectMessageRepository directMessages;

  setUp(() {
    notifications = _NotificationRepository();
    directMessages = _DirectMessageRepository();
  });

  test('首个基线压住历史通知，同一聚合通知变化后才提醒', () async {
    final pages = [
      _notificationPage([_notification(totalCount: 1)]),
      _notificationPage([_notification(totalCount: 2)]),
    ];
    when(
      () => notifications.fetchPage(),
    ).thenAnswer((_) async => pages.removeAt(0));
    when(() => notifications.fetchUnreadCount()).thenAnswer((_) async => 1);
    _stubDirectBaseline(directMessages);
    final poller = BackgroundOnlinePoller(notifications, directMessages);

    expect(await poller.ensureBaseline(includeDirectMessages: false), isTrue);
    final alerts = await poller.poll(includeDirectMessages: false);

    expect(alerts, hasLength(1));
    expect(alerts.single.title, '温油站');
    expect(alerts.single.body, contains('赞了你的内容'));
    expect(alerts.single.body, isNot(contains('![')));
  });

  test('私聊未读增长仅显示用户名和通用提示，不泄露消息正文', () async {
    when(
      () => notifications.fetchPage(),
    ).thenAnswer((_) async => _notificationPage(const []));
    when(() => notifications.fetchUnreadCount()).thenAnswer((_) async => 0);
    final countResults = [
      const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
      const DirectUnreadCounts(unreadMessages: 1, pendingRequests: 0),
    ];
    when(
      () => directMessages.fetchUnreadCounts(),
    ).thenAnswer((_) async => countResults.removeAt(0));
    final inboxPages = [
      _conversationPage(const []),
      _conversationPage([_conversation(secret: '绝密私聊正文')]),
    ];
    when(
      () => directMessages.fetchConversations(
        view: DirectConversationView.inbox,
        limit: 20,
      ),
    ).thenAnswer((_) async => inboxPages.removeAt(0));
    when(
      () => directMessages.fetchConversations(
        view: DirectConversationView.requests,
        limit: 20,
      ),
    ).thenAnswer((_) async => _conversationPage(const []));
    final poller = BackgroundOnlinePoller(notifications, directMessages);

    await poller.ensureBaseline(includeDirectMessages: true);
    final alerts = await poller.poll(includeDirectMessages: true);

    expect(alerts, hasLength(1));
    expect(alerts.single.title, '小温');
    expect(alerts.single.body, '发来一条新私聊');
    expect(
      '${alerts.single.title}${alerts.single.body}',
      isNot(contains('绝密')),
    );
    expect(
      BackgroundNotificationPayload.tryParse(alerts.single.payload)?.location,
      '/messages/conversation-1',
    );
  });

  test('超过三条新通知时只显示一条消息中心汇总', () async {
    final pages = [
      _notificationPage(const []),
      _notificationPage([
        for (var index = 0; index < 4; index++)
          _notification(id: 'notification-$index'),
      ]),
    ];
    when(
      () => notifications.fetchPage(),
    ).thenAnswer((_) async => pages.removeAt(0));
    when(() => notifications.fetchUnreadCount()).thenAnswer((_) async => 4);
    _stubDirectBaseline(directMessages);
    final poller = BackgroundOnlinePoller(notifications, directMessages);

    await poller.ensureBaseline(includeDirectMessages: false);
    final alerts = await poller.poll(includeDirectMessages: false);

    expect(alerts, hasLength(1));
    expect(alerts.single.body, '你有 4 条新消息');
    expect(
      BackgroundNotificationPayload.tryParse(alerts.single.payload)?.location,
      '/notifications',
    );
  });
}

void _stubDirectBaseline(_DirectMessageRepository repository) {
  when(() => repository.fetchUnreadCounts()).thenAnswer(
    (_) async =>
        const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0),
  );
}

CursorPage<NotificationListItem> _notificationPage(
  List<NotificationListItem> items,
) => CursorPage(items: items, hasMore: false);

NotificationListItem _notification({
  String id = 'notification-1',
  int totalCount = 1,
}) {
  return NotificationListItem(
    id: id,
    recipientUserId: 'me',
    kind: NotificationKind.like,
    content: '小油赞了你的内容 ![私密图片](https://example.invalid/private)',
    payload: NotificationPayload(
      action: 'like',
      actorName: '小油',
      totalCount: totalCount,
    ),
    target: const NotificationTarget(
      kind: NotificationTargetKind.thread,
      threadId: 'thread-1',
    ),
    isRead: false,
    createdAt: DateTime.utc(2026, 8, 26),
  );
}

CursorPage<DirectConversation> _conversationPage(
  List<DirectConversation> items,
) => CursorPage(items: items, hasMore: false);

DirectConversation _conversation({required String secret}) {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: const DirectMessageUser(
      id: 'user-1',
      username: '小温',
      isDeactivated: false,
    ),
    lastMessage: DirectMessagePreview(
      id: 'message-1',
      senderId: 'user-1',
      content: secret,
      hasImage: false,
      hasSticker: false,
      isRecalled: false,
      createdAt: DateTime.utc(2026, 8, 26),
    ),
    unreadCount: 1,
    createdAt: DateTime.utc(2026, 8, 26),
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

class _NotificationRepository extends Mock implements NotificationRepository {}

class _DirectMessageRepository extends Mock
    implements DirectMessageRepository {}

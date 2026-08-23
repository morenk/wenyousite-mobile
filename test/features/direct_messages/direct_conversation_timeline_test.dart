import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_states.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_timeline.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

void main() {
  testWidgets('私聊时间线使用同组 8dp 与换人或跨时间组 16dp 间距', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final base = DateTime(2024, 1, 1, 9);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [stickersEnabledProvider.overrideWithValue(false)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DirectMessageTimeline(
              state: DirectConversationState(
                phase: DirectConversationPhase.ready,
                conversation: _conversation(base),
                messages: [
                  _message('same-first', 'user-2', base),
                  _message(
                    'same-last',
                    'user-2',
                    base.add(const Duration(seconds: 30)),
                  ),
                  _message(
                    'sender-switch',
                    'user-1',
                    base.add(const Duration(minutes: 1)),
                  ),
                  _message(
                    'time-break',
                    'user-1',
                    base.add(const Duration(minutes: 6)),
                  ),
                ],
              ),
              now: base.add(const Duration(minutes: 7)),
              controller: controller,
              onLoadOlder: () {},
              onRecall: (_) {},
              onRetryMessage: (_) {},
              onAbandonFailedMessage: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_bottomPadding(tester, 'same-first'), 8);
    expect(_bottomPadding(tester, 'same-last'), 16);
    expect(_bottomPadding(tester, 'sender-switch'), 16);
    expect(_bottomPadding(tester, 'time-break'), 12);
  });
}

double _bottomPadding(WidgetTester tester, String messageId) {
  final padding = tester.widget<Padding>(
    find.byKey(ValueKey('direct-message-item-$messageId')),
  );
  return (padding.padding as EdgeInsets).bottom;
}

DirectConversation _conversation(DateTime createdAt) {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: const DirectMessageUser(
      id: 'user-2',
      username: '小油',
      isDeactivated: false,
    ),
    unreadCount: 0,
    createdAt: createdAt,
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectMessage _message(String id, String senderId, DateTime createdAt) {
  return DirectMessage(
    id: id,
    conversationId: 'conversation-1',
    senderId: senderId,
    recipientId: senderId == 'user-1' ? 'user-2' : 'user-1',
    content: id,
    createdAt: createdAt,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import '../../support/foundation_test_fonts.dart';
import 'direct_conversation_page_test_support.dart';

void registerDirectConversationPageGoldenCases() {
  setUpAll(loadFoundationTestFonts);
  testWidgets('600dp 私信气泡分组视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final base = DateTime(2024, 1, 1, 9);
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        directConversationPageTestTextMessage(
          id: 'golden-incoming-1',
          senderId: 'user-2',
          content: '今天的团期还是晚上八点。',
          createdAt: base,
        ),
        directConversationPageTestTextMessage(
          id: 'golden-incoming-2',
          senderId: 'user-2',
          content: '地图和人物卡我已经整理好了。',
          createdAt: base.add(const Duration(seconds: 30)),
        ),
        directConversationPageTestTextMessage(
          id: 'golden-mine',
          senderId: 'user-1',
          content: '收到，我会提前上线。',
          createdAt: base.add(const Duration(minutes: 1)),
        ),
        directConversationPageTestTextMessage(
          id: 'golden-portal',
          senderId: 'user-2',
          content: '入口：[私密团入口](/join/AbCdEfGh_123-XYZ)',
          createdAt: base.add(const Duration(minutes: 2)),
        ),
      ],
    );
    final router = directConversationPageTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: directConversationPageTestOverrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const PageStorageKey('direct-message-timeline')),
      matchesGoldenFile('goldens/direct_conversation_bubbles_600.png'),
    );
  });
}

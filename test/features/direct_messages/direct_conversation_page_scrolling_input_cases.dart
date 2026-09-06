import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import '../../support/foundation_test_fonts.dart';
import 'direct_conversation_page_test_support.dart';

void registerDirectConversationPageScrollingInputCases() {
  setUpAll(loadFoundationTestFonts);
  testWidgets('图片上传中取消会立即解除等待并保留正文', (tester) async {
    final repository = DirectConversationPageTestFakeRepository();
    final router = directConversationPageTestRouter();
    final gateway = DirectConversationPageTestBlockingMediaUploadGateway();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...directConversationPageTestOverrides(
            repository,
            mediaUploadGateway: gateway,
          ),
          editorImagePickerPortProvider.overrideWithValue(
            DirectConversationPageTestFakeImagePicker(),
          ),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      '取消后保留',
    );
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(gateway.started, isFalse);
    expect(
      tester
          .widget<WenyouComposerSubmitButton>(
            find.byKey(const Key('direct-message-composer-submit')),
          )
          .enabled,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    expect(gateway.started, isTrue);
    expect(find.text('取消后保留'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-pending-local-image')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('消息发送中'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-composer-upload-failure')),
      findsNothing,
    );
    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      '下一条消息',
    );
    expect(
      directConversationPageTestAtomicEditorPlainText(
        tester,
        const Key('direct-message-composer-field'),
      ),
      '下一条消息',
    );
    expect(repository.sentDrafts, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(gateway.operation.cancelled, isTrue);
  });

  testWidgets('连续消息保持分组且组末才有方向尾角', (tester) async {
    final createdAt = DateTime.now().subtract(const Duration(minutes: 2));
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        directConversationPageTestTextMessage(
          id: 'group-first',
          senderId: 'user-2',
          content: '第一条',
          createdAt: createdAt,
        ),
        directConversationPageTestTextMessage(
          id: 'group-last',
          senderId: 'user-2',
          content: '第二条',
          createdAt: createdAt.add(const Duration(seconds: 20)),
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

    BorderRadius radiusOf(String id) {
      final bubble = find.byKey(ValueKey('direct-message-actions-$id'));
      final decorated = find.descendant(
        of: bubble,
        matching: find.byType(DecoratedBox),
      );
      final decoration =
          tester.widget<DecoratedBox>(decorated.first).decoration
              as BoxDecoration;
      return decoration.borderRadius! as BorderRadius;
    }

    final first = radiusOf('group-first');
    final last = radiusOf('group-last');
    expect(first.bottomLeft, first.bottomRight);
    expect(last.bottomLeft.x, lessThan(last.bottomRight.x));
  });

  testWidgets('本人发送的纯图片不再套消息气泡', (tester) async {
    final repository = DirectConversationPageTestFakeRepository(
      messages: [directConversationPageTestOutgoingImageMessage()],
    );
    final router = directConversationPageTestRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: directConversationPageTestOverrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    for (var frame = 0; frame < 8; frame += 1) {
      await tester.pump(const Duration(milliseconds: 80));
    }

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('direct-message-surface-outgoing-image')),
    );
    expect((surface.decoration as BoxDecoration).color, Colors.transparent);
    expect(
      tester
          .widget<Padding>(
            find.byKey(
              const ValueKey('direct-message-content-padding-outgoing-image'),
            ),
          )
          .padding,
      EdgeInsets.zero,
    );
  });

  testWidgets('陌生消息请求图片默认隐藏，接受后才开放发送', (tester) async {
    final repository = DirectConversationPageTestFakeRepository(
      conversation: directConversationPageTestIncomingRequest(),
      messages: [directConversationPageTestIncomingImageMessage()],
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

    expect(find.text('点击查看陌生人图片'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-composer-field')),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('direct-conversation-accept')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.requestActions, [true]);
    expect(
      find.byKey(const Key('direct-message-composer-field')),
      findsOneWidget,
    );
    expect(find.text('点击查看陌生人图片'), findsNothing);
    final imageSurface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('direct-message-surface-incoming-image')),
    );
    final imageDecoration = imageSurface.decoration as BoxDecoration;
    expect(imageDecoration.color, Colors.transparent);
    expect(
      tester
          .widget<Padding>(
            find.byKey(
              const ValueKey('direct-message-content-padding-incoming-image'),
            ),
          )
          .padding,
      EdgeInsets.zero,
    );
  });

  testWidgets('阅读历史时收到新消息不抢滚动并显示回到底部入口', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final base = DateTime.now().subtract(const Duration(minutes: 30));
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        for (var index = 0; index < 24; index += 1)
          directConversationPageTestTextMessage(
            id: 'message-$index',
            senderId: index.isEven ? 'user-2' : 'user-1',
            content: '用于填满时间线的消息 $index',
            createdAt: base.add(Duration(minutes: index)),
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

    final timeline = find.byKey(
      const PageStorageKey('direct-message-timeline'),
    );
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: timeline, matching: find.byType(Scrollable)),
    );
    scrollable.position.jumpTo(
      (scrollable.position.minScrollExtent + 360).clamp(
        scrollable.position.minScrollExtent,
        scrollable.position.maxScrollExtent,
      ),
    );
    await tester.pump();
    expect(
      scrollable.position.pixels - scrollable.position.minScrollExtent,
      greaterThan(96),
    );
    repository.pendingAfterMessages.add(
      directConversationPageTestTextMessage(
        id: 'incoming-new',
        senderId: 'user-2',
        content: '一条新消息',
        createdAt: DateTime.now(),
      ),
    );
    final container = ProviderScope.containerOf(tester.element(timeline));
    final conversationProvider = directConversationControllerProvider(
      'conversation-1',
    );
    await container.read(conversationProvider.notifier).pollLatest();
    await tester.pumpAndSettle();
    expect(
      container.read(conversationProvider).messages.last.id,
      'incoming-new',
    );

    final jump = find.byKey(const Key('direct-conversation-new-messages'));
    expect(jump, findsOneWidget);
    expect(find.text('1 条新消息'), findsOneWidget);
    await tester.tap(jump);
    await tester.pump();
    expect(jump, findsNothing);
    expect(find.text('一条新消息'), findsOneWidget);
  });

  testWidgets('首次进入长会话直接停留在最新消息且不恢复历史位置', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final base = DateTime.now().subtract(const Duration(minutes: 30));
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        for (var index = 0; index < 30; index += 1)
          directConversationPageTestTextMessage(
            id: 'initial-$index',
            senderId: index.isEven ? 'user-2' : 'user-1',
            content: '初始消息 $index',
            createdAt: base.add(Duration(minutes: index)),
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

    final timeline = find.byKey(
      const PageStorageKey('direct-message-timeline'),
    );
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: timeline, matching: find.byType(Scrollable)),
    );
    expect(scrollable.position.pixels, scrollable.position.minScrollExtent);
    expect(find.text('初始消息 29'), findsOneWidget);
    expect(find.text('初始消息 0'), findsNothing);
    expect(tester.widget<ListView>(timeline).reverse, isTrue);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 会话与输入器无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = DirectConversationPageTestFakeRepository();
      final router = directConversationPageTestRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: directConversationPageTestOverrides(
            repository,
            stickersEnabled: true,
          ),
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('360dp 私信输入 dock 随键盘避让且发送操作保持可见', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final repository = DirectConversationPageTestFakeRepository();
    final router = directConversationPageTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: directConversationPageTestOverrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('direct-message-composer-field'));
    final send = find.byKey(const Key('direct-message-composer-submit'));
    final dock = find.byKey(const Key('direct-message-composer-dock'));
    final unobstructedBottom = tester.getBottomRight(send).dy;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    final firstInsetFrameBottom = tester.getBottomRight(send).dy;

    expect(firstInsetFrameBottom, lessThan(unobstructedBottom));
    expect(tester.getBottomRight(send).dy, lessThanOrEqualTo(460));
    expect(
      tester.getBottomLeft(field).dy,
      lessThanOrEqualTo(tester.getTopLeft(send).dy),
    );
    expect(dock, findsOneWidget);
    expect(
      find.descendant(of: dock, matching: find.byType(AnimatedPadding)),
      findsNothing,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getBottomRight(send).dy, firstInsetFrameBottom);
    expect(find.text('0/1000'), findsNothing);
    expect(
      find.byKey(const Key('direct-message-composer-character-count')),
      findsNothing,
    );
    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      '长' * 900,
    );
    await tester.pump();
    expect(
      find.byKey(const Key('direct-message-composer-character-count')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.3, 2.0]) {
    testWidgets('320dp 与 $scale 倍字体下键盘态无溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
      final repository = DirectConversationPageTestFakeRepository();
      final router = directConversationPageTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: directConversationPageTestOverrides(
            repository,
            stickersEnabled: true,
          ),
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('direct-message-composer-submit')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('360dp 键盘态私信输入 dock 视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        directConversationPageTestTextMessage(
          id: 'golden-keyboard-incoming',
          senderId: 'user-2',
          content: '你好',
          createdAt: DateTime(2024, 1, 1, 9),
        ),
      ],
    );
    final router = directConversationPageTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: directConversationPageTestOverrides(
          repository,
          stickersEnabled: true,
        ),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('direct-message-composer-dock')),
      matchesGoldenFile('goldens/direct_message_composer_keyboard_360.png'),
    );
  });
}

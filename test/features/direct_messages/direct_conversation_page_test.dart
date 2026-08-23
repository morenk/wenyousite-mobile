import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/direct_messages/application/direct_message_controllers.dart';
import 'package:wenyousite_mobile/features/direct_messages/data/direct_message_repository.dart';
import 'package:wenyousite_mobile/features/direct_messages/domain/direct_message_models.dart';
import 'package:wenyousite_mobile/features/direct_messages/presentation/direct_conversation_page.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/reports/application/report_repository_ports.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'package:wenyousite_mobile/features/reports/presentation/report_widgets.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('已接受会话可发送、撤回并切换归档状态', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('你好'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('direct-message-composer-field')),
      '发送内容',
    );
    await tester.pump();
    final composerField = tester.widget<TextField>(
      find.byKey(const Key('direct-message-composer-field')),
    );
    expect(composerField.focusNode?.hasFocus, isTrue);
    await tester.tap(find.text('你好'));
    await tester.pump();
    expect(composerField.focusNode?.hasFocus, isFalse);
    expect(composerField.controller?.text, '发送内容');

    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.sentDrafts.single.content, '发送内容');
    expect(find.text('发送内容'), findsOneWidget);

    final sentBubble = find.byKey(
      const ValueKey('direct-message-actions-sent-1'),
    );
    await tester.ensureVisible(sentBubble);
    expect(
      find.byKey(const ValueKey('direct-message-recall-sent-1')),
      findsNothing,
    );
    await tester.longPress(sentBubble);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('direct-message-recall-sent-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('direct-conversation-recall-confirm')),
    );
    await tester.pumpAndSettle();
    expect(repository.recalledIds, ['sent-1']);
    expect(find.text('你撤回了一条消息'), findsOneWidget);

    await tester.tap(find.byKey(const Key('direct-conversation-archive')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('归档会话'));
    await tester.pumpAndSettle();
    expect(repository.archiveValues, [true]);
    expect(find.byTooltip('更多会话操作'), findsOneWidget);
  });

  testWidgets('收到且未撤回的私信可举报，并提交消息目标', (tester) async {
    final repository = _FakeRepository();
    final reportRepository = _FakeReportRepository();
    final session = SessionController(
      _MemoryTokenStore(),
      _FakeSessionRemote(),
    );
    await session.authenticate(_tokens('user-1'));
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(repository),
          sessionControllerProvider.overrideWith((ref) => session),
          reportRepositoryProvider.overrideWithValue(reportRepository),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final incomingBubble = find.byKey(
      const ValueKey('direct-message-actions-incoming-1'),
    );
    await tester.longPress(incomingBubble);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('direct-message-report-incoming-1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('举报这条私信'), findsOneWidget);

    await tester.tap(find.byKey(const Key('report-submit')));
    await tester.pumpAndSettle();

    expect(reportRepository.inputs, hasLength(1));
    expect(
      reportRepository.inputs.single.target,
      const ReportTarget.directMessage('incoming-1'),
    );
    expect(find.textContaining('举报已提交'), findsOneWidget);
  });

  testWidgets('发送失败只标记对应气泡并可原位重试', (tester) async {
    final repository = _FakeRepository(failSendOnce: true);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('direct-message-composer-field')),
      '稍后重试',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final failed = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'direct-message-delivery-failed-',
          ),
    );
    expect(failed, findsOneWidget);
    await tester.tap(failed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final retry = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'direct-message-retry-',
          ),
    );
    await tester.tap(retry);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.sentDrafts, hasLength(2));
    expect(find.text('稍后重试'), findsOneWidget);
    expect(failed, findsNothing);
  });

  testWidgets('图片上传失败保留正文、选区与焦点并提供同文件重试', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(repository),
          editorImagePickerPortProvider.overrideWithValue(_FakeImagePicker()),
          mediaUploadGatewayPortProvider.overrideWithValue(
            _FailingMediaUploadGateway(),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('direct-message-composer-field'));
    final emptySend = tester.widget<WenyouComposerSubmitButton>(
      find.byKey(const Key('direct-message-composer-submit')),
    );
    expect(emptySend.enabled, isFalse);
    await tester.enterText(field, '带图消息');
    await tester.tapAt(tester.getTopLeft(field) + const Offset(24, 20));
    await tester.pump();
    final editable = tester.widget<EditableText>(
      find.byType(EditableText).last,
    );
    final expectedSelection = editable.controller.selection;
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('带图消息'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-composer-upload-failure')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('direct-message-composer-retry-upload')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('direct-message-composer-attachment')),
      findsNothing,
    );
    final restored = tester.widget<EditableText>(
      find.byType(EditableText).last,
    );
    expect(restored.focusNode.hasFocus, isTrue);
    expect(restored.controller.selection, expectedSelection);
    expect(repository.sentDrafts, isEmpty);
  });

  testWidgets('图片上传失败后重试同一文件，完成后才允许发送', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    final gateway = _RetryingMediaUploadGateway();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(repository),
          editorImagePickerPortProvider.overrideWithValue(_FakeImagePicker()),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('direct-message-composer-field')),
      '重试图片',
    );
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(1));
    expect(
      find.byKey(const Key('direct-message-composer-retry-upload')),
      findsOneWidget,
    );
    var send = tester.widget<WenyouComposerSubmitButton>(
      find.byKey(const Key('direct-message-composer-submit')),
    );
    expect(send.enabled, isFalse);

    await tester.tap(
      find.byKey(const Key('direct-message-composer-retry-upload')),
    );
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(2));
    expect(identical(gateway.inputs.first, gateway.inputs.last), isTrue);
    expect(gateway.inputs.first.purpose, MediaUploadPurpose.directMessage);
    expect(
      find.byKey(const Key('direct-message-composer-attachment')),
      findsOneWidget,
    );
    send = tester.widget<WenyouComposerSubmitButton>(
      find.byKey(const Key('direct-message-composer-submit')),
    );
    expect(send.enabled, isTrue);
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.sentDrafts.single.content, '重试图片');
    expect(repository.sentDrafts.single.mediaId, 'media-retried');
  });

  testWidgets('图片上传中取消会立即解除等待并保留正文', (tester) async {
    final repository = _FakeRepository();
    final router = _router();
    final gateway = _BlockingMediaUploadGateway();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ..._overrides(repository),
          editorImagePickerPortProvider.overrideWithValue(_FakeImagePicker()),
          mediaUploadGatewayPortProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('direct-message-composer-field'));
    await tester.enterText(field, '取消后保留');
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);

    expect(find.text('正在上传 50%'), findsOneWidget);
    expect(
      tester
          .widget<WenyouComposerSubmitButton>(
            find.byKey(const Key('direct-message-composer-submit')),
          )
          .enabled,
      isFalse,
    );

    await tester.tap(
      find.byKey(const Key('direct-message-composer-cancel-upload')),
    );
    await tester.pump();
    await tester.pump();

    expect(gateway.operation.cancelled, isTrue);
    expect(find.text('取消后保留'), findsOneWidget);
    expect(find.text('正在上传 50%'), findsNothing);
    expect(
      find.byKey(const Key('direct-message-composer-upload-failure')),
      findsNothing,
    );
    expect(
      tester
          .widget<WenyouComposerSubmitButton>(
            find.byKey(const Key('direct-message-composer-submit')),
          )
          .enabled,
      isTrue,
    );
    expect(repository.sentDrafts, isEmpty);
  });

  testWidgets('连续消息保持分组且组末才有方向尾角', (tester) async {
    final createdAt = DateTime.now().subtract(const Duration(minutes: 2));
    final repository = _FakeRepository(
      messages: [
        _textMessage(
          id: 'group-first',
          senderId: 'user-2',
          content: '第一条',
          createdAt: createdAt,
        ),
        _textMessage(
          id: 'group-last',
          senderId: 'user-2',
          content: '第二条',
          createdAt: createdAt.add(const Duration(seconds: 20)),
        ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
    final repository = _FakeRepository(messages: [_outgoingImageMessage()]);
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
    final repository = _FakeRepository(
      conversation: _incomingRequest(),
      messages: [_incomingImageMessage()],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
    final repository = _FakeRepository(
      messages: [
        for (var index = 0; index < 24; index += 1)
          _textMessage(
            id: 'message-$index',
            senderId: index.isEven ? 'user-2' : 'user-1',
            content: '用于填满时间线的消息 $index',
            createdAt: base.add(Duration(minutes: index)),
          ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
      _textMessage(
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
    final repository = _FakeRepository(
      messages: [
        for (var index = 0; index < 30; index += 1)
          _textMessage(
            id: 'initial-$index',
            senderId: index.isEven ? 'user-2' : 'user-1',
            content: '初始消息 $index',
            createdAt: base.add(Duration(minutes: index)),
          ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
      final repository = _FakeRepository();
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repository),
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
    final repository = _FakeRepository();
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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
    expect(tester.getCenter(field).dy, closeTo(tester.getCenter(send).dy, 8));
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
    await tester.enterText(field, '长' * 900);
    await tester.pump();
    expect(find.text('100'), findsOneWidget);
    expect(
      find.byKey(const Key('direct-message-composer-character-count')),
      findsOneWidget,
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
      final repository = _FakeRepository();
      final router = _router();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(repository),
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
    final repository = _FakeRepository(
      messages: [
        _textMessage(
          id: 'golden-keyboard-incoming',
          senderId: 'user-2',
          content: '你好',
          createdAt: DateTime(2024, 1, 1, 9),
        ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('direct-message-composer-dock')),
      matchesGoldenFile('goldens/direct_message_composer_keyboard_360.png'),
    );
  });

  testWidgets('600dp 私信气泡分组视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 760);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final base = DateTime(2024, 1, 1, 9);
    final repository = _FakeRepository(
      messages: [
        _textMessage(
          id: 'golden-incoming-1',
          senderId: 'user-2',
          content: '今天的团期还是晚上八点。',
          createdAt: base,
        ),
        _textMessage(
          id: 'golden-incoming-2',
          senderId: 'user-2',
          content: '地图和人物卡我已经整理好了。',
          createdAt: base.add(const Duration(seconds: 30)),
        ),
        _textMessage(
          id: 'golden-mine',
          senderId: 'user-1',
          content: '收到，我会提前上线。',
          createdAt: base.add(const Duration(minutes: 1)),
        ),
      ],
    );
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(repository),
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

List<Override> _overrides(_FakeRepository repository) {
  return [
    directMessagesEnabledProvider.overrideWithValue(true),
    stickersEnabledProvider.overrideWithValue(false),
    directMessageRepositoryProvider.overrideWithValue(repository),
    directConversationControllerProvider.overrideWith((ref, conversationId) {
      return DirectConversationController(
        conversationId,
        repository,
        pollInterval: Duration.zero,
      );
    }),
    directUnreadControllerProvider.overrideWith((ref) {
      return DirectUnreadController(repository, autoStart: false);
    }),
  ];
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/messages/conversation-1',
    routes: [
      GoRoute(
        path: '/messages/:conversationId',
        builder: (_, state) => Consumer(
          builder: (_, ref, _) => DirectConversationPage(
            conversationId: state.pathParameters['conversationId']!,
            onReportMessage: (reportContext, messageId) => showWenyouReportFlow(
              context: reportContext,
              ref: ref,
              target: ReportTarget.directMessage(messageId),
              targetLabel: '这条私信',
              returnTo: '/messages/${state.pathParameters['conversationId']!}',
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        name: 'user-profile',
        builder: (_, state) =>
            Scaffold(body: Text('用户=${state.pathParameters['userId']}')),
      ),
    ],
  );
}

class _FakeRepository implements DirectMessageRepository {
  _FakeRepository({
    DirectConversation? conversation,
    List<DirectMessage>? messages,
    this.failSendOnce = false,
  }) : conversation = conversation ?? _acceptedConversation(),
       messages = messages ?? [_incomingTextMessage()];

  DirectConversation conversation;
  final List<DirectMessage> messages;
  final List<DirectMessage> pendingAfterMessages = [];
  bool failSendOnce;
  final List<DirectMessageDraft> sentDrafts = [];
  final List<String> recalledIds = [];
  final List<bool> archiveValues = [];
  final List<bool> requestActions = [];

  @override
  Future<DirectConversation> fetchConversation(String conversationId) async {
    return conversation;
  }

  @override
  Future<CursorPage<DirectMessage>> fetchMessages({
    required String conversationId,
    String? cursor,
    String? after,
    int limit = 30,
  }) async {
    if (after != null) {
      final pending = List<DirectMessage>.of(pendingAfterMessages);
      pendingAfterMessages.clear();
      return CursorPage(items: pending, hasMore: false);
    }
    return CursorPage(items: List.unmodifiable(messages), hasMore: false);
  }

  @override
  Future<DirectMessage> sendMessage({
    required String conversationId,
    required DirectMessageDraft draft,
  }) async {
    sentDrafts.add(draft);
    if (failSendOnce) {
      failSendOnce = false;
      throw const ApiFailure(userMessage: '网络暂时不可用。');
    }
    final message = DirectMessage(
      id: 'sent-1',
      conversationId: conversationId,
      senderId: 'user-1',
      recipientId: 'user-2',
      content: draft.content,
      createdAt: DateTime.now(),
    );
    messages.add(message);
    return message;
  }

  @override
  Future<DirectConversation> handleRequest({
    required String conversationId,
    required bool accept,
  }) async {
    requestActions.add(accept);
    conversation = accept ? _acceptedConversation() : _declinedConversation();
    if (!accept) messages.clear();
    return conversation;
  }

  @override
  Future<DirectConversation> setArchived({
    required String conversationId,
    required bool archived,
  }) async {
    archiveValues.add(archived);
    conversation = conversation.copyWith(
      archivedAt: archived ? DateTime.now() : null,
    );
    return conversation;
  }

  @override
  Future<DirectRecallResult> recall(String messageId) async {
    recalledIds.add(messageId);
    return const DirectRecallResult(conversationCanceled: false);
  }

  @override
  Future<DirectUnreadCounts> fetchUnreadCounts() async {
    return const DirectUnreadCounts(unreadMessages: 0, pendingRequests: 0);
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String throughMessageId,
  }) async {}

  @override
  Future<CursorPage<DirectConversation>> fetchConversations({
    required DirectConversationView view,
    String? cursor,
    int limit = 20,
  }) => throw UnimplementedError();

  @override
  Future<DirectConversationLookup> findByUser(String userId) =>
      throw UnimplementedError();

  @override
  Future<DirectConversationStart> createConversation({
    required String recipientId,
    required DirectMessageDraft draft,
  }) => throw UnimplementedError();
}

class _FakeReportRepository implements ReportRepository {
  final inputs = <ReportInput>[];

  @override
  Future<ReportResult> create(ReportInput input) async {
    inputs.add(input);
    return ReportResult(
      id: 'report-${inputs.length}',
      target: input.target,
      reason: input.reason,
      createdAt: DateTime.utc(2026, 8, 21),
    );
  }
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

SessionTokens _tokens(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-token',
  );
}

class _FakeImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'draft.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      ),
    );
  }
}

class _FailingMediaUploadGateway implements MediaUploadGateway {
  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: 1,
        totalBytes: input.bytes.length,
      ),
    );
    return _TestMediaUploadOperation(
      Future.error(const ApiFailure(userMessage: '图片上传失败。')),
    );
  }
}

class _RetryingMediaUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    if (inputs.length == 1) {
      return _TestMediaUploadOperation(
        Future.error(const ApiFailure(userMessage: '请稍后重试上传。')),
      );
    }
    return _TestMediaUploadOperation(
      Future.value(
        const UploadedEditorImage(
          mediaId: 'media-retried',
          url: 'https://wenyou.site/media/retried.png',
        ),
      ),
    );
  }
}

class _BlockingMediaUploadGateway implements MediaUploadGateway {
  final operation = _BlockingMediaUploadOperation();

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length ~/ 2,
        totalBytes: input.bytes.length,
      ),
    );
    return operation;
  }
}

class _BlockingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final Completer<UploadedEditorImage> _result =
      Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _result.future;

  @override
  void cancel() => cancelled = true;
}

class _TestMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  _TestMediaUploadOperation(this.result);

  @override
  final Future<UploadedEditorImage> result;

  @override
  void cancel() {}
}

DirectMessageUser _user() {
  return const DirectMessageUser(
    id: 'user-2',
    username: '小油',
    isDeactivated: false,
  );
}

DirectConversation _acceptedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.accepted,
    requestDirection: DirectRequestDirection.none,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: true,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectConversation _incomingRequest() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.pending,
    requestDirection: DirectRequestDirection.incoming,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: true,
    canDecline: true,
    isBlocked: false,
  );
}

DirectConversation _declinedConversation() {
  return DirectConversation(
    id: 'conversation-1',
    status: DirectConversationStatus.declined,
    requestDirection: DirectRequestDirection.none,
    otherUser: _user(),
    unreadCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    canSend: false,
    canAccept: false,
    canDecline: false,
    isBlocked: false,
  );
}

DirectMessage _incomingTextMessage() {
  return DirectMessage(
    id: 'incoming-1',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    content: '你好',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

DirectMessage _textMessage({
  required String id,
  required String senderId,
  required String content,
  required DateTime createdAt,
}) {
  return DirectMessage(
    id: id,
    conversationId: 'conversation-1',
    senderId: senderId,
    recipientId: senderId == 'user-2' ? 'user-1' : 'user-2',
    content: content,
    createdAt: createdAt,
  );
}

DirectMessage _incomingImageMessage() {
  return DirectMessage(
    id: 'incoming-image',
    conversationId: 'conversation-1',
    senderId: 'user-2',
    recipientId: 'user-1',
    media: const DirectMessageMedia(
      id: 'media-1',
      url: 'https://cdn.wenyou.site/private-image.png',
      isSticker: false,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );
}

DirectMessage _outgoingImageMessage() {
  return DirectMessage(
    id: 'outgoing-image',
    conversationId: 'conversation-1',
    senderId: 'user-1',
    recipientId: 'user-2',
    media: const DirectMessageMedia(
      id: 'media-outgoing',
      url: 'https://cdn.wenyou.site/outgoing-image.png',
      width: 800,
      height: 1169,
      isSticker: false,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );
}

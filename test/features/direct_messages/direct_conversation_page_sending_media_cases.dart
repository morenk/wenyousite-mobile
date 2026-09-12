import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_internal_reference_text.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_ui.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/reports/application/report_repository_ports.dart';
import 'package:wenyousite_mobile/features/reports/domain/report_models.dart';
import 'direct_conversation_page_test_support.dart';

void registerDirectConversationPageSendingMediaCases() {
  testWidgets('已接受会话可发送、撤回并切换归档状态', (tester) async {
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

    expect(find.text('你好'), findsOneWidget);
    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      '发送内容',
    );
    await tester.pump();
    final composerField = tester.widget<QuillEditor>(
      find.byKey(const Key('direct-message-composer-field')),
    );
    expect(composerField.focusNode.hasFocus, isTrue);
    await tester.tap(find.text('你好'));
    await tester.pump();
    expect(composerField.focusNode.hasFocus, isFalse);
    expect(
      directConversationPageTestAtomicEditorPlainText(
        tester,
        composerField.key!,
      ),
      '发送内容',
    );

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

  testWidgets('完整私信渲染邀请传送门并保留导航、长按与 label 复制', (tester) async {
    const raw =
        '入口 [https://wenyou.site/join/AbCdEfGh_123-XYZ]'
        '(/join/AbCdEfGh_123-XYZ)';
    String? copiedText;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final repository = DirectConversationPageTestFakeRepository(
      messages: [
        directConversationPageTestTextMessage(
          id: 'portal-invite',
          senderId: 'user-2',
          content: raw,
          createdAt: DateTime(2024, 1, 1, 9),
        ),
        directConversationPageTestTextMessage(
          id: 'portal-named',
          senderId: 'user-1',
          content: '查看 [私密团入口](/join/AbCdEfGh_123-XYZ)',
          createdAt: DateTime(2024, 1, 1, 9, 1),
        ),
        directConversationPageTestTextMessage(
          id: 'portal-invalid',
          senderId: 'user-2',
          content: 'https://wenyou.site/join/too-short',
          createdAt: DateTime(2024, 1, 1, 9, 2),
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

    final portals = find.byType(WenyouInternalReferenceChip);
    final invitePortal = find.descendant(
      of: find.byKey(const ValueKey('direct-message-actions-portal-invite')),
      matching: find.byType(WenyouInternalReferenceChip),
    );
    expect(portals, findsNWidgets(2));
    expect(invitePortal, findsOneWidget);
    expect(find.text('传送门'), findsOneWidget);
    expect(find.text('私密团入口'), findsOneWidget);
    expect(find.text('https://wenyou.site/join/too-short'), findsOneWidget);
    expect(
      find.text('https://wenyou.site/join/AbCdEfGh_123-XYZ'),
      findsNothing,
    );

    await tester.longPress(invitePortal);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('direct-message-copy-portal-invite')),
    );
    await tester.pumpAndSettle();
    expect(copiedText, '入口 传送门');

    await tester.tap(invitePortal);
    await tester.pumpAndSettle();
    expect(find.text('邀请=AbCdEfGh_123-XYZ'), findsOneWidget);
  });

  testWidgets('私聊邀请链接发送前成为可混排原子且发送规范正文', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
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

    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      url,
    );
    await tester.pump();

    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('站内传送门：传送门'), findsOneWidget);

    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      repository.sentDrafts.single.content,
      '[传送门](/join/AbCdEfGh_123-XYZ)',
    );
    expect(
      find.byKey(const Key('atomic-editor-internal-reference')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('direct-message-actions-sent-1')),
        matching: find.byType(WenyouInternalReferenceChip),
      ),
      findsOneWidget,
    );
  });

  testWidgets('收到且未撤回的私信可举报，并提交消息目标', (tester) async {
    final repository = DirectConversationPageTestFakeRepository();
    final reportRepository = DirectConversationPageTestFakeReportRepository();
    final session = SessionController(
      DirectConversationPageTestMemoryTokenStore(),
      DirectConversationPageTestFakeSessionRemote(),
    );
    await session.authenticate(directConversationPageTestTokens('user-1'));
    final router = directConversationPageTestRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...directConversationPageTestOverrides(repository),
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
    final repository = DirectConversationPageTestFakeRepository(
      failSendOnce: true,
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

    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
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
    final repository = DirectConversationPageTestFakeRepository();
    final router = directConversationPageTestRouter();
    final gateway = DirectConversationPageTestFailingMediaUploadGateway();
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

    final field = find.byKey(const Key('direct-message-composer-field'));
    final emptySend = tester.widget<WenyouComposerSubmitButton>(
      find.byKey(const Key('direct-message-composer-submit')),
    );
    expect(emptySend.enabled, isFalse);
    directConversationPageTestReplaceAtomicEditor(
      tester,
      const Key('direct-message-composer-field'),
      '带图消息',
    );
    await tester.tapAt(tester.getTopLeft(field) + const Offset(24, 20));
    await tester.pump();
    final editable = tester.widget<QuillEditor>(
      find.byKey(const Key('direct-message-composer-field')),
    );
    final expectedSelection = editable.controller.selection;
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();
    expect(gateway.inputs, isEmpty);
    expect(
      find.byKey(const Key('direct-message-composer-attachment')),
      findsOneWidget,
    );
    final selected = tester.widget<QuillEditor>(
      find.byKey(const Key('direct-message-composer-field')),
    );
    expect(selected.focusNode.hasFocus, isTrue);
    expect(
      selected.controller.selection.baseOffset,
      expectedSelection.baseOffset,
    );
    expect(
      selected.controller.selection.extentOffset,
      expectedSelection.extentOffset,
    );
    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('带图消息'), findsOneWidget);
    expect(gateway.inputs, hasLength(1));
    expect(
      find.byKey(const Key('direct-message-pending-local-image')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'direct-message-delivery-failed-',
            ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('direct-message-composer-attachment')),
      findsNothing,
    );
    expect(
      directConversationPageTestAtomicEditorPlainText(
        tester,
        const Key('direct-message-composer-field'),
      ),
      isEmpty,
    );
    expect(repository.sentDrafts, isEmpty);
  });

  testWidgets('图片上传失败后重试同一文件，完成后才允许发送', (tester) async {
    final repository = DirectConversationPageTestFakeRepository();
    final router = directConversationPageTestRouter();
    final gateway = DirectConversationPageTestRetryingMediaUploadGateway();
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
      '重试图片',
    );
    await tester.tap(find.byKey(const Key('direct-message-composer-image')));
    await tester.pump();
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    await tester.pumpAndSettle();

    expect(gateway.inputs, isEmpty);
    expect(
      find.byKey(const Key('direct-message-composer-attachment')),
      findsOneWidget,
    );
    var send = tester.widget<WenyouComposerSubmitButton>(
      find.byKey(const Key('direct-message-composer-submit')),
    );
    expect(send.enabled, isTrue);

    await tester.tap(find.byKey(const Key('direct-message-composer-submit')));
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(1));
    final failureButton = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'direct-message-delivery-failed-',
          ),
    );
    await tester.tap(failureButton);
    await tester.pumpAndSettle();
    final retry = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith(
            'direct-message-retry-',
          ),
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(gateway.inputs, hasLength(2));
    expect(identical(gateway.inputs.first, gateway.inputs.last), isTrue);
    expect(gateway.inputs.first.purpose, MediaUploadPurpose.directMessage);
    expect(repository.sentDrafts.single.content, '重试图片');
    expect(repository.sentDrafts.single.mediaId, 'media-retried');
  });
}

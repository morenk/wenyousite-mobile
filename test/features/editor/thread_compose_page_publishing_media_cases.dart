import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_theme_tokens.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/models/editor_models.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_snapshot_store.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/threads/application/thread_compose_controller.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_compose_models.dart';
import 'thread_compose_page_test_support.dart';

void registerThreadComposePagePublishingMediaCases() {
  testWidgets('加载态可渲染', (tester) async {
    final controller = ThreadComposeController(
      ThreadComposePageTestFakeRepository(),
      ThreadComposePageTestMemorySnapshotStore(),
      knownOwnerId: 'user-one',
      autoStart: false,
    );

    await threadComposePageTestPumpPage(tester, controller);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('恢复本地主题快照并渲染真实创作表单', (tester) async {
    final store = ThreadComposePageTestMemorySnapshotStore(
      snapshot: LocalEditorSnapshot(
        id: DatabaseEditorSnapshotStore.threadSnapshotId('user-one'),
        contextType: EditorContextType.thread,
        body: '恢复的主题正文',
        metadataJson: const ThreadSnapshotMetadata(
          ownerId: 'user-one',
          title: '恢复的标题',
          categorySlug: 'TRPG',
          visibility: ThreadComposeVisibility.private,
          tags: ['奇幻', '跑团'],
        ).toJson(),
        clientRequestId: threadComposePageTestRequestId,
        updatedAt: DateTime.utc(2026, 8, 10),
      ),
    );
    final controller = await threadComposePageTestReadyController(store);

    await threadComposePageTestPumpPage(tester, controller);

    expect(find.text('已恢复上次未完成的本地内容。'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('compose-title')))
          .controller!
          .text,
      '恢复的标题',
    );
    expect(find.byKey(const Key('compose-title-label')), findsOneWidget);
    expect(controller.state.body, '恢复的主题正文');
    expect(find.byKey(const Key('compose-body')), findsOneWidget);
    expect(
      tester
          .widget<QuillEditor>(find.byKey(const Key('compose-body')))
          .config
          .paintCursorAboveText,
      isTrue,
    );
    expect(find.byType(MentionSuggestions), findsOneWidget);
    expect(
      tester
          .widget<MentionSuggestions>(find.byType(MentionSuggestions))
          .threadId,
      isNull,
    );
    expect(find.byKey(const Key('compose-remote-drafts')), findsOneWidget);
    expect(find.byKey(const Key('compose-save-draft')), findsNothing);

    await tester.tap(find.byKey(const Key('compose-remote-drafts')));
    await tester.pumpAndSettle();
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);
    expect(find.byKey(const Key('compose-save-draft')), findsOneWidget);

    await tester.tap(find.byKey(const Key('compose-save-draft')));
    await tester.pumpAndSettle();
    expect(find.text('已保存到云端草稿'), findsOneWidget);
  });

  testWidgets('发布前在页面内显示验证错误且不调用后端创建', (tester) async {
    final repository = ThreadComposePageTestFakeRepository();
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
      repository: repository,
    );
    await threadComposePageTestPumpPage(tester, controller);
    final publish = find.byKey(const Key('compose-publish'));
    await tester.ensureVisible(publish);
    final publishButton = tester.widget<FilledButton>(publish);
    expect(
      publishButton.style?.backgroundColor?.resolve({}),
      WenyouThemeTokens.light.brandSurface,
    );
    expect(
      publishButton.style?.foregroundColor?.resolve({}),
      WenyouThemeTokens.light.onBrandSurface,
    );

    await tester.tap(publish);
    await tester.pump();

    expect(find.text('请填写主题标题。'), findsOneWidget);
    expect(repository.createCalls, 0);
  });

  testWidgets('页面插入分隔线后发布载荷保持独占块且没有额外空段', (tester) async {
    final repository = ThreadComposePageTestFakeRepository();
    final controller =
        await threadComposePageTestReadyController(
            ThreadComposePageTestMemorySnapshotStore(),
            repository: repository,
          )
          ..updateTitle('分隔线主题')
          ..updateCategory('TRPG')
          ..updateBody('上文下文');
    await threadComposePageTestPumpPage(tester, controller);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    editor.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('editor-horizontal-rule')));
    await tester.pump();
    expect(await controller.publish(), 'thread-one');
    await tester.pump();

    const expected = '上文\n\n---\n\n下文';
    expect(repository.createPayload?.body, expected);
    expect(repository.savedBody, expected);
    expect(repository.savedBody, isNot(contains('<br />')));
    expect(controller.state.publishedThreadId, 'thread-one');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: repository.savedBody!,
            enablePlainTextFastPath: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<WenyouMarkdown>(find.byType(WenyouMarkdown)).data,
      expected,
    );
    expect(find.text('上文'), findsOneWidget);
    expect(find.text('下文'), findsOneWidget);
  });

  testWidgets('页面点击居中后立即发布仍把 marker 写入创建和聚合载荷', (tester) async {
    const expected = '[wenyousite-align-v1-center]: #\n居中发布正文';
    final repository = ThreadComposePageTestFakeRepository();
    final controller =
        await threadComposePageTestReadyController(
            ThreadComposePageTestMemorySnapshotStore(),
            repository: repository,
          )
          ..updateTitle('居中发布主题')
          ..updateCategory('TRPG')
          ..updateBody('居中发布正文');
    await threadComposePageTestPumpPage(
      tester,
      controller,
      markdownAlignment: true,
      withThreadRoute: true,
    );
    final editorController = tester
        .widget<QuillEditor>(find.byKey(const Key('compose-body')))
        .controller;
    editorController.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-align-center')));
    await tester.pump();
    expect(
      MarkdownDeltaCodec.encode(editorController.document.toDelta()),
      expected,
    );
    expect(controller.state.body, '居中发布正文');

    await tester.tap(find.byKey(const Key('compose-publish')));
    await tester.pumpAndSettle();

    expect(repository.createPayload?.body, expected);
    expect(repository.savedBody, expected);
    expect(find.byKey(const Key('published-thread-route')), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WenyouMarkdown(
            data: repository.savedBody!,
            enablePlainTextFastPath: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MarkdownBody>(
            find.descendant(
              of: find.byKey(
                const ValueKey('wenyou-markdown-segment-0-center'),
              ),
              matching: find.byType(MarkdownBody),
            ),
          )
          .styleSheet!
          .textAlign,
      WrapAlignment.center,
    );
  });

  testWidgets('主题正文和原子表情共同进入创建及聚合保存载荷', (tester) async {
    const expected =
        '前文![表情]($threadComposePageTestComposeStickerUrl '
        '"wenyousite-sticker:v1:$threadComposePageTestComposeStickerAssetId")后文';
    final repository = ThreadComposePageTestFakeRepository();
    final controller =
        await threadComposePageTestReadyController(
            ThreadComposePageTestMemorySnapshotStore(),
            repository: repository,
          )
          ..updateTitle('混合正文主题')
          ..updateCategory('TRPG')
          ..updateBody('前文后文');
    await threadComposePageTestPumpPage(
      tester,
      controller,
      stickerRepository: ThreadComposePageTestComposeStickerRepository(),
    );
    final editorController = tester
        .widget<QuillEditor>(find.byKey(const Key('compose-body')))
        .controller;
    editorController.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    editorController.formatSelection(Attribute.bold);

    final promotedSticker = find.byKey(const Key('editor-sticker'));
    if (promotedSticker.evaluate().isEmpty) {
      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byTooltip('表情包').hitTestable());
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('收藏表情'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('收藏表情'));
    await tester.pumpAndSettle();

    expect(controller.state.body, expected);
    await tester.tap(find.byKey(const Key('compose-publish')));
    await tester.pumpAndSettle();
    expect(repository.createPayload?.body, expected);
    expect(repository.savedBody, expected);
  });

  testWidgets('图片上传完成后插入安全 Markdown 图片节点', (tester) async {
    final controller = await threadComposePageTestReadyController(
      ThreadComposePageTestMemorySnapshotStore(),
    );
    await threadComposePageTestPumpPage(
      tester,
      controller,
      picker: ThreadComposePageTestFakePicker(),
      mediaRepository: ThreadComposePageTestFakeMediaRepository(),
    );
    final imageButton = find.byKey(const Key('editor-image'));
    await tester.ensureVisible(imageButton);
    await tester.tap(imageButton);
    await threadComposePageTestConfirmImageCrop(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('描述这张图片'), findsNothing);
    expect(
      controller.state.body,
      contains('![图片](https://cdn.example.com/editor.png)'),
    );
  });

  testWidgets('图片上传中锁定发布，取消后保留原正文', (tester) async {
    final controller =
        await threadComposePageTestReadyController(
            ThreadComposePageTestMemorySnapshotStore(),
          )
          ..updateBody('保留的主题正文');
    final mediaRepository = ThreadComposePageTestBlockingMediaRepository();
    await threadComposePageTestPumpPage(
      tester,
      controller,
      picker: ThreadComposePageTestFakePicker(),
      mediaRepository: mediaRepository,
    );
    final publish = find.byKey(const Key('compose-publish'));
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);

    final imageButton = find.byKey(const Key('editor-image'));
    await tester.ensureVisible(imageButton);
    await tester.tap(imageButton);
    await threadComposePageTestConfirmImageCrop(tester);
    await tester.pump();

    expect(find.textContaining('正在上传图片'), findsOneWidget);
    expect(
      tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .any((indicator) => indicator.value == .5),
      isTrue,
    );
    expect(tester.widget<FilledButton>(publish).onPressed, isNull);

    await tester.tap(find.text('取消上传'));
    await tester.pump();
    await tester.pump();

    expect(mediaRepository.cancelled, isTrue);
    expect(find.textContaining('正在上传图片'), findsNothing);
    expect(controller.state.body, '保留的主题正文');
    expect(controller.state.body, isNot(contains('wenyou_image')));
    expect(tester.widget<FilledButton>(publish).onPressed, isNotNull);
  });

  testWidgets('上传中系统返回先取消任务且迟到成功不会写入草稿', (tester) async {
    final store = ThreadComposePageTestMemorySnapshotStore();
    final controller = await threadComposePageTestReadyController(store)
      ..updateBody('返回前正文');
    final gateway = ThreadComposePageTestLateCompletingMediaUploadGateway();
    await threadComposePageTestPumpPage(
      tester,
      controller,
      picker: ThreadComposePageTestFakePicker(),
      mediaGateway: gateway,
    );

    await tester.tap(find.byKey(const Key('editor-image')));
    await threadComposePageTestConfirmImageCrop(tester);
    expect(find.textContaining('正在上传图片'), findsOneWidget);

    await tester.binding.handlePopRoute();
    expect(gateway.operation.cancelled, isTrue);
    gateway.operation.complete(
      const UploadedEditorImage(
        mediaId: 'late-image',
        url: 'https://cdn.example.com/late.png',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(controller.state.body, '返回前正文');
    expect(controller.state.body, isNot(contains('late.png')));
    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 640),
    Size(360, 600),
    Size(400, 800),
    Size(600, 900),
  ]) {
    testWidgets('${size.width}dp 创作页和紧凑顶栏无布局溢出', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = await threadComposePageTestReadyController(
        ThreadComposePageTestMemorySnapshotStore(),
      );

      await threadComposePageTestPumpPage(tester, controller);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('compose-body')), findsOneWidget);
      expect(
        tester.getTopRight(find.byKey(const Key('compose-publish'))).dx,
        lessThanOrEqualTo(size.width),
      );
    });
  }

  for (final width in const [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 键盘写作固定完整格式栏且保留焦点选区', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final controller = await threadComposePageTestReadyController(
        ThreadComposePageTestMemorySnapshotStore(),
      );

      await threadComposePageTestPumpPage(tester, controller);
      final editor = tester.widget<QuillEditor>(
        find.byKey(const Key('compose-body')),
      );
      editor.focusNode.requestFocus();
      await tester.pump();
      final selection = editor.controller.selection;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final toolbar = find.byKey(const Key('compose-toolbar'));
      expect(toolbar, findsOneWidget);
      final dock = tester.widget<WenyouComposerDock>(toolbar);
      expect(dock.enabled, isTrue);
      expect(dock.surface, WenyouComposerSurface.page);
      expect(dock.capabilities, WenyouEditorCapabilities.richMarkdown);
      expect(controller.state.isSubmitting, isFalse);
      expect(find.text('当前格式组合暂时不能安全保存。'), findsNothing);
      expect(tester.getSize(toolbar).height, greaterThanOrEqualTo(48));
      if (width <= 400) {
        expect(find.bySemanticsLabel('正文格式工具'), findsOneWidget);
      }
      expect(find.byKey(const Key('editor-heading')), findsOneWidget);
      expect(find.byKey(const Key('editor-bold')), findsOneWidget);
      expect(find.byKey(const Key('editor-italic')), findsOneWidget);
      expect(find.byKey(const Key('editor-image')), findsOneWidget);
      expect(find.byKey(const Key('editor-more')), findsOneWidget);
      expect(editor.focusNode.hasFocus, isTrue);

      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pump();

      expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
      expect(editor.controller.selection, selection);
      expect(editor.focusNode.hasFocus, isTrue);
      if (width == 320) {
        await tester.tap(find.byTooltip('骰子'));
        await tester.pump();
        expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
        expect(find.byKey(const Key('editor-dice-insert')), findsOneWidget);
        expect(
          find.byKey(const Key('editor-task-tray-scroll')),
          findsOneWidget,
        );
      } else if (width == 360) {
        await tester.tap(find.byKey(const Key('editor-heading')));
        await tester.pump();
        expect(find.byKey(const Key('editor-heading-tray')), findsOneWidget);

        await tester.tap(find.text('H2'));
        await tester.pump();

        expect(find.byKey(const Key('editor-heading-tray')), findsNothing);
        expect(editor.controller.selection, selection);
        expect(
          editor.controller.getSelectionStyle().attributes['header']?.value,
          2,
        );
        expect(editor.focusNode.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    });
  }
}

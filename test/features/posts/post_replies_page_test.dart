import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/fake_image_crop_processor.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
        postThreadContextLookupProvider.overrideWithValue(
          (_) async =>
              const PostThreadContext(isPrivate: false, canManageThread: false),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-order')), findsNothing);
    expect(find.byKey(const Key('post-replies-author')), findsNothing);
    expect(find.byKey(const Key('post-replies-settings')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-count')), findsOneWidget);
    expect(find.text('远行主题'), findsOneWidget);
    expect(find.text('主线 · #8楼'), findsOneWidget);
    expect(find.text('楼中楼讨论'), findsNothing);
    expect(find.byType(WenyouMarkdown), findsNWidgets(3));
    for (final markdown in tester.widgetList<WenyouMarkdown>(
      find.byType(WenyouMarkdown),
    )) {
      expect(markdown.bodyFontSize, 17);
      expect(markdown.bodyHeight, 1.8);
    }
    final countCenter = tester.getCenter(
      find.byKey(const Key('post-replies-count')),
    );
    final settingsCenter = tester.getCenter(
      find.byKey(const Key('post-replies-settings')),
    );
    expect((countCenter.dy - settingsCenter.dy).abs(), lessThan(2));
    expect(
      tester.getSize(find.byKey(const Key('post-replies-settings'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.getTopLeft(find.text('原楼层内容')).dy, lessThan(150));
    expect(find.byKey(const Key('post-edit-reply-own')), findsNothing);
    expect(find.byKey(const Key('post-edit-reply-other')), findsNothing);
    expect(find.byKey(const Key('post-report-root')), findsNothing);
    expect(find.byKey(const Key('post-report-reply-own')), findsNothing);
    expect(find.byKey(const Key('post-report-reply-other')), findsNothing);
    expect(find.byKey(const Key('post-reply-compose')), findsOneWidget);
    expect(find.text('发表回复…'), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.longPress(find.byKey(const Key('post-card-root')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-card-action-root-link')), findsOneWidget);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('post-reply-reply-other')));
    await tester.pumpAndSettle();
    expect(find.text('复制'), findsOneWidget);
    expect(
      find.byKey(const Key('post-card-action-reply-other-link')),
      findsOneWidget,
    );
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pump();
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('回复 @楼层作者'), findsWidgets);
    expect(find.text('回复会平级挂在当前主楼层下。'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('post-composer-sheet'))).height,
      inInclusiveRange(400, 600),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-canvas'))).height,
      greaterThan(240),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-close'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('editor-submit'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('post-composer-body')),
        matching: find.byType(Card),
      ),
      findsNothing,
    );
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .focusNode
          .hasFocus,
      isTrue,
    );
    expect(
      tester
          .widget<MentionSuggestions>(find.byType(MentionSuggestions))
          .threadId,
      'thread',
    );
    await _replaceComposerText(tester, '新发表的回复');
    await tester.tap(find.byKey(const Key('post-composer-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsNothing);

    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller
          .document
          .toPlainText()
          .trim(),
      '新发表的回复',
    );
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.parentPostId, 'root');
    expect(repository.createInputs.single.replyToPostId, 'root');
    expect(find.text('新发表的回复'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await tester.longPress(find.byKey(const Key('post-reply-created')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('post-card-action-created-edit')),
      findsOneWidget,
    );
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    final editController = tester
        .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
        .widget
        .controller;
    expect(
      editController.selection.baseOffset,
      editController.document.length - 1,
    );
    await _replaceComposerText(tester, '编辑后的新回复');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();

    expect(repository.updateRequests.single.version, 1);
    expect(find.text('编辑后的新回复'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await tester.longPress(find.byKey(const Key('post-reply-created')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这条回复？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['created']);
    expect(find.text('编辑后的新回复'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('独立讨论中的头像进入个人主页且不会打开回复栏', (tester) async {
    final repository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));
    final router = GoRouter(
      initialLocation: '/discussion',
      routes: [
        GoRoute(
          path: '/discussion',
          builder: (context, state) =>
              const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
        GoRoute(
          path: '/users/:userId',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              leading: const BackButton(key: Key('avatar-user-back')),
            ),
            body: Text(
              state.pathParameters['userId']!,
              key: const Key('avatar-user-destination'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final rootAvatar = find.byKey(const Key('post-author-avatar-root'));
    expect(tester.getSize(rootAvatar).height, greaterThanOrEqualTo(48));
    await tester.tap(rootAvatar);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('avatar-user-destination')), findsOneWidget);
    expect(find.text('root-author'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);

    await tester.tap(find.byKey(const Key('avatar-user-back')));
    await tester.pumpAndSettle();
    final replyAvatar = find.byKey(const Key('post-author-avatar-reply-other'));
    await tester.ensureVisible(replyAvatar);
    await tester.tap(replyAvatar);
    await tester.pumpAndSettle();
    expect(find.text('author-2'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
  });

  testWidgets('私密主题管理者可删除他人回复但不会获得举报入口', (tester) async {
    final repository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
        postThreadContextLookupProvider.overrideWithValue(
          (_) async =>
              const PostThreadContext(isPrivate: true, canManageThread: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('thread-manager'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('post-reply-reply-other')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('post-card-action-reply-other-delete')),
      findsOneWidget,
    );
    expect(find.text('举报'), findsNothing);

    await tester.tap(
      find.byKey(const Key('post-card-action-reply-other-delete')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['reply-other']);
    expect(find.text('他人的回复'), findsNothing);
  });

  testWidgets('点击别人的楼中楼回复会把回复目标指向该回复', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final otherReply = find.byKey(const Key('post-card-reply-other'));
    await tester.ensureVisible(otherReply);
    await tester.tap(otherReply);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    expect(find.text('回复 @他人'), findsWidgets);
    await _replaceComposerText(tester, '针对这条回复继续讨论');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.parentPostId, 'root');
    expect(repository.createInputs.single.replyToPostId, 'reply-other');
    expect(tester.takeException(), isNull);
  });

  testWidgets('360dp 回复编辑器保持纯正文画布的视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: Key('post-composer-text-first-visual'),
            child: PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
    expect(tester.getTopLeft(find.text('远行主题')).dy, greaterThan(0));
    await expectLater(
      find.byKey(const Key('post-composer-sheet')),
      matchesGoldenFile('goldens/post_composer_text_first_360.png'),
    );

    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    final dock = tester.widget<WenyouComposerDock>(
      find.byKey(const Key('post-composer-toolbar')),
    );
    expect(dock.surface, WenyouComposerSurface.expandableSheet);
    expect(dock.capabilities, WenyouEditorCapabilities.richMarkdown);
    expect(editor.config.customStyles?.paragraph?.style.fontSize, 17);
    expect(editor.config.customStyles?.paragraph?.style.height, 1.8);
    expect(editor.focusNode.hasFocus, isTrue);
    final toolbar = find.byKey(const Key('post-composer-toolbar'));
    final unobstructedToolbarTop = tester.getTopLeft(toolbar).dy;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    final firstInsetFrameToolbarTop = tester.getTopLeft(toolbar).dy;

    expect(firstInsetFrameToolbarTop, lessThan(unobstructedToolbarTop));
    expect(toolbar, findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.byType(AnimatedPadding)),
      findsNothing,
    );
    expect(find.byKey(const Key('editor-heading')), findsOneWidget);
    expect(editor.focusNode.hasFocus, isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getTopLeft(toolbar).dy, firstInsetFrameToolbarTop);
    final selection = editor.controller.selection;

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pump();

    expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    expect(
      find.descendant(of: toolbar, matching: find.byType(AnimatedSize)),
      findsNothing,
    );
    expect(editor.controller.selection, selection);
    expect(editor.focusNode.hasFocus, isTrue);
  });

  testWidgets('回复编辑器选图后直接上传并写入统一图片节点', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        imageCropProcessorPortProvider.overrideWithValue(
          const FakePassThroughImageCropProcessor(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          _FakeEditorImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(
          RepositoryMediaUploadGateway(_FakeMediaUploadRepository()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-image')));
    await _confirmImageCrop(tester);
    await tester.pumpAndSettle();

    expect(find.text('描述这张图片'), findsNothing);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(
      MarkdownDeltaCodec.encode(editor.controller.document.toDelta()),
      contains('![图片](https://cdn.example.com/reply.png)'),
    );
  });

  testWidgets('回复图片上传失败后可复用原图片重试且只插入一次', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final uploadGateway = _FailingThenSuccessfulMediaUploadGateway();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        imageCropProcessorPortProvider.overrideWithValue(
          const FakePassThroughImageCropProcessor(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          _FakeEditorImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(uploadGateway),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await _replaceComposerText(tester, '保留的回复正文');

    await tester.tap(find.byKey(const Key('editor-image')));
    await _confirmImageCrop(tester);
    await tester.pumpAndSettle();

    expect(find.text('图片处理失败'), findsOneWidget);
    expect(find.text('问题编号：request-one'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-retry-upload')), findsOneWidget);
    var editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    var markdown = MarkdownDeltaCodec.encode(
      editor.controller.document.toDelta(),
    );
    expect(markdown, contains('保留的回复正文'));
    expect(markdown, isNot(contains('wenyou_image')));

    expect(editor.controller.readOnly, isFalse);
    expect(
      tester
          .widget<WenyouComposerDock>(
            find.byKey(const Key('post-composer-toolbar')),
          )
          .enabled,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('post-composer-retry-upload')));
    await tester.pumpAndSettle();

    editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    markdown = MarkdownDeltaCodec.encode(editor.controller.document.toDelta());
    expect(uploadGateway.inputs, hasLength(2));
    expect(uploadGateway.inputs[1], same(uploadGateway.inputs[0]));
    const retriedImage = '![图片](https://cdn.example.com/retried-reply.png)';
    expect(markdown.replaceFirst(retriedImage, ''), contains('保留的回复正文'));
    expect(retriedImage.allMatches(markdown), hasLength(1));
    expect(find.byKey(const Key('post-composer-retry-upload')), findsNothing);
  });

  testWidgets('上传中系统返回会在关闭 Sheet 前取消任务', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final uploadGateway = _LateCompletingMediaUploadGateway();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        imageCropProcessorPortProvider.overrideWithValue(
          const FakePassThroughImageCropProcessor(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          _FakeEditorImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(uploadGateway),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-image')));
    await _confirmImageCrop(tester);
    expect(find.textContaining('正在上传图片'), findsOneWidget);

    await tester.binding.handlePopRoute();
    expect(uploadGateway.operation.cancelled, isTrue);
    uploadGateway.operation.complete(
      const UploadedEditorImage(
        mediaId: 'late-reply-image',
        url: 'https://cdn.example.com/late-reply.png',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('发布请求在途时系统返回不会丢失待确认创建状态', (tester) async {
    final pendingCreate = Completer<PostItem>();
    final repository = _FakePostRepository(createCompleter: pendingCreate);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await _replaceComposerText(tester, '等待服务端确认的回复');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pump();

    expect(repository.createInputs, hasLength(1));
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('post-composer-body')),
    );
    expect(
      MarkdownDeltaCodec.encode(editor.controller.document.toDelta()),
      contains('等待服务端确认的回复'),
    );
    expect(editor.controller.readOnly, isTrue);

    pendingCreate.complete(_reply('created-pending', '等待服务端确认的回复', _author));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(repository.createInputs, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('首屏外目标回复定位后会释放用户滚动', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final replies = [
      for (var index = 1; index <= 20; index += 1)
        _reply(
          'long-reply-$index',
          '第 $index 条较长回复，用来确保目标一开始不在 Sliver 构建范围内。\n\n补充内容。',
          _otherAuthor,
        ),
      _reply('far-reply', '远端目标回复', _otherAuthor),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(
            _FakePostRepository(initialReplies: replies),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(
            threadId: 'thread',
            rootPostId: 'root',
            focusedReplyId: 'far-reply',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final targetFinder = find.byKey(const Key('post-reply-far-reply'));
    expect(targetFinder, findsOneWidget);
    final targetRect = tester.getRect(targetFinder);
    expect(targetRect.bottom, greaterThan(0));
    expect(targetRect.top, lessThan(640));

    final scrollView = tester.widget<CustomScrollView>(
      find.byKey(const Key('post-replies-list')),
    );
    final scrollController = scrollView.controller!;
    final locatedOffset = scrollController.offset;
    await tester.drag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, 240),
    );
    await tester.pumpAndSettle();
    final userOffset = scrollController.offset;
    expect(userOffset, lessThan(locatedOffset - 100));

    final scrollContext = tester.element(
      find.byKey(const Key('post-replies-list')),
    );
    ScrollMetricsNotification(
      metrics: scrollController.position,
      context: scrollContext,
    ).dispatch(scrollContext);
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(scrollController.offset, closeTo(userOffset, 1));
  });

  testWidgets('360dp 独立讨论保持正文优先视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const visualKey = Key('post-discussion-text-first-visual');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: visualKey,
            child: PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/post_discussion_text_first_360.png'),
    );
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 独立讨论压缩重复语境并按需展开设置', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stickersEnabledProvider.overrideWithValue(false),
            postRepositoryProvider.overrideWithValue(_FakePostRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('远行主题'), findsOneWidget);
      expect(find.text('主线 · #8楼'), findsOneWidget);
      expect(find.text('楼中楼讨论'), findsNothing);
      expect(find.text('原楼层内容'), findsOneWidget);
      expect(tester.getTopLeft(find.text('原楼层内容')).dy, lessThan(150));
      expect(find.byKey(const Key('post-replies-settings')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('post-replies-settings'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('320dp 与 2 倍系统字号仍保留正文和讨论设置', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-settings')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('post-replies-settings'))).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.byKey(const Key('post-replies-settings')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('post-replies-settings-sheet')),
      findsOneWidget,
    );
    expect(find.text('回复顺序'), findsOneWidget);
    expect(find.text('只看回复者'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('讨论设置从单一入口切换顺序和回复者', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(_FakePostRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('最早在前'), findsOneWidget);
    await tester.tap(find.byKey(const Key('post-replies-settings')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('post-replies-settings-sheet')),
      findsOneWidget,
    );
    expect(find.text('讨论设置'), findsOneWidget);
    expect(find.text('回复顺序'), findsOneWidget);
    expect(find.text('只看回复者'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(RadioListTile<PostReplyOrder>, '最新回复在前'),
    );
    await tester.pumpAndSettle();

    expect(find.text('最新在前'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('他人的回复')).dy,
      lessThan(tester.getTopLeft(find.text('自己的回复')).dy),
    );

    await tester.tap(find.byKey(const Key('post-replies-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RadioListTile<String>, '自己'));
    await tester.pumpAndSettle();

    expect(find.text('最新在前 · 自己'), findsOneWidget);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('楼中楼阅读滚动时顶栏和发表入口保持固定', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(_FakePostRepository()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('远行主题').hitTestable(), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('远行主题').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('post-reply-compose')), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('post-replies-list')),
      const Offset(0, 120),
    );
    await tester.pumpAndSettle();
    expect(find.text('远行主题').hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('post-reply-compose')), findsOneWidget);
  });
}

Future<void> _confirmImageCrop(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('editor-image-crop-dialog')), findsOneWidget);
  tester
      .widget<FilledButton>(find.byKey(const Key('image-crop-confirm')))
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

Future<void> _replaceComposerText(WidgetTester tester, String text) async {
  final editor = find.byKey(const Key('post-composer-body'));
  expect(editor, findsOneWidget);
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
  expect(state.widget.focusNode.hasFocus, isTrue);
  final rawEditor = tester.state<QuillRawEditorState>(
    find.descendant(of: editor, matching: find.byType(QuillRawEditor)),
  );
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(
        offset: rawEditor.textEditingValue.text.length,
      ),
    ),
  );
  await tester.idle();
}

class _FakePostRepository implements PostRepository {
  _FakePostRepository({this.createCompleter, List<PostItem>? initialReplies})
    : replies =
          initialReplies ??
          [
            _reply('reply-own', '自己的回复', _author),
            _reply('reply-other', '他人的回复', _otherAuthor),
          ];

  final Completer<PostItem>? createCompleter;
  final List<PostItem> replies;
  final List<PostCreateInput> createInputs = [];
  final List<({String id, String content, int version})> updateRequests = [];
  final List<String> removedIds = [];

  @override
  Future<PostItem> fetchPost(String postId) async {
    if (postId == 'root') return _root;
    return replies.singleWhere((post) => post.id == postId);
  }

  @override
  Future<PostReplyPage> fetchReplies({
    required String rootPostId,
    String? cursor,
    int limit = 20,
    PostReplyOrder order = PostReplyOrder.oldest,
    String? authorId,
  }) async {
    final filtered =
        replies
            .where((post) => authorId == null || post.author.id == authorId)
            .toList()
          ..sort(
            (left, right) => order == PostReplyOrder.oldest
                ? left.createdAt.compareTo(right.createdAt)
                : right.createdAt.compareTo(left.createdAt),
          );
    return CursorPage(items: filtered, hasMore: false);
  }

  @override
  Future<PostItem> create(PostCreateInput input) async {
    createInputs.add(input);
    final created = createCompleter == null
        ? _reply('created', input.content, _author)
        : await createCompleter!.future;
    replies.add(created);
    return created;
  }

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    updateRequests.add((id: postId, content: content, version: version));
    final index = replies.indexWhere((post) => post.id == postId);
    final previous = replies[index];
    final updated = _reply(
      postId,
      content,
      previous.author,
      version: version + 1,
    );
    replies[index] = updated;
    return updated;
  }

  @override
  Future<PostItem> upsertBody({
    required String subthreadId,
    required String content,
    int? version,
  }) {
    throw UnsupportedError('not used');
  }

  @override
  Future<void> remove(String postId) async {
    removedIds.add(postId);
    replies.removeWhere((post) => post.id == postId);
  }
}

const _author = PostAuthor(id: 'author-1', username: '自己', level: 3);
const _otherAuthor = PostAuthor(id: 'author-2', username: '他人', level: 2);
const _rootAuthor = PostAuthor(id: 'root-author', username: '楼层作者', level: 4);

final _rootCreatedAt = DateTime.now().subtract(const Duration(days: 2));

final _root = PostItem(
  id: 'root',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: _rootAuthor,
  content: '原楼层内容',
  version: 2,
  createdAt: _rootCreatedAt,
  updatedAt: _rootCreatedAt,
  isBody: false,
  isDeleted: false,
  floorNumber: 8,
  replyCount: 2,
  threadTitle: '远行主题',
  subthreadTitle: '主线',
);

PostItem _reply(
  String id,
  String content,
  PostAuthor author, {
  int version = 1,
}) {
  final createdAt = DateTime.now().subtract(
    Duration(days: id == 'reply-other' ? 1 : 2),
  );
  return PostItem(
    id: id,
    threadId: 'thread',
    subthreadId: 'subthread',
    author: author,
    content: content,
    version: version,
    createdAt: createdAt,
    updatedAt: createdAt,
    isBody: false,
    isDeleted: false,
    parentPostId: 'root',
    replyToPostId: 'root',
    replyToAuthor: _rootAuthor,
  );
}

SessionTokens _tokensFor(String userId) {
  final payload = base64Url.encode(utf8.encode(jsonEncode({'sub': userId})));
  return SessionTokens(
    accessToken: 'e30.$payload.signature',
    refreshToken: 'refresh-token',
  );
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
  Future<SessionTokens> refresh(String refreshToken) async =>
      _tokensFor('author-1');
}

class _FakeEditorImagePicker implements EditorImagePicker {
  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    return MediaUploadInput(
      filename: 'reply.png',
      declaredContentType: 'image/png',
      bytes: Uint8List.fromList(const [137, 80, 78, 71]),
    );
  }
}

class _FakeMediaUploadRepository implements MediaUploadRepository {
  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    return const UploadedEditorImage(
      mediaId: 'reply-image',
      url: 'https://cdn.example.com/reply.png',
    );
  }
}

class _FailingThenSuccessfulMediaUploadGateway implements MediaUploadGateway {
  final inputs = <MediaUploadInput>[];

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    inputs.add(input);
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.uploading,
        sentBytes: input.bytes.length,
        totalBytes: input.bytes.length,
      ),
    );
    if (inputs.length == 1) return _FailingMediaUploadOperation();
    return _SuccessfulMediaUploadOperation();
  }
}

class _FailingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  @override
  Future<UploadedEditorImage> get result => Future<UploadedEditorImage>.error(
    const ApiFailure(userMessage: '图片处理失败', requestId: 'request-one'),
  );

  @override
  void cancel() {}
}

class _SuccessfulMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  @override
  Future<UploadedEditorImage> get result => Future.value(
    const UploadedEditorImage(
      mediaId: 'retried-reply-image',
      url: 'https://cdn.example.com/retried-reply.png',
    ),
  );

  @override
  void cancel() {}
}

class _LateCompletingMediaUploadGateway implements MediaUploadGateway {
  final operation = _LateCompletingMediaUploadOperation();

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

class _LateCompletingMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  final _completer = Completer<UploadedEditorImage>();
  var cancelled = false;

  @override
  Future<UploadedEditorImage> get result => _completer.future;

  @override
  void cancel() => cancelled = true;

  void complete(UploadedEditorImage image) => _completer.complete(image);
}

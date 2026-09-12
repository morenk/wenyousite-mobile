import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/fake_image_crop_processor.dart';
import 'post_replies_page_test_support.dart';

void registerPostRepliesPageComposerMediaCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('新回复从百分之四十起步，工具托盘按需扩展且手动拖动优先', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await postRepliesPageTestPostContainer(
      PostRepliesPageTestFakePostRepository(),
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();

    double sheetHeight() =>
        tester.getSize(find.byKey(const Key('post-composer-viewport'))).height;

    final initialHeight = sheetHeight();
    expect(initialHeight, closeTo(320, 1));
    await tester.tap(find.byKey(const Key('post-composer-expand')));
    await tester.pumpAndSettle();
    expect(sheetHeight(), closeTo(752, 1));
    await tester.tap(find.byKey(const Key('post-composer-expand')));
    await tester.pumpAndSettle();
    expect(sheetHeight(), closeTo(initialHeight, 1));
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    final moreHeight = sheetHeight();
    expect(moreHeight, greaterThanOrEqualTo(initialHeight));

    await tester.tap(find.byTooltip('骰子'));
    await tester.pumpAndSettle();
    expect(sheetHeight(), greaterThanOrEqualTo(moreHeight));
    await tester.tap(find.byTooltip('返回格式工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(sheetHeight(), closeTo(initialHeight, 1));

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('post-composer-header')),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    final manualHeight = sheetHeight();
    expect(manualHeight, greaterThan(moreHeight));
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(sheetHeight(), closeTo(manualHeight, 1));

    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
    expect(find.byKey(const Key('editor-more-tray')), findsNothing);
  });

  testWidgets('独立讨论中的头像进入个人主页且不会打开回复栏', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-1'));
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
    final repository = PostRepliesPageTestFakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
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
        .authenticate(postRepliesPageTestTokensFor('thread-manager'));

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
    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-other');
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
    final repository = PostRepliesPageTestFakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-1'));

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
    await postRepliesPageTestReplaceComposerText(tester, '针对这条回复继续讨论');
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
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(
          PostRepliesPageTestFakePostRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-1'));

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
    expect(editor.config.paintCursorAboveText, isTrue);
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

    await tester.tap(find.byTooltip('骰子'));
    await tester.pump();

    expect(find.byKey(const Key('editor-dice-tray')), findsOneWidget);
    expect(find.byKey(const Key('editor-dice-insert')), findsOneWidget);
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    expect(find.byKey(const Key('editor-dice-status')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('post-composer-sheet')),
      matchesGoldenFile('goldens/post_composer_dice_keyboard_360.png'),
    );
  });

  testWidgets('回复编辑器选图后直接上传并写入统一图片节点', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(
          PostRepliesPageTestFakePostRepository(),
        ),
        imageCropProcessorPortProvider.overrideWithValue(
          const FakePassThroughImageCropProcessor(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          PostRepliesPageTestFakeEditorImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(
          RepositoryMediaUploadGateway(
            PostRepliesPageTestFakeMediaUploadRepository(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-1'));

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
    await postRepliesPageTestConfirmImageCrop(tester);
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
    final uploadGateway =
        PostRepliesPageTestFailingThenSuccessfulMediaUploadGateway();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          PostRepliesPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          PostRepliesPageTestFakeSessionRemote(),
        ),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(
          PostRepliesPageTestFakePostRepository(),
        ),
        imageCropProcessorPortProvider.overrideWithValue(
          const FakePassThroughImageCropProcessor(),
        ),
        editorImagePickerPortProvider.overrideWithValue(
          PostRepliesPageTestFakeEditorImagePicker(),
        ),
        mediaUploadGatewayPortProvider.overrideWithValue(uploadGateway),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-1'));
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
    await postRepliesPageTestReplaceComposerText(tester, '保留的回复正文');

    await tester.tap(find.byKey(const Key('editor-image')));
    await postRepliesPageTestConfirmImageCrop(tester);
    await tester.pumpAndSettle();

    expect(find.text('图片处理失败'), findsOneWidget);
    expect(find.textContaining('问题编号：request-one'), findsOneWidget);
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
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import '../../support/fake_image_crop_processor.dart';
import 'post_replies_page_test_support.dart';

void registerPostRepliesPageSessionEditingCases() {
  testWidgets('编辑回复失败不覆盖原内容且保留编辑稿可重试', (tester) async {
    var attempts = 0;
    final repository = PostRepliesPageTestFakePostRepository(
      onUpdate: ({required postId, required content, required version}) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '回复没有更新成功。',
            httpStatus: 503,
            requestId: 'discussion-update-request',
          );
        }
        return postRepliesPageTestReply(
          postId,
          content,
          postRepliesPageTestAuthor,
          version: version + 1,
        );
      },
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-own');
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-card-action-reply-own-edit')));
    await postRepliesPageTestPumpUi(tester);
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getSize(find.byKey(const Key('post-composer-viewport'))).height,
      closeTo(viewportHeight * .52, 1),
    );
    await postRepliesPageTestReplaceComposerText(tester, '编辑失败后保留的内容');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(find.text('回复没有更新成功。'), findsOneWidget);
    expect(
      find.textContaining('问题编号：discussion-update-request'),
      findsOneWidget,
    );
    expect(
      repository.replies.singleWhere((post) => post.id == 'reply-own').content,
      '自己的回复',
    );
    expect(
      MarkdownDeltaCodec.encode(
        tester
            .state<QuillEditorState>(
              find.byKey(const Key('post-composer-body')),
            )
            .widget
            .controller
            .document
            .toDelta(),
      ),
      contains('编辑失败后保留的内容'),
    );

    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(attempts, 2);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('编辑失败后保留的内容'), findsOneWidget);
    expect(find.text('自己的回复'), findsNothing);
  });

  testWidgets('会话切换丢弃旧账号迟到首屏并立即加载新会话', (tester) async {
    final staleLoad = Completer<PostItem>();
    var fetchPostCalls = 0;
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (postId) {
        fetchPostCalls += 1;
        if (fetchPostCalls == 1) return staleLoad.future;
        return Future.value(postRepliesPageTestRootWithContent('新会话楼层'));
      },
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await tester.pump();
    expect(fetchPostCalls, 1);
    expect(find.text('新会话楼层'), findsNothing);
    expect(find.text('旧账号迟到楼层'), findsNothing);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-2'));
    await postRepliesPageTestPumpUi(tester);

    expect(fetchPostCalls, greaterThanOrEqualTo(2));
    expect(find.text('新会话楼层'), findsOneWidget);

    staleLoad.complete(postRepliesPageTestRootWithContent('旧账号迟到楼层'));
    await postRepliesPageTestPumpUi(tester);

    expect(find.text('新会话楼层'), findsOneWidget);
    expect(find.text('旧账号迟到楼层'), findsNothing);
  });

  testWidgets('切号和退出登录关闭旧编辑器并清除内存草稿', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, '账号一的未发布草稿');

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-2'));
    await postRepliesPageTestPumpUi(tester);

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller
          .document
          .toPlainText()
          .trim(),
      isEmpty,
    );
    await postRepliesPageTestReplaceComposerText(tester, '账号二的未发布草稿');

    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await postRepliesPageTestPumpUi(tester);

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('登录后发表回复'), findsOneWidget);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-3'));
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    expect(
      tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller
          .document
          .toPlainText()
          .trim(),
      isEmpty,
    );
  });

  testWidgets('图片裁剪弹窗上切号只移除旧编辑器并保留同帧新根路由', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final navigatorKey = GlobalKey<NavigatorState>();
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
          navigatorKey: navigatorKey,
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, '旧账号不得发布的正文');
    await tester.tap(find.byKey(const Key('editor-image')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-image-crop-dialog')), findsOneWidget);
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);

    unawaited(
      navigatorKey.currentState!.push<void>(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => const Scaffold(
            body: SizedBox(key: Key('new-root-business-page')),
          ),
        ),
      ),
    );
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(postRepliesPageTestTokensFor('author-2'));
    await postRepliesPageTestPumpUi(tester);

    expect(find.byKey(const Key('new-root-business-page')), findsOneWidget);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    expect(repository.createInputs, isEmpty);

    navigatorKey.currentState!.pop();
    await postRepliesPageTestPumpUi(tester);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, '新账号允许发布的正文');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.content, '新账号允许发布的正文');
    expect(find.text('旧账号不得发布的正文'), findsNothing);
  });

  testWidgets('360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = PostRepliesPageTestFakePostRepository();
    final authorDirectory =
        PostRepliesPageTestMutablePostDiscussionAuthorDirectory();
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
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          authorDirectory,
        ),
        postThreadContextLookupProvider.overrideWithValue(
          (_) async =>
              const PostThreadContext(isPrivate: false, canManageThread: false),
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

    expect(authorDirectory.replyCalls, 1);
    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-order')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-author')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-settings')), findsNothing);
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
    final orderCenter = tester.getCenter(
      find.byKey(const Key('post-replies-order')),
    );
    expect((countCenter.dy - orderCenter.dy).abs(), lessThan(2));
    expect(
      tester.getSize(find.byKey(const Key('post-replies-order'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-replies-author'))).height,
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

    await postRepliesPageTestLongPressPostMetadata(tester, 'root');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-card-action-root-link')), findsOneWidget);
    expect(find.byKey(const Key('post-card-action-root-reply')), findsNothing);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-other');
    await tester.pumpAndSettle();
    expect(find.text('复制内容'), findsOneWidget);
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
      closeTo(400, 1),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-composer-canvas'))).height,
      greaterThan(160),
    );
    expect(find.byKey(const Key('post-composer-close')), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('post-composer-expand'))).height,
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
    await postRepliesPageTestReplaceComposerText(tester, '新发表的回复');
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    await postRepliesPageTestDismissPostComposerFromOutside(tester);
    expect(find.byKey(const Key('post-composer-body')), findsNothing);

    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('post-composer-viewport'))).height,
      closeTo(400, 1),
    );
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
    expect(authorDirectory.replyCalls, 2);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await postRepliesPageTestLongPressPostMetadata(tester, 'created');
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
    await postRepliesPageTestReplaceComposerText(tester, '编辑后的新回复');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();

    expect(repository.updateRequests.single.version, 1);
    expect(find.text('编辑后的新回复'), findsOneWidget);
    expect(authorDirectory.replyCalls, 2);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await postRepliesPageTestLongPressPostMetadata(tester, 'created');
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这条回复？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repository.removedIds, ['created']);
    expect(find.text('编辑后的新回复'), findsNothing);
    expect(authorDirectory.replyCalls, 3);
    expect(tester.takeException(), isNull);
  });
}

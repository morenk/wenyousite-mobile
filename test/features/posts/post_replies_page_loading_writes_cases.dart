import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'post_replies_page_test_support.dart';

void registerPostRepliesPageLoadingWritesCases() {
  testWidgets('楼中楼首屏加载失败展示问题编号并可重试', (tester) async {
    var attempts = 0;
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (postId) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '楼中楼暂时不可用。',
            httpStatus: 503,
            requestId: 'discussion-initial-request',
          );
        }
        return postRepliesPageTestRoot;
      },
    );
    final container = await postRepliesPageTestPostContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    expect(find.text('楼中楼讨论加载失败'), findsOneWidget);
    expect(find.text('楼中楼暂时不可用。'), findsOneWidget);
    expect(
      find.textContaining('问题编号：discussion-initial-request'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('post-replies-list')), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '重试'));
    await postRepliesPageTestPumpUi(tester);

    expect(attempts, 2);
    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-list')), findsOneWidget);
  });

  testWidgets('分页失败保留已加载回复并从原 cursor 重试', (tester) async {
    var pageAttempts = 0;
    final cursors = <String?>[];
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchReplies:
          ({required rootPostId, cursor, required order, authorId}) async {
            cursors.add(cursor);
            if (cursor == null) {
              return CursorPage(
                items: [
                  postRepliesPageTestReply(
                    'reply-own',
                    '已加载的回复',
                    postRepliesPageTestAuthor,
                  ),
                ],
                cursor: 'next-page',
                hasMore: true,
              );
            }
            pageAttempts += 1;
            if (pageAttempts == 1) {
              throw const ApiFailure(
                userMessage: '更多回复加载失败。',
                httpStatus: 503,
                requestId: 'discussion-page-request',
              );
            }
            return CursorPage(
              items: [
                postRepliesPageTestReply(
                  'reply-other',
                  '重试加载的回复',
                  postRepliesPageTestOtherAuthor,
                ),
              ],
              hasMore: false,
            );
          },
    );
    final container = await postRepliesPageTestPostContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    expect(find.text('已加载的回复'), findsOneWidget);
    expect(find.text('更多回复加载失败。'), findsOneWidget);
    expect(find.textContaining('问题编号：discussion-page-request'), findsOneWidget);
    expect(cursors, [null, 'next-page']);

    await tester.tap(find.widgetWithText(TextButton, '重试'));
    await postRepliesPageTestPumpUi(tester);

    expect(cursors, [null, 'next-page', 'next-page']);
    expect(find.text('已加载的回复'), findsOneWidget);
    expect(find.text('重试加载的回复'), findsOneWidget);
    expect(find.text('更多回复加载失败。'), findsNothing);
  });

  testWidgets('回复创建失败保留编辑内容且重试后只追加一次', (tester) async {
    var attempts = 0;
    final repository = PostRepliesPageTestFakePostRepository(
      onCreate: (input) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '回复没有发布成功。',
            httpStatus: 400,
            requestId: 'discussion-create-request',
          );
        }
        return postRepliesPageTestReply(
          'created-after-retry',
          input.content,
          postRepliesPageTestAuthor,
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
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, '应在失败后保留的回复');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(find.text('回复没有发布成功。'), findsOneWidget);
    expect(find.textContaining('问题编号：discussion-create-request'), findsNothing);
    expect(repository.createInputs, hasLength(1));
    expect(
      repository.replies.where((post) => post.id == 'created-after-retry'),
      isEmpty,
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
      contains('应在失败后保留的回复'),
    );

    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(repository.createInputs, hasLength(2));
    expect(
      repository.createInputs.map((input) => input.clientRequestId).toSet(),
      hasLength(1),
    );
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('应在失败后保留的回复'), findsOneWidget);
  });

  testWidgets('连续回车新建的空段进入实际回复发布载荷', (tester) async {
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
    await postRepliesPageTestReplaceComposerText(tester, '第一段\n\n第二段');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.content, '第一段\n<br />\n第二段');
  });

  for (final invalid in [false, true]) {
    testWidgets('真实回复${invalid ? '拒绝有损正文且保留编辑器' : '发布合并后的新旧粗体文字'}', (
      tester,
    ) async {
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
      final controller = tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller;
      controller.document = invalid
          ? (Document()..insert(0, '**源码字符**'))
          : Document.fromDelta(MarkdownDeltaCodec.decode('**甲乙**').delta);
      if (!invalid) {
        controller.updateSelection(
          const TextSelection.collapsed(offset: 1),
          ChangeSource.local,
        );
        controller.formatSelection(Attribute.bold);
        controller.replaceText(
          1,
          0,
          '新',
          const TextSelection.collapsed(offset: 2),
        );
      }
      final before = controller.document.toDelta().toJson();
      await tester.tap(find.byKey(const Key('editor-submit')));
      await postRepliesPageTestPumpUi(tester);
      if (invalid) {
        expect(repository.createInputs, isEmpty);
        expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);
        expect(controller.document.toDelta().toJson(), before);
      } else {
        expect(repository.createInputs.single.content, '**甲新乙**');
        expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      }
    });
  }

  testWidgets('回复正文和原子表情共同进入发布载荷并在列表回显', (tester) async {
    const expected =
        '前文![表情]($postRepliesPageTestStickerUrl '
        '"wenyousite-sticker:v1:$postRepliesPageTestStickerAssetId")后文';
    final repository = PostRepliesPageTestFakePostRepository();
    final stickerRepository = PostRepliesPageTestFakeStickerRepository();
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'author-1',
      stickerRepository: stickerRepository,
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
        GoRoute(
          path: '/stickers',
          name: 'me-stickers',
          builder: (context, state) => const SizedBox.shrink(),
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
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestReplaceComposerText(tester, '前文后文');
    final editorController = tester
        .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
        .widget
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
    await postRepliesPageTestPumpUi(tester);
    expect(find.bySemanticsLabel('收藏表情'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('收藏表情'));
    await postRepliesPageTestPumpUi(tester);

    expect(
      MarkdownDeltaCodec.encode(editorController.document.toDelta()),
      expected,
    );
    expect(
      editorController.document
          .toDelta()
          .operations
          .singleWhere(
            (operation) =>
                operation.data is Map &&
                (operation.data as Map).containsKey(
                  MarkdownDeltaCodec.stickerEmbed,
                ),
          )
          .attributes,
      isNull,
    );
    await tester.tap(find.byKey(const Key('editor-submit')));
    await postRepliesPageTestPumpUi(tester);

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.content, expected);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(
      tester
          .widgetList<WenyouMarkdown>(find.byType(WenyouMarkdown))
          .any((markdown) => markdown.data == expected),
      isTrue,
    );
  });

  for (final scenario in const [
    (
      label: '左对齐',
      content: '左对齐发布正文',
      alignmentKeys: [Key('editor-align-center'), Key('editor-align-left')],
      expected: '左对齐发布正文',
      segment: 'left',
    ),
    (
      label: '居中',
      content: '居中发布正文',
      alignmentKeys: [Key('editor-align-center')],
      expected: '[wenyousite-align-v1-center]: #\n居中发布正文',
      segment: 'center',
    ),
    (
      label: '居右',
      content: '居右发布正文',
      alignmentKeys: [Key('editor-align-right')],
      expected: '[wenyousite-align-v1-right]: #\n居右发布正文',
      segment: 'right',
    ),
  ]) {
    testWidgets('页面选择${scenario.label}后立即发布，载荷和字形位置一致', (tester) async {
      final repository = PostRepliesPageTestFakePostRepository();
      final container = await postRepliesPageTestPostContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
      await postRepliesPageTestPumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await postRepliesPageTestPumpUi(tester);
      await postRepliesPageTestReplaceComposerText(tester, scenario.content);
      final sheet = tester.widget<PostComposerSheet>(
        find.byType(PostComposerSheet),
      );
      final editorController = tester
          .state<QuillEditorState>(find.byKey(const Key('post-composer-body')))
          .widget
          .controller;
      editorController.updateSelection(
        const TextSelection.collapsed(offset: 2),
        ChangeSource.local,
      );

      await tester.tap(find.byKey(const Key('editor-more')));
      await tester.pump();
      for (final key in scenario.alignmentKeys) {
        await tester.tap(find.byKey(key));
        await tester.pump();
      }

      expect(
        MarkdownDeltaCodec.encode(editorController.document.toDelta()),
        scenario.expected,
      );
      expect(
        container.read(postComposerControllerProvider(sheet.target)).content,
        isNot(contains('wenyousite-align')),
      );

      await tester.tap(find.byKey(const Key('editor-submit')));
      await postRepliesPageTestPumpUi(tester);

      expect(repository.createInputs, hasLength(1));
      expect(repository.createInputs.single.content, scenario.expected);
      expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
      final card = find.byKey(const Key('post-card-created'));
      final textFinder = find.descendant(
        of: card,
        matching: find.text(scenario.content, findRichText: true),
      );
      final areaFinder = scenario.segment == 'left'
          ? find.descendant(
              of: card,
              matching: find.byKey(const Key('wenyou-markdown-plain-text')),
            )
          : find.descendant(
              of: card,
              matching: find.byKey(
                ValueKey('wenyou-markdown-segment-0-${scenario.segment}'),
              ),
            );
      expect(textFinder, findsOneWidget);
      expect(areaFinder, findsOneWidget);
      final area = tester.getRect(areaFinder);
      final glyphs = postRepliesPageTestGlyphRect(
        tester,
        textFinder,
        scenario.content.length,
      );
      switch (scenario.segment) {
        case 'left':
          expect(glyphs.left, closeTo(area.left, 1));
        case 'center':
          expect(glyphs.center.dx, closeTo(area.center.dx, 1));
        case 'right':
          expect(glyphs.right, closeTo(area.right, 1));
      }
    });
  }

  testWidgets('删除回复失败保留原内容并展示可诊断错误', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository(
      onRemove: (postId) async => throw const ApiFailure(
        userMessage: '回复没有删除成功。',
        httpStatus: 503,
        requestId: 'discussion-delete-request',
      ),
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
    await tester.tap(
      find.byKey(const Key('post-card-action-reply-own-delete')),
    );
    await postRepliesPageTestPumpUi(tester);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await postRepliesPageTestPumpUi(tester);

    expect(repository.removedIds, isEmpty);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('回复没有删除成功。'), findsOneWidget);
    expect(
      find.textContaining('问题编号：discussion-delete-request'),
      findsOneWidget,
    );
  });

  testWidgets('已删除的原楼层和回复都不暴露举报入口', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (postId) async =>
          postRepliesPageTestRootWithContent('已删除的原楼层', isDeleted: true),
      initialReplies: [
        postRepliesPageTestReply(
          'deleted-reply',
          '已删除的回复',
          postRepliesPageTestOtherAuthor,
          isDeleted: true,
        ),
      ],
    );
    final container = await postRepliesPageTestPostContainer(
      repository,
      userId: 'viewer',
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestLongPressPostMetadata(tester, 'root');
    await postRepliesPageTestPumpUi(tester);

    expect(find.byKey(const Key('post-card-action-root-report')), findsNothing);
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await postRepliesPageTestPumpUi(tester);

    await postRepliesPageTestLongPressPostMetadata(tester, 'deleted-reply');
    await postRepliesPageTestPumpUi(tester);

    expect(
      find.byKey(const Key('post-card-action-deleted-reply-report')),
      findsNothing,
    );
  });

  testWidgets('游客可举报公开主题的他人回复并在登录后精确返回', (tester) async {
    final repository = PostRepliesPageTestFakePostRepository();
    final container = await postRepliesPageTestPostContainer(repository);
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/discussion',
      routes: [
        GoRoute(
          path: '/discussion',
          builder: (context, state) =>
              const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => Scaffold(
            body: Text(
              state.uri.queryParameters['returnTo'] ?? '',
              key: const Key('guest-reply-report-login'),
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
    await postRepliesPageTestPumpUi(tester);
    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-other');
    await postRepliesPageTestPumpUi(tester);

    final reportAction = find.byKey(
      const Key('post-card-action-reply-other-report'),
    );
    expect(reportAction, findsOneWidget);
    await tester.tap(reportAction);
    await postRepliesPageTestPumpUi(tester);

    expect(find.byKey(const Key('guest-reply-report-login')), findsOneWidget);
    expect(
      find.text('/threads/thread/posts/root/replies?post=reply-other'),
      findsOneWidget,
    );
  });
}

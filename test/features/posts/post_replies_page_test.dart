import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_capabilities.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/mention_suggestions.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_controllers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/application/post_thread_context_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_discussion_author.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_composer_sheet.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_repository_ports.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

import '../../support/fake_image_crop_processor.dart';
import '../../support/foundation_test_fonts.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('楼中楼首屏加载失败展示问题编号并可重试', (tester) async {
    var attempts = 0;
    final repository = _FakePostRepository(
      onFetchPost: (postId) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '楼中楼暂时不可用。',
            httpStatus: 503,
            requestId: 'discussion-initial-request',
          );
        }
        return _root;
      },
    );
    final container = await _postContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);

    expect(find.text('楼中楼讨论加载失败'), findsOneWidget);
    expect(find.text('楼中楼暂时不可用。'), findsOneWidget);
    expect(
      find.textContaining('问题编号：discussion-initial-request'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('post-replies-list')), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '重试'));
    await _pumpUi(tester);

    expect(attempts, 2);
    expect(find.text('原楼层内容'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-list')), findsOneWidget);
  });

  testWidgets('分页失败保留已加载回复并从原 cursor 重试', (tester) async {
    var pageAttempts = 0;
    final cursors = <String?>[];
    final repository = _FakePostRepository(
      onFetchReplies:
          ({required rootPostId, cursor, required order, authorId}) async {
            cursors.add(cursor);
            if (cursor == null) {
              return CursorPage(
                items: [_reply('reply-own', '已加载的回复', _author)],
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
              items: [_reply('reply-other', '重试加载的回复', _otherAuthor)],
              hasMore: false,
            );
          },
    );
    final container = await _postContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);

    expect(find.text('已加载的回复'), findsOneWidget);
    expect(find.text('更多回复加载失败。'), findsOneWidget);
    expect(find.textContaining('问题编号：discussion-page-request'), findsOneWidget);
    expect(cursors, [null, 'next-page']);

    await tester.tap(find.widgetWithText(TextButton, '重试'));
    await _pumpUi(tester);

    expect(cursors, [null, 'next-page', 'next-page']);
    expect(find.text('已加载的回复'), findsOneWidget);
    expect(find.text('重试加载的回复'), findsOneWidget);
    expect(find.text('更多回复加载失败。'), findsNothing);
  });

  testWidgets('回复创建失败保留编辑内容且重试后只追加一次', (tester) async {
    var attempts = 0;
    final repository = _FakePostRepository(
      onCreate: (input) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '回复没有发布成功。',
            httpStatus: 400,
            requestId: 'discussion-create-request',
          );
        }
        return _reply('created-after-retry', input.content, _author);
      },
    );
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '应在失败后保留的回复');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await _pumpUi(tester);

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
    await _pumpUi(tester);

    expect(repository.createInputs, hasLength(2));
    expect(
      repository.createInputs.map((input) => input.clientRequestId).toSet(),
      hasLength(1),
    );
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('应在失败后保留的回复'), findsOneWidget);
  });

  testWidgets('连续回车新建的空段进入实际回复发布载荷', (tester) async {
    final repository = _FakePostRepository();
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '第一段\n\n第二段');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await _pumpUi(tester);

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.content, '第一段\n<br />\n第二段');
  });

  testWidgets('回复正文和原子表情共同进入发布载荷并在列表回显', (tester) async {
    const expected =
        '前文![表情]($_stickerUrl '
        '"wenyousite-sticker:v1:$_stickerAssetId")后文';
    final repository = _FakePostRepository();
    final stickerRepository = _FakeStickerRepository();
    final container = await _postContainer(
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
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '前文后文');
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
    await _pumpUi(tester);
    expect(find.bySemanticsLabel('收藏表情'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('收藏表情'));
    await _pumpUi(tester);

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
    await _pumpUi(tester);

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
      final repository = _FakePostRepository();
      final container = await _postContainer(
        repository,
        userId: 'author-1',
        markdownAlignment: true,
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(_postRepliesApp(container));
      await _pumpUi(tester);
      await tester.tap(find.byKey(const Key('post-reply-compose')));
      await _pumpUi(tester);
      await _replaceComposerText(tester, scenario.content);
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
      await _pumpUi(tester);

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
      final glyphs = _glyphRect(tester, textFinder, scenario.content.length);
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
    final repository = _FakePostRepository(
      onRemove: (postId) async => throw const ApiFailure(
        userMessage: '回复没有删除成功。',
        httpStatus: 503,
        requestId: 'discussion-delete-request',
      ),
    );
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await _longPressPostMetadata(tester, 'reply-own');
    await _pumpUi(tester);
    await tester.tap(
      find.byKey(const Key('post-card-action-reply-own-delete')),
    );
    await _pumpUi(tester);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await _pumpUi(tester);

    expect(repository.removedIds, isEmpty);
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('回复没有删除成功。'), findsOneWidget);
    expect(
      find.textContaining('问题编号：discussion-delete-request'),
      findsOneWidget,
    );
  });

  testWidgets('已删除的原楼层和回复都不暴露举报入口', (tester) async {
    final repository = _FakePostRepository(
      onFetchPost: (postId) async =>
          _rootWithContent('已删除的原楼层', isDeleted: true),
      initialReplies: [
        _reply('deleted-reply', '已删除的回复', _otherAuthor, isDeleted: true),
      ],
    );
    final container = await _postContainer(repository, userId: 'viewer');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await _longPressPostMetadata(tester, 'root');
    await _pumpUi(tester);

    expect(find.byKey(const Key('post-card-action-root-report')), findsNothing);
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await _pumpUi(tester);

    await _longPressPostMetadata(tester, 'deleted-reply');
    await _pumpUi(tester);

    expect(
      find.byKey(const Key('post-card-action-deleted-reply-report')),
      findsNothing,
    );
  });

  testWidgets('游客可举报公开主题的他人回复并在登录后精确返回', (tester) async {
    final repository = _FakePostRepository();
    final container = await _postContainer(repository);
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
    await _pumpUi(tester);
    await _longPressPostMetadata(tester, 'reply-other');
    await _pumpUi(tester);

    final reportAction = find.byKey(
      const Key('post-card-action-reply-other-report'),
    );
    expect(reportAction, findsOneWidget);
    await tester.tap(reportAction);
    await _pumpUi(tester);

    expect(find.byKey(const Key('guest-reply-report-login')), findsOneWidget);
    expect(
      find.text('/threads/thread/posts/root/replies?post=reply-other'),
      findsOneWidget,
    );
  });

  testWidgets('编辑回复失败不覆盖原内容且保留编辑稿可重试', (tester) async {
    var attempts = 0;
    final repository = _FakePostRepository(
      onUpdate: ({required postId, required content, required version}) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ApiFailure(
            userMessage: '回复没有更新成功。',
            httpStatus: 503,
            requestId: 'discussion-update-request',
          );
        }
        return _reply(postId, content, _author, version: version + 1);
      },
    );
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await _longPressPostMetadata(tester, 'reply-own');
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-card-action-reply-own-edit')));
    await _pumpUi(tester);
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getSize(find.byKey(const Key('post-composer-viewport'))).height,
      closeTo(viewportHeight * .52, 1),
    );
    await _replaceComposerText(tester, '编辑失败后保留的内容');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await _pumpUi(tester);

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
    await _pumpUi(tester);

    expect(attempts, 2);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('编辑失败后保留的内容'), findsOneWidget);
    expect(find.text('自己的回复'), findsNothing);
  });

  testWidgets('会话切换丢弃旧账号迟到首屏并立即加载新会话', (tester) async {
    final staleLoad = Completer<PostItem>();
    var fetchPostCalls = 0;
    final repository = _FakePostRepository(
      onFetchPost: (postId) {
        fetchPostCalls += 1;
        if (fetchPostCalls == 1) return staleLoad.future;
        return Future.value(_rootWithContent('新会话楼层'));
      },
    );
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await tester.pump();
    expect(fetchPostCalls, 1);
    expect(find.text('新会话楼层'), findsNothing);
    expect(find.text('旧账号迟到楼层'), findsNothing);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-2'));
    await _pumpUi(tester);

    expect(fetchPostCalls, greaterThanOrEqualTo(2));
    expect(find.text('新会话楼层'), findsOneWidget);

    staleLoad.complete(_rootWithContent('旧账号迟到楼层'));
    await _pumpUi(tester);

    expect(find.text('新会话楼层'), findsOneWidget);
    expect(find.text('旧账号迟到楼层'), findsNothing);
  });

  testWidgets('切号和退出登录关闭旧编辑器并清除内存草稿', (tester) async {
    final repository = _FakePostRepository();
    final container = await _postContainer(repository, userId: 'author-1');
    addTearDown(container.dispose);

    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '账号一的未发布草稿');

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-2'));
    await _pumpUi(tester);

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
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
    await _replaceComposerText(tester, '账号二的未发布草稿');

    await container.read(sessionControllerProvider.notifier).logoutLocally();
    await _pumpUi(tester);

    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.text('登录后发表回复'), findsOneWidget);

    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor('author-3'));
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
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
    final repository = _FakePostRepository();
    final navigatorKey = GlobalKey<NavigatorState>();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
        stickersEnabledProvider.overrideWithValue(false),
        postRepositoryProvider.overrideWithValue(repository),
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
          navigatorKey: navigatorKey,
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await _pumpUi(tester);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '旧账号不得发布的正文');
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
        .authenticate(_tokensFor('author-2'));
    await _pumpUi(tester);

    expect(find.byKey(const Key('new-root-business-page')), findsOneWidget);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(find.byKey(const Key('editor-submit')), findsNothing);
    expect(repository.createInputs, isEmpty);

    navigatorKey.currentState!.pop();
    await _pumpUi(tester);
    expect(find.byKey(const Key('editor-image-crop-dialog')), findsNothing);
    expect(find.byKey(const Key('post-composer-sheet')), findsNothing);
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await _pumpUi(tester);
    await _replaceComposerText(tester, '新账号允许发布的正文');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await _pumpUi(tester);

    expect(repository.createInputs, hasLength(1));
    expect(repository.createInputs.single.content, '新账号允许发布的正文');
    expect(find.text('旧账号不得发布的正文'), findsNothing);
  });

  testWidgets('360dp 独立楼中楼悬浮发表入口并完成编辑删除与权限收敛', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakePostRepository();
    final authorDirectory = _MutablePostDiscussionAuthorDirectory();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
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

    await _longPressPostMetadata(tester, 'root');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-card-action-root-link')), findsOneWidget);
    expect(find.byKey(const Key('post-card-action-root-reply')), findsNothing);
    expect(find.text('举报'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    await _longPressPostMetadata(tester, 'reply-other');
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
    await _replaceComposerText(tester, '新发表的回复');
    await tester.tap(find.byKey(const Key('editor-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-more-tray')), findsOneWidget);
    await _dismissPostComposerFromOutside(tester);
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
    await _longPressPostMetadata(tester, 'created');
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
    expect(authorDirectory.replyCalls, 2);

    await tester.ensureVisible(find.byKey(const Key('post-reply-created')));
    await _longPressPostMetadata(tester, 'created');
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

  testWidgets('新回复从百分之四十起步，工具托盘按需扩展且手动拖动优先', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = await _postContainer(
      _FakePostRepository(),
      userId: 'author-1',
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);
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
    await _longPressPostMetadata(tester, 'reply-other');
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

  testWidgets('上传中点击编辑器外部会在关闭 Sheet 前取消任务', (tester) async {
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
    expect(find.textContaining('正在上传'), findsOneWidget);

    await _dismissPostComposerFromOutside(tester);
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
    final sheetTop = tester
        .getTopLeft(find.byKey(const Key('post-composer-viewport')))
        .dy;
    await tester.tapAt(Offset(12, sheetTop / 2));
    await tester.pump();
    expect(find.byKey(const Key('post-composer-sheet')), findsOneWidget);

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
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            const _FakePostDiscussionAuthorDirectory(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: RepaintBoundary(
            key: visualKey,
            child: PostRepliesPage(
              threadId: 'thread',
              rootPostId: 'root',
              timeReference: _visualTimeReference,
            ),
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
    testWidgets('$width dp 独立讨论压缩重复语境并展示直接控件', (tester) async {
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
      expect(find.byKey(const Key('post-replies-author')), findsOneWidget);
      expect(find.byKey(const Key('post-replies-order')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('post-replies-author'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('post-replies-order'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('320dp 与 2 倍系统字号仍保留正文和直接讨论控件', (tester) async {
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
    expect(find.byKey(const Key('post-replies-author')), findsOneWidget);
    expect(find.byKey(const Key('post-replies-order')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('post-replies-author'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byKey(const Key('post-replies-order'))).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.byKey(const Key('post-replies-settings')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('排序和回复者筛选从独立控件直接生效', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final authorDirectory = _MutablePostDiscussionAuthorDirectory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(_FakePostRepository()),
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            authorDirectory,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('正序'), findsOneWidget);
    expect(find.byKey(const Key('post-replies-settings')), findsNothing);
    await tester.tap(find.byKey(const Key('post-replies-order')));
    await tester.pumpAndSettle();

    expect(find.text('倒序'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('他人的回复')).dy,
      lessThan(tester.getTopLeft(find.text('自己的回复')).dy),
    );

    await tester.tap(find.byKey(const Key('post-replies-author')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('自己').last);
    await tester.pumpAndSettle();

    expect(find.text('倒序'), findsOneWidget);
    expect(find.text('自己'), findsAtLeastNWidgets(1));
    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsNothing);

    authorDirectory.replyAuthors = const [];
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PostRepliesPage)),
    );
    container.invalidate(postReplyDiscussionAuthorsProvider('root'));
    await tester.pumpAndSettle();

    expect(find.text('自己的回复'), findsOneWidget);
    expect(find.text('他人的回复'), findsOneWidget);
    expect(find.text('暂无可筛选作者'), findsOneWidget);
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

  testWidgets('独立讨论楼层和回复复制菜单把原始 Markdown 交给结构化写入器', (tester) async {
    final root = _rootWithContent('**原楼层粗体**');
    final reply = _reply('reply-markdown', '> 回复引用', _otherAuthor);
    final repository = _FakePostRepository(
      onFetchPost: (_) async => root,
      initialReplies: [reply],
    );
    final copiedMarkdown = <String>[];
    final container = await _postContainer(
      repository,
      clipboardWriter:
          ({required markdown, required diceLabels, required scope}) async {
            copiedMarkdown.add(markdown);
          },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_postRepliesApp(container));
    await _pumpUi(tester);

    await _longPressPostMetadata(tester, 'root');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-card-action-root-copy')));
    await tester.pumpAndSettle();

    await _longPressPostMetadata(tester, 'reply-markdown');
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('post-card-action-reply-markdown-copy')),
    );
    await tester.pumpAndSettle();

    expect(copiedMarkdown, [root.content, reply.content]);
  });
}

Future<ProviderContainer> _postContainer(
  PostRepository repository, {
  String? userId,
  _FakeStickerRepository? stickerRepository,
  ReaderMarkdownClipboardWriter? clipboardWriter,
  bool markdownAlignment = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      appCapabilitiesProvider.overrideWithValue(
        AppCapabilities(markdownAlignment: markdownAlignment),
      ),
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      stickersEnabledProvider.overrideWithValue(stickerRepository != null),
      if (stickerRepository != null) ...[
        stickerRepositoryProvider.overrideWithValue(stickerRepository),
        stickerCollectionControllerProvider.overrideWith((ref) {
          return StickerCollectionController(
            stickerRepository,
            pollInterval: Duration.zero,
          );
        }),
      ],
      postRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        const _FakePostDiscussionAuthorDirectory(),
      ),
      postThreadContextLookupProvider.overrideWithValue(
        (_) async =>
            const PostThreadContext(isPrivate: false, canManageThread: false),
      ),
      if (clipboardWriter != null)
        readerMarkdownClipboardWriterProvider.overrideWithValue(
          clipboardWriter,
        ),
    ],
  );
  if (userId != null) {
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(_tokensFor(userId));
  }
  return container;
}

Widget _postRepliesApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      home: const PostRepliesPage(threadId: 'thread', rootPostId: 'root'),
    ),
  );
}

Future<void> _pumpUi(WidgetTester tester, [int frames = 6]) async {
  for (var frame = 0; frame < frames; frame += 1) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> _dismissPostComposerFromOutside(WidgetTester tester) async {
  expect(find.byKey(const Key('post-composer-dismiss-region')), findsOneWidget);
  final sheetTop = tester
      .getTopLeft(find.byKey(const Key('post-composer-viewport')))
      .dy;
  expect(sheetTop, greaterThan(0));
  await tester.tapAt(Offset(12, sheetTop / 2));
  await tester.pumpAndSettle();
}

Rect _glyphRect(WidgetTester tester, Finder finder, int textLength) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: textLength),
  );
  expect(boxes, isNotEmpty);
  Rect? result;
  for (final box in boxes) {
    final local = box.toRect();
    final global = Rect.fromPoints(
      paragraph.localToGlobal(local.topLeft),
      paragraph.localToGlobal(local.bottomRight),
    );
    result = result?.expandToInclude(global) ?? global;
  }
  return result!;
}

Future<void> _longPressPostMetadata(WidgetTester tester, String postId) async {
  final card = find.byKey(Key('post-card-$postId'));
  final rect = tester.getRect(card);
  await tester.longPressAt(Offset(rect.right - 12, rect.top + 24));
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
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
  await tester.idle();
}

typedef _FetchRepliesHandler =
    Future<PostReplyPage> Function({
      required String rootPostId,
      String? cursor,
      required PostReplyOrder order,
      String? authorId,
    });
typedef _UpdateHandler =
    Future<PostItem> Function({
      required String postId,
      required String content,
      required int version,
    });

class _FakePostRepository implements PostRepository {
  _FakePostRepository({
    this.createCompleter,
    this.onFetchPost,
    this.onFetchReplies,
    this.onCreate,
    this.onUpdate,
    this.onRemove,
    List<PostItem>? initialReplies,
  }) : replies =
           initialReplies ??
           [
             _reply('reply-own', '自己的回复', _author),
             _reply('reply-other', '他人的回复', _otherAuthor),
           ];

  final Completer<PostItem>? createCompleter;
  final Future<PostItem> Function(String postId)? onFetchPost;
  final _FetchRepliesHandler? onFetchReplies;
  final Future<PostItem> Function(PostCreateInput input)? onCreate;
  final _UpdateHandler? onUpdate;
  final Future<void> Function(String postId)? onRemove;
  final List<PostItem> replies;
  final List<PostCreateInput> createInputs = [];
  final List<({String id, String content, int version})> updateRequests = [];
  final List<String> removedIds = [];

  @override
  Future<PostItem> fetchPost(String postId) async {
    if (onFetchPost case final handler?) return handler(postId);
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
    if (onFetchReplies case final handler?) {
      return handler(
        rootPostId: rootPostId,
        cursor: cursor,
        order: order,
        authorId: authorId,
      );
    }
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
    final created = onCreate != null
        ? await onCreate!(input)
        : createCompleter == null
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
    final updated = onUpdate != null
        ? await onUpdate!(postId: postId, content: content, version: version)
        : _reply(postId, content, previous.author, version: version + 1);
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
    await onRemove?.call(postId);
    removedIds.add(postId);
    replies.removeWhere((post) => post.id == postId);
  }

  @override
  Future<void> setPinned(String postId, {required bool pinned}) async {}
}

class _FakeStickerRepository implements StickerRepository {
  @override
  Future<StickerCollection> fetchCollection() async => _stickerCollection;

  @override
  Future<StickerImport> fetchImport(String id) => throw UnimplementedError();

  @override
  Future<StickerImport> importSource(
    StickerImportSource source, {
    required String clientRequestId,
  }) => throw UnimplementedError();

  @override
  Future<StickerCollection> remove(String favoriteId) =>
      throw UnimplementedError();

  @override
  Future<StickerCollection> reorder({
    required int version,
    required List<String> favoriteIds,
  }) => throw UnimplementedError();
}

const _stickerAssetId = 'cm1234567890123456789012';
const _stickerUrl = 'https://cdn.example.com/stickers/reply.webp';
const _sticker = UserSticker(
  id: 'favorite-reply',
  position: 0,
  asset: StickerAsset(
    id: _stickerAssetId,
    url: _stickerUrl,
    thumbnailUrl: 'https://cdn.example.com/stickers/reply-thumb.webp',
    width: 96,
    height: 96,
    animated: false,
    frameCount: 1,
    durationMs: 0,
  ),
  markdown: '![表情]($_stickerUrl "wenyousite-sticker:v1:$_stickerAssetId")',
);
const _stickerCollection = StickerCollection(
  version: 1,
  limit: 200,
  items: [_sticker],
  recent: [],
  pendingImports: [],
);

class _FakePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  const _FakePostDiscussionAuthorDirectory();

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async => const [];

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async {
    return [
      PostDiscussionAuthor(
        userId: _rootAuthor.id,
        username: _rootAuthor.username,
        role: PostDiscussionAuthorRole.owner,
      ),
      PostDiscussionAuthor(
        userId: _author.id,
        username: _author.username,
        role: PostDiscussionAuthorRole.player,
      ),
    ];
  }
}

class _MutablePostDiscussionAuthorDirectory
    implements PostDiscussionAuthorDirectory {
  int floorCalls = 0;
  int replyCalls = 0;
  List<PostDiscussionAuthor> replyAuthors = [
    PostDiscussionAuthor(
      userId: _rootAuthor.id,
      username: _rootAuthor.username,
      role: PostDiscussionAuthorRole.owner,
    ),
    PostDiscussionAuthor(
      userId: _author.id,
      username: _author.username,
      role: PostDiscussionAuthorRole.player,
    ),
  ];

  @override
  Future<List<PostDiscussionAuthor>> fetchFloorAuthors(
    String subthreadId,
  ) async {
    floorCalls += 1;
    return const [];
  }

  @override
  Future<List<PostDiscussionAuthor>> fetchReplyAuthors(
    String rootPostId,
  ) async {
    replyCalls += 1;
    return replyAuthors;
  }
}

const _author = PostAuthor(id: 'author-1', username: '自己', level: 3);
const _otherAuthor = PostAuthor(id: 'author-2', username: '他人', level: 2);
const _rootAuthor = PostAuthor(id: 'root-author', username: '楼层作者', level: 4);

final _rootCreatedAt = DateTime.utc(2026, 8, 20, 12);
final _visualTimeReference = DateTime.utc(2026, 8, 22, 12);

final _root = _rootWithContent('原楼层内容');

PostItem _rootWithContent(String content, {bool isDeleted = false}) => PostItem(
  id: 'root',
  threadId: 'thread',
  subthreadId: 'subthread',
  author: _rootAuthor,
  content: content,
  version: 2,
  createdAt: _rootCreatedAt,
  updatedAt: _rootCreatedAt,
  isBody: false,
  isDeleted: isDeleted,
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
  bool isDeleted = false,
}) {
  final createdAt = DateTime.utc(
    2026,
    8,
    22,
    12,
  ).subtract(Duration(days: id == 'reply-other' ? 1 : 2));
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
    isDeleted: isDeleted,
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

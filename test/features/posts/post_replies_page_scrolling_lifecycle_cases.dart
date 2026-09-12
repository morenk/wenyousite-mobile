import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_task_controller.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/posts/presentation/post_replies_page.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';

import '../../support/deterministic_test_fonts.dart';
import '../../support/fake_image_crop_processor.dart';
import 'post_replies_page_test_support.dart';

void registerPostRepliesPageScrollingLifecycleCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('楼中楼末尾长回复从作者信息开头定位', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(
            PostRepliesPageTestFakePostRepository(
              initialReplies: [
                postRepliesPageTestReply(
                  'long-target',
                  List.filled(90, '楼中楼长正文，作者与正文开头必须可见。').join('\n\n'),
                  postRepliesPageTestOtherAuthor,
                ),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const PostRepliesPage(
            threadId: 'thread',
            rootPostId: 'root',
            focusedReplyId: 'long-target',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final target = tester.getRect(
      find.byKey(const ValueKey('target-frame-long-target')),
    );
    final viewport = tester.getRect(find.byKey(const Key('post-replies-list')));
    expect(target.height, greaterThan(viewport.height));
    expect(target.top, closeTo(viewport.top, 1));
  });
  testWidgets('上传中点击编辑器外部会在关闭 Sheet 前取消任务', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final uploadGateway = PostRepliesPageTestLateCompletingMediaUploadGateway();
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
    await tester.tap(find.byKey(const Key('editor-image')));
    await postRepliesPageTestConfirmImageCrop(tester);
    expect(find.textContaining('正在上传'), findsOneWidget);

    await postRepliesPageTestDismissPostComposerFromOutside(tester);
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
    final repository = PostRepliesPageTestFakePostRepository(
      createCompleter: pendingCreate,
    );
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
    await tester.tap(find.byKey(const Key('post-reply-compose')));
    await tester.pumpAndSettle();
    await postRepliesPageTestReplaceComposerText(tester, '等待服务端确认的回复');
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

    pendingCreate.complete(
      postRepliesPageTestReply(
        'created-pending',
        '等待服务端确认的回复',
        postRepliesPageTestAuthor,
      ),
    );
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
        postRepliesPageTestReply(
          'long-reply-$index',
          '第 $index 条较长回复，用来确保目标一开始不在 Sliver 构建范围内。\n\n补充内容。',
          postRepliesPageTestOtherAuthor,
        ),
      postRepliesPageTestReply(
        'far-reply',
        '远端目标回复',
        postRepliesPageTestOtherAuthor,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(
            PostRepliesPageTestFakePostRepository(initialReplies: replies),
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
          postRepositoryProvider.overrideWithValue(
            PostRepliesPageTestFakePostRepository(),
          ),
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            const PostRepliesPageTestFakePostDiscussionAuthorDirectory(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: RepaintBoundary(
            key: visualKey,
            child: PostRepliesPage(
              threadId: 'thread',
              rootPostId: 'root',
              timeReference: postRepliesPageTestVisualTimeReference,
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
            postRepositoryProvider.overrideWithValue(
              PostRepliesPageTestFakePostRepository(),
            ),
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
          postRepositoryProvider.overrideWithValue(
            PostRepliesPageTestFakePostRepository(),
          ),
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

    final authorDirectory =
        PostRepliesPageTestMutablePostDiscussionAuthorDirectory();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickersEnabledProvider.overrideWithValue(false),
          postRepositoryProvider.overrideWithValue(
            PostRepliesPageTestFakePostRepository(),
          ),
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
    final root = postRepliesPageTestRootWithContent('**原楼层粗体**');
    final reply = postRepliesPageTestReply(
      'reply-markdown',
      '> 回复引用',
      postRepliesPageTestOtherAuthor,
    );
    final repository = PostRepliesPageTestFakePostRepository(
      onFetchPost: (_) async => root,
      initialReplies: [reply],
    );
    final copiedMarkdown = <String>[];
    final container = await postRepliesPageTestPostContainer(
      repository,
      clipboardWriter:
          ({required markdown, required diceLabels, required scope}) async {
            copiedMarkdown.add(markdown);
          },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(postRepliesPageTestPostRepliesApp(container));
    await postRepliesPageTestPumpUi(tester);

    await postRepliesPageTestLongPressPostMetadata(tester, 'root');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('post-card-action-root-copy')));
    await tester.pumpAndSettle();

    await postRepliesPageTestLongPressPostMetadata(tester, 'reply-markdown');
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('post-card-action-reply-markdown-copy')),
    );
    await tester.pumpAndSettle();

    expect(copiedMarkdown, [root.content, reply.content]);
  });
}

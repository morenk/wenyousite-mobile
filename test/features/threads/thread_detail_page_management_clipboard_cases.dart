import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import '../../support/deterministic_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void registerThreadDetailPageManagementClipboardCases() {
  setUpAll(loadDeterministicTestFonts);
  testWidgets('点击短楼中楼预览直接精确回复且楼层长按菜单保持独立', (tester) async {
    final reply = ThreadReplyModel(
      id: 'reply-direct',
      author: const ThreadAuthorModel(
        id: 'user-2',
        username: '楼中楼作者',
        level: 4,
      ),
      body: const ThreadBodyModel(markdown: '点击这条短回复'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
    );
    final floorModel = ThreadFloorModel(
      id: 'floor-direct',
      floorNumber: 1,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '可直接回复的楼层'),
      createdAt: threadDetailPageTestRecentFixtureTime,
      isDeleted: false,
      replyCount: 1,
      replies: [reply],
    );
    final detailRepository = ThreadDetailPageTestFakeThreadDetailRepository(
      mainFloor: floorModel,
      postTarget: ThreadPostTargetModel(
        requestedPostId: 'floor-created',
        threadId: 'thread-1',
        subthreadId: 'subthread-1',
        floor: floorModel,
      ),
    );
    final postRepository = ThreadDetailPageTestCreatingPostRepository();
    final container = ProviderContainer(
      overrides: [
        stickersEnabledProvider.overrideWithValue(false),
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(postRepository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('viewer-1'));
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          builder: (context, state) => ThreadDetailPage(
            threadId: state.pathParameters['threadId']!,
            entryTarget: ThreadDetailEntryTarget.fromQuery(
              postId: state.uri.queryParameters['post'],
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

    final floor = find.byKey(const Key('thread-floor-card-floor-direct'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPressAt(tester.getTopLeft(floor) + const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-direct-copy')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('post-composer-body')), findsNothing);
    await tester.tap(find.byKey(const Key('wenyou-modal-action-close')));
    await tester.pumpAndSettle();

    final preview = find.byKey(
      const Key('thread-floor-reply-floor-direct-reply-direct'),
    );
    await tester.scrollUntilVisible(
      preview,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-direct')),
      findsOneWidget,
    );
    await tester.tap(preview);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    expect(find.text('回复 @楼中楼作者'), findsOneWidget);

    await threadDetailPageTestReplacePostComposerText(tester, '精确回复内容');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(postRepository.createInputs, hasLength(1));
    expect(postRepository.createInputs.single.parentPostId, 'floor-direct');
    expect(postRepository.createInputs.single.replyToPostId, 'reply-direct');
  });

  testWidgets('管理者从主题详情编辑正文并按作者与管理权限操作楼层', (tester) async {
    final detailRepository = ThreadDetailPageTestFakeThreadDetailRepository(
      detail: threadDetailPageTestManagerDetail,
    );
    final postRepository = ThreadDetailPageTestFakePostRepository();
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(postRepository),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('collaborator-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-detail-more')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-export-button')), findsNothing);
    expect(find.byKey(const Key('thread-detail-manage')), findsNothing);
    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    expect(find.byKey(const Key('thread-detail-edit-body')), findsNothing);
    final bodyRect = tester.getRect(
      find.byKey(const Key('thread-body-container-subthread-1')),
    );
    await tester.longPressAt(Offset(bodyRect.right - 12, bodyRect.top + 12));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-copy')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-link')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-body-action-subthread-1-edit')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('thread-body-action-subthread-1-edit')),
    );
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴正文'), findsOneWidget);
    expect(find.byKey(const Key('post-composer-close')), findsNothing);
    final viewportHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(
      tester.getSize(find.byKey(const Key('post-composer-viewport'))).height,
      closeTo(viewportHeight * .52, 1),
    );
    await threadDetailPageTestDismissPostComposerFromOutside(tester);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-detail-manage')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-export')), findsNothing);
    expect(find.byKey(const Key('thread-detail-edit-body')), findsOneWidget);
    expect(find.text('编辑正文'), findsOneWidget);
    expect(find.text('主线'), findsAtLeastNWidgets(1));
    expect(find.byKey(const Key('thread-detail-tip')), findsOneWidget);
    expect(find.byKey(const Key('thread-detail-report')), findsOneWidget);
    await tester.tapAt(const Offset(12, 12));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.text('发表楼层'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('post-composer-body')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('post-composer-viewport'))).height,
      closeTo(viewportHeight * .40, 1),
    );
    await threadDetailPageTestDismissPostComposerFromOutside(tester);

    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-detail-edit-body')));
    await tester.pumpAndSettle();
    expect(find.text('编辑子贴正文'), findsOneWidget);
    await threadDetailPageTestDismissPostComposerFromOutside(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('thread-floor-compose')), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-edit-floor-1')), findsNothing);
    expect(find.byKey(const Key('thread-floor-delete-floor-1')), findsNothing);
    expect(
      find.byKey(const Key('thread-floor-discussion-floor-1')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('thread-floor-reply-preview-expand-floor-1')),
      findsOneWidget,
    );

    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-delete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('thread-floor-action-floor-1-pin')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('thread-floor-action-floor-1-pin')));
    await tester.pumpAndSettle();
    expect(postRepository.pinRequests, [(postId: 'floor-1', pinned: true)]);
    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('删除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除这个楼层？'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(postRepository.removedIds, ['floor-1']);
  });

  for (final width in const [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 管理者阅读区不常驻正文编辑控件', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final container = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            ThreadDetailPageTestMemoryTokenStore(),
          ),
          sessionRemoteProvider.overrideWithValue(
            ThreadDetailPageTestFakeSessionRemote(),
          ),
          threadDetailRepositoryProvider.overrideWithValue(
            ThreadDetailPageTestFakeThreadDetailRepository(
              detail: threadDetailPageTestManagerDetail,
            ),
          ),
          postDiscussionAuthorDirectoryProvider.overrideWithValue(
            ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
          ),
          threadSubscriptionRepositoryProvider.overrideWithValue(
            ThreadDetailPageTestFakeThreadSubscriptionRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container
          .read(sessionControllerProvider.notifier)
          .authenticate(threadDetailPageTestTokensFor('collaborator-1'));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ThreadDetailPage(threadId: 'thread-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('thread-body-edit')), findsNothing);
      expect(find.text('主线正文'), findsOneWidget);
      expect(tester.getTopLeft(find.text('主线正文')).dy, lessThan(400));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('thread-detail-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('thread-detail-edit-body')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('thread-detail-edit-body'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }

  testWidgets('360dp 管理者首屏同样保持正文优先视觉基线', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(
            detail: threadDetailPageTestManagerDetail,
          ),
        ),
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('collaborator-1'));
    const visualKey = Key('thread-detail-manager-text-first-visual');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RepaintBoundary(
            key: visualKey,
            child: ThreadDetailPage(threadId: 'thread-1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('thread-body-edit')), findsNothing);
    expect(find.text('主线正文'), findsOneWidget);
    await expectLater(
      find.byKey(visualKey),
      matchesGoldenFile('goldens/thread_detail_manager_text_first_360.png'),
    );
  });

  testWidgets('管理者在空子贴从主题操作添加正文', (tester) async {
    final emptyBodyDetail = threadDetailPageTestCopyThreadDetail(
      threadDetailPageTestManagerDetail,
      subthreads: const [
        ThreadSubthreadModel(
          id: 'subthread-1',
          title: '尚未开篇',
          sortOrder: 1,
          postCount: 0,
          postingPolicyLabel: '参与者发言',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(
          ThreadDetailPageTestMemoryTokenStore(),
        ),
        sessionRemoteProvider.overrideWithValue(
          ThreadDetailPageTestFakeSessionRemote(),
        ),
        threadDetailRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadDetailRepository(
            detail: emptyBodyDetail,
          ),
        ),
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
        ),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakePostRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('collaborator-1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ThreadDetailPage(threadId: 'thread-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('这个子贴还没有正文。'), findsOneWidget);
    expect(
      find.byKey(const Key('thread-body-add-subthread-1')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('thread-detail-more')));
    await tester.pumpAndSettle();
    expect(find.text('添加正文'), findsAtLeastNWidgets(1));
    expect(find.text('尚未开篇'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('thread-detail-edit-body')));
    await tester.pumpAndSettle();
    expect(find.text('添加子贴正文'), findsOneWidget);
  });

  testWidgets('子贴正文和主题楼层复制菜单把原始 Markdown 交给结构化写入器', (tester) async {
    final copiedMarkdown = <String>[];
    await tester.pumpWidget(
      threadDetailPageTestDetailApp(
        ThreadDetailPageTestFakeThreadDetailRepository(),
        clipboardWriter:
            ({required markdown, required diceLabels, required scope}) async {
              copiedMarkdown.add(markdown);
            },
      ),
    );
    await tester.pumpAndSettle();

    final body = find.byKey(const Key('thread-body-container-subthread-1'));
    await tester.scrollUntilVisible(
      body,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    final bodyRect = tester.getRect(body);
    await tester.longPressAt(Offset(bodyRect.right - 12, bodyRect.top + 12));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('thread-body-action-subthread-1-copy')),
    );
    await tester.pumpAndSettle();

    final floor = find.byKey(const Key('thread-floor-card-floor-1'));
    await tester.scrollUntilVisible(
      floor,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.longPressAt(tester.getTopLeft(floor) + const Offset(8, 8));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floor-action-floor-1-copy')));
    await tester.pumpAndSettle();

    expect(copiedMarkdown, [
      threadDetailPageTestDetail.subthreads.first.body!.markdown,
      threadDetailPageTestMainFloor.body.markdown,
    ]);
  });
}

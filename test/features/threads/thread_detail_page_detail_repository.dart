import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import 'thread_detail_page_collaboration_repositories.dart';
import 'thread_detail_page_content_fixtures.dart';

Future<void> threadDetailPageTestReplacePostComposerText(
  WidgetTester tester,
  String text,
) async {
  final editor = find.byKey(const Key('post-composer-body'));
  final state = tester.state<QuillEditorState>(editor);
  state.widget.focusNode.requestFocus();
  await tester.pump();
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

enum ThreadDetailPageTestSubthreadSelectionSurface {
  previous('上一个按钮'),
  next('下一个按钮'),
  directory('目录');

  const ThreadDetailPageTestSubthreadSelectionSurface(this.label);

  final String label;
}

Future<void> threadDetailPageTestSelectMainSubthread(
  WidgetTester tester,
  ThreadDetailPageTestSubthreadSelectionSurface surface,
) async {
  switch (surface) {
    case ThreadDetailPageTestSubthreadSelectionSurface.previous:
      await tester.tap(find.byKey(const Key('thread-subthread-previous')));
      return;
    case ThreadDetailPageTestSubthreadSelectionSurface.next:
      await tester.tap(find.byKey(const Key('thread-subthread-next')));
      return;
    case ThreadDetailPageTestSubthreadSelectionSurface.directory:
      await tester.tap(find.byKey(const Key('thread-subthread-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('thread-subthread-subthread-1')));
      return;
  }
}

const threadDetailPageTestThreadDetailViewportFixtures =
    <ThreadDetailPageTestThreadDetailViewportFixture>[
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '小屏三键 320x568@2x',
        physicalSize: Size(640, 1136),
        devicePixelRatio: 2,
        padding: FakeViewPadding(top: 48, bottom: 96),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '小屏手势 320x800@3x 双倍字体',
        physicalSize: Size(960, 2400),
        devicePixelRatio: 3,
        padding: FakeViewPadding(top: 90, bottom: 72),
        systemGestures: FakeViewPadding(
          left: 54,
          top: 90,
          right: 54,
          bottom: 120,
        ),
        textScale: 2,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '折叠屏窄幅 347x945@2.4x',
        physicalSize: Size(832, 2268),
        devicePixelRatio: 2.4,
        padding: FakeViewPadding(top: 84, bottom: 60),
        systemGestures: FakeViewPadding(
          left: 48,
          top: 84,
          right: 48,
          bottom: 120,
        ),
        textScale: 1.3,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '短窗口 360x480@2x',
        physicalSize: Size(720, 960),
        devicePixelRatio: 2,
        padding: FakeViewPadding(top: 48, bottom: 48),
        systemGestures: FakeViewPadding(
          left: 32,
          top: 48,
          right: 32,
          bottom: 64,
        ),
        textScale: 1.3,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '标准三键 360x640@3x',
        physicalSize: Size(1080, 1920),
        devicePixelRatio: 3,
        padding: FakeViewPadding(top: 72, bottom: 144),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '标准手势 360x800@3x',
        physicalSize: Size(1080, 2400),
        devicePixelRatio: 3,
        padding: FakeViewPadding(top: 90, bottom: 72),
        systemGestures: FakeViewPadding(
          left: 48,
          top: 90,
          right: 48,
          bottom: 120,
        ),
        textScale: 1.3,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '高密度 360x800@4x',
        physicalSize: Size(1440, 3200),
        devicePixelRatio: 4,
        padding: FakeViewPadding(top: 128, bottom: 96),
        systemGestures: FakeViewPadding(
          left: 64,
          top: 128,
          right: 64,
          bottom: 160,
        ),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '荣耀 Magic8 359x789@3.5x',
        physicalSize: Size(1256, 2760),
        devicePixelRatio: 3.5,
        padding: FakeViewPadding(top: 119, bottom: 78),
        systemGestures: FakeViewPadding(
          left: 53,
          top: 119,
          right: 53,
          bottom: 140,
        ),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '主流长屏 393x851@2.75x',
        physicalSize: Size(1080, 2340),
        devicePixelRatio: 2.75,
        padding: FakeViewPadding(top: 93, bottom: 66),
        systemGestures: FakeViewPadding(
          left: 48,
          top: 93,
          right: 48,
          bottom: 110,
        ),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '主流大屏 411x914@2.625x',
        physicalSize: Size(1080, 2400),
        devicePixelRatio: 2.625,
        padding: FakeViewPadding(top: 84, bottom: 63),
        systemGestures: FakeViewPadding(
          left: 44,
          top: 84,
          right: 44,
          bottom: 105,
        ),
        textScale: 1.3,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '大号手机 480x960@2.5x 双倍字体',
        physicalSize: Size(1200, 2400),
        devicePixelRatio: 2.5,
        padding: FakeViewPadding(top: 75, bottom: 60),
        systemGestures: FakeViewPadding(
          left: 45,
          top: 75,
          right: 45,
          bottom: 100,
        ),
        textScale: 2,
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '小平板 600x960@2x',
        physicalSize: Size(1200, 1920),
        devicePixelRatio: 2,
        padding: FakeViewPadding(top: 48, bottom: 48),
        systemGestures: FakeViewPadding(
          left: 32,
          top: 48,
          right: 32,
          bottom: 80,
        ),
      ),
      ThreadDetailPageTestThreadDetailViewportFixture(
        name: '平板 800x1280@2x 放大字体',
        physicalSize: Size(1600, 2560),
        devicePixelRatio: 2,
        padding: FakeViewPadding(top: 48, bottom: 48),
        systemGestures: FakeViewPadding(
          left: 32,
          top: 48,
          right: 32,
          bottom: 80,
        ),
        textScale: 1.3,
      ),
    ];

const threadDetailPageTestAuthenticatedViewportFixtureNames = <String>{
  '小屏手势 320x800@3x 双倍字体',
  '荣耀 Magic8 359x789@3.5x',
  '主流长屏 393x851@2.75x',
  '大号手机 480x960@2.5x 双倍字体',
  '平板 800x1280@2x 放大字体',
};

class ThreadDetailPageTestThreadDetailViewportFixture {
  const ThreadDetailPageTestThreadDetailViewportFixture({
    required this.name,
    required this.physicalSize,
    required this.devicePixelRatio,
    this.padding = FakeViewPadding.zero,
    this.systemGestures = FakeViewPadding.zero,
    this.textScale = 1,
  });

  final String name;
  final Size physicalSize;
  final double devicePixelRatio;
  final FakeViewPadding padding;
  final FakeViewPadding systemGestures;
  final double textScale;

  Size get logicalSize => physicalSize / devicePixelRatio;
}

void threadDetailPageTestConfigureThreadDetailViewport(
  WidgetTester tester,
  ThreadDetailPageTestThreadDetailViewportFixture fixture,
) {
  tester.view.devicePixelRatio = fixture.devicePixelRatio;
  tester.view.physicalSize = fixture.physicalSize;
  tester.view.padding = fixture.padding;
  tester.view.viewPadding = fixture.padding;
  tester.view.viewInsets = FakeViewPadding.zero;
  tester.view.systemGestureInsets = fixture.systemGestures;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.view.resetViewInsets);
  addTearDown(tester.view.resetSystemGestureInsets);
}

Widget threadDetailPageTestDetailApp(
  ThreadDetailRepository repository, {
  String? targetPostId,
  String? subthreadIdHint,
  Key? visualKey,
  PostDiscussionAuthorDirectory? authorDirectory,
  double? textScale,
  bool enableRenderDiagnostics = false,
  ReaderMarkdownClipboardWriter? clipboardWriter,
}) {
  final page = ThreadDetailPage(
    threadId: 'thread-1',
    enableRenderDiagnostics: enableRenderDiagnostics,
    entryTarget: ThreadDetailEntryTarget.fromQuery(
      postId: targetPostId,
      subthreadId: subthreadIdHint,
    ),
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        authorDirectory ??
            ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
      ),
      if (clipboardWriter != null)
        readerMarkdownClipboardWriterProvider.overrideWithValue(
          clipboardWriter,
        ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: textScale == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
      home: visualKey == null
          ? page
          : RepaintBoundary(key: visualKey, child: page),
    ),
  );
}

Future<Widget> threadDetailPageTestAuthenticatedDetailApp(
  ThreadDetailRepository repository, {
  required String userId,
  double? textScale,
}) async {
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(
        ThreadDetailPageTestMemoryTokenStore(),
      ),
      sessionRemoteProvider.overrideWithValue(
        ThreadDetailPageTestFakeSessionRemote(),
      ),
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
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
      .authenticate(threadDetailPageTestTokensFor(userId));
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      builder: textScale == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
      home: const ThreadDetailPage(threadId: 'thread-1'),
    ),
  );
}

Widget threadDetailPageTestDetailRouterApp(
  ThreadDetailRepository repository, {
  String initialLocation = '/threads/thread-1',
  bool enableRenderDiagnostics = false,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        builder: (context, state) => ThreadDetailPage(
          threadId: state.pathParameters['threadId']!,
          enableRenderDiagnostics: enableRenderDiagnostics,
          entryTarget: ThreadDetailEntryTarget.fromQuery(
            postId: state.uri.queryParameters['post'],
          ),
        ),
      ),
      GoRoute(
        path: '/threads/:threadId/posts/:postId/replies',
        name: 'post-replies',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          final postId = state.pathParameters['postId']!;
          final replyId = state.uri.queryParameters['post'];
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(key: Key('test-post-replies-back')),
              title: const Text('楼中楼讨论'),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    [threadId, postId, ?replyId].join('/'),
                    key: const Key('test-post-replies-destination'),
                  ),
                  if (!state.uri.queryParameters.containsKey('reports'))
                    const SizedBox.shrink(
                      key: Key('test-post-replies-reports-absent'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/tags/:tagId',
        name: 'tag-threads',
        builder: (context, state) => Scaffold(
          appBar: AppBar(leading: const BackButton(key: Key('test-tag-back'))),
          body: Center(
            child: Text(
              state.pathParameters['tagId']!,
              key: const Key('test-tag-destination'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) => Scaffold(
          appBar: AppBar(leading: const BackButton(key: Key('test-user-back'))),
          body: Center(
            child: Text(
              state.pathParameters['userId']!,
              key: const Key('test-user-destination'),
            ),
          ),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        ThreadDetailPageTestFakePostDiscussionAuthorDirectory(),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

Future<void> threadDetailPageTestDismissPostComposerFromOutside(
  WidgetTester tester,
) async {
  expect(find.byKey(const Key('post-composer-dismiss-region')), findsOneWidget);
  final sheetTop = tester
      .getTopLeft(find.byKey(const Key('post-composer-viewport')))
      .dy;
  expect(sheetTop, greaterThan(0));
  await tester.tapAt(Offset(12, sheetTop / 2));
  await tester.pumpAndSettle();
}

class ThreadDetailPageTestFakeThreadDetailRepository
    implements ThreadDetailRepository {
  ThreadDetailPageTestFakeThreadDetailRepository({
    this.threadFailure,
    this.floorFailure,
    this.loadMoreFailure,
    this.postTarget,
    this.postTargetFuture,
    this.latestPost,
    this.latestPostFuture,
    this.latestFailure,
    ThreadDetailModel? detail,
    ThreadFloorModel? mainFloor,
    List<ThreadFloorModel>? mainFloors,
    this.nextFloors,
  }) : detail = detail ?? threadDetailPageTestDetail,
       mainFloors = mainFloors ?? [mainFloor ?? threadDetailPageTestMainFloor];

  final ApiFailure? threadFailure;
  final ApiFailure? floorFailure;
  final ApiFailure? loadMoreFailure;
  final ThreadPostTargetModel? postTarget;
  final Future<ThreadPostTargetModel>? postTargetFuture;
  final ThreadLatestPostModel? latestPost;
  final Future<ThreadLatestPostModel>? latestPostFuture;
  final ApiFailure? latestFailure;
  final ThreadDetailModel detail;
  final List<ThreadFloorModel> mainFloors;
  final List<ThreadFloorModel>? nextFloors;
  final List<String> requestedSubthreads = [];
  final List<ThreadFloorOrder> requestedOrders = [];
  final List<String?> requestedAuthors = [];
  final List<String> targetPostIds = [];
  final List<String> latestThreadIds = [];
  int threadCalls = 0;

  @override
  Future<ThreadDetailModel> fetchThread(String threadId) async {
    threadCalls += 1;
    if (threadFailure case final failure?) throw failure;
    return detail;
  }

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) async {
    targetPostIds.add(postId);
    if (postTargetFuture case final future?) return future;
    return postTarget!;
  }

  @override
  Future<ThreadLatestPostModel> fetchLatestPost(String threadId) async {
    latestThreadIds.add(threadId);
    if (latestFailure case final failure?) throw failure;
    if (latestPostFuture case final future?) return future;
    return latestPost ?? threadDetailPageTestLatestFloorPost;
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    requestedSubthreads.add(subthreadId);
    requestedOrders.add(order);
    requestedAuthors.add(authorId);
    if (cursor != null && loadMoreFailure != null) {
      throw loadMoreFailure!;
    }
    if (cursor != null) {
      final floors = nextFloors ?? const <ThreadFloorModel>[];
      return CursorPage(
        items: authorId == null
            ? floors
            : floors.where((floor) => floor.author.id == authorId).toList(),
        hasMore: false,
      );
    }
    if (cursor == null && floorFailure != null) {
      throw floorFailure!;
    }
    if (cursor == null && (loadMoreFailure != null || nextFloors != null)) {
      final floors = subthreadId == 'subthread-1'
          ? mainFloors
          : [threadDetailPageTestSideFloor];
      return CursorPage(
        items: authorId == null
            ? floors
            : floors.where((floor) => floor.author.id == authorId).toList(),
        cursor: 'next-cursor',
        hasMore: true,
      );
    }
    final floors = subthreadId == 'subthread-1'
        ? mainFloors
        : [threadDetailPageTestSideFloor];
    return CursorPage(
      items: authorId == null
          ? floors
          : floors.where((floor) => floor.author.id == authorId).toList(),
      hasMore: false,
    );
  }
}

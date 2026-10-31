import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';
import '../../support/memory_pending_media_file_store.dart';
import 'thread_detail_page_test_support.dart';
import 'thread_publish_locate_support.dart';

void main() {
  for (final entry in ['plain', 'empty', 'subthread', 'post', 'long']) {
    testWidgets('$entry 入口连续两次发布各读取一次目标窗口，真实文本可见', (tester) async {
      final repository = PublishedFloorRepository(
        mainFloors: entry == 'empty' ? [] : null,
        postTarget: entry == 'post'
            ? ThreadPostTargetModel(
                requestedPostId: 'floor-1',
                threadId: 'thread-1',
                subthreadId: 'subthread-1',
                floor: threadDetailPageTestMainFloor,
              )
            : null,
      );
      final posts = PublishingPostRepository(
        baseNumber: entry == 'long' ? 19 : 1,
      );
      await _mount(tester, repository, posts, entry: entry);
      final initialThreadCalls = repository.threadCalls;
      for (var publication = 1; publication <= 2; publication++) {
        final number = posts.baseNumber + publication;
        await _publish(tester, number);
        expect(repository.targets, hasLength(publication));
        expect(posts.createInputs, hasLength(publication));
        expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
        expect(find.text('已发布，正在定位新楼层…'), findsOneWidget);
        expect(
          find.byKey(const Key('thread-floor-compose')).hitTestable(),
          findsOneWidget,
        );
        expect(repository.threadCalls, initialThreadCalls);
        if (entry == 'subthread') {
          expect(repository.targets.last.subthread, 'subthread-2');
        }
        repository.requests.last.complete(
          publishedWindow(
            number,
            before: entry == 'long'
                ? [
                    for (var i = 1; i < number; i++)
                      ThreadFloorModel(
                        id: 'older-$i',
                        floorNumber: i,
                        author: threadDetailPageTestAuthor,
                        body: ThreadBodyModel(
                          markdown: List.filled(
                            i % 3 + 1,
                            '已有的较长楼层正文。',
                          ).join('\n\n'),
                        ),
                        createdAt: DateTime.utc(2026, 10, 1),
                        isDeleted: false,
                        replyCount: 0,
                        replies: const [],
                      ),
                  ]
                : const [],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('已发表的第 $number 楼').hitTestable(), findsOneWidget);
        expect(
          find.byKey(const Key('thread-published-floor-status')),
          findsNothing,
        );
        expect(repository.targets, hasLength(publication));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('定位失败仍可读，点击重试只 GET 一次，不重发帖子', (tester) async {
    final repository = PublishedFloorRepository();
    final posts = PublishingPostRepository();
    await _mount(tester, repository, posts);
    await _publish(tester, 2);
    repository.requests.single.completeError(
      const ApiFailure(httpStatus: 429, userMessage: '请稍后重试'),
    );
    await tester.pumpAndSettle();
    expect(find.text('已发布，定位失败。'), findsOneWidget);
    expect(find.text('第一层内容').hitTestable(), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(repository.targets, hasLength(1));
    await tester.tap(find.byKey(const Key('thread-published-floor-retry')));
    await _frames(tester);
    expect(repository.targets, hasLength(2));
    expect(posts.createInputs, hasLength(1));
    repository.requests.last.complete(publishedWindow(2));
    await tester.pumpAndSettle();
    expect(find.text('已发表的第 2 楼').hitTestable(), findsOneWidget);
    expect(posts.createInputs, hasLength(1));
  });

  testWidgets('定位期间用户拖动取消自动跳转，查看入口可恢复', (tester) async {
    final repository = PublishedFloorRepository();
    final posts = PublishingPostRepository();
    await _mount(tester, repository, posts);
    await _publish(tester, 2);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -80));
    repository.requests.single.complete(publishedWindow(2));
    await tester.pumpAndSettle();
    expect(find.text('已发表的第 2 楼'), findsNothing);
    expect(find.text('查看新楼层'), findsOneWidget);
    await tester.tap(find.byKey(const Key('thread-published-floor-retry')));
    await _frames(tester);
    repository.requests.last.complete(publishedWindow(2));
    await tester.pumpAndSettle();
    expect(find.text('已发表的第 2 楼').hitTestable(), findsOneWidget);
    expect(posts.createInputs, hasLength(1));
  });

  testWidgets('页面切号后迟到新楼层不会显示给新身份', (tester) async {
    final repository = PublishedFloorRepository();
    final posts = PublishingPostRepository();
    final container = await _mount(tester, repository, posts);
    await _publish(tester, 2);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('user-2'));
    repository.requests.single.complete(publishedWindow(2));
    await tester.pumpAndSettle();
    expect(find.text('已发表的第 2 楼'), findsNothing);
    expect(
      find.byKey(const Key('thread-published-floor-status')),
      findsNothing,
    );
    expect(posts.createInputs, hasLength(1));
  });
}

Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 25; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _publish(WidgetTester tester, int number) async {
  await tester.tap(find.byKey(const Key('thread-floor-compose')));
  await tester.pumpAndSettle();
  await threadDetailPageTestReplacePostComposerText(tester, '已发表的第 $number 楼');
  await tester.tap(find.byKey(const Key('editor-submit')));
  await _frames(tester);
}

Future<ProviderContainer> _mount(
  WidgetTester tester,
  PublishedFloorRepository repository,
  PublishingPostRepository posts, {
  String entry = 'plain',
}) async {
  tester.view.physicalSize = const Size(360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [
      memoryPendingMediaFileStoreOverride(),
      tokenStoreProvider.overrideWithValue(
        ThreadDetailPageTestMemoryTokenStore(),
      ),
      sessionRemoteProvider.overrideWithValue(
        ThreadDetailPageTestFakeSessionRemote(),
      ),
      stickersEnabledProvider.overrideWithValue(false),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      threadSubscriptionRepositoryProvider.overrideWithValue(
        ThreadDetailPageTestFakeThreadSubscriptionRepository(),
      ),
      postRepositoryProvider.overrideWithValue(posts),
      postDiscussionAuthorDirectoryProvider.overrideWithValue(
        ThreadDetailPageTestMutablePostDiscussionAuthorDirectory(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(threadDetailPageTestTokensFor('user-1'));
  final router = GoRouter(
    initialLocation:
        '/threads/thread-1${switch (entry) {
          'subthread' => '?subthread=subthread-2',
          'post' => '?post=floor-1',
          _ => '',
        }}',
    routes: [
      GoRoute(
        path: '/threads/:threadId',
        name: 'thread-detail',
        builder: (context, state) => ThreadDetailPage(
          threadId: state.pathParameters['threadId']!,
          entryTarget: ThreadDetailEntryTarget.fromQuery(
            postId: state.uri.queryParameters['post'],
            subthreadId: state.uri.queryParameters['subthread'],
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
  return container;
}

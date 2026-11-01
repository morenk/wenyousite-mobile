import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/discussion_window.dart';
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

void main() {
  testWidgets('发布后慢目标窗口跨多帧仅请求一次并显示真实楼层', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final createdFloor = ThreadFloorModel(
      id: 'floor-created',
      floorNumber: 2,
      author: threadDetailPageTestAuthor,
      body: const ThreadBodyModel(markdown: '刚发表的楼层'),
      createdAt: DateTime.utc(2026, 8, 10, 9),
      isDeleted: false,
      replyCount: 0,
      replies: const [],
    );
    final detailRepository = _DelayedWindowRepository(
      mainFloors: [threadDetailPageTestMainFloor],
    );
    final postRepository = ThreadDetailPageTestCreatingPostRepository();
    final authorDirectory =
        ThreadDetailPageTestMutablePostDiscussionAuthorDirectory();
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
        threadDetailRepositoryProvider.overrideWithValue(detailRepository),
        threadSubscriptionRepositoryProvider.overrideWithValue(
          ThreadDetailPageTestFakeThreadSubscriptionRepository(),
        ),
        postRepositoryProvider.overrideWithValue(postRepository),
        postDiscussionAuthorDirectoryProvider.overrideWithValue(
          authorDirectory,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(threadDetailPageTestTokensFor('user-1'));
    final router = GoRouter(
      initialLocation: '/threads/thread-1',
      routes: [
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
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
    expect(authorDirectory.floorCalls, 1);

    await tester.tap(find.byKey(const Key('thread-floor-compose')));
    await tester.pumpAndSettle();
    await threadDetailPageTestReplacePostComposerText(tester, '刚发表的楼层');

    await tester.tap(find.byKey(const Key('editor-submit')));
    for (var frame = 0; frame < 25; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(detailRepository.windowTargets, ['floor-created']);
    expect(find.text('刚发表的楼层').hitTestable(), findsNothing);
    detailRepository.pending.complete(
      DiscussionWindow(
        items: [createdFloor],
        total: 2,
        maxNumber: 2,
        targetId: createdFloor.id,
        targetNumber: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(postRepository.createInputs, hasLength(1));
    expect(postRepository.createInputs.single.parentPostId, isNull);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['post'],
      isNull,
    );
    expect(detailRepository.targetPostIds, isEmpty);
    expect(detailRepository.requestedSubthreads, ['subthread-1']);
    expect(authorDirectory.floorCalls, 2);
    expect(find.text('刚发表的楼层'), findsOneWidget);
    expect(find.byKey(const Key('discussion-target-cover')), findsNothing);
    expect(
      find.byKey(const Key('thread-target-show-discussion')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}

class _DelayedWindowRepository
    extends ThreadDetailPageTestFakeThreadDetailRepository {
  _DelayedWindowRepository({super.mainFloors});
  final windowTargets = <String>[];
  final pending = Completer<DiscussionWindow<ThreadFloorModel>>();

  @override
  Future<DiscussionWindow<ThreadFloorModel>> fetchFloorWindow({
    required String subthreadId,
    int? number,
    String? postId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) {
    if (postId != null) {
      windowTargets.add(postId);
      return pending.future;
    }
    return super.fetchFloorWindow(
      subthreadId: subthreadId,
      number: number,
      cursor: cursor,
      limit: limit,
      order: order,
      authorId: authorId,
    );
  }
}

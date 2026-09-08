import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/posts/application/post_discussion_author_directory_ports.dart';
import 'package:wenyousite_mobile/features/posts/data/post_repository.dart';
import 'package:wenyousite_mobile/features/posts/domain/post_models.dart';
import 'package:wenyousite_mobile/features/social/data/thread_subscription_repository.dart';
import 'package:wenyousite_mobile/features/stickers/application/sticker_collection_controller.dart';
import 'package:wenyousite_mobile/features/threads/data/thread_detail_repository.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_page.dart';
import 'package:wenyousite_mobile/features/threads/presentation/thread_detail_target_utils.dart';

import '../../support/foundation_test_fonts.dart';
import 'thread_detail_page_test_support.dart';

void main() {
  setUpAll(loadFoundationTestFonts);

  testWidgets('普通入口编辑保存后删除楼层，原文立即移除且刷新不补回', (tester) async {
    final posts = _MutablePosts();
    final repository = _MutableDetail(posts);
    final router = await _pumpPage(tester, posts, repository, targeted: false);
    expect(repository.targetPostIds, isEmpty);
    await tester.ensureVisible(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.longPress(
      find.byKey(const Key('thread-floor-number-floor-1')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('thread-floor-action-floor-1-edit')));
    await tester.pumpAndSettle();
    await threadDetailPageTestReplacePostComposerText(tester, '编辑后的楼层原文');
    await tester.tap(find.byKey(const Key('editor-submit')));
    await tester.pumpAndSettle();
    expect(posts.content, '编辑后的楼层原文');
    expect(
      router.routeInformationProvider.value.uri.queryParameters['post'],
      'floor-1',
    );
    expect(repository.targetPostIds, contains('floor-1'));
    expect(find.text('编辑后的楼层原文'), findsOneWidget);
    await _deleteTarget(tester);
    expect(find.text('楼层已删除。'), findsOneWidget);
    expect(find.text('编辑后的楼层原文'), findsNothing);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    await _refreshPage(tester);
    expect(find.text('编辑后的楼层原文'), findsNothing);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('普通帖子入口删除楼层后移除，刷新不恢复且不发起定位查询', (tester) async {
    final posts = _MutablePosts();
    final repository = _MutableDetail(posts);
    await _pumpPage(tester, posts, repository, targeted: false);
    await _deleteTarget(tester);
    expect(posts.removedIds, ['floor-1']);
    expect(find.text('楼层已删除。'), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    await _refreshPage(tester);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    expect(repository.targetPostIds, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('删除定位楼层成功后立即移除，刷新不会从目标缓存补回', (tester) async {
    final posts = _MutablePosts();
    final repository = _MutableDetail(posts);
    await _pumpPage(tester, posts, repository);
    await _deleteTarget(tester);
    expect(posts.removedIds, ['floor-1']);
    expect(find.text('楼层已删除。'), findsOneWidget);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    await _refreshPage(tester);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('其他入口删除定位楼层后，下拉刷新同时重读目标并移除旧正文', (tester) async {
    final posts = _MutablePosts();
    final repository = _MutableDetail(posts);
    await _pumpPage(tester, posts, repository);
    posts.removedIds.add('floor-1');
    await _refreshPage(tester);
    expect(repository.targetPostIds.length, greaterThan(1));
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('删除请求失败不移除定位楼层也不显示删除成功', (tester) async {
    final posts = _MutablePosts(failDelete: true);
    final repository = _MutableDetail(posts);
    await _pumpPage(tester, posts, repository);
    await _deleteTarget(tester);
    expect(posts.removedIds, isEmpty);
    expect(find.text('楼层已删除。'), findsNothing);
    expect(find.byKey(const Key('thread-floor-card-floor-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<GoRouter> _pumpPage(
  WidgetTester tester,
  _MutablePosts posts,
  _MutableDetail repository, {
  bool targeted = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      stickersEnabledProvider.overrideWithValue(false),
      tokenStoreProvider.overrideWithValue(
        ThreadDetailPageTestMemoryTokenStore(),
      ),
      sessionRemoteProvider.overrideWithValue(
        ThreadDetailPageTestFakeSessionRemote(),
      ),
      threadDetailRepositoryProvider.overrideWithValue(repository),
      postRepositoryProvider.overrideWithValue(posts),
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
      .authenticate(threadDetailPageTestTokensFor('user-1'));
  final router = GoRouter(
    initialLocation: targeted
        ? '/threads/thread-1?post=floor-1'
        : '/threads/thread-1',
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
  expect(find.byKey(const Key('thread-floor-card-floor-1')), findsOneWidget);
  return router;
}

Future<void> _deleteTarget(WidgetTester tester) async {
  await tester.ensureVisible(
    find.byKey(const Key('thread-floor-number-floor-1')),
  );
  await tester.longPress(find.byKey(const Key('thread-floor-number-floor-1')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('thread-floor-action-floor-1-delete')));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '删除'));
  await tester.pumpAndSettle();
}

Future<void> _refreshPage(WidgetTester tester) async {
  final refresh = tester.widget<RefreshIndicator>(
    find.byType(RefreshIndicator),
  );
  await refresh.onRefresh();
  await tester.pumpAndSettle();
}

class _MutablePosts extends ThreadDetailPageTestFakePostRepository {
  _MutablePosts({this.failDelete = false});
  final bool failDelete;
  String content = '第一层内容';
  int version = 1;

  ThreadFloorModel get floor => ThreadFloorModel(
    id: 'floor-1',
    floorNumber: 1,
    author: threadDetailPageTestAuthor,
    body: ThreadBodyModel(markdown: content),
    version: version,
    createdAt: threadDetailPageTestRecentFixtureTime,
    isDeleted: false,
    replyCount: 0,
    replies: const [],
  );

  @override
  Future<PostItem> fetchPost(String postId) async => threadFloorAsPost(
    threadDetailPageTestManagerDetail,
    threadDetailPageTestManagerDetail.subthreadById('subthread-1')!,
    floor,
  );

  @override
  Future<PostItem> update({
    required String postId,
    required String content,
    required int version,
  }) async {
    this.content = content;
    this.version = version + 1;
    return fetchPost(postId);
  }

  @override
  Future<void> remove(String postId) async {
    if (failDelete) {
      throw const ApiFailure(userMessage: '删除失败，请重试。', httpStatus: 500);
    }
    await super.remove(postId);
  }
}

class _MutableDetail extends ThreadDetailPageTestFakeThreadDetailRepository {
  _MutableDetail(this.posts)
    : super(
        detail: threadDetailPageTestManagerDetail,
        postTarget: ThreadPostTargetModel(
          requestedPostId: 'floor-1',
          threadId: 'thread-1',
          subthreadId: 'subthread-1',
          floor: threadDetailPageTestMainFloor,
        ),
      );

  final _MutablePosts posts;

  @override
  Future<ThreadPostTargetModel> fetchPostTarget(String postId) async {
    if (posts.removedIds.contains(postId)) {
      targetPostIds.add(postId);
      throw const ApiFailure(
        userMessage: '楼层不存在。',
        httpStatus: 404,
        businessCode: 40403,
      );
    }
    targetPostIds.add(postId);
    return ThreadPostTargetModel(
      requestedPostId: postId,
      threadId: 'thread-1',
      subthreadId: 'subthread-1',
      floor: posts.floor,
    );
  }

  @override
  Future<CursorPage<ThreadFloorModel>> fetchFloors({
    required String subthreadId,
    String? cursor,
    int limit = 20,
    ThreadFloorOrder order = ThreadFloorOrder.oldest,
    String? authorId,
  }) async {
    final page = await super.fetchFloors(
      subthreadId: subthreadId,
      cursor: cursor,
      limit: limit,
      order: order,
      authorId: authorId,
    );
    return CursorPage(
      items: page.items
          .where((item) => !posts.removedIds.contains(item.id))
          .map((item) => item.id == 'floor-1' ? posts.floor : item)
          .toList(),
      cursor: page.cursor,
      hasMore: page.hasMore,
    );
  }
}

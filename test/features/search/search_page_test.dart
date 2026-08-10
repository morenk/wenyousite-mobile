import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';
import 'package:wenyousite_mobile/features/search/presentation/search_page.dart';

void main() {
  testWidgets('搜索页按综合、动态、主题、用户和正文五个页签惰性展示结果', (tester) async {
    final repository = _FakeSearchRepository();
    await tester.pumpWidget(_searchApp(repository));

    expect(find.text('输入关键词开始搜索'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search-query-input')), '星海');
    await tester.tap(find.byKey(const Key('search-submit')));
    await tester.pumpAndSettle();

    expect(find.text('星海旅团'), findsOneWidget);
    expect(repository.threadCalls, 1);
    expect(repository.userCalls, 0);
    expect(repository.postCalls, 0);

    await tester.tap(find.text('综合'));
    await tester.pumpAndSettle();
    expect(find.text('综合结果共 1 条'), findsNWidgets(3));
    expect(repository.overviewCalls, 1);

    await tester.tap(find.text('动态'));
    await tester.pumpAndSettle();
    expect(find.text('星海动态'), findsNWidgets(2));
    expect(repository.momentCalls, 1);

    await tester.tap(find.text('用户'));
    await tester.pumpAndSettle();
    expect(find.text('温柔测试员'), findsOneWidget);
    expect(repository.userCalls, 1);

    await tester.tap(find.text('正文'));
    await tester.pumpAndSettle();
    expect(find.text('这是一段星海正文'), findsOneWidget);
    expect(repository.postCalls, 1);
  });

  testWidgets('正文单字符提示最小长度且不发请求', (tester) async {
    final repository = _FakeSearchRepository();
    await tester.pumpWidget(_searchApp(repository));

    await tester.tap(find.text('正文'));
    await tester.enterText(find.byKey(const Key('search-query-input')), '星');
    await tester.tap(find.byKey(const Key('search-submit')));
    await tester.pumpAndSettle();

    expect(find.text('动态和正文搜索至少需要 2 个字符'), findsOneWidget);
    expect(repository.postCalls, 0);
  });

  testWidgets('首屏搜索失败展示请求 ID 并可重试恢复', (tester) async {
    final repository = _FakeSearchRepository(failFirstThreadRequest: true);
    await tester.pumpWidget(_searchApp(repository));

    await tester.enterText(find.byKey(const Key('search-query-input')), '星海');
    await tester.tap(find.byKey(const Key('search-submit')));
    await tester.pumpAndSettle();

    expect(find.text('搜索没有完成'), findsOneWidget);
    expect(find.text('请求 ID：search-request-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('search-retry')));
    await tester.pumpAndSettle();

    expect(find.text('星海旅团'), findsOneWidget);
    expect(repository.threadCalls, 2);
  });

  testWidgets('三类结果分别进入稳定主题、用户和帖子目标路径', (tester) async {
    final repository = _FakeSearchRepository();
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
        GoRoute(
          path: '/moments/:momentId',
          name: 'moment-detail',
          builder: (_, state) => Text('动态=${state.pathParameters['momentId']}'),
        ),
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => Text(
            '主题=${state.pathParameters['threadId']};'
            '帖子=${state.uri.queryParameters['post']}',
          ),
        ),
        GoRoute(
          path: '/users/:userId',
          name: 'user-profile',
          builder: (_, state) => Text('用户=${state.pathParameters['userId']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchControllerProvider.overrideWith(
            (ref) => SearchController(repository),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );

    await tester.enterText(find.byKey(const Key('search-query-input')), '星海');
    await tester.tap(find.byKey(const Key('search-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('星海旅团'));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1;帖子=null'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('动态'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('moment-open-moment-1')));
    await tester.pumpAndSettle();
    expect(find.text('动态=moment-1'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('用户'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('温柔测试员'));
    await tester.pumpAndSettle();
    expect(find.text('用户=user-1'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('正文'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('这是一段星海正文'));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1;帖子=post-1'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 搜索表单与结果卡片无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_searchApp(_FakeSearchRepository()));
      await tester.enterText(find.byKey(const Key('search-query-input')), '星海');
      await tester.tap(find.byKey(const Key('search-submit')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('search-submit'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}

Widget _searchApp(SearchRepository repository) {
  return ProviderScope(
    overrides: [
      searchControllerProvider.overrideWith(
        (ref) => SearchController(repository),
      ),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
  );
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.failFirstThreadRequest = false});

  final bool failFirstThreadRequest;
  int threadCalls = 0;
  int overviewCalls = 0;
  int momentCalls = 0;
  int userCalls = 0;
  int postCalls = 0;

  @override
  Future<SearchOverviewResult> searchOverview(String query) async {
    overviewCalls += 1;
    return SearchOverviewResult(
      threads: [_threadResult()],
      users: const [
        SearchUserResult(id: 'user-1', username: '温柔测试员', bio: '一起写下温柔的故事。'),
      ],
      posts: [_postResult()],
    );
  }

  @override
  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    momentCalls += 1;
    return CursorPage(items: [_momentResult()], hasMore: false);
  }

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) async {
    threadCalls += 1;
    if (failFirstThreadRequest && threadCalls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'search-request-id',
      );
    }
    return [_threadResult()];
  }

  @override
  Future<List<SearchUserResult>> searchUsers(String query) async {
    userCalls += 1;
    return const [
      SearchUserResult(id: 'user-1', username: '温柔测试员', bio: '一起写下温柔的故事。'),
    ];
  }

  @override
  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    postCalls += 1;
    return CursorPage(items: [_postResult()], hasMore: false);
  }

  @override
  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    return CursorPage(items: [_postResult()], hasMore: false);
  }
}

SearchThreadResult _threadResult() {
  return SearchThreadResult(
    id: 'thread-1',
    title: '星海旅团',
    categorySlug: 'RPG',
    ownerId: 'user-1',
    ownerName: '温柔测试员',
    createdAt: DateTime.utc(2026, 8, 10),
    memberCount: 5,
    playerCount: 2,
    postCount: 12,
    coverImageUrls: const [],
  );
}

SearchPostResult _postResult() {
  return SearchPostResult(
    id: 'post-1',
    floorNumber: 7,
    content: '这是一段星海正文',
    preview: '这是一段星海正文',
    authorId: 'user-1',
    authorName: '温柔测试员',
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    subthreadId: 'subthread-1',
    subthreadTitle: '主线',
    createdAt: DateTime.utc(2026, 8, 10),
  );
}

MomentCard _momentResult() {
  return MomentCard(
    id: 'moment-1',
    author: const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 3),
    title: '星海动态',
    contentExcerpt: '一起看星海',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.rose,
    imageCount: 0,
    likeCount: 1,
    commentCount: 1,
    bookmarkCount: 0,
    tipTotal: 0,
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: DateTime.utc(2026, 8, 10),
    updatedAt: DateTime.utc(2026, 8, 10),
  );
}

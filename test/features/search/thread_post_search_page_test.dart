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
import 'package:wenyousite_mobile/features/search/presentation/thread_post_search_page.dart';

void main() {
  testWidgets('主题内搜索校验短词、展示结果并定位目标楼层', (tester) async {
    final repository = _FakeSearchRepository();
    final router = GoRouter(
      initialLocation: '/threads/thread-1/search',
      routes: [
        GoRoute(
          path: '/threads/:threadId/search',
          builder: (_, state) =>
              ThreadPostSearchPage(threadId: state.pathParameters['threadId']!),
        ),
        GoRoute(
          path: '/threads/:threadId',
          name: 'thread-detail',
          builder: (_, state) => Text(
            '主题=${state.pathParameters['threadId']};'
            '帖子=${state.uri.queryParameters['post']}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(repository, router: router));

    expect(find.text('输入关键词搜索当前主题'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('thread-search-query-input')),
      '星',
    );
    await tester.tap(find.byKey(const Key('thread-search-submit')));
    await tester.pumpAndSettle();
    expect(find.text('主题内搜索至少需要 2 个字符'), findsOneWidget);
    expect(repository.threadPostCalls, 0);

    await tester.enterText(
      find.byKey(const Key('thread-search-query-input')),
      '星海',
    );
    await tester.tap(find.byKey(const Key('thread-search-submit')));
    await tester.pumpAndSettle();
    expect(find.text('主题内命中正文'), findsOneWidget);
    expect(repository.threadPostCalls, 1);

    await tester.tap(find.byKey(const Key('thread-search-result-post-1')));
    await tester.pumpAndSettle();
    expect(find.text('主题=thread-1;帖子=post-1'), findsOneWidget);
  });

  testWidgets('主题内搜索失败展示请求 ID 并可重试', (tester) async {
    final repository = _FakeSearchRepository(failFirst: true);
    await tester.pumpWidget(_app(repository));

    await tester.enterText(
      find.byKey(const Key('thread-search-query-input')),
      '星海',
    );
    await tester.tap(find.byKey(const Key('thread-search-submit')));
    await tester.pumpAndSettle();
    expect(find.text('问题编号：thread-search-request'), findsOneWidget);

    await tester.tap(find.byKey(const Key('thread-search-retry')));
    await tester.pumpAndSettle();
    expect(find.text('主题内命中正文'), findsOneWidget);
    expect(repository.threadPostCalls, 2);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 主题内搜索表单与结果无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_app(_FakeSearchRepository()));

      await tester.enterText(
        find.byKey(const Key('thread-search-query-input')),
        '星海',
      );
      await tester.tap(find.byKey(const Key('thread-search-submit')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('thread-search-submit'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}

Widget _app(_FakeSearchRepository repository, {GoRouter? router}) {
  final scope = ProviderScope(
    overrides: [
      threadPostSearchControllerProvider.overrideWith(
        (ref, threadId) => ThreadPostSearchController(repository, threadId),
      ),
    ],
    child: router == null
        ? MaterialApp(
            theme: AppTheme.light,
            home: const ThreadPostSearchPage(threadId: 'thread-1'),
          )
        : MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
  return scope;
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.failFirst = false});

  final bool failFirst;
  int threadPostCalls = 0;

  @override
  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    threadPostCalls += 1;
    if (failFirst && threadPostCalls == 1) {
      throw const ApiFailure(
        userMessage: '主题内搜索暂时不可用。',
        requestId: 'thread-search-request',
      );
    }
    return CursorPage(items: [_post()], hasMore: false);
  }

  @override
  Future<SearchOverviewResult> searchOverview(String query) {
    throw UnimplementedError();
  }

  @override
  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) {
    throw UnimplementedError();
  }

  @override
  Future<List<SearchUserResult>> searchUsers(String query) {
    throw UnimplementedError();
  }
}

SearchPostResult _post() {
  return SearchPostResult(
    id: 'post-1',
    floorNumber: 7,
    content: '主题内命中正文',
    preview: '主题内命中正文',
    authorId: 'user-1',
    authorName: '温柔测试员',
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    subthreadId: 'subthread-1',
    subthreadTitle: '主线',
    createdAt: DateTime.utc(2026, 8, 10),
  );
}

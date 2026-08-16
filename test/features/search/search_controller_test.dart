import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/moments/domain/moment_models.dart';
import 'package:wenyousite_mobile/features/search/application/search_controller.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';
import 'package:wenyousite_mobile/features/search/domain/search_models.dart';

void main() {
  test('提交时只加载当前页签，切换页签后才按需搜索', () async {
    final repository = _FakeSearchRepository();
    final controller = SearchController(repository);

    await controller.submit('  星海  ');

    expect(controller.state.query, '星海');
    expect(controller.state.threads.phase, SearchSectionPhase.ready);
    expect(repository.threadQueries, ['星海']);
    expect(repository.userQueries, isEmpty);
    expect(repository.postQueries, isEmpty);

    await controller.selectTab(SearchResultTab.overview);
    expect(controller.state.overview.phase, SearchSectionPhase.ready);
    expect(repository.overviewQueries, ['星海']);

    await controller.selectTab(SearchResultTab.moments);
    expect(controller.state.moments.phase, SearchSectionPhase.ready);
    expect(repository.momentQueries, ['星海']);

    await controller.selectTab(SearchResultTab.users);
    expect(controller.state.users.phase, SearchSectionPhase.ready);
    expect(repository.userQueries, ['星海']);

    await controller.selectTab(SearchResultTab.posts);
    expect(controller.state.posts.phase, SearchSectionPhase.ready);
    expect(repository.postQueries, ['星海']);
  });

  test('正文单字符搜索不请求接口并展示空闲态', () async {
    final repository = _FakeSearchRepository();
    final controller = SearchController(repository);

    await controller.selectTab(SearchResultTab.posts);
    await controller.submit('星');

    expect(controller.state.isContentQueryValid, isFalse);
    expect(controller.state.posts.phase, SearchSectionPhase.idle);
    expect(repository.postQueries, isEmpty);
  });

  test('较早请求晚返回时不会覆盖新的搜索词结果', () async {
    final oldResult = Completer<List<SearchThreadResult>>();
    final newResult = Completer<List<SearchThreadResult>>();
    final repository = _FakeSearchRepository(
      onThreads: (query) => query == '旧词' ? oldResult.future : newResult.future,
    );
    final controller = SearchController(repository);

    final oldRequest = controller.submit('旧词');
    final newRequest = controller.submit('新词');
    newResult.complete([_thread('new-thread', '新结果')]);
    await newRequest;
    oldResult.complete([_thread('old-thread', '旧结果')]);
    await oldRequest;

    expect(controller.state.query, '新词');
    expect(controller.state.threads.items.single.id, 'new-thread');
  });

  test('正文分页按 ID 去重，cursor 失效时从第一页恢复', () async {
    var firstPageCalls = 0;
    final repository = _FakeSearchRepository(
      onPosts: (query, cursor) async {
        if (cursor == 'next') {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        firstPageCalls += 1;
        return CursorPage(
          items: [
            firstPageCalls == 1
                ? _post('post-1', '第一条')
                : _post('post-2', '恢复后的结果'),
          ],
          cursor: 'next',
          hasMore: true,
        );
      },
    );
    final controller = SearchController(repository);

    await controller.selectTab(SearchResultTab.posts);
    await controller.submit('星海');
    await controller.loadMorePosts();

    expect(firstPageCalls, 2);
    expect(controller.state.posts.items.single.id, 'post-2');
    expect(controller.state.posts.failure, isNull);
    expect(controller.state.posts.isLoadingMore, isFalse);
  });

  test('动态分页去重，主题内搜索游标失效后也从第一页恢复', () async {
    var momentFirstPageCalls = 0;
    var threadFirstPageCalls = 0;
    final repository = _FakeSearchRepository(
      onMoments: (query, cursor) async {
        if (cursor == 'moment-next') {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        momentFirstPageCalls += 1;
        return CursorPage(
          items: [_moment('moment-$momentFirstPageCalls')],
          cursor: 'moment-next',
          hasMore: true,
        );
      },
      onThreadPosts: (threadId, query, cursor) async {
        if (cursor == 'thread-next') {
          throw const ApiFailure(
            userMessage: '列表位置已失效，正在重新加载。',
            businessCode: 40007,
          );
        }
        threadFirstPageCalls += 1;
        return CursorPage(
          items: [_post('thread-post-$threadFirstPageCalls', '主题内结果')],
          cursor: 'thread-next',
          hasMore: true,
        );
      },
    );
    final search = SearchController(repository);
    await search.selectTab(SearchResultTab.moments);
    await search.submit('星海');
    await search.loadMoreMoments();
    expect(momentFirstPageCalls, 2);
    expect(search.state.moments.items.single.id, 'moment-2');

    final threadSearch = ThreadPostSearchController(repository, 'thread-1');
    await threadSearch.submit('星海');
    await threadSearch.loadMore();
    expect(threadFirstPageCalls, 2);
    expect(threadSearch.state.results.items.single.id, 'thread-post-2');
  });

  test('正文分页晚返回时不会覆盖已经完成的刷新结果', () async {
    final stalePage = Completer<CursorPage<SearchPostResult>>();
    var firstPageCalls = 0;
    final repository = _FakeSearchRepository(
      onPosts: (query, cursor) {
        if (cursor == 'next') return stalePage.future;
        firstPageCalls += 1;
        return Future.value(
          CursorPage(
            items: [_post(firstPageCalls == 1 ? 'initial' : 'refreshed', '正文')],
            cursor: 'next',
            hasMore: true,
          ),
        );
      },
    );
    final controller = SearchController(repository);
    await controller.selectTab(SearchResultTab.posts);
    await controller.submit('星海');

    final loadMore = controller.loadMorePosts();
    await Future<void>.delayed(Duration.zero);
    await controller.refreshActive();
    stalePage.complete(
      CursorPage(items: [_post('stale-page', '旧分页')], hasMore: false),
    );
    await loadMore;

    expect(controller.state.posts.items.single.id, 'refreshed');
    expect(controller.state.posts.isLoadingMore, isFalse);
  });

  test('主题内分页晚返回时不会覆盖已经完成的重试结果', () async {
    final stalePage = Completer<CursorPage<SearchPostResult>>();
    var firstPageCalls = 0;
    final repository = _FakeSearchRepository(
      onThreadPosts: (threadId, query, cursor) {
        if (cursor == 'next') return stalePage.future;
        firstPageCalls += 1;
        return Future.value(
          CursorPage(
            items: [
              _post(firstPageCalls == 1 ? 'initial' : 'retried', '主题内正文'),
            ],
            cursor: 'next',
            hasMore: true,
          ),
        );
      },
    );
    final controller = ThreadPostSearchController(repository, 'thread-1');
    await controller.submit('星海');

    final loadMore = controller.loadMore();
    await Future<void>.delayed(Duration.zero);
    await controller.retry();
    stalePage.complete(
      CursorPage(items: [_post('stale-page', '旧分页')], hasMore: false),
    );
    await loadMore;

    expect(controller.state.results.items.single.id, 'retried');
    expect(controller.state.results.isLoadingMore, isFalse);
  });
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({
    this.onThreads,
    this.onPosts,
    this.onMoments,
    this.onThreadPosts,
  });

  final Future<List<SearchThreadResult>> Function(String query)? onThreads;
  final Future<CursorPage<SearchPostResult>> Function(
    String query,
    String? cursor,
  )?
  onPosts;
  final Future<CursorPage<MomentCard>> Function(String query, String? cursor)?
  onMoments;
  final Future<CursorPage<SearchPostResult>> Function(
    String threadId,
    String query,
    String? cursor,
  )?
  onThreadPosts;
  final overviewQueries = <String>[];
  final momentQueries = <String>[];
  final threadQueries = <String>[];
  final userQueries = <String>[];
  final postQueries = <String>[];

  @override
  Future<SearchOverviewResult> searchOverview(String query) async {
    overviewQueries.add(query);
    return SearchOverviewResult(
      threads: [_thread('thread-1', '星海')],
      users: const [SearchUserResult(id: 'user-1', username: '温柔测试员')],
      posts: [_post('post-1', '星海正文')],
    );
  }

  @override
  Future<CursorPage<MomentCard>> searchMoments(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    momentQueries.add(query);
    return onMoments?.call(query, cursor) ??
        Future.value(CursorPage(items: [_moment('moment-1')], hasMore: false));
  }

  @override
  Future<List<SearchThreadResult>> searchThreads(String query) {
    threadQueries.add(query);
    return onThreads?.call(query) ?? Future.value([_thread('thread-1', '星海')]);
  }

  @override
  Future<List<SearchUserResult>> searchUsers(String query) async {
    userQueries.add(query);
    return const [SearchUserResult(id: 'user-1', username: '温柔测试员')];
  }

  @override
  Future<CursorPage<SearchPostResult>> searchPosts(
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    postQueries.add(query);
    return onPosts?.call(query, cursor) ??
        Future.value(
          CursorPage(items: [_post('post-1', '星海正文')], hasMore: false),
        );
  }

  @override
  Future<CursorPage<SearchPostResult>> searchThreadPosts(
    String threadId,
    String query, {
    String? cursor,
    int limit = 20,
  }) {
    return onThreadPosts?.call(threadId, query, cursor) ??
        Future.value(
          CursorPage(items: [_post('post-1', '主题内正文')], hasMore: false),
        );
  }
}

SearchThreadResult _thread(String id, String title) {
  return SearchThreadResult(
    id: id,
    title: title,
    ownerId: 'user-1',
    ownerName: '温柔测试员',
    createdAt: DateTime.utc(2026, 8, 10),
    memberCount: 3,
    playerCount: 1,
    postCount: 8,
    coverImageUrls: const [],
  );
}

SearchPostResult _post(String id, String content) {
  return SearchPostResult(
    id: id,
    content: content,
    preview: content,
    authorId: 'user-1',
    authorName: '温柔测试员',
    threadId: 'thread-1',
    threadTitle: '星海旅团',
    subthreadId: 'subthread-1',
    subthreadTitle: '主线',
    createdAt: DateTime.utc(2026, 8, 10),
  );
}

MomentCard _moment(String id) {
  return MomentCard(
    id: id,
    author: const MomentAuthor(id: 'user-1', username: '温柔测试员', level: 3),
    title: '星海动态',
    contentExcerpt: '一起看星海',
    coverType: MomentCoverType.text,
    textCoverTheme: MomentTextCoverTheme.rose,
    imageCount: 0,
    likeCount: 0,
    commentCount: 0,
    bookmarkCount: 0,
    tipTotal: '0',
    viewerLiked: false,
    viewerBookmarked: false,
    createdAt: DateTime.utc(2026, 8, 10),
    updatedAt: DateTime.utc(2026, 8, 10),
  );
}

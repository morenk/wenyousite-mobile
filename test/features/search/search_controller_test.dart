import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
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

    expect(controller.state.isPostQueryValid, isFalse);
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
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.onThreads, this.onPosts});

  final Future<List<SearchThreadResult>> Function(String query)? onThreads;
  final Future<CursorPage<SearchPostResult>> Function(
    String query,
    String? cursor,
  )?
  onPosts;
  final threadQueries = <String>[];
  final userQueries = <String>[];
  final postQueries = <String>[];

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

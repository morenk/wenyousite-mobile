import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';

void main() {
  test('搜索仓库映射综合、动态、分类与主题内结果契约', () async {
    final api = _MockSearchApi();
    when(
      () => api.searchSearch(q: '星海', extra: const {'skipAuth': true}),
    ).thenAnswer((_) async => _overviewResponse());
    when(
      () =>
          api.searchSearchMoments(q: '星海', cursor: 'moment-cursor-1', limit: 6),
    ).thenAnswer((_) async => _momentsResponse());
    when(
      () => api.searchSearchThreads(q: '星海', extra: const {'skipAuth': true}),
    ).thenAnswer((_) async => _threadsResponse());
    when(
      () => api.searchSearchUsers(q: '星海', extra: const {'skipAuth': true}),
    ).thenAnswer((_) async => _usersResponse());
    when(
      () => api.searchSearchPosts(
        q: '星海',
        cursor: 'cursor-1',
        limit: 7,
        extra: const {'skipAuth': true},
      ),
    ).thenAnswer((_) async => _postsResponse());
    when(
      () => api.threadSearchSearchPosts(
        threadId: 'thread-1',
        q: '星海',
        cursor: 'cursor-1',
        limit: 7,
      ),
    ).thenAnswer((_) async => _threadPostsResponse());
    final repository = ApiSearchRepository(api);

    final overview = await repository.searchOverview('  星海  ');
    final moments = await repository.searchMoments(
      '  星海  ',
      cursor: 'moment-cursor-1',
      limit: 6,
    );
    final threads = await repository.searchThreads('  星海  ');
    final users = await repository.searchUsers('  星海  ');
    final posts = await repository.searchPosts(
      '  星海  ',
      cursor: 'cursor-1',
      limit: 7,
    );
    final threadPosts = await repository.searchThreadPosts(
      ' thread-1 ',
      '  星海  ',
      cursor: 'cursor-1',
      limit: 7,
    );

    expect(overview.threads.single.title, '星海旅团');
    expect(overview.users.single.username, '温柔测试员');
    expect(overview.posts.single.id, 'post-7');
    expect(moments.items.single.title, '星海动态');
    expect(moments.items.single.author.level, 3);
    expect(moments.cursor, 'moment-cursor-2');
    expect(threads.single.title, '星海旅团');
    expect(threads.single.ownerName, '已注销用户');
    expect(threads.single.coverImageUrls, [
      'https://cdn.example.com/cover.jpg',
    ]);
    expect(threads.single.memberCount, 5);
    expect(users.single.username, '温柔测试员');
    expect(users.single.avatarUrl, isNull);
    expect(users.single.bio, isNull);
    expect(posts.cursor, 'cursor-2');
    expect(posts.hasMore, isTrue);
    expect(posts.items.single.floorNumber, 7);
    expect(posts.items.single.preview, '星海正文 [图片]');
    expect(posts.items.single.threadTitle, '星海旅团');
    expect(threadPosts.items.single.threadId, 'thread-1');
  });

  test('动态搜索拒绝不安全封面，主题内搜索拒绝跨主题结果', () async {
    final api = _MockSearchApi();
    when(
      () => api.searchSearchMoments(q: '星海', cursor: null, limit: 20),
    ).thenAnswer((_) async => _momentsResponse(unsafeCover: true));
    when(
      () => api.threadSearchSearchPosts(
        threadId: 'thread-1',
        q: '星海',
        cursor: null,
        limit: 20,
      ),
    ).thenAnswer((_) async => _threadPostsResponse(postThreadId: 'thread-2'));
    final repository = ApiSearchRepository(api);

    await expectLater(
      repository.searchMoments('星海'),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      repository.searchThreadPosts('thread-1', '星海'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockSearchApi extends Mock implements SearchApi {}

Response<SearchSearchThreads200Response> _threadsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/search/threads'),
    data: SearchSearchThreads200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(_threadDto()),
    ),
  );
}

Response<SearchSearchUsers200Response> _usersResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/search/users'),
    data: SearchSearchUsers200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(_userDto()),
    ),
  );
}

Response<SearchSearchPosts200Response> _postsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/search/posts'),
    data: SearchSearchPosts200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'cursor-2'
            ..hasMore = true,
        )
        ..data.add(_postDto()),
    ),
  );
}

Response<SearchSearch200Response> _overviewResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/search'),
    data: SearchSearch200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..threads.add(_threadDto())
            ..users.add(_userDto())
            ..posts.add(_postDto()),
        ),
    ),
  );
}

Response<SearchSearchMoments200Response> _momentsResponse({
  bool unsafeCover = false,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/search/moments'),
    data: SearchSearchMoments200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'moment-cursor-2'
            ..hasMore = true,
        )
        ..data.add(
          MomentSearchResponseDto(
            (moment) => moment
              ..id = 'moment-1'
              ..authorId = 'user-1'
              ..author.update(
                (author) => author
                  ..id = 'user-1'
                  ..username = '温柔测试员'
                  ..avatar = null
                  ..level = 3,
              )
              ..title = '星海动态'
              ..contentExcerpt = '一起看星海'
              ..coverType = unsafeCover
                  ? MomentSearchResponseDtoCoverTypeEnum.IMAGE
                  : MomentSearchResponseDtoCoverTypeEnum.TEXT
              ..textCoverTheme = MomentSearchResponseDtoTextCoverThemeEnum.ROSE
              ..coverMedia = unsafeCover
                  ? MomentMediaResponseDto(
                      (media) => media
                        ..id = 'media-1'
                        ..url = 'file:///private/cover.jpg'
                        ..thumbnailUrl = null
                        ..feedUrl = null
                        ..mediumUrl = null
                        ..width = 640
                        ..height = 480,
                    ).toBuilder()
                  : null
              ..imageCount = unsafeCover ? 1 : 0
              ..likeCount = 2
              ..commentCount = 1
              ..bookmarkCount = 1
              ..tipTotal = '0'
              ..viewerLiked = false
              ..viewerBookmarked = false
              ..createdAt = DateTime.utc(2026, 8, 10)
              ..updatedAt = DateTime.utc(2026, 8, 10)
              ..relevance = 0.9,
          ),
        ),
    ),
  );
}

Response<ThreadSearchSearchPosts200Response> _threadPostsResponse({
  String postThreadId = 'thread-1',
}) {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/threads/thread-1/search/posts',
    ),
    data: ThreadSearchSearchPosts200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = null
            ..hasMore = false,
        )
        ..data.add(_postDto(threadId: postThreadId)),
    ),
  );
}

SearchThreadResponseDto _threadDto() {
  return SearchThreadResponseDto(
    (thread) => thread
      ..id = 'thread-1'
      ..title = '  星海旅团  '
      ..category = 'RPG'
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..owner.update(
        (owner) => owner
          ..id = 'user-1'
          ..username = '已注销用户'
          ..avatar = 'javascript:alert(1)',
      )
      ..count.update(
        (count) => count
          ..members = 5
          ..players = 2
          ..posts = 12,
      )
      ..coverImages.addAll([
        'https://cdn.example.com/cover.jpg',
        'https://cdn.example.com/ignored-second-cover.jpg',
      ]),
  );
}

SearchUserResponseDto _userDto() {
  return SearchUserResponseDto(
    (user) => user
      ..id = 'user-1'
      ..username = '温柔测试员'
      ..avatar = 'file:///private/avatar.png'
      ..bio = '   ',
  );
}

SearchPostResponseDto _postDto({String threadId = 'thread-1'}) {
  return SearchPostResponseDto(
    (post) => post
      ..id = 'post-7'
      ..floorNumber = 7
      ..content = '**星海正文** ![航图](https://cdn.example.com/map.jpg)'
      ..createdAt = DateTime.utc(2026, 8, 10)
      ..author.update(
        (author) => author
          ..id = 'user-1'
          ..username = '温柔测试员',
      )
      ..thread.update(
        (thread) => thread
          ..id = threadId
          ..title = '星海旅团',
      )
      ..subthread.update(
        (subthread) => subthread
          ..id = 'subthread-1'
          ..title = '主线',
      ),
  );
}

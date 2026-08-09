import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/search/data/search_repository.dart';

void main() {
  test('搜索仓库传递匿名请求参数并映射三个结果契约', () async {
    final api = _MockSearchApi();
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
    final repository = ApiSearchRepository(api);

    final threads = await repository.searchThreads('  星海  ');
    final users = await repository.searchUsers('  星海  ');
    final posts = await repository.searchPosts(
      '  星海  ',
      cursor: 'cursor-1',
      limit: 7,
    );

    expect(threads.single.title, '星海旅团');
    expect(threads.single.ownerName, '温柔测试员');
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
    expect(posts.items.single.preview, '星海正文 [图片：航图]');
    expect(posts.items.single.threadTitle, '星海旅团');
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
        ..data.add(
          SearchThreadResponseDto(
            (thread) => thread
              ..id = 'thread-1'
              ..title = '  星海旅团  '
              ..category = 'RPG'
              ..createdAt = DateTime.utc(2026, 8, 10)
              ..owner.update(
                (owner) => owner
                  ..id = 'user-1'
                  ..username = '温柔测试员'
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
                'data:image/png;base64,YQ==',
              ]),
          ),
        ),
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
        ..data.add(
          SearchUserResponseDto(
            (user) => user
              ..id = 'user-1'
              ..username = '温柔测试员'
              ..avatar = 'file:///private/avatar.png'
              ..bio = '   ',
          ),
        ),
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
        ..data.add(
          SearchPostResponseDto(
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
                  ..id = 'thread-1'
                  ..title = '星海旅团',
              )
              ..subthread.update(
                (subthread) => subthread
                  ..id = 'subthread-1'
                  ..title = '主线',
              ),
          ),
        ),
    ),
  );
}

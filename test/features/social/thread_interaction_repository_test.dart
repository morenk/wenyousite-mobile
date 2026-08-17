import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/thread_interaction_repository.dart';

void main() {
  test('点赞和取消点赞使用主题 ID 并采用服务端权威计数', () async {
    final threadsApi = _MockThreadsApi();
    final bookmarksApi = _MockBookmarksApi();
    when(
      () => threadsApi.threadsLike(id: 'thread-1'),
    ).thenAnswer((_) async => _likeResponse(13));
    when(
      () => threadsApi.threadsUnlike(id: 'thread-1'),
    ).thenAnswer((_) async => _unlikeResponse(11));
    final repository = ApiThreadInteractionRepository(threadsApi, bookmarksApi);

    expect(await repository.like('thread-1'), 13);
    expect(await repository.unlike('thread-1'), 11);
    verify(() => threadsApi.threadsLike(id: 'thread-1')).called(1);
    verify(() => threadsApi.threadsUnlike(id: 'thread-1')).called(1);
  });

  test('创建收藏提交 threadId 并返回后续删除所需记录 ID', () async {
    final threadsApi = _MockThreadsApi();
    final bookmarksApi = _MockBookmarksApi();
    final body = CreateBookmarkDto((dto) => dto.threadId = 'thread-1');
    when(
      () => bookmarksApi.bookmarksCreate(createBookmarkDto: body),
    ).thenAnswer((_) async => _createBookmarkResponse());
    when(
      () => bookmarksApi.bookmarksRemove(id: 'bookmark-1'),
    ).thenAnswer((_) async => _removeBookmarkResponse());
    final repository = ApiThreadInteractionRepository(threadsApi, bookmarksApi);

    expect(await repository.createBookmark('thread-1'), 'bookmark-1');
    await repository.removeBookmark('bookmark-1');

    verify(
      () => bookmarksApi.bookmarksCreate(createBookmarkDto: body),
    ).called(1);
    verify(() => bookmarksApi.bookmarksRemove(id: 'bookmark-1')).called(1);
  });

  test('互动空响应不伪装成功', () async {
    final threadsApi = _MockThreadsApi();
    when(() => threadsApi.threadsLike(id: 'thread-1')).thenAnswer(
      (_) async => Response<ThreadsLike201Response>(
        requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/like'),
      ),
    );

    await expectLater(
      ApiThreadInteractionRepository(
        threadsApi,
        _MockBookmarksApi(),
      ).like('thread-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('点赞失败'),
        ),
      ),
    );
  });
}

class _MockThreadsApi extends Mock implements ThreadsApi {}

class _MockBookmarksApi extends Mock implements BookmarksApi {}

Response<ThreadsLike201Response> _likeResponse(int likeCount) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/like'),
    data: ThreadsLike201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..id = 'thread-1'
            ..likeCount = likeCount,
        ),
    ),
  );
}

Response<ThreadsUnlike200Response> _unlikeResponse(int likeCount) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/threads/thread-1/like'),
    data: ThreadsUnlike200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..id = 'thread-1'
            ..likeCount = likeCount,
        ),
    ),
  );
}

Response<BookmarksCreate201Response> _createBookmarkResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks'),
    data: BookmarksCreate201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..id = 'bookmark-1'
            ..userId = 'user-1'
            ..threadId = 'thread-1'
            ..folderId = 'default-folder-1'
            ..createdAt = DateTime.utc(2026, 8, 10),
        ),
    ),
  );
}

Response<BookmarksRemove200Response> _removeBookmarkResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks/bookmark-1'),
    data: BookmarksRemove200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已取消收藏'),
    ),
  );
}

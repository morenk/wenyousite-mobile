import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

void main() {
  test('本人收藏传递游标并映射帖子摘要与下一页', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksFindAll(cursor: 'bookmark-cursor', limit: 7),
    ).thenAnswer((_) async => _listResponse());

    final page = await ApiBookmarkListRepository(
      api,
    ).fetchPage(cursor: 'bookmark-cursor', limit: 7);

    verify(
      () => api.bookmarksFindAll(cursor: 'bookmark-cursor', limit: 7),
    ).called(1);
    expect(page.cursor, 'bookmark-next');
    expect(page.hasMore, isTrue);
    final item = page.items.single;
    expect(item.bookmarkId, 'bookmark-1');
    expect(item.threadId, 'thread-1');
    expect(item.title, '雾港来信');
    expect(item.status, BookmarkedThreadStatus.recruiting);
    expect(item.isPrivate, isTrue);
    expect(item.isPinned, isTrue);
    expect(item.ownerName, '骰子猫');
    expect(item.memberCount, 4);
    expect(item.postCount, 18);
  });

  test('缺少收藏记录 ID 时整页失败而不是展示不可管理条目', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksFindAll(cursor: null, limit: 20),
    ).thenAnswer((_) async => _listResponse(includeBookmarkId: false));

    await expectLater(
      ApiBookmarkListRepository(api).fetchPage(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('管理 ID'),
        ),
      ),
    );
  });

  test('取消收藏使用记录 ID，空响应不伪装成功', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksRemove(id: 'bookmark-1'),
    ).thenAnswer((_) async => _removeResponse());
    final repository = ApiBookmarkListRepository(api);

    await repository.remove('bookmark-1');
    verify(() => api.bookmarksRemove(id: 'bookmark-1')).called(1);

    when(() => api.bookmarksRemove(id: 'bookmark-empty')).thenAnswer(
      (_) async => Response<BookmarksRemove200Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/bookmarks/bookmark-empty',
        ),
      ),
    );
    await expectLater(
      repository.remove('bookmark-empty'),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockBookmarksApi extends Mock implements BookmarksApi {}

Response<BookmarksFindAll200Response> _listResponse({
  bool includeBookmarkId = true,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks'),
    data: BookmarksFindAll200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'bookmark-next'
            ..hasMore = true,
        )
        ..data.add(
          OwnBookmarkThreadResponseDto((thread) {
            thread
              ..id = 'thread-1'
              ..title = '  雾港来信  '
              ..category = 'RPG'
              ..status = OwnBookmarkThreadResponseDtoStatusEnum.RECRUITING
              ..visibility = OwnBookmarkThreadResponseDtoVisibilityEnum.PRIVATE
              ..published = true
              ..pinned = true
              ..tipTotal = '9'
              ..createdAt = DateTime.utc(2026, 8, 1)
              ..updatedAt = DateTime.utc(2026, 8, 10)
              ..owner.update(
                (owner) => owner
                  ..id = 'owner-1'
                  ..username = '骰子猫'
                  ..level = 3,
              )
              ..count.update(
                (count) => count
                  ..members = 4
                  ..posts = 18,
              );
            if (includeBookmarkId) thread.bookmarkId = 'bookmark-1';
          }),
        ),
    ),
  );
}

Response<BookmarksRemove200Response> _removeResponse() {
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

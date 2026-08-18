import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/bookmark_list_repository.dart';
import 'package:wenyousite_mobile/features/social/domain/bookmark_list_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      CreateBookmarkFolderDto((builder) => builder.name = 'x'),
    );
    registerFallbackValue(MoveBookmarkDto((builder) => builder.folderId = 'x'));
  });

  test('本人收藏传递游标并映射完整主题卡与下一页', () async {
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
    expect(item.folderId, 'folder-default');
    expect(item.threadId, 'thread-1');
    expect(item.title, '雾港来信');
    expect(item.status, BookmarkedThreadStatus.recruiting);
    expect(item.isPrivate, isTrue);
    expect(item.isPinned, isTrue);
    expect(item.isPublished, isTrue);
    expect(item.ownerId, 'owner-1');
    expect(item.ownerName, '骰子猫');
    expect(item.ownerAvatarUrl, 'https://cdn.example.com/avatar.jpg');
    expect(item.lastActivityAt, DateTime.utc(2026, 8, 11));
    expect(item.preview, '雾港中的第一封信');
    expect(item.tags.single.name, '都市奇谈');
    expect(item.coverImageUrls, ['https://cdn.example.com/cover.jpg']);
    expect(item.memberCount, 4);
    expect(item.playerCount, 2);
    expect(item.postCount, 18);
  });

  test('按收藏夹读取时原样传递 folderId', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksFindAll(
        cursor: null,
        folderId: 'folder-custom',
        limit: 20,
      ),
    ).thenAnswer((_) async => _listResponse());

    await ApiBookmarkListRepository(api).fetchPage(folderId: 'folder-custom');

    verify(
      () => api.bookmarksFindAll(
        cursor: null,
        folderId: 'folder-custom',
        limit: 20,
      ),
    ).called(1);
  });

  test('映射服务端收藏夹顺序和计数，并在创建前 trim 名称', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksFindFolders(),
    ).thenAnswer((_) async => _foldersResponse());
    when(
      () => api.bookmarksCreateFolder(
        createBookmarkFolderDto: any(named: 'createBookmarkFolderDto'),
      ),
    ).thenAnswer((_) async => _createFolderResponse());
    final repository = ApiBookmarkListRepository(api);

    final folders = await repository.fetchFolders();
    final created = await repository.createFolder('  跑团资料  ');

    expect(folders.map((folder) => folder.name), ['默认收藏夹', '灵感']);
    expect(folders.first.isDefault, isTrue);
    expect(folders.first.bookmarkCount, 2);
    expect(created.name, '跑团资料');
    final captured =
        verify(
              () => api.bookmarksCreateFolder(
                createBookmarkFolderDto: captureAny(
                  named: 'createBookmarkFolderDto',
                ),
              ),
            ).captured.single
            as CreateBookmarkFolderDto;
    expect(captured.name, '跑团资料');
  });

  test('移动使用收藏记录 ID 与目标收藏夹 ID，空响应不伪装成功', () async {
    final api = _MockBookmarksApi();
    when(
      () => api.bookmarksMove(
        id: 'bookmark-1',
        moveBookmarkDto: any(named: 'moveBookmarkDto'),
      ),
    ).thenAnswer((_) async => _moveResponse());
    final repository = ApiBookmarkListRepository(api);

    await repository.move('bookmark-1', 'folder-custom');

    final captured =
        verify(
              () => api.bookmarksMove(
                id: 'bookmark-1',
                moveBookmarkDto: captureAny(named: 'moveBookmarkDto'),
              ),
            ).captured.single
            as MoveBookmarkDto;
    expect(captured.folderId, 'folder-custom');

    when(
      () => api.bookmarksMove(
        id: 'bookmark-empty',
        moveBookmarkDto: any(named: 'moveBookmarkDto'),
      ),
    ).thenAnswer(
      (_) async => Response<BookmarksMove200Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/bookmarks/bookmark-empty',
        ),
      ),
    );
    await expectLater(
      repository.move('bookmark-empty', 'folder-custom'),
      throwsA(isA<ApiFailure>()),
    );

    when(
      () => api.bookmarksMove(
        id: 'bookmark-drifted',
        moveBookmarkDto: any(named: 'moveBookmarkDto'),
      ),
    ).thenAnswer(
      (_) async =>
          _moveResponse(bookmarkId: 'bookmark-other', folderId: 'folder-other'),
    );
    await expectLater(
      repository.move('bookmark-drifted', 'folder-custom'),
      throwsA(isA<ApiFailure>()),
    );
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
              ..bookmarkFolderId = 'folder-default'
              ..defaultSubthread.update(
                (subthread) => subthread
                  ..id = 'subthread-1'
                  ..title = '主线'
                  ..lastPostAt = DateTime.utc(2026, 8, 11),
              )
              ..topicTags.add(
                ThreadTagRelationResponseDto(
                  (relation) => relation
                    ..id = 'relation-1'
                    ..threadId = 'thread-1'
                    ..tagId = 'tag-1'
                    ..tag.update(
                      (tag) => tag
                        ..id = 'tag-1'
                        ..name = '都市奇谈'
                        ..sortOrder = 1
                        ..isActive = true,
                    ),
                ),
              )
              ..preview = '  雾港中的第一封信  '
              ..coverImages.addAll([
                'javascript:alert(1)',
                'https://cdn.example.com/cover.jpg',
                'https://cdn.example.com/ignored.jpg',
              ])
              ..owner.update(
                (owner) => owner
                  ..id = 'owner-1'
                  ..username = '骰子猫'
                  ..avatar = 'https://cdn.example.com/avatar.jpg'
                  ..level = 3,
              )
              ..count.update(
                (count) => count
                  ..members = 4
                  ..players = 2
                  ..posts = 18,
              );
            thread.bookmarkId = includeBookmarkId ? 'bookmark-1' : '';
          }),
        ),
    ),
  );
}

Response<BookmarksFindFolders200Response> _foldersResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks/folders'),
    data: BookmarksFindFolders200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.addAll([
          _folderDto('folder-default', '默认收藏夹', isDefault: true, count: 2),
          _folderDto('folder-custom', '灵感', count: 1),
        ]),
    ),
  );
}

Response<BookmarksCreateFolder201Response> _createFolderResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks/folders'),
    data: BookmarksCreateFolder201Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_folderDto('folder-created', '跑团资料')),
    ),
  );
}

Response<BookmarksMove200Response> _moveResponse({
  String bookmarkId = 'bookmark-1',
  String folderId = 'folder-custom',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/bookmarks/$bookmarkId'),
    data: BookmarksMove200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (bookmark) => bookmark
            ..id = bookmarkId
            ..userId = 'user-1'
            ..threadId = 'thread-1'
            ..folderId = folderId
            ..createdAt = DateTime.utc(2026, 8, 1),
        ),
    ),
  );
}

BookmarkFolderResponseDto _folderDto(
  String id,
  String name, {
  bool isDefault = false,
  int count = 0,
}) {
  return BookmarkFolderResponseDto(
    (folder) => folder
      ..id = id
      ..name = name
      ..isDefault = isDefault
      ..bookmarkCount = count
      ..momentBookmarkCount = 0
      ..createdAt = DateTime.utc(2026, 8, 1),
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

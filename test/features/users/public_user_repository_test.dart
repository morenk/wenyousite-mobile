import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/users/data/public_user_repository.dart';

void main() {
  test('公开用户资料传递用户 ID 并完整映射统计与关系状态', () async {
    final api = _MockUsersApi();
    when(() => api.usersGetUser(id: 'user-1')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/api/v1/users/user-1'),
        data: UsersGetUser200Response(
          (response) => response
            ..code = ApiSuccessEnvelopeCodeEnum.number0
            ..message = 'ok'
            ..data.update(
              (user) => user
                ..id = 'user-1'
                ..username = '温柔测试员'
                ..avatar = 'javascript:alert(1)'
                ..bio = '  一起写下温柔的故事。  '
                ..level = 4
                ..receivedTipTotal = '18'
                ..receivedTipCount = 6
                ..showRecentReplies = true
                ..showPlayerBadges = true
                ..showBookmarks = true
                ..createdAt = DateTime.utc(2026, 8, 10)
                ..count.update(
                  (count) => count
                    ..following = 7
                    ..followers = 9,
                )
                ..isFollowing = true
                ..isFollowedBy = true
                ..isBlocked = false
                ..isBlockedBy = false
                ..isDeactivated = false,
            ),
        ),
      ),
    );

    final profile = await ApiPublicUserRepository(api).fetchUser('user-1');

    verify(() => api.usersGetUser(id: 'user-1')).called(1);
    expect(profile.username, '温柔测试员');
    expect(profile.avatarUrl, isNull);
    expect(profile.bio, '一起写下温柔的故事。');
    expect(profile.level, 4);
    expect(profile.followingCount, 7);
    expect(profile.followerCount, 9);
    expect(profile.receivedTipTotal, '18');
    expect(profile.receivedTipCount, 6);
    expect(profile.showRecentReplies, isTrue);
    expect(profile.showPlayedThreads, isTrue);
    expect(profile.showBookmarks, isTrue);
    expect(profile.isFollowing, isTrue);
    expect(profile.isFollowedBy, isTrue);
  });

  test('公开内容接口原样传递 cursor 并映射主题、收藏和最近回复', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersGetUserCreatedThreads(
        id: 'user-1',
        cursor: 'cursor-1',
        limit: 7,
      ),
    ).thenAnswer((_) async => _createdThreadsResponse());
    when(
      () =>
          api.usersGetUserPlayedThreads(id: 'user-1', cursor: null, limit: 10),
    ).thenAnswer((_) async => _playedThreadsResponse());
    when(
      () => api.usersGetUserBookmarks(id: 'user-1', cursor: null, limit: 10),
    ).thenAnswer((_) async => _bookmarksResponse());
    when(
      () => api.usersGetUserRecentReplies(id: 'user-1'),
    ).thenAnswer((_) async => _recentRepliesResponse());
    final repository = ApiPublicUserRepository(api);

    final created = await repository.fetchCreatedThreads(
      'user-1',
      cursor: 'cursor-1',
      limit: 7,
    );
    final played = await repository.fetchPlayedThreads('user-1');
    final bookmarks = await repository.fetchBookmarks('user-1');
    final replies = await repository.fetchRecentReplies('user-1');

    expect(created.cursor, 'cursor-2');
    expect(created.hasMore, isTrue);
    expect(created.items.single.title, '星海旅团');
    expect(created.items.single.status.name, 'recruiting');
    expect(created.items.single.memberCount, 5);
    expect(played.items.single.isPrivate, isTrue);
    expect(bookmarks.items.single.ownerName, '收藏作者');
    expect(bookmarks.items.single.postCount, 6);
    expect(replies.single.preview, '最近回复 [图片：航图]');
    expect(replies.single.parentPostId, 'floor-7');
    expect(replies.single.threadTitle, '星海旅团');
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersGetUserCreatedThreads200Response> _createdThreadsResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/users/user-1/created-threads',
    ),
    data: UsersGetUserCreatedThreads200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update(
          (meta) => meta
            ..cursor = 'cursor-2'
            ..hasMore = true,
        )
        ..data.add(_thread(id: 'thread-created')),
    ),
  );
}

Response<UsersGetUserPlayedThreads200Response> _playedThreadsResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/user-1/played-threads'),
    data: UsersGetUserPlayedThreads200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta.hasMore = false)
        ..data.add(_thread(id: 'thread-played', isPrivate: true)),
    ),
  );
}

Response<UsersGetUserBookmarks200Response> _bookmarksResponse() {
  final now = DateTime.utc(2026, 8, 10);
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/user-1/bookmarks'),
    data: UsersGetUserBookmarks200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..meta.update((meta) => meta.hasMore = false)
        ..data.add(
          BookmarkThreadResponseDto(
            (thread) => thread
              ..id = 'thread-bookmark'
              ..title = '收藏主题'
              ..category = 'DEDUCTION'
              ..status = BookmarkThreadResponseDtoStatusEnum.CLOSED
              ..visibility = BookmarkThreadResponseDtoVisibilityEnum.PUBLIC
              ..published = true
              ..pinned = false
              ..tipTotal = '2'
              ..createdAt = now
              ..updatedAt = now
              ..owner.update(
                (owner) => owner
                  ..id = 'bookmark-owner'
                  ..username = '收藏作者'
                  ..level = 2,
              )
              ..count.update(
                (count) => count
                  ..members = 3
                  ..posts = 6,
              ),
          ),
        ),
    ),
  );
}

Response<UsersGetUserRecentReplies200Response> _recentRepliesResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/user-1/recent-replies'),
    data: UsersGetUserRecentReplies200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.add(
          RecentReplyResponseDto(
            (reply) => reply
              ..id = 'reply-1'
              ..createdAt = DateTime.utc(2026, 8, 10, 8)
              ..parentPostId = 'floor-7'
              ..content = '正文回退'
              ..preview = '**最近回复** ![航图](https://cdn.example.com/map.jpg)'
              ..threadId = 'thread-created'
              ..thread.update((thread) => thread.title = '星海旅团')
              ..subthreadId = 'subthread-1'
              ..subthread.update((subthread) => subthread.title = '主线'),
          ),
        ),
    ),
  );
}

ThreadListItemResponseDto _thread({
  required String id,
  bool isPrivate = false,
}) {
  final now = DateTime.utc(2026, 8, 10);
  return ThreadListItemResponseDto(
    (thread) => thread
      ..id = id
      ..title = '  星海旅团  '
      ..category = 'RPG'
      ..status = ThreadListItemResponseDtoStatusEnum.RECRUITING
      ..visibility = isPrivate
          ? ThreadListItemResponseDtoVisibilityEnum.PRIVATE
          : ThreadListItemResponseDtoVisibilityEnum.PUBLIC
      ..published = true
      ..pinned = false
      ..tipTotal = '8'
      ..createdAt = now
      ..updatedAt = now
      ..owner.update(
        (owner) => owner
          ..id = 'owner-1'
          ..username = '温柔测试员'
          ..level = 4,
      )
      ..count.update(
        (count) => count
          ..members = 5
          ..players = 2
          ..posts = 12,
      ),
  );
}

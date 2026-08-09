import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_list_repository.dart';

void main() {
  test('指定用户关注列表只映射 following 并过滤缺失投影', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowUserFollowing(id: 'user-1')).thenAnswer(
      (_) async => _publicFollowingResponse([
        _followRecord(
          following: _author(
            id: 'following-1',
            username: '被关注者',
            avatar: 'https://wenyou.site/avatar.png',
          ),
          follower: _author(id: 'wrong-side', username: '错误一侧'),
        ),
        _followRecord(
          follower: _author(id: 'only-follower', username: '仅粉丝投影'),
        ),
      ]),
    );

    final items = await ApiUserRelationListRepository(
      api,
    ).fetchFollowing(userId: 'user-1');

    expect(items, hasLength(1));
    expect(items.single.userId, 'following-1');
    expect(items.single.username, '被关注者');
    expect(items.single.avatarUrl, 'https://wenyou.site/avatar.png');
  });

  test('指定用户粉丝列表只映射 follower 并拒绝不安全头像', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowUserFollowers(id: 'user-1')).thenAnswer(
      (_) async => _publicFollowersResponse([
        _followRecord(
          following: _author(id: 'wrong-side', username: '错误一侧'),
          follower: _author(
            id: 'follower-1',
            username: '关注者',
            avatar: 'file:///secret.png',
          ),
        ),
      ]),
    );

    final items = await ApiUserRelationListRepository(
      api,
    ).fetchFollowers(userId: 'user-1');

    expect(items.single.userId, 'follower-1');
    expect(items.single.avatarUrl, isNull);
  });

  test('本人关注与粉丝使用本人接口而不是公开用户接口', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowFollowing()).thenAnswer(
      (_) async => _currentFollowingResponse([
        _followRecord(
          following: _author(id: 'following-1', username: '被关注者'),
        ),
      ]),
    );
    when(() => api.usersFollowFollowers()).thenAnswer(
      (_) async => _currentFollowersResponse([
        _followRecord(
          follower: _author(id: 'follower-1', username: '关注者'),
        ),
      ]),
    );
    final repository = ApiUserRelationListRepository(api);

    expect((await repository.fetchFollowing()).single.userId, 'following-1');
    expect((await repository.fetchFollowers()).single.userId, 'follower-1');
    verify(() => api.usersFollowFollowing()).called(1);
    verify(() => api.usersFollowFollowers()).called(1);
    verifyNever(() => api.usersFollowUserFollowing(id: any(named: 'id')));
    verifyNever(() => api.usersFollowUserFollowers(id: any(named: 'id')));
  });

  test('黑名单映射 blocked 投影与关系时间', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowBlocks()).thenAnswer(
      (_) async => _blocksResponse([
        BlockedUserRecordResponseDto(
          (record) => record
            ..id = 'block-1'
            ..blockerId = 'me-1'
            ..blockedId = 'blocked-1'
            ..createdAt = DateTime.utc(2026, 8, 10)
            ..blocked.replace(_author(id: 'blocked-1', username: '被拉黑用户')),
        ),
      ]),
    );

    final item = (await ApiUserRelationListRepository(
      api,
    ).fetchBlocks()).single;

    expect(item.userId, 'blocked-1');
    expect(item.username, '被拉黑用户');
    expect(item.relatedAt, DateTime.utc(2026, 8, 10));
  });

  test('空响应不伪装成空列表', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowBlocks()).thenAnswer(
      (_) async => Response<UsersFollowBlocks200Response>(
        requestOptions: RequestOptions(path: '/api/v1/users/me/blocks'),
      ),
    );

    await expectLater(
      ApiUserRelationListRepository(api).fetchBlocks(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('返回不完整'),
        ),
      ),
    );
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

PostAuthorResponseDto _author({
  required String id,
  required String username,
  String? avatar,
}) {
  return PostAuthorResponseDto(
    (author) => author
      ..id = id
      ..username = username
      ..avatar = avatar
      ..level = 4,
  );
}

UserFollowRecordResponseDto _followRecord({
  PostAuthorResponseDto? following,
  PostAuthorResponseDto? follower,
}) {
  return UserFollowRecordResponseDto((record) {
    record
      ..id = 'follow-${following?.id ?? follower?.id}'
      ..followerId = follower?.id ?? 'follower-id'
      ..followingId = following?.id ?? 'following-id'
      ..createdAt = DateTime.utc(2026, 8, 10);
    if (following != null) record.following.replace(following);
    if (follower != null) record.follower.replace(follower);
  });
}

Response<UsersFollowUserFollowing200Response> _publicFollowingResponse(
  List<UserFollowRecordResponseDto> records,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/user-1/following'),
    data: UsersFollowUserFollowing200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(records),
    ),
  );
}

Response<UsersFollowUserFollowers200Response> _publicFollowersResponse(
  List<UserFollowRecordResponseDto> records,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/user-1/followers'),
    data: UsersFollowUserFollowers200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(records),
    ),
  );
}

Response<UsersFollowFollowing200Response> _currentFollowingResponse(
  List<UserFollowRecordResponseDto> records,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/following'),
    data: UsersFollowFollowing200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(records),
    ),
  );
}

Response<UsersFollowFollowers200Response> _currentFollowersResponse(
  List<UserFollowRecordResponseDto> records,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/followers'),
    data: UsersFollowFollowers200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(records),
    ),
  );
}

Response<UsersFollowBlocks200Response> _blocksResponse(
  List<BlockedUserRecordResponseDto> records,
) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/blocks'),
    data: UsersFollowBlocks200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(records),
    ),
  );
}

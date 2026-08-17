import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/social/data/user_relation_repository.dart';

void main() {
  test('四类关系写操作按目标 ID 调用无 body 生成接口', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersFollowFollow(id: 'user-1'),
    ).thenAnswer((_) async => _followResponse());
    when(
      () => api.usersFollowUnfollow(id: 'user-1'),
    ).thenAnswer((_) async => _unfollowResponse());
    when(
      () => api.usersFollowBlock(id: 'user-1'),
    ).thenAnswer((_) async => _blockResponse());
    when(
      () => api.usersFollowUnblock(id: 'user-1'),
    ).thenAnswer((_) async => _unblockResponse());
    final repository = ApiUserRelationRepository(api);

    await repository.follow('user-1');
    await repository.unfollow('user-1');
    await repository.block('user-1');
    await repository.unblock('user-1');

    verify(() => api.usersFollowFollow(id: 'user-1')).called(1);
    verify(() => api.usersFollowUnfollow(id: 'user-1')).called(1);
    verify(() => api.usersFollowBlock(id: 'user-1')).called(1);
    verify(() => api.usersFollowUnblock(id: 'user-1')).called(1);
  });

  test('关系响应缺失时不假装操作成功', () async {
    final api = _MockUsersApi();
    when(() => api.usersFollowFollow(id: 'user-1')).thenAnswer(
      (_) async => Response<UsersFollowFollow200Response>(
        requestOptions: RequestOptions(path: '/api/v1/users/follow/user-1'),
      ),
    );

    await expectLater(
      ApiUserRelationRepository(api).follow('user-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('关注失败'),
        ),
      ),
    );
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersFollowFollow200Response> _followResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/follow/user-1'),
    data: UsersFollowFollow200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已关注'),
    ),
  );
}

Response<UsersFollowUnfollow200Response> _unfollowResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/follow/user-1'),
    data: UsersFollowUnfollow200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已取消关注'),
    ),
  );
}

Response<UsersFollowBlock200Response> _blockResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/block/user-1'),
    data: UsersFollowBlock200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已拉黑'),
    ),
  );
}

Response<UsersFollowUnblock200Response> _unblockResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/block/user-1'),
    data: UsersFollowUnblock200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '已取消拉黑'),
    ),
  );
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/data/avatar_repository.dart';

void main() {
  setUpAll(
    () => registerFallbackValue(
      SetAvatarDto((builder) => builder.mediaId = 'fallback-media'),
    ),
  );

  test('设置头像发送 mediaId 并只接受服务端安全 URL', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersSetAvatar(setAvatarDto: any(named: 'setAvatarDto')),
    ).thenAnswer(
      (_) async => _setResponse(avatar: 'https://cdn.example.com/avatar.webp'),
    );

    final result = await ApiAvatarRepository(api).setAvatar('media-1');

    final dto =
        verify(
              () => api.usersSetAvatar(
                setAvatarDto: captureAny(named: 'setAvatarDto'),
              ),
            ).captured.single
            as SetAvatarDto;
    expect(dto.mediaId, 'media-1');
    expect(result.avatarUrl, 'https://cdn.example.com/avatar.webp');
    expect(result.updatedAt, DateTime.utc(2026, 8, 10, 11));
  });

  test('设置头像响应缺失或返回不安全 URL 时不伪装成功', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersSetAvatar(setAvatarDto: any(named: 'setAvatarDto')),
    ).thenAnswer((_) async => _setResponse(avatar: 'file:///private/a.png'));

    await expectLater(
      ApiAvatarRepository(api).setAvatar('media-1'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('安全图片地址'),
        ),
      ),
    );
  });

  test('移除头像要求服务端最终 avatar 为 null', () async {
    final api = _MockUsersApi();
    when(
      api.usersRemoveAvatar,
    ).thenAnswer((_) async => _removeResponse(avatar: null));

    final result = await ApiAvatarRepository(api).removeAvatar();

    expect(result.avatarUrl, isNull);
    verify(api.usersRemoveAvatar).called(1);
  });

  test('移除头像响应仍含 URL 时保留失败状态', () async {
    final api = _MockUsersApi();
    when(api.usersRemoveAvatar).thenAnswer(
      (_) async => _removeResponse(avatar: 'https://cdn.example.com/old.png'),
    );

    await expectLater(
      ApiAvatarRepository(api).removeAvatar(),
      throwsA(isA<ApiFailure>()),
    );
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersSetAvatar200Response> _setResponse({required String? avatar}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/avatar'),
    data: UsersSetAvatar200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = '头像已更新'
        ..data.replace(_privateUser(avatar: avatar)),
    ),
  );
}

Response<UsersRemoveAvatar200Response> _removeResponse({
  required String? avatar,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/avatar'),
    data: UsersRemoveAvatar200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = '头像已移除'
        ..data.replace(_privateUser(avatar: avatar)),
    ),
  );
}

PrivateUserResponseDto _privateUser({required String? avatar}) {
  return PrivateUserResponseDto(
    (user) => user
      ..id = 'user-1'
      ..email = 'owner@example.com'
      ..username = '温柔测试员'
      ..avatar = avatar
      ..role = PrivateUserResponseDtoRoleEnum.USER
      ..level = 4
      ..experience = 150
      ..currentLevelExperience = 100
      ..nextLevelExperience = 200
      ..receivedTipTotal = '18'
      ..receivedTipCount = 6
      ..showRecentReplies = true
      ..showPlayerBadges = true
      ..showBookmarks = true
      ..emailVerified = true
      ..createdAt = DateTime.utc(2026, 8, 1)
      ..updatedAt = DateTime.utc(2026, 8, 10, 11),
  );
}

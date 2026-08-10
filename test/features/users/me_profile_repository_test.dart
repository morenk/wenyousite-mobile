import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const MeProfilePatch());
    registerFallbackValue(UpdateUserDto());
  });

  test('本人资料读取映射私有字段、成长进度与社交统计', () async {
    final api = _MockUsersApi();
    when(() => api.usersGetMe()).thenAnswer((_) async => _meResponse());

    final profile = await ApiMeProfileRepository(api).fetchMe();

    expect(profile.id, 'user-1');
    expect(profile.email, 'owner@example.com');
    expect(profile.username, '温柔测试员');
    expect(profile.avatarUrl, isNull);
    expect(profile.bio, '一起写故事。');
    expect(profile.level, 4);
    expect(profile.levelProgress, closeTo(0.5, 0.001));
    expect(profile.followingCount, 7);
    expect(profile.followerCount, 9);
    expect(profile.showPlayedThreads, isTrue);
    expect(profile.emailVerified, isTrue);
  });

  test('重新创建仓储后从本人事实恢复安全头像 URL', () async {
    final api = _MockUsersApi();
    when(api.usersGetMe).thenAnswer(
      (_) async => _meResponse(avatar: 'https://cdn.example.com/avatar.webp'),
    );

    final profile = await ApiMeProfileRepository(api).fetchMe();

    expect(profile.avatarUrl, 'https://cdn.example.com/avatar.webp');
  });

  test('资料更新只发送变更字段并映射服务端最终结果', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersUpdateMe(updateUserDto: any(named: 'updateUserDto')),
    ).thenAnswer((_) async => _updateResponse());
    final repository = ApiMeProfileRepository(api);

    final result = await repository.updateMe(
      const MeProfilePatch(username: '新名字', showBookmarks: false),
    );

    final captured =
        verify(
              () => api.usersUpdateMe(
                updateUserDto: captureAny(named: 'updateUserDto'),
              ),
            ).captured.single
            as UpdateUserDto;
    expect(captured.username, '新名字');
    expect(captured.bio, isNull);
    expect(captured.showRecentReplies, isNull);
    expect(captured.showPlayerBadges, isNull);
    expect(captured.showBookmarks, isFalse);
    expect(result.username, '新名字');
    expect(result.showBookmarks, isFalse);
    expect(result.updatedAt, DateTime.utc(2026, 8, 10, 10));
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersGetMe200Response> _meResponse({
  String? avatar = 'javascript:alert(1)',
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me'),
    data: UsersGetMe200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (user) => user
            ..id = 'user-1'
            ..email = 'owner@example.com'
            ..username = '温柔测试员'
            ..avatar = avatar
            ..bio = '  一起写故事。  '
            ..role = CurrentUserResponseDtoRoleEnum.USER
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
            ..updatedAt = DateTime.utc(2026, 8, 10, 8)
            ..count.update(
              (count) => count
                ..following = 7
                ..followers = 9,
            ),
        ),
    ),
  );
}

Response<UsersUpdateMe200Response> _updateResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me'),
    data: UsersUpdateMe200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (user) => user
            ..id = 'user-1'
            ..email = 'owner@example.com'
            ..username = '新名字'
            ..bio = '一起写故事。'
            ..role = PrivateUserResponseDtoRoleEnum.USER
            ..level = 4
            ..experience = 150
            ..currentLevelExperience = 100
            ..nextLevelExperience = 200
            ..receivedTipTotal = '18'
            ..receivedTipCount = 6
            ..showRecentReplies = true
            ..showPlayerBadges = true
            ..showBookmarks = false
            ..emailVerified = true
            ..createdAt = DateTime.utc(2026, 8, 1)
            ..updatedAt = DateTime.utc(2026, 8, 10, 10),
        ),
    ),
  );
}

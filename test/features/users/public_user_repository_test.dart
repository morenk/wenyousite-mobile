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
    expect(profile.isFollowing, isTrue);
    expect(profile.isFollowedBy, isTrue);
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

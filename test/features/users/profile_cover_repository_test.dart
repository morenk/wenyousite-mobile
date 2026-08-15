import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/users/data/profile_cover_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      SetProfileCoverDto(
        (builder) => builder
          ..mediaId = 'web-fallback'
          ..mobileMediaId = 'mobile-fallback',
      ),
    );
  });

  test('设置背景原子发送双 mediaId 并优先映射移动中图', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersSetProfileCover(
        setProfileCoverDto: any(named: 'setProfileCoverDto'),
      ),
    ).thenAnswer((_) async => _setResponse(includeMobile: true));

    final result = await ApiProfileCoverRepository(
      api,
    ).setProfileCover(webMediaId: 'web-media', mobileMediaId: 'mobile-media');

    final dto =
        verify(
              () => api.usersSetProfileCover(
                setProfileCoverDto: captureAny(named: 'setProfileCoverDto'),
              ),
            ).captured.single
            as SetProfileCoverDto;
    expect(dto.mediaId, 'web-media');
    expect(dto.mobileMediaId, 'mobile-media');
    expect(
      result.profileCover?.preferredForMobile.url,
      'https://cdn.example.com/mobile-md.webp',
    );
  });

  test('双画幅响应缺少移动端资产时不伪装设置成功', () async {
    final api = _MockUsersApi();
    when(
      () => api.usersSetProfileCover(
        setProfileCoverDto: any(named: 'setProfileCoverDto'),
      ),
    ).thenAnswer((_) async => _setResponse(includeMobile: false));

    await expectLater(
      ApiProfileCoverRepository(
        api,
      ).setProfileCover(webMediaId: 'web-media', mobileMediaId: 'mobile-media'),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('移除背景要求服务端同时返回空 profileCover', () async {
    final api = _MockUsersApi();
    when(
      api.usersRemoveProfileCover,
    ).thenAnswer((_) async => _removeResponse());

    final result = await ApiProfileCoverRepository(api).removeProfileCover();

    expect(result.profileCover, isNull);
    verify(api.usersRemoveProfileCover).called(1);
  });
}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersSetProfileCover200Response> _setResponse({
  required bool includeMobile,
}) {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/profile-cover'),
    data: UsersSetProfileCover200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(
          _privateUser(includeCover: true, includeMobile: includeMobile),
        ),
    ),
  );
}

Response<UsersRemoveProfileCover200Response> _removeResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/users/me/profile-cover'),
    data: UsersRemoveProfileCover200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.replace(_privateUser(includeCover: false, includeMobile: false)),
    ),
  );
}

PrivateUserResponseDto _privateUser({
  required bool includeCover,
  required bool includeMobile,
}) {
  return PrivateUserResponseDto((user) {
    user
      ..id = 'user-1'
      ..email = 'owner@example.com'
      ..username = '温柔测试员'
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
      ..createdAt = DateTime.utc(2026, 8, 1)
      ..updatedAt = DateTime.utc(2026, 8, 10, 11);
    if (includeCover) {
      user.profileCover.update((cover) {
        cover
          ..url = 'https://cdn.example.com/web.webp'
          ..mediumUrl = 'https://cdn.example.com/web-md.webp'
          ..width = 1500
          ..height = 500;
        if (includeMobile) {
          cover.mobile.update(
            (mobile) => mobile
              ..url = 'https://cdn.example.com/mobile.webp'
              ..mediumUrl = 'https://cdn.example.com/mobile-md.webp'
              ..width = 1200
              ..height = 600,
          );
        }
      });
    }
  });
}

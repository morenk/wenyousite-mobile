import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/data/email_verification_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      ResendVerificationDto(
        (builder) => builder.email = 'fallback@example.com',
      ),
    );
    registerFallbackValue(
      VerifyEmailDto((builder) => builder.token = '123456'),
    );
  });

  test('本人资料提供当前邮箱和服务端验证事实', () async {
    final authApi = _MockAuthApi();
    final usersApi = _MockUsersApi();
    when(
      () => usersApi.usersGetMe(),
    ).thenAnswer((_) async => _meResponse(emailVerified: false));

    final account = await ApiEmailVerificationRepository(
      authApi,
      usersApi,
    ).fetchAccount();

    expect(account.email, 'owner@example.com');
    expect(account.isVerified, isFalse);
  });

  test('重发与验证映射当前邮箱和六位验证码', () async {
    final authApi = _MockAuthApi();
    final usersApi = _MockUsersApi();
    when(
      () => authApi.authResendVerification(
        resendVerificationDto: any(named: 'resendVerificationDto'),
      ),
    ).thenAnswer((_) async => _resendResponse());
    when(
      () =>
          authApi.authVerifyEmail(verifyEmailDto: any(named: 'verifyEmailDto')),
    ).thenAnswer((_) async => _verifyResponse());
    final repository = ApiEmailVerificationRepository(authApi, usersApi);

    await repository.resendCode(email: ' OWNER@example.com ');
    await repository.verifyCode(code: ' 654321 ');

    final resendDto =
        verify(
              () => authApi.authResendVerification(
                resendVerificationDto: captureAny(
                  named: 'resendVerificationDto',
                ),
              ),
            ).captured.single
            as ResendVerificationDto;
    final verifyDto =
        verify(
              () => authApi.authVerifyEmail(
                verifyEmailDto: captureAny(named: 'verifyEmailDto'),
              ),
            ).captured.single
            as VerifyEmailDto;
    expect(resendDto.email, 'owner@example.com');
    expect(verifyDto.token, '654321');
  });

  test('缺少成功 data 时不伪装发送或验证完成', () async {
    final authApi = _MockAuthApi();
    final usersApi = _MockUsersApi();
    when(
      () => authApi.authResendVerification(
        resendVerificationDto: any(named: 'resendVerificationDto'),
      ),
    ).thenAnswer(
      (_) async => Response<AuthResendVerification200Response>(
        requestOptions: RequestOptions(
          path: '/api/v1/auth/resend-verification',
        ),
      ),
    );
    final repository = ApiEmailVerificationRepository(authApi, usersApi);

    expect(
      repository.resendCode(email: 'owner@example.com'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('发送结果不完整'),
        ),
      ),
    );
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockUsersApi extends Mock implements UsersApi {}

Response<UsersGetMe200Response> _meResponse({required bool emailVerified}) {
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
            ..role = CurrentUserResponseDtoRoleEnum.USER
            ..level = 4
            ..experience = 150
            ..currentLevelExperience = 100
            ..receivedTipTotal = '18'
            ..receivedTipCount = 6
            ..showRecentReplies = true
            ..showPlayerBadges = true
            ..showBookmarks = true
            ..emailVerified = emailVerified
            ..createdAt = DateTime.utc(2026, 8, 1)
            ..updatedAt = DateTime.utc(2026, 8, 10)
            ..count.update(
              (count) => count
                ..following = 7
                ..followers = 9,
            ),
        ),
    ),
  );
}

Response<AuthResendVerification200Response> _resendResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/resend-verification'),
    data: AuthResendVerification200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = 'sent'),
    ),
  );
}

Response<AuthVerifyEmail200Response> _verifyResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/verify-email'),
    data: AuthVerifyEmail200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = 'verified'),
    ),
  );
}

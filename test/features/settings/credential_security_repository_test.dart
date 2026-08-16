import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/features/settings/data/credential_security_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      ChangePasswordDto(
        (builder) => builder
          ..oldPassword = 'fallback-old'
          ..newPassword = 'fallback-new1',
      ),
    );
    registerFallbackValue(
      ChangeEmailRequestDto(
        (builder) => builder
          ..newEmail = 'fallback@example.com'
          ..oldPassword = 'fallback-old',
      ),
    );
    registerFallbackValue(
      ChangeEmailVerifyDto(
        (builder) => builder
          ..newEmail = 'fallback@example.com'
          ..code = '123456',
      ),
    );
  });

  test('修改密码映射当前密码与新密码', () async {
    final api = _MockAuthApi();
    when(
      () => api.authChangePassword(
        changePasswordDto: any(named: 'changePasswordDto'),
      ),
    ).thenAnswer((_) async => _passwordResponse());

    await ApiCredentialSecurityRepository(
      api,
    ).changePassword(oldPassword: 'current123', newPassword: 'next-pass9');

    final dto =
        verify(
              () => api.authChangePassword(
                changePasswordDto: captureAny(named: 'changePasswordDto'),
              ),
            ).captured.single
            as ChangePasswordDto;
    expect(dto.oldPassword, 'current123');
    expect(dto.newPassword, 'next-pass9');
  });

  test('请求换绑验证码映射新邮箱与当前密码', () async {
    final api = _MockAuthApi();
    when(
      () => api.authRequestChangeEmailCode(
        extra: any(named: 'extra'),
        changeEmailRequestDto: any(named: 'changeEmailRequestDto'),
      ),
    ).thenAnswer((_) async => _requestEmailResponse());

    await ApiCredentialSecurityRepository(api).requestEmailChangeCode(
      newEmail: 'next@example.com',
      oldPassword: 'current123',
    );

    final dto = verify(
      () => api.authRequestChangeEmailCode(
        extra: captureAny(named: 'extra'),
        changeEmailRequestDto: captureAny(named: 'changeEmailRequestDto'),
      ),
    ).captured;
    expect(
      dto.whereType<Map<String, dynamic>>().single,
      ApiRequestPolicy.authenticatedNonReplayable.extra,
    );
    final request = dto.whereType<ChangeEmailRequestDto>().single;
    expect(request.newEmail, 'next@example.com');
    expect(request.oldPassword, 'current123');
  });

  test('确认换绑映射新邮箱与验证码', () async {
    final api = _MockAuthApi();
    when(
      () => api.authVerifyChangeEmail(
        changeEmailVerifyDto: any(named: 'changeEmailVerifyDto'),
      ),
    ).thenAnswer((_) async => _verifyEmailResponse());

    await ApiCredentialSecurityRepository(
      api,
    ).verifyEmailChange(newEmail: 'next@example.com', code: '654321');

    final dto =
        verify(
              () => api.authVerifyChangeEmail(
                changeEmailVerifyDto: captureAny(named: 'changeEmailVerifyDto'),
              ),
            ).captured.single
            as ChangeEmailVerifyDto;
    expect(dto.newEmail, 'next@example.com');
    expect(dto.code, '654321');
  });

  test('成功状态缺少 data 时不伪装完成', () async {
    final api = _MockAuthApi();
    when(
      () => api.authChangePassword(
        changePasswordDto: any(named: 'changePasswordDto'),
      ),
    ).thenAnswer(
      (_) async => Response<AuthChangePassword200Response>(
        requestOptions: RequestOptions(path: '/api/v1/auth/change-password'),
      ),
    );

    await expectLater(
      ApiCredentialSecurityRepository(
        api,
      ).changePassword(oldPassword: 'current123', newPassword: 'next-pass9'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('结果不完整'),
        ),
      ),
    );
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

Response<AuthChangePassword200Response> _passwordResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/change-password'),
    data: AuthChangePassword200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '密码已修改'),
    ),
  );
}

Response<AuthRequestChangeEmailCode200Response> _requestEmailResponse() {
  return Response(
    requestOptions: RequestOptions(
      path: '/api/v1/auth/change-email/request-code',
    ),
    data: AuthRequestChangeEmailCode200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '验证码已发送'),
    ),
  );
}

Response<AuthVerifyChangeEmail200Response> _verifyEmailResponse() {
  return Response(
    requestOptions: RequestOptions(path: '/api/v1/auth/change-email/verify'),
    data: AuthVerifyChangeEmail200Response(
      (response) => response
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update((data) => data.message = '邮箱已更换'),
    ),
  );
}

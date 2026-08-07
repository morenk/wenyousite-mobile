import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      LoginDto(
        (builder) => builder
          ..account = 'fallback'
          ..password = 'fallback-password',
      ),
    );
    registerFallbackValue(
      RequestCodeDto((builder) => builder.email = 'fallback@example.com'),
    );
    registerFallbackValue(
      VerifyAndCompleteDto(
        (builder) => builder
          ..email = 'fallback@example.com'
          ..code = '123456'
          ..username = 'fallback'
          ..password = 'fallback123',
      ),
    );
  });

  test('登录显式声明 mobile 并返回双 Token', () async {
    final api = _MockAuthApi();
    when(
      () => api.authLogin(
        loginDto: any(named: 'loginDto'),
        xClientPlatform: any(named: 'xClientPlatform'),
      ),
    ).thenAnswer((_) async => _loginResponse(refreshToken: 'refresh-token'));

    final tokens = await ApiAuthRepository(
      api,
    ).login(account: 'user@example.com', password: 'password123');

    expect(tokens.accessToken, 'access-token');
    expect(tokens.refreshToken, 'refresh-token');
    final captured = verify(
      () => api.authLogin(
        loginDto: captureAny(named: 'loginDto'),
        xClientPlatform: captureAny(named: 'xClientPlatform'),
      ),
    ).captured;
    final dto = captured[0] as LoginDto;
    expect(dto.account, 'user@example.com');
    expect(dto.password, 'password123');
    expect(captured[1], 'mobile');
  });

  test('移动端响应缺少 refresh token 时拒绝建立会话', () async {
    final api = _MockAuthApi();
    when(
      () => api.authLogin(
        loginDto: any(named: 'loginDto'),
        xClientPlatform: any(named: 'xClientPlatform'),
      ),
    ).thenAnswer((_) async => _loginResponse());

    expect(
      ApiAuthRepository(api).login(account: 'user', password: 'password123'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('移动端登录会话'),
        ),
      ),
    );
  });

  test('请求注册验证码映射邮箱与服务端有效期', () async {
    final api = _MockAuthApi();
    when(
      () => api.authRequestCode(requestCodeDto: any(named: 'requestCodeDto')),
    ).thenAnswer((_) async => _requestCodeResponse());

    final info = await ApiAuthRepository(
      api,
    ).requestRegistrationCode(email: 'new@example.com');

    expect(info.expiresIn, const Duration(minutes: 15));
    final dto =
        verify(
              () => api.authRequestCode(
                requestCodeDto: captureAny(named: 'requestCodeDto'),
              ),
            ).captured.single
            as RequestCodeDto;
    expect(dto.email, 'new@example.com');
  });

  test('完成注册显式声明 mobile 并返回双 Token', () async {
    final api = _MockAuthApi();
    when(
      () => api.authVerifyAndComplete(
        verifyAndCompleteDto: any(named: 'verifyAndCompleteDto'),
        xClientPlatform: any(named: 'xClientPlatform'),
      ),
    ).thenAnswer(
      (_) async => _registrationResponse(refreshToken: 'refresh-token'),
    );

    final tokens = await ApiAuthRepository(api).completeRegistration(
      email: 'new@example.com',
      code: '123456',
      username: '新用户2',
      password: 'password123',
    );

    expect(tokens.accessToken, 'access-token');
    expect(tokens.refreshToken, 'refresh-token');
    final captured = verify(
      () => api.authVerifyAndComplete(
        verifyAndCompleteDto: captureAny(named: 'verifyAndCompleteDto'),
        xClientPlatform: captureAny(named: 'xClientPlatform'),
      ),
    ).captured;
    final dto = captured[0] as VerifyAndCompleteDto;
    expect(dto.email, 'new@example.com');
    expect(dto.code, '123456');
    expect(dto.username, '新用户2');
    expect(dto.password, 'password123');
    expect(captured[1], 'mobile');
  });

  test('完成注册缺少 refresh token 时拒绝建立移动会话', () async {
    final api = _MockAuthApi();
    when(
      () => api.authVerifyAndComplete(
        verifyAndCompleteDto: any(named: 'verifyAndCompleteDto'),
        xClientPlatform: any(named: 'xClientPlatform'),
      ),
    ).thenAnswer((_) async => _registrationResponse());

    expect(
      ApiAuthRepository(api).completeRegistration(
        email: 'new@example.com',
        code: '123456',
        username: 'newuser',
        password: 'password123',
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('移动端注册会话'),
        ),
      ),
    );
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

Response<AuthLogin200Response> _loginResponse({String? refreshToken}) {
  return Response<AuthLogin200Response>(
    requestOptions: RequestOptions(path: '/api/v1/auth/login'),
    data: AuthLogin200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..accessToken = 'access-token'
            ..refreshToken = refreshToken
            ..user.update(
              (user) => user
                ..id = 'user-id'
                ..email = 'user@example.com'
                ..username = 'user'
                ..role = 'USER'
                ..emailVerified = true,
            ),
        ),
    ),
  );
}

Response<AuthRequestCode200Response> _requestCodeResponse() {
  return Response<AuthRequestCode200Response>(
    requestOptions: RequestOptions(path: '/api/v1/auth/register/request-code'),
    data: AuthRequestCode200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..emailSent = true
            ..codeExpiresIn = 900
            ..message = 'sent',
        ),
    ),
  );
}

Response<AuthVerifyAndComplete200Response> _registrationResponse({
  String? refreshToken,
}) {
  return Response<AuthVerifyAndComplete200Response>(
    requestOptions: RequestOptions(
      path: '/api/v1/auth/register/verify-and-complete',
    ),
    data: AuthVerifyAndComplete200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..accessToken = 'access-token'
            ..refreshToken = refreshToken
            ..user.update(
              (user) => user
                ..id = 'user-id'
                ..email = 'new@example.com'
                ..username = 'newuser'
                ..role = 'USER'
                ..emailVerified = true,
            ),
        ),
    ),
  );
}

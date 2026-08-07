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
  });

  test('登录显式声明 mobile 并返回双 Token', () async {
    final api = _MockAuthApi();
    when(
      () => api.authLogin(
        loginDto: any(named: 'loginDto'),
        xClientPlatform: any(named: 'xClientPlatform'),
      ),
    ).thenAnswer((_) async => _response(refreshToken: 'refresh-token'));

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
    ).thenAnswer((_) async => _response());

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
}

class _MockAuthApi extends Mock implements AuthApi {}

Response<AuthLogin200Response> _response({String? refreshToken}) {
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

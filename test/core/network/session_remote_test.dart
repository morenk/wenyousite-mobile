import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(RefreshDto());
    registerFallbackValue(LogoutDto());
  });

  test('刷新通过生成客户端发送 refresh token 并返回新双 Token', () async {
    final api = _MockAuthApi();
    final uuid = _MockUuid();
    when(() => uuid.v4()).thenReturn('refresh-request-id');
    when(
      () => api.authRefresh(
        refreshDto: any(named: 'refreshDto'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) async => _refreshResponse(refreshToken: 'new-refresh'));

    final tokens = await ApiSessionRemote(api, uuid).refresh('old-refresh');

    expect(tokens.accessToken, 'new-access');
    expect(tokens.refreshToken, 'new-refresh');
    final captured = verify(
      () => api.authRefresh(
        refreshDto: captureAny(named: 'refreshDto'),
        headers: captureAny(named: 'headers'),
      ),
    ).captured;
    expect((captured[0] as RefreshDto).refreshToken, 'old-refresh');
    expect(captured[1], {
      'X-Request-ID': 'refresh-request-id',
      'X-Client-Platform': 'mobile',
    });
  });

  test('刷新响应缺少移动端 refresh token 时拒绝继续会话', () async {
    final api = _MockAuthApi();
    final uuid = _MockUuid();
    when(() => uuid.v4()).thenReturn('refresh-request-id');
    when(
      () => api.authRefresh(
        refreshDto: any(named: 'refreshDto'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) async => _refreshResponse());

    expect(
      ApiSessionRemote(api, uuid).refresh('old-refresh'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          contains('完整会话'),
        ),
      ),
    );
  });

  test('退出显式发送 bearer、refresh token 与请求 ID', () async {
    final api = _MockAuthApi();
    final uuid = _MockUuid();
    when(() => uuid.v4()).thenReturn('logout-request-id');
    when(
      () => api.authLogout(
        logoutDto: any(named: 'logoutDto'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer(
      (_) async => Response<AuthLogout200Response>(
        requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
      ),
    );

    await ApiSessionRemote(api, uuid).logout(
      const SessionTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );

    final captured = verify(
      () => api.authLogout(
        logoutDto: captureAny(named: 'logoutDto'),
        headers: captureAny(named: 'headers'),
      ),
    ).captured;
    expect((captured[0] as LogoutDto).refreshToken, 'refresh-token');
    expect(captured[1], {
      'Authorization': 'Bearer access-token',
      'X-Request-ID': 'logout-request-id',
    });
  });
}

class _MockAuthApi extends Mock implements AuthApi {}

class _MockUuid extends Mock implements Uuid {}

Response<AuthRefresh200Response> _refreshResponse({String? refreshToken}) {
  return Response<AuthRefresh200Response>(
    requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
    data: AuthRefresh200Response(
      (builder) => builder
        ..code = ApiSuccessEnvelopeCodeEnum.number0
        ..message = 'ok'
        ..data.update(
          (data) => data
            ..accessToken = 'new-access'
            ..refreshToken = refreshToken
            ..user.update(
              (user) => user
                ..id = 'user-id'
                ..email = 'user@example.com'
                ..username = 'user'
                ..role = 'USER'
                ..level = 1,
            ),
        ),
    ),
  );
}

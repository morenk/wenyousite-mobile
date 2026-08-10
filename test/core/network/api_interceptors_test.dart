import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/fallback'));
    registerFallbackValue(
      Response<Object?>(requestOptions: RequestOptions(path: '/fallback')),
    );
  });

  test('首次 40101 刷新双 Token 后只重放一次原请求', () async {
    final dio = _MockDio();
    final handler = _MockErrorInterceptorHandler();
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_oldTokens);
    final replayed = Response<Object?>(
      requestOptions: RequestOptions(path: '/api/v1/users/me'),
      data: const {'code': 0},
    );
    when(() => dio.fetch<Object?>(any())).thenAnswer((_) async => replayed);
    final options = RequestOptions(path: '/api/v1/users/me');
    final error = _businessError(options, 40101);

    RequestContextInterceptor(dio, session).onError(error, handler);
    await untilCalled(() => handler.resolve(any()));

    expect(remote.refreshCalls, 1);
    expect(store.value?.refreshToken, 'new-refresh');
    final replayOptions =
        verify(() => dio.fetch<Object?>(captureAny())).captured.single
            as RequestOptions;
    expect(replayOptions.headers['Authorization'], 'Bearer new-access');
    expect(replayOptions.extra['wenyou.auth.retried'], isTrue);
    verify(() => handler.resolve(replayed)).called(1);
  });

  test('重放后再次 40101 清除会话且不再刷新', () async {
    final dio = _MockDio();
    final handler = _MockErrorInterceptorHandler();
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_oldTokens);
    final options = RequestOptions(
      path: '/api/v1/users/me',
      extra: {'wenyou.auth.retried': true},
    );
    final error = _businessError(options, 40101);

    RequestContextInterceptor(dio, session).onError(error, handler);
    await Future<void>.delayed(Duration.zero);

    expect(remote.refreshCalls, 0);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.invalidated);
    expect(session.state.reason, SessionInvalidationReason.refreshFailed);
    verify(() => handler.next(error)).called(1);
    verifyNever(() => dio.fetch<Object?>(any()));
  });

  test('40103 立即清除会话并记录撤销原因', () async {
    final dio = _MockDio();
    final handler = _MockErrorInterceptorHandler();
    final store = _MemoryTokenStore();
    final session = SessionController(store, _FakeSessionRemote());
    await session.authenticate(_oldTokens);
    final options = RequestOptions(path: '/api/v1/users/me');
    final error = _businessError(options, 40103);

    RequestContextInterceptor(dio, session).onError(error, handler);
    await Future<void>.delayed(Duration.zero);

    expect(store.value, isNull);
    expect(session.state.reason, SessionInvalidationReason.revoked);
    verify(() => handler.next(error)).called(1);
  });

  test('网络日志移除查询参数并脱敏私密邀请 token', () {
    const token = 'Abcd_1234-efGh56';
    final sanitized = sanitizeNetworkLogUri(
      Uri.parse(
        'https://wenyou.site/api/v1/threads/join-by-link/$token?debug=value',
      ),
    );

    expect(sanitized, contains('/threads/join-by-link/<redacted>'));
    expect(sanitized, isNot(contains(token)));
    expect(sanitized, isNot(contains('debug=value')));
  });
}

DioException _businessError(RequestOptions options, int code) {
  return DioException.badResponse(
    statusCode: 401,
    requestOptions: options,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: 401,
      data: {'code': code, 'message': 'sensitive'},
    ),
  );
}

const _oldTokens = SessionTokens(
  accessToken: 'old-access',
  refreshToken: 'old-refresh',
);

class _MockDio extends Mock implements Dio {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class _FakeSessionRemote implements SessionRemote {
  int refreshCalls = 0;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    refreshCalls += 1;
    return const SessionTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }

  @override
  Future<void> logout(SessionTokens tokens) async {}
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

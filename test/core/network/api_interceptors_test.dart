import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
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

  test('首次 40101 刷新双 Token 后只重放一次并保持业务路由', () async {
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
    const targetLocation = '/compose/thread';

    expect(
      resolveSessionRedirect(
        session: session.state,
        matchedLocation: targetLocation,
        uri: Uri.parse(targetLocation),
      ),
      isNull,
    );

    RequestContextInterceptor(dio, session).onError(error, handler);
    await untilCalled(() => handler.resolve(any()));

    expect(remote.refreshCalls, 1);
    expect(store.value?.refreshToken, 'new-refresh');
    final replayOptions =
        verify(() => dio.fetch<Object?>(captureAny())).captured.single
            as RequestOptions;
    expect(replayOptions.headers['Authorization'], 'Bearer new-access');
    expect(replayOptions.extra['wenyou.auth.retried'], isTrue);
    expect(
      resolveSessionRedirect(
        session: session.state,
        matchedLocation: targetLocation,
        uri: Uri.parse(targetLocation),
      ),
      isNull,
    );
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

  test('携带稳定 clientRequestId 的创建请求由真实 Dio 自动重试且保留请求 ID', () async {
    final adapter = _TransientThenSuccessAdapter(failures: 2);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      SafeRetryInterceptor(dio, random: Random(1), wait: (_) async {}),
    );
    addTearDown(dio.close);

    final response = await dio.post<Object?>(
      '/api/v1/posts',
      data: const {'clientRequestId': '00000000-0000-4000-8000-000000000001'},
      options: Options(
        headers: const {'X-Request-ID': 'transport-request-id'},
        extra: ApiRequestPolicy.idempotentCreate.extra,
      ),
    );

    expect(response.statusCode, 201);
    expect(adapter.attempts, 3);
    expect(adapter.requestIds, const [
      'transport-request-id',
      'transport-request-id',
      'transport-request-id',
    ]);
  });

  test('普通 POST 即使遇到瞬时错误也不会自动重试', () async {
    final adapter = _TransientThenSuccessAdapter(failures: 1);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(SafeRetryInterceptor(dio, wait: (_) async {}));
    addTearDown(dio.close);

    await expectLater(
      dio.post<Object?>(
        '/api/v1/actions',
        options: Options(extra: ApiRequestPolicy.standard.extra),
      ),
      throwsA(isA<DioException>()),
    );
    expect(adapter.attempts, 1);
  });

  for (final method in const ['PUT', 'DELETE']) {
    test('$method 作为幂等写入遇到瞬时错误会由真实 Dio 自动重试', () async {
      final adapter = _TransientThenSuccessAdapter(failures: 1);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter;
      dio.interceptors.add(SafeRetryInterceptor(dio, wait: (_) async {}));
      addTearDown(dio.close);

      final response = await dio.request<Object?>(
        '/api/v1/resources/example',
        options: Options(method: method),
      );

      expect(response.statusCode, 201);
      expect(adapter.attempts, 2);
    });
  }
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

class _TransientThenSuccessAdapter implements HttpClientAdapter {
  _TransientThenSuccessAdapter({required this.failures});

  final int failures;
  int attempts = 0;
  final List<String?> requestIds = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    attempts += 1;
    requestIds.add(options.headers['X-Request-ID'] as String?);
    if (attempts <= failures) {
      return ResponseBody.fromString(
        '{"code":50300,"message":"temporary"}',
        503,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"code":0,"data":{"id":"created"}}',
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

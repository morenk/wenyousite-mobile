import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_recovery.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  test('自动读取无响应 HttpException 退避且不改写原未知故障诊断', () async {
    final session = SessionController(
      _MemoryTokenStore(),
      _FakeSessionRemote(),
    );
    addTearDown(session.dispose);
    await session.authenticate(_oldTokens);
    final diagnostics = FailureDiagnostics();
    final adapter = _TransientThenSuccessAdapter(
      failures: 1,
      error: const HttpException('unverified transport'),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    dio.interceptors.addAll([
      RequestContextInterceptor(dio, session),
      SafeRetryInterceptor(dio, wait: (_) async {}),
      NetworkDiagnosticInterceptor(diagnostics: diagnostics),
    ]);
    for (var i = 0; i < 2; i++) {
      await expectLater(
        runAutomaticNetworkRequests(() => dio.get<Object?>('/test')),
        throwsA(isA<DioException>()),
      );
    }
    expect(adapter.attempts, 1);
    expect(session.recovery.isCoolingDown, isTrue);
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(1));
    expect(diagnostics.records.single.source, FailureSource.unknown);
    expect(diagnostics.records.single.reason, FailureReason.unknown);
    expect(diagnostics.records.single.shouldSend, isTrue);
  });

  test('有效令牌自动读取失败建立冷却，保留首次真实诊断且前台读取可恢复', () async {
    final remote = _FakeSessionRemote();
    final session = SessionController(
      _MemoryTokenStore(),
      remote,
      recovery: NetworkRecovery(elapsed: () => Duration.zero),
    );
    addTearDown(session.dispose);
    await session.authenticate(_oldTokens);
    final diagnostics = FailureDiagnostics();
    final adapter = _TransientThenSuccessAdapter(failures: 1);
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    // 与生产相同顺序：自动安全读取首次失败进入退避，后续冷却拒绝
    // 不能覆盖原始 503，诊断只记录真正发出的那一次请求。
    dio.interceptors.addAll([
      RequestContextInterceptor(dio, session),
      SafeRetryInterceptor(dio, wait: (_) async {}),
      NetworkDiagnosticInterceptor(diagnostics: diagnostics),
    ]);
    await expectLater(
      runAutomaticNetworkRequests(() => dio.get<Object?>('/test')),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'original status',
          503,
        ),
      ),
    );
    expect(session.recovery.remaining.inSeconds, inInclusiveRange(30, 33));
    for (var i = 0; i < 3; i++) {
      await expectLater(
        runAutomaticNetworkRequests(() => dio.get<Object?>('/test')),
        throwsA(
          isA<DioException>().having(
            (error) => ApiFailure.fromDio(error).isCancellation,
            'deferred without sending',
            isTrue,
          ),
        ),
      );
    }
    expect(adapter.attempts, 1);
    expect(remote.refreshCalls, 0);
    expect(session.tokens, _oldTokens);
    await diagnostics.settled;
    expect(diagnostics.records, hasLength(1));
    expect(diagnostics.records.single.fields['httpStatus'], 503);
    expect(diagnostics.records.single.shouldSend, isTrue);
    await dio.get<Object?>('/test');
    expect(session.recovery.isCoolingDown, isFalse);
    await runAutomaticNetworkRequests(() => dio.get<Object?>('/test'));
    expect(adapter.attempts, 3);
  });

  test('自动批次的单个读取成功不会清空其他读取的失败预算', () async {
    var elapsed = Duration.zero;
    final recovery = NetworkRecovery(elapsed: () => elapsed);
    final session = SessionController(
      _MemoryTokenStore(),
      _FakeSessionRemote(),
      recovery: recovery,
    );
    addTearDown(session.dispose);
    await session.authenticate(_oldTokens);
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    elapsed += recovery.remaining;
    final adapter = _TransientThenSuccessAdapter(failures: 0);
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    dio.interceptors.add(RequestContextInterceptor(dio, session));
    await runAutomaticNetworkRequests(() => dio.get<Object?>('/test'));
    recovery.failed(recovery.ticket, const ApiFailure(httpStatus: 502));
    expect(recovery.remaining.inSeconds, inInclusiveRange(60, 66));
  });

  test('后台续期冷却拒绝不发请求或诊断，前台写入可立即续期且仅发送一次', () async {
    var offline = true;
    final remote = _FakeSessionRemote()
      ..onRefresh = () async {
        if (offline) throw const ApiFailure(reason: FailureReason.offline);
        return const SessionTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
      };
    final session = SessionController(_MemoryTokenStore(), remote);
    addTearDown(session.dispose);
    await session.authenticate(
      SessionTokens(
        accessToken: _jwtExpiringIn(Duration.zero),
        refreshToken: 'old-refresh',
      ),
    );
    final diagnostics = FailureDiagnostics();
    final adapter = _TransientThenSuccessAdapter(failures: 0);
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    dio.interceptors.addAll([
      RequestContextInterceptor(dio, session),
      SafeRetryInterceptor(dio, wait: (_) async {}),
      NetworkDiagnosticInterceptor(diagnostics: diagnostics),
    ]);
    for (var attempt = 0; attempt < 4; attempt++) {
      await expectLater(
        runAutomaticNetworkRequests(
          () => dio.get<Object?>('/api/v1/notifications'),
        ),
        throwsA(isA<DioException>()),
      );
    }
    expect(remote.refreshCalls, 1);
    expect(adapter.attempts, 0);
    await diagnostics.settled;
    expect(diagnostics.records, isEmpty);
    offline = false;
    await dio.post<Object?>(
      '/api/v1/posts',
      data: {'test': true},
      options: Options(
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
      ),
    );
    expect(remote.refreshCalls, 2);
    expect(adapter.attempts, 1);
    expect(session.recovery.isCoolingDown, isFalse);
    expect(session.tokens?.refreshToken, 'new-refresh');
  });

  test('后台读取冷却不阻止前台普通请求，读取未发出时无远程事件', () async {
    final session = SessionController(
      _MemoryTokenStore(),
      _FakeSessionRemote(),
    );
    addTearDown(session.dispose);
    await session.authenticate(_oldTokens);
    session.recovery.failed(
      session.recovery.ticket,
      const ApiFailure(httpStatus: 502),
    );
    final adapter = _TransientThenSuccessAdapter(failures: 0);
    final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);
    dio.interceptors.add(RequestContextInterceptor(dio, session));
    await expectLater(
      runAutomaticNetworkRequests(() => dio.get<Object?>('/test')),
      throwsA(isA<DioException>()),
    );
    expect(adapter.attempts, 0);
    await dio.get<Object?>('/test');
    expect(adapter.attempts, 1);
    expect(session.recovery.isCoolingDown, isFalse);
  });

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

  test('不可重放写请求遇到 40101 只续期会话并交还原错误', () async {
    final dio = _MockDio();
    final handler = _MockErrorInterceptorHandler();
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_oldTokens);
    final options = RequestOptions(
      path: '/api/v1/auth/request-change-email-code',
      method: 'POST',
      extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
    );
    final error = _businessError(options, 40101);

    RequestContextInterceptor(dio, session).onError(error, handler);
    await untilCalled(() => handler.next(error));

    expect(remote.refreshCalls, 1);
    expect(store.value?.accessToken, 'new-access');
    verifyNever(() => dio.fetch<Object?>(any()));
    verify(() => handler.next(error)).called(1);
  });

  test('普通 POST 遇到 40101 也只续期会话且不会重放', () async {
    final dio = _MockDio();
    final handler = _MockErrorInterceptorHandler();
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_oldTokens);
    final options = RequestOptions(
      path: '/api/v1/subscriptions',
      method: 'POST',
    );
    final error = _businessError(options, 40101);

    RequestContextInterceptor(dio, session).onError(error, handler);
    await untilCalled(() => handler.next(error));

    expect(remote.refreshCalls, 1);
    verifyNever(() => dio.fetch<Object?>(any()));
    verify(() => handler.next(error)).called(1);
  });

  test('不可重放写请求在 access token 到期前静默续期并只发送一次', () async {
    final adapter = _TransientThenSuccessAdapter(failures: 0);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(
      SessionTokens(
        accessToken: _jwtExpiringIn(const Duration(seconds: 30)),
        refreshToken: 'old-refresh',
      ),
    );
    dio.interceptors.add(RequestContextInterceptor(dio, session));
    addTearDown(dio.close);

    final response = await dio.post<Object?>(
      '/api/v1/auth/request-change-email-code',
      options: Options(
        extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
      ),
    );

    expect(response.statusCode, 201);
    expect(remote.refreshCalls, 1);
    expect(adapter.attempts, 1);
    expect(adapter.authorizationHeaders, const ['Bearer new-access']);
    expect(store.value?.refreshToken, 'new-refresh');
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

  test('显式不可重放策略覆盖幂等 HTTP 方法', () async {
    final adapter = _TransientThenSuccessAdapter(failures: 1);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(SafeRetryInterceptor(dio, wait: (_) async {}));
    addTearDown(dio.close);

    await expectLater(
      dio.put<Object?>(
        '/api/v1/auth/request-change-email-code',
        options: Options(
          extra: ApiRequestPolicy.authenticatedNonReplayable.extra,
        ),
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

String _jwtExpiringIn(Duration duration) {
  final expiresAt = DateTime.now().toUtc().add(duration);
  final payload = base64Url
      .encode(
        utf8.encode(
          '{"sub":"user-one","exp":${expiresAt.millisecondsSinceEpoch ~/ 1000}}',
        ),
      )
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

class _MockDio extends Mock implements Dio {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class _FakeSessionRemote implements SessionRemote {
  int refreshCalls = 0;
  Future<SessionTokens> Function()? onRefresh;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    refreshCalls += 1;
    if (onRefresh case final action?) return action();
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
  _TransientThenSuccessAdapter({required this.failures, this.error});

  final int failures;
  final Object? error;
  int attempts = 0;
  final List<String?> requestIds = [];
  final List<String?> authorizationHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    attempts += 1;
    requestIds.add(options.headers['X-Request-ID'] as String?);
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    if (attempts <= failures) {
      if (error != null) {
        throw DioException(requestOptions: options, error: error);
      }
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

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_interceptors.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  test('登录完成后 Provider scope 发布真实账号，存储期间的游客请求失效', () async {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(_Store()),
        sessionRemoteProvider.overrideWithValue(_Remote()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(sessionScopeProvider, (_, _) {});
    addTearDown(subscription.close);
    final payload = base64Url.encode(utf8.encode('{"sub":"account-a"}'));
    await container
        .read(sessionControllerProvider.notifier)
        .authenticate(
          SessionTokens(accessToken: 'h.$payload.s', refreshToken: 'r'),
        );
    expect(container.read(sessionScopeProvider).accountId, 'account-a');
  });

  for (final code in [0, 40101, 40103, 50300]) {
    test('切号后丢弃旧请求 $code，不重放或清除新账号', () async {
      final reply = Completer<ResponseBody>();
      final entered = Completer<void>();
      final adapter = _Adapter((_) {
        entered.complete();
        return reply.future;
      });
      final session = SessionController(_Store(), _Remote());
      await session.authenticate(_a);
      final dio = _dio(session, adapter);
      addTearDown(dio.close);
      final result = expectLater(
        dio.get<Object?>('/test'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'cancel',
            DioExceptionType.cancel,
          ),
        ),
      );
      await entered.future;
      await session.authenticate(_b);
      reply.complete(_response(code));
      await result;
      expect(adapter.calls, 1);
      expect(session.tokens, same(_b));
      expect(session.state.isAuthenticated, isTrue);
    });
  }

  test('退避等待期间退出不会再次发送旧 Authorization', () async {
    final waiting = Completer<void>();
    final release = Completer<void>();
    final session = SessionController(_Store(), _Remote());
    await session.authenticate(_a);
    final adapter = _Adapter((_) async => _response(50300));
    final dio = _dio(
      session,
      adapter,
      wait: (_) {
        waiting.complete();
        return release.future;
      },
    );
    addTearDown(dio.close);
    final result = expectLater(
      dio.get<Object?>('/test'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'cancel',
          DioExceptionType.cancel,
        ),
      ),
    );
    await waiting.future;
    await session.logoutLocally();
    release.complete();
    await result;
    expect(adapter.calls, 1);
    expect(session.tokens, isNull);
  });

  for (final policy in [
    ApiRequestPolicy.public,
    ApiRequestPolicy.explicitCredentials,
  ]) {
    test('$policy 的鉴权错误不刷新或清除普通会话', () async {
      final remote = _Remote();
      final session = SessionController(_Store(), remote);
      await session.authenticate(_a);
      String? authorization;
      final adapter = _Adapter((options) async {
        authorization = options.headers['Authorization'] as String?;
        return _response(40103);
      });
      final dio = _dio(session, adapter);
      addTearDown(dio.close);
      await expectLater(
        dio.get<Object?>(
          '/test',
          options: Options(
            extra: policy.extra,
            headers: {'Authorization': 'Bearer appeal'},
          ),
        ),
        throwsA(isA<DioException>()),
      );
      expect(
        authorization,
        policy == ApiRequestPolicy.public ? null : 'Bearer appeal',
      );
      expect(remote.refreshCalls, 0);
      expect(session.tokens, same(_a));
    });
  }

  test('刷新已进入安全存储写入时退出，旧完成不能恢复登录', () async {
    final store = _Store();
    final session = SessionController(store, _Remote());
    await session.authenticate(_a);
    final entered = Completer<void>();
    final release = Completer<void>();
    store.beforeWrite = (_) {
      entered.complete();
      return release.future;
    };
    final refresh = expectLater(session.refresh(), throwsA(isA<ApiFailure>()));
    await entered.future;
    final logout = session.logoutLocally();
    expect(session.tokens, isNull);
    expect(session.state.isAuthenticated, isFalse);
    release.complete();
    await Future.wait([refresh, logout]);
    expect(store.value, isNull);
    expect(session.tokens, isNull);
    expect(session.state.status, SessionStatus.guest);
  });

  test('旧凭据写入期间重新登录，内存与持久化都只保留新账号', () async {
    final store = _Store();
    final session = SessionController(store, _Remote());
    final entered = Completer<void>();
    final release = Completer<void>();
    store.beforeWrite = (tokens) {
      if (!identical(tokens, _a)) return Future.value();
      entered.complete();
      return release.future;
    };
    final oldLogin = expectLater(
      session.authenticate(_a),
      throwsA(isA<ApiFailure>()),
    );
    await entered.future;
    final newLogin = session.authenticate(_b);
    release.complete();
    await Future.wait([oldLogin, newLogin]);
    expect(session.tokens, same(_b));
    expect(store.value, same(_b));
  });

  test('清理失败不恢复内存凭据，后续登录仍能使用存储队列', () async {
    final store = _Store();
    final session = SessionController(store, _Remote());
    await session.authenticate(_a);
    store.failClear = true;
    await expectLater(session.logoutLocally(), throwsStateError);
    expect(session.tokens, isNull);
    expect(session.state.isAuthenticated, isFalse);
    store.failClear = false;
    await session.authenticate(_b);
    expect(session.tokens, same(_b));
    expect(store.value, same(_b));
  });

  test('新账号刷新不加入旧账号尚未完成的刷新', () async {
    final oldRefresh = Completer<SessionTokens>();
    final remote = _Remote(
      onRefresh: (token) =>
          token == _a.refreshToken ? oldRefresh.future : Future.value(_b),
    );
    final session = SessionController(_Store(), remote);
    await session.authenticate(_a);
    final oldResult = expectLater(
      session.refresh(),
      throwsA(isA<ApiFailure>()),
    );
    await session.authenticate(_b);
    expect(await session.refresh(), same(_b));
    oldRefresh.complete(_a);
    await oldResult;
    expect(remote.refreshCalls, 2);
    expect(session.tokens, same(_b));
  });

  test('旧退出请求迟到成功不清除新登录', () async {
    final reply = Completer<void>();
    final session = SessionController(
      _Store(),
      _Remote(onLogout: () => reply.future),
    );
    await session.authenticate(_a);
    final logout = expectLater(session.logout(), throwsA(isA<ApiFailure>()));
    await session.authenticate(_b);
    reply.complete();
    await logout;
    expect(session.tokens, same(_b));
  });
}

const _a = SessionTokens(accessToken: 'access-a', refreshToken: 'refresh-a');
const _b = SessionTokens(accessToken: 'access-b', refreshToken: 'refresh-b');

Dio _dio(
  SessionController session,
  _Adapter adapter, {
  Future<void> Function(Duration)? wait,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.invalid'))
    ..httpClientAdapter = adapter;
  dio.interceptors.addAll([
    RequestContextInterceptor(dio, session),
    SafeRetryInterceptor(dio, wait: wait ?? (_) async {}),
  ]);
  return dio;
}

ResponseBody _response(int code) => ResponseBody.fromString(
  '{"code":$code}',
  code == 0
      ? 200
      : code >= 50000
      ? 503
      : 401,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.reply);
  final Future<ResponseBody> Function(RequestOptions) reply;
  int calls = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) {
    calls++;
    return reply(options);
  }

  @override
  void close({bool force = false}) {}
}

class _Store implements TokenStore {
  SessionTokens? value;
  Future<void> Function(SessionTokens)? beforeWrite;
  bool failClear = false;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async {
    await beforeWrite?.call(tokens);
    value = tokens;
  }

  @override
  Future<void> clear() async {
    if (failClear) throw StateError('test storage failure');
    value = null;
  }
}

class _Remote implements SessionRemote {
  _Remote({this.onRefresh, this.onLogout});
  final Future<SessionTokens> Function(String)? onRefresh;
  final Future<void> Function()? onLogout;
  int refreshCalls = 0;
  @override
  Future<SessionTokens> refresh(String token) {
    refreshCalls++;
    return onRefresh?.call(token) ?? Future.value(_a);
  }

  @override
  Future<void> logout(SessionTokens tokens) =>
      onLogout?.call() ?? Future.value();
}

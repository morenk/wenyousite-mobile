import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_recovery.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
  for (final failure in [
    ApiFailure.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        error: const SocketException('DNS test failure'),
      ),
    ),
    const ApiFailure(
      source: FailureSource.network,
      reason: FailureReason.timeout,
    ),
    const ApiFailure(httpStatus: 502),
  ]) {
    test(
      '续期 ${failure.effectiveSource}/${failure.reason} 冷却到期恢复，手动尝试保持合并和令牌',
      () async {
        var elapsed = Duration.zero;
        var shouldFail = true;
        final pending = Completer<SessionTokens>();
        final remote = _FakeSessionRemote(
          onRefresh: (_) async {
            if (shouldFail) throw failure;
            return pending.future;
          },
        );
        final recovery = NetworkRecovery(elapsed: () => elapsed);
        final store = _MemoryTokenStore();
        final controller = SessionController(store, remote, recovery: recovery);
        addTearDown(controller.dispose);
        await controller.authenticate(_oldTokens);
        await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
        await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
        expect(remote.refreshCalls, 1);
        elapsed += recovery.remaining;
        await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
        expect(remote.refreshCalls, 2);
        expect(recovery.remaining.inSeconds, inInclusiveRange(60, 66));
        shouldFail = false;
        final manual = controller.refresh(automatic: false);
        final joined = controller.refresh();
        expect(identical(manual, joined), isTrue);
        expect(recovery.isCoolingDown, isTrue);
        pending.complete(_tokensFor('user-one', '2'));
        final tokens = await manual;
        await joined;
        expect(remote.refreshCalls, 3);
        expect(recovery.isCoolingDown, isFalse);
        expect(controller.tokens, same(tokens));
        expect(store.value, same(tokens));
      },
    );
  }

  test('手动尝试失败不会解除自动冷却', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (_) async =>
          throw const ApiFailure(reason: FailureReason.offline),
    );
    final controller = SessionController(_MemoryTokenStore(), remote);
    addTearDown(controller.dispose);
    await controller.authenticate(_oldTokens);
    await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
    await expectLater(
      controller.refresh(automatic: false),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
    expect(remote.refreshCalls, 2);
    expect(controller.recovery.isCoolingDown, isTrue);
    expect(controller.tokens, same(_oldTokens));
  });

  test('旧账号瞬时失败不能给新账号添加冷却，重新登录清除旧冷却', () async {
    final pending = Completer<SessionTokens>();
    final remote = _FakeSessionRemote(
      onRefresh: (token) => token == _oldTokens.refreshToken
          ? pending.future
          : Future.value(_tokensFor('new', '2')),
    );
    final controller = SessionController(_MemoryTokenStore(), remote);
    addTearDown(controller.dispose);
    await controller.authenticate(_oldTokens);
    final result = expectLater(
      controller.refresh(),
      throwsA(isA<ApiFailure>()),
    );
    await controller.authenticate(_tokensFor('new', '1'));
    pending.completeError(const ApiFailure(reason: FailureReason.offline));
    await result;
    expect(controller.recovery.isCoolingDown, isFalse);
    await controller.refresh();
    expect(remote.refreshCalls, 2);
  });

  test('瞬时刷新失败后连续自动请求不会再次调用刷新接口', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (_) async => throw const ApiFailure(
        source: FailureSource.network,
        reason: FailureReason.offline,
      ),
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    addTearDown(controller.dispose);
    await controller.authenticate(_oldTokens);
    for (var attempt = 0; attempt < 5; attempt++) {
      await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));
    }
    expect(remote.refreshCalls, 1);
    expect(controller.tokens, same(_oldTokens));
    expect(store.value, same(_oldTokens));
  });

  test('仅从结构完整的 JWT 提取本地数据隔离用户 ID', () async {
    final controller = SessionController(
      _MemoryTokenStore(),
      _FakeSessionRemote(),
    );
    final payload = base64Url
        .encode(utf8.encode('{"sub":"user-one","role":"USER"}'))
        .replaceAll('=', '');
    await controller.authenticate(
      SessionTokens(
        accessToken: 'header.$payload.signature',
        refreshToken: 'refresh',
      ),
    );

    expect(controller.currentUserId, 'user-one');
    await controller.authenticate(_oldTokens);
    expect(controller.currentUserId, isNull);
  });

  test('会话 scope 在令牌刷新时稳定，仅在登录边界推进代次', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (_) async => _tokensFor('user-one', '2'),
    );
    final controller = SessionController(_MemoryTokenStore(), remote);
    await controller.authenticate(_tokensFor('user-one', '1'));
    final signedIn = controller.scope;

    await controller.refresh();

    expect(controller.scope, signedIn);
    await controller.authenticate(_tokensFor('user-two', '1'));
    final switchedAccount = controller.scope;
    expect(switchedAccount.accountId, 'user-two');
    expect(switchedAccount.generation, greaterThan(signedIn.generation));

    await controller.logoutLocally();
    final signedOut = controller.scope;
    expect(signedOut.accountId, isNull);
    expect(signedOut.generation, greaterThan(switchedAccount.generation));

    await controller.authenticate(_tokensFor('user-two', '2'));
    final reauthenticated = controller.scope;
    await controller.invalidate(SessionInvalidationReason.revoked);
    expect(controller.scope.accountId, isNull);
    expect(
      controller.scope.generation,
      greaterThan(reauthenticated.generation),
    );
  });

  test('重复恢复同一账号保持 scope，恢复为空或失败时推进退出边界', () async {
    final store = _MemoryTokenStore()..value = _tokensFor('user-one', '1');
    final controller = SessionController(store, _FakeSessionRemote());

    await controller.restore();
    final restored = controller.scope;
    await controller.restore();
    expect(controller.scope, restored);

    store.value = null;
    await controller.restore();
    expect(controller.scope.accountId, isNull);
    expect(controller.scope.generation, greaterThan(restored.generation));

    await controller.authenticate(_tokensFor('user-two', '1'));
    final authenticated = controller.scope;
    store.readError = StateError('secure storage unavailable');
    await controller.restore();
    expect(controller.scope.accountId, isNull);
    expect(controller.scope.generation, greaterThan(authenticated.generation));
  });

  test('旧会话刷新迟到成功不会覆盖已切换账号', () async {
    final refresh = Completer<SessionTokens>();
    final store = _MemoryTokenStore();
    final controller = SessionController(
      store,
      _FakeSessionRemote(onRefresh: (_) => refresh.future),
    );
    await controller.authenticate(_tokensFor('user-one', '1'));
    final expectation = expectLater(
      controller.refresh(),
      throwsA(isA<ApiFailure>()),
    );

    final nextTokens = _tokensFor('user-two', '1');
    await controller.authenticate(nextTokens);
    final switchedScope = controller.scope;
    refresh.complete(_tokensFor('user-one', '2'));
    await expectation;

    expect(controller.tokens, same(nextTokens));
    expect(store.value, same(nextTokens));
    expect(controller.scope, switchedScope);
    expect(controller.state.isAuthenticated, isTrue);
  });

  test('旧会话刷新迟到失败不会清除已切换账号', () async {
    final refresh = Completer<SessionTokens>();
    final store = _MemoryTokenStore();
    final controller = SessionController(
      store,
      _FakeSessionRemote(onRefresh: (_) => refresh.future),
    );
    await controller.authenticate(_tokensFor('user-one', '1'));
    final expectation = expectLater(
      controller.refresh(),
      throwsA(isA<ApiFailure>()),
    );

    final nextTokens = _tokensFor('user-two', '1');
    await controller.authenticate(nextTokens);
    refresh.completeError(
      const ApiFailure(
        userMessage: '旧会话已撤销。',
        httpStatus: 401,
        businessCode: 40103,
      ),
    );
    await expectation;

    expect(controller.tokens, same(nextTokens));
    expect(store.value, same(nextTokens));
    expect(controller.scope.accountId, 'user-two');
    expect(controller.state.isAuthenticated, isTrue);
  });

  test('并发刷新共享一次请求并原子替换双 Token', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (refreshToken) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const SessionTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
      },
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    final results = await Future.wait([
      controller.refresh(),
      controller.refresh(),
    ]);

    expect(
      results.map((tokens) => tokens.accessToken),
      everyElement('new-access'),
    );
    expect(remote.refreshCalls, 1);
    expect(remote.lastRefreshToken, 'old-refresh');
    expect(store.value?.refreshToken, 'new-refresh');
    expect(controller.state.isAuthenticated, isTrue);
  });

  test('刷新失败清除本地会话并保留失效原因', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (_) => throw const ApiFailure(
        userMessage: '登录已被撤销，请重新登录。',
        businessCode: 40103,
      ),
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));

    expect(store.value, isNull);
    expect(controller.tokens, isNull);
    expect(controller.state.status, SessionStatus.invalidated);
    expect(controller.state.reason, SessionInvalidationReason.revoked);
  });

  test('transient refresh failures preserve the local session', () async {
    final remote = _FakeSessionRemote(
      onRefresh: (_) =>
          throw const ApiFailure(userMessage: 'temporary network failure'),
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    await expectLater(controller.refresh(), throwsA(isA<ApiFailure>()));

    expect(store.value, same(_oldTokens));
    expect(controller.tokens, same(_oldTokens));
    expect(controller.state.isAuthenticated, isTrue);
  });

  test('服务端退出成功后清除双 Token 并进入游客状态', () async {
    final remote = _FakeSessionRemote();
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    await controller.logout();

    expect(remote.logoutCalls, 1);
    expect(remote.lastLogoutTokens, same(_oldTokens));
    expect(store.value, isNull);
    expect(controller.state.status, SessionStatus.guest);
  });

  test('退出遇到 40101 时先轮转双 Token 再重试一次', () async {
    var logoutAttempts = 0;
    final remote = _FakeSessionRemote(
      onRefresh: (_) async => const SessionTokens(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      ),
      onLogout: (_) async {
        if (logoutAttempts == 0) {
          logoutAttempts += 1;
          throw const ApiFailure(userMessage: '访问令牌已过期。', businessCode: 40101);
        }
        logoutAttempts += 1;
      },
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    await controller.logout();

    expect(remote.refreshCalls, 1);
    expect(remote.logoutCalls, 2);
    expect(remote.lastLogoutTokens?.accessToken, 'new-access');
    expect(store.value, isNull);
    expect(controller.state.status, SessionStatus.guest);
  });

  test('服务端退出遇到暂时错误时保留本地会话供重试', () async {
    final remote = _FakeSessionRemote(
      onLogout: (_) => throw const ApiFailure(
        userMessage: '服务器暂时开小差了，请稍后重试。',
        requestId: 'logout-request-id',
      ),
    );
    final store = _MemoryTokenStore();
    final controller = SessionController(store, remote);
    await controller.authenticate(_oldTokens);

    await expectLater(controller.logout(), throwsA(isA<ApiFailure>()));

    expect(store.value, same(_oldTokens));
    expect(controller.tokens, same(_oldTokens));
    expect(controller.state.isAuthenticated, isTrue);
  });
}

const _oldTokens = SessionTokens(
  accessToken: 'old-access',
  refreshToken: 'old-refresh',
);

SessionTokens _tokensFor(String userId, String nonce) {
  final payload = base64Url
      .encode(utf8.encode('{"sub":"$userId","nonce":"$nonce"}'))
      .replaceAll('=', '');
  return SessionTokens(
    accessToken: 'header.$payload.signature',
    refreshToken: 'refresh-$userId-$nonce',
  );
}

class _FakeSessionRemote implements SessionRemote {
  _FakeSessionRemote({this.onRefresh, this.onLogout});

  final Future<SessionTokens> Function(String refreshToken)? onRefresh;
  final Future<void> Function(SessionTokens tokens)? onLogout;
  int refreshCalls = 0;
  int logoutCalls = 0;
  String? lastRefreshToken;
  SessionTokens? lastLogoutTokens;

  @override
  Future<SessionTokens> refresh(String refreshToken) {
    refreshCalls += 1;
    lastRefreshToken = refreshToken;
    return onRefresh?.call(refreshToken) ?? Future.value(_oldTokens);
  }

  @override
  Future<void> logout(SessionTokens tokens) {
    logoutCalls += 1;
    lastLogoutTokens = tokens;
    return onLogout?.call(tokens) ?? Future.value();
  }
}

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;
  Object? readError;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async {
    if (readError case final error?) throw error;
    return value;
  }

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

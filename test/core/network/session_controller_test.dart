import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';

void main() {
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

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

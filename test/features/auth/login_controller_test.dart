import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/auth/application/login_controller.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';

void main() {
  test('登录成功后原子保存双 Token 并进入认证状态', () async {
    final repository = _FakeAuthRepository(
      onLogin: (account, password) async => const SessionTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );
    final store = _MemoryTokenStore();
    final dio = Dio();
    addTearDown(dio.close);
    final session = SessionController(store, dio);
    final controller = LoginController(repository, session);

    final result = await controller.submit(
      account: '  user@example.com  ',
      password: 'password123',
    );

    expect(result, isTrue);
    expect(repository.lastAccount, 'user@example.com');
    expect(repository.lastPassword, 'password123');
    expect(store.value?.accessToken, 'access-token');
    expect(store.value?.refreshToken, 'refresh-token');
    expect(session.state.isAuthenticated, isTrue);
    expect(controller.state.status, LoginStatus.idle);
  });

  test('提交期间拒绝重复登录请求', () async {
    final pending = Completer<SessionTokens>();
    final repository = _FakeAuthRepository(
      onLogin: (account, password) => pending.future,
    );
    final dio = Dio();
    addTearDown(dio.close);
    final controller = LoginController(
      repository,
      SessionController(_MemoryTokenStore(), dio),
    );

    final first = controller.submit(account: 'user', password: 'password123');
    final second = await controller.submit(
      account: 'user',
      password: 'password123',
    );
    pending.complete(
      const SessionTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );

    expect(second, isFalse);
    expect(await first, isTrue);
    expect(repository.calls, 1);
  });

  test('登录失败保留安全错误和请求 ID', () async {
    final repository = _FakeAuthRepository(
      onLogin: (account, password) => throw const ApiFailure(
        userMessage: '账号或密码错误。',
        businessCode: 40110,
        requestId: 'request-id',
      ),
    );
    final dio = Dio();
    addTearDown(dio.close);
    final controller = LoginController(
      repository,
      SessionController(_MemoryTokenStore(), dio),
    );

    final result = await controller.submit(
      account: 'user',
      password: 'wrong-password',
    );

    expect(result, isFalse);
    expect(controller.state.status, LoginStatus.failed);
    expect(controller.state.failure?.businessCode, 40110);
    expect(controller.state.failure?.requestId, 'request-id');
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.onLogin});

  final Future<SessionTokens> Function(String account, String password) onLogin;
  int calls = 0;
  String? lastAccount;
  String? lastPassword;

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) {
    calls += 1;
    lastAccount = account;
    lastPassword = password;
    return onLogin(account, password);
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

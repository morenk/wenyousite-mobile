import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/auth/application/logout_controller.dart';

void main() {
  test('退出提交期间拒绝重复请求并在成功后进入游客状态', () async {
    final pending = Completer<void>();
    final remote = _FakeSessionRemote(onLogout: (_) => pending.future);
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_tokens);
    final controller = LogoutController(session);

    final first = controller.submit();
    final second = await controller.submit();
    pending.complete();

    expect(second, isFalse);
    expect(await first, isTrue);
    expect(remote.logoutCalls, 1);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
  });

  test('退出失败保留会话、错误与请求 ID', () async {
    final remote = _FakeSessionRemote(
      onLogout: (_) => throw const ApiFailure(
        userMessage: '服务器暂时开小差了，请稍后重试。',
        requestId: 'logout-request-id',
      ),
    );
    final store = _MemoryTokenStore();
    final session = SessionController(store, remote);
    await session.authenticate(_tokens);
    final controller = LogoutController(session);

    expect(await controller.submit(), isFalse);

    expect(controller.state.status, LogoutStatus.failed);
    expect(controller.state.failure?.requestId, 'logout-request-id');
    expect(session.state.isAuthenticated, isTrue);
    expect(store.value, same(_tokens));
  });

  test('明确选择仅清除本机后删除 Token', () async {
    final store = _MemoryTokenStore();
    final session = SessionController(store, _FakeSessionRemote());
    await session.authenticate(_tokens);
    final controller = LogoutController(session);

    await controller.forceLocalLogout();

    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
    expect(controller.state.status, LogoutStatus.idle);
  });
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class _FakeSessionRemote implements SessionRemote {
  _FakeSessionRemote({this.onLogout});

  final Future<void> Function(SessionTokens tokens)? onLogout;
  int logoutCalls = 0;

  @override
  Future<void> logout(SessionTokens tokens) {
    logoutCalls += 1;
    return onLogout?.call(tokens) ?? Future.value();
  }

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
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

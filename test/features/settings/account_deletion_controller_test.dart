import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/settings/application/account_deletion_controller.dart';
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';

void main() {
  test('服务端确认注销后清除本地双 Token', () async {
    final store = _MemoryTokenStore();
    final session = await _authenticatedSession(store);
    final repository = _FakeAccountDeletionRepository();
    final controller = AccountDeletionController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(await controller.submit(), isTrue);

    expect(repository.calls, 1);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
  });

  test('服务端拒绝注销时保留会话、请求 ID 且可重试', () async {
    final store = _MemoryTokenStore();
    final session = await _authenticatedSession(store);
    final repository = _FakeAccountDeletionRepository(
      failure: const ApiFailure(
        userMessage: '账号注销暂时没有完成。',
        requestId: 'delete-request-id',
      ),
    );
    final controller = AccountDeletionController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(await controller.submit(), isFalse);

    expect(controller.state.remoteDeletionConfirmed, isFalse);
    expect(controller.state.failure?.requestId, 'delete-request-id');
    expect(session.state.status, SessionStatus.authenticated);
    expect(store.value, isNotNull);
  });

  test('远端已注销但本机清理失败时不重复注销请求', () async {
    final store = _MemoryTokenStore(failFirstClear: true);
    final session = await _authenticatedSession(store);
    final repository = _FakeAccountDeletionRepository();
    final controller = AccountDeletionController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(await controller.submit(), isFalse);
    expect(controller.state.remoteDeletionConfirmed, isTrue);
    expect(controller.state.failure?.userMessage, contains('登录信息失败'));
    expect(await controller.submit(), isFalse);
    expect(repository.calls, 1);

    expect(await controller.retryLocalCleanup(), isTrue);
    expect(repository.calls, 1);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
  });
}

class _FakeAccountDeletionRepository implements AccountDeletionRepository {
  _FakeAccountDeletionRepository({this.failure});

  final ApiFailure? failure;
  int calls = 0;

  @override
  Future<void> deleteAccount() async {
    calls += 1;
    if (failure != null) throw failure!;
  }
}

Future<SessionController> _authenticatedSession(_MemoryTokenStore store) async {
  final controller = SessionController(store, _UnusedSessionRemote());
  await controller.authenticate(_tokens);
  return controller;
}

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore({this.failFirstClear = false});

  bool failFirstClear;
  SessionTokens? value;

  @override
  Future<void> clear() async {
    if (failFirstClear) {
      failFirstClear = false;
      throw StateError('secure storage unavailable');
    }
    value = null;
  }

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) async {}

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

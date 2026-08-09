import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/settings/application/credential_security_controllers.dart';
import 'package:wenyousite_mobile/features/settings/data/credential_security_repository.dart';
import 'package:wenyousite_mobile/features/settings/domain/credential_security_models.dart';

void main() {
  test('修改密码成功后清除本地会话', () async {
    final store = _MemoryTokenStore();
    final session = await _authenticatedSession(store);
    final repository = _FakeRepository();
    final controller = PasswordChangeController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(
      await controller.submit(
        oldPassword: 'current123',
        newPassword: 'next-pass9',
      ),
      isTrue,
    );

    expect(repository.passwordChanges, [('current123', 'next-pass9')]);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
    expect(controller.state.status, PasswordChangeStatus.idle);
  });

  test('修改密码失败保留会话、请求 ID 并串行化提交', () async {
    final pending = Completer<void>();
    final store = _MemoryTokenStore();
    final session = await _authenticatedSession(store);
    final repository = _FakeRepository(changePasswordPending: pending);
    final controller = PasswordChangeController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    final first = controller.submit(
      oldPassword: 'current123',
      newPassword: 'next-pass9',
    );
    expect(controller.state.isSubmitting, isTrue);
    expect(
      await controller.submit(
        oldPassword: 'current123',
        newPassword: 'another9',
      ),
      isFalse,
    );
    pending.completeError(
      const ApiFailure(
        userMessage: '当前密码不正确。',
        requestId: 'password-request-id',
      ),
    );

    expect(await first, isFalse);
    expect(repository.changePasswordCalls, 1);
    expect(controller.state.failure?.requestId, 'password-request-id');
    expect(session.state.status, SessionStatus.authenticated);
    expect(store.value, isNotNull);
  });

  test('请求换绑验证码规范化邮箱并启用重发冷却', () async {
    final session = await _authenticatedSession(_MemoryTokenStore());
    final repository = _FakeRepository();
    final controller = EmailChangeController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(
      await controller.requestCode(
        newEmail: '  NEXT@Example.COM ',
        oldPassword: 'current123',
      ),
      isTrue,
    );

    expect(repository.emailCodeRequests, [('next@example.com', 'current123')]);
    expect(controller.state.step, EmailChangeStep.verifyCode);
    expect(controller.state.email, 'next@example.com');
    expect(controller.state.resendSecondsRemaining, 60);
    expect(
      await controller.requestCode(
        newEmail: 'next@example.com',
        oldPassword: 'current123',
      ),
      isFalse,
    );
    expect(repository.requestEmailCodeCalls, 1);

    controller.editEmail();
    expect(controller.state.step, EmailChangeStep.requestCode);
    expect(controller.state.resendSecondsRemaining, 0);
  });

  test('验证码请求限流按 Retry-After 锁定重发并保留错误', () async {
    final session = await _authenticatedSession(_MemoryTokenStore());
    final repository = _FakeRepository(
      requestEmailCodeFailure: const ApiFailure(
        userMessage: '操作太频繁，请稍后再试。',
        requestId: 'rate-request-id',
        retryAfter: Duration(seconds: 7),
      ),
    );
    final controller = EmailChangeController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);

    expect(
      await controller.requestCode(
        newEmail: 'next@example.com',
        oldPassword: 'current123',
      ),
      isFalse,
    );

    expect(controller.state.failure?.requestId, 'rate-request-id');
    expect(controller.state.resendSecondsRemaining, 7);
    expect(controller.state.step, EmailChangeStep.requestCode);
  });

  test('确认换绑失败保留目标邮箱，成功后清除本地会话', () async {
    final store = _MemoryTokenStore();
    final session = await _authenticatedSession(store);
    final repository = _FakeRepository(
      verifyEmailFailure: const ApiFailure(
        userMessage: '验证码不正确。',
        requestId: 'verify-request-id',
      ),
    );
    final controller = EmailChangeController(repository, session);
    addTearDown(controller.dispose);
    addTearDown(session.dispose);
    await controller.requestCode(
      newEmail: 'next@example.com',
      oldPassword: 'current123',
    );

    expect(await controller.verifyCode(' 123456 '), isFalse);
    expect(controller.state.email, 'next@example.com');
    expect(controller.state.failure?.requestId, 'verify-request-id');
    expect(session.state.status, SessionStatus.authenticated);

    repository.verifyEmailFailure = null;
    expect(await controller.verifyCode(' 654321 '), isTrue);
    expect(repository.emailVerifications, [
      ('next@example.com', '123456'),
      ('next@example.com', '654321'),
    ]);
    expect(store.value, isNull);
    expect(session.state.status, SessionStatus.guest);
    expect(controller.state.step, EmailChangeStep.requestCode);
  });
}

class _FakeRepository implements CredentialSecurityRepository {
  _FakeRepository({
    this.changePasswordPending,
    this.requestEmailCodeFailure,
    this.verifyEmailFailure,
  });

  final Completer<void>? changePasswordPending;
  final ApiFailure? requestEmailCodeFailure;
  ApiFailure? verifyEmailFailure;
  int changePasswordCalls = 0;
  int requestEmailCodeCalls = 0;
  final List<(String, String)> passwordChanges = [];
  final List<(String, String)> emailCodeRequests = [];
  final List<(String, String)> emailVerifications = [];

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    changePasswordCalls += 1;
    final pending = changePasswordPending;
    if (pending != null) await pending.future;
    passwordChanges.add((oldPassword, newPassword));
  }

  @override
  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  }) async {
    requestEmailCodeCalls += 1;
    if (requestEmailCodeFailure != null) throw requestEmailCodeFailure!;
    emailCodeRequests.add((newEmail, oldPassword));
  }

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  }) async {
    emailVerifications.add((newEmail, code));
    if (verifyEmailFailure != null) throw verifyEmailFailure!;
  }
}

Future<SessionController> _authenticatedSession(_MemoryTokenStore store) async {
  final session = SessionController(store, _UnusedSessionRemote());
  await session.authenticate(_tokens);
  return session;
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class _MemoryTokenStore implements TokenStore {
  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) => throw UnimplementedError();

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

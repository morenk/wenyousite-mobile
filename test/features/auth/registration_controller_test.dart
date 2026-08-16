import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/auth/application/registration_controller.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';

void main() {
  test('验证码请求规范化邮箱并进入带冷却的验证步骤', () async {
    final repository = _FakeAuthRepository();
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    final succeeded = await controller.requestCode('  new@example.com  ');

    expect(succeeded, isTrue);
    expect(repository.lastEmail, 'new@example.com');
    expect(controller.state.step, RegistrationStep.verify);
    expect(controller.state.codeExpiresInSeconds, 900);
    expect(controller.state.resendSecondsRemaining, 60);
    expect(await controller.resendCode(), isFalse);
  });

  test('验证码请求期间拒绝重复提交', () async {
    final pending = Completer<RegistrationCodeInfo>();
    final repository = _FakeAuthRepository(
      onRequestCode: (_) => pending.future,
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    final first = controller.requestCode('new@example.com');
    final second = await controller.requestCode('new@example.com');
    pending.complete(
      const RegistrationCodeInfo(expiresIn: Duration(minutes: 15)),
    );

    expect(second, isFalse);
    expect(await first, isTrue);
    expect(repository.requestCodeCalls, 1);
  });

  test('429 视为投递结果不确定并固定冷却 60 秒', () async {
    final repository = _FakeAuthRepository(
      onRequestCode: (_) => throw const ApiFailure(
        userMessage: '操作太频繁，请稍后再试。',
        businessCode: 42900,
        requestId: 'rate-limit-request-id',
        retryAfter: Duration(seconds: 37),
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);

    expect(await controller.requestCode('new@example.com'), isTrue);

    expect(controller.state.status, RegistrationStatus.idle);
    expect(controller.state.step, RegistrationStep.verify);
    expect(controller.state.codeDeliveryUncertain, isTrue);
    expect(controller.state.failure?.requestId, 'rate-limit-request-id');
    expect(controller.state.resendSecondsRemaining, 60);
  });

  test('完成注册保存双 Token 并规范化验证码和用户名', () async {
    final repository = _FakeAuthRepository();
    final store = _MemoryTokenStore();
    final session = SessionController(store, _UnusedSessionRemote());
    final controller = RegistrationController(repository, session);
    addTearDown(controller.dispose);
    await controller.requestCode('new@example.com');

    final succeeded = await controller.complete(
      code: ' 123456 ',
      username: ' 新用户2 ',
      password: 'password123',
    );

    expect(succeeded, isTrue);
    expect(repository.lastCode, '123456');
    expect(repository.lastUsername, '新用户2');
    expect(store.value?.refreshToken, 'refresh-token');
    expect(session.state.isAuthenticated, isTrue);
  });

  test('验证码错误保留验证步骤和安全错误供修改重试', () async {
    final repository = _FakeAuthRepository(
      onComplete: (_, _, _, _) => throw const ApiFailure(
        userMessage: '验证码不正确，请检查后重试。',
        businessCode: 40112,
        requestId: 'verify-request-id',
      ),
    );
    final controller = _controller(repository);
    addTearDown(controller.dispose);
    await controller.requestCode('new@example.com');

    expect(
      await controller.complete(
        code: '000000',
        username: 'newuser',
        password: 'password123',
      ),
      isFalse,
    );

    expect(controller.state.step, RegistrationStep.verify);
    expect(controller.state.status, RegistrationStatus.failed);
    expect(controller.state.failure?.businessCode, 40112);
    expect(controller.state.failure?.requestId, 'verify-request-id');
  });
}

RegistrationController _controller(AuthRepository repository) {
  return RegistrationController(
    repository,
    SessionController(_MemoryTokenStore(), _UnusedSessionRemote()),
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.onRequestCode, this.onComplete});

  final Future<RegistrationCodeInfo> Function(String email)? onRequestCode;
  final Future<SessionTokens> Function(
    String email,
    String code,
    String username,
    String password,
  )?
  onComplete;
  int requestCodeCalls = 0;
  String? lastEmail;
  String? lastCode;
  String? lastUsername;

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) {
    requestCodeCalls += 1;
    lastEmail = email;
    return onRequestCode?.call(email) ??
        Future.value(
          const RegistrationCodeInfo(expiresIn: Duration(minutes: 15)),
        );
  }

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) {
    lastEmail = email;
    lastCode = code;
    lastUsername = username;
    return onComplete?.call(email, code, username, password) ??
        Future.value(
          const SessionTokens(
            accessToken: 'access-token',
            refreshToken: 'refresh-token',
          ),
        );
  }

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) => throw UnimplementedError();
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

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) => throw UnimplementedError();

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

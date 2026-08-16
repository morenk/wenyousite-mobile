import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/application/password_recovery_controller.dart';
import 'package:wenyousite_mobile/features/auth/data/password_recovery_repository.dart';

void main() {
  test('投递结果恢复确定后清除旧请求 ID', () {
    const uncertain = PasswordRecoveryState(
      codeDeliveryUncertain: true,
      codeDeliveryRequestId: 'old-request-id',
    );

    final resolved = uncertain.copyWith(codeDeliveryUncertain: false);

    expect(resolved.codeDeliveryUncertain, isFalse);
    expect(resolved.codeDeliveryRequestId, isNull);
  });

  test('请求重置验证码规范化邮箱并建立 60 秒反枚举冷却', () async {
    final repository = _FakePasswordRecoveryRepository();
    final controller = PasswordRecoveryController(
      repository,
      const PasswordRecoverySeed(),
    );
    addTearDown(controller.dispose);

    expect(await controller.requestCode('  User@Example.COM  '), isTrue);

    expect(repository.codeRequests, ['user@example.com']);
    expect(controller.state.lastRequestedEmail, 'user@example.com');
    expect(controller.state.resendSecondsRemaining, 60);
    expect(await controller.requestCode('other@example.com'), isFalse);
    expect(repository.codeRequests, hasLength(1));
  });

  test('验证码请求期间拒绝重复发送', () async {
    final pending = Completer<void>();
    final repository = _FakePasswordRecoveryRepository(
      onRequestCode: (_) => pending.future,
    );
    final controller = PasswordRecoveryController(
      repository,
      const PasswordRecoverySeed(),
    );
    addTearDown(controller.dispose);

    final first = controller.requestCode('user@example.com');
    expect(await controller.requestCode('user@example.com'), isFalse);
    pending.complete();

    expect(await first, isTrue);
    expect(repository.codeRequests, hasLength(1));
  });

  test('429 视为投递结果不确定并保留邮箱与请求 ID', () async {
    final repository = _FakePasswordRecoveryRepository(
      onRequestCode: (_) => throw const ApiFailure(
        userMessage: '操作太频繁，请稍后再试。',
        businessCode: 42900,
        requestId: 'recovery-rate-id',
        retryAfter: Duration(seconds: 41),
      ),
    );
    final controller = PasswordRecoveryController(
      repository,
      const PasswordRecoverySeed(),
    );
    addTearDown(controller.dispose);

    expect(await controller.requestCode('user@example.com'), isTrue);

    expect(controller.state.codeDeliveryUncertain, isTrue);
    expect(controller.state.lastRequestedEmail, 'user@example.com');
    expect(controller.state.failure?.businessCode, 42900);
    expect(controller.state.failure?.requestId, 'recovery-rate-id');
    expect(controller.state.resendSecondsRemaining, 60);
  });

  test('重置密码规范化邮箱和验证码且提交期间拒绝重复请求', () async {
    final pending = Completer<void>();
    final repository = _FakePasswordRecoveryRepository(
      onReset: (_, _, _) => pending.future,
    );
    final controller = PasswordRecoveryController(
      repository,
      const PasswordRecoverySeed(),
    );
    addTearDown(controller.dispose);

    final first = controller.resetPassword(
      email: ' User@Example.COM ',
      code: ' 654321 ',
      newPassword: 'next-pass9',
    );
    expect(
      await controller.resetPassword(
        email: 'user@example.com',
        code: '654321',
        newPassword: 'next-pass9',
      ),
      isFalse,
    );
    pending.complete();

    expect(await first, isTrue);
    expect(repository.resets, [('user@example.com', '654321', 'next-pass9')]);
  });

  test('验证码失败保留业务码和请求 ID 供原表单修正', () async {
    final repository = _FakePasswordRecoveryRepository(
      onReset: (_, _, _) => throw const ApiFailure(
        userMessage: '验证码不正确，请检查后重试。',
        businessCode: 40112,
        requestId: 'reset-code-id',
      ),
    );
    final controller = PasswordRecoveryController(
      repository,
      const PasswordRecoverySeed(),
    );
    addTearDown(controller.dispose);

    expect(
      await controller.resetPassword(
        email: 'user@example.com',
        code: '000000',
        newPassword: 'next-pass9',
      ),
      isFalse,
    );

    expect(controller.state.failure?.businessCode, 40112);
    expect(controller.state.failure?.requestId, 'reset-code-id');
    expect(controller.state.isBusy, isFalse);
  });
}

class _FakePasswordRecoveryRepository implements PasswordRecoveryRepository {
  _FakePasswordRecoveryRepository({this.onRequestCode, this.onReset});

  final Future<void> Function(String email)? onRequestCode;
  final Future<void> Function(String email, String code, String newPassword)?
  onReset;
  final List<String> codeRequests = [];
  final List<(String, String, String)> resets = [];

  @override
  Future<void> requestCode({required String email}) {
    codeRequests.add(email);
    return onRequestCode?.call(email) ?? Future.value();
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    resets.add((email, code, newPassword));
    return onReset?.call(email, code, newPassword) ?? Future.value();
  }
}

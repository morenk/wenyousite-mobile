import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/application/email_verification_controller.dart';
import 'package:wenyousite_mobile/features/auth/data/email_verification_repository.dart';

void main() {
  test('读取待验证账号、重发验证码并执行冷却', () async {
    final repository = _FakeEmailVerificationRepository();
    final controller = EmailVerificationController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.state.phase, EmailVerificationPhase.ready);
    expect(controller.state.account?.email, 'owner@example.com');
    expect(controller.state.account?.isVerified, isFalse);

    expect(await controller.requestCode(), isTrue);
    expect(repository.resends, ['owner@example.com']);
    expect(controller.state.resendSecondsRemaining, 60);
    expect(controller.state.successMessage, contains('如果当前邮箱仍待验证'));
    expect(await controller.requestCode(), isFalse);
    expect(repository.resends, hasLength(1));
  });

  test('验证成功后重读账号事实且不刷新 Token', () async {
    final repository = _FakeEmailVerificationRepository();
    final controller = EmailVerificationController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    final succeeded = await controller.verifyCode(' 654321 ');

    expect(succeeded, isTrue);
    expect(repository.codes, ['654321']);
    expect(repository.fetches, 2);
    expect(controller.state.account?.isVerified, isTrue);
    expect(controller.state.successMessage, contains('邮箱验证成功'));
  });

  test('验证码错误保留账号、请求 ID 与可修正状态', () async {
    final repository = _FakeEmailVerificationRepository(
      verifyFailure: const ApiFailure(
        userMessage: '验证码不正确，请检查后重试。',
        businessCode: 40112,
        requestId: 'verify-request-id',
      ),
    );
    final controller = EmailVerificationController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.verifyCode('123456'), isFalse);

    expect(controller.state.phase, EmailVerificationPhase.ready);
    expect(controller.state.account?.email, 'owner@example.com');
    expect(controller.state.failure?.businessCode, 40112);
    expect(controller.state.failure?.requestId, 'verify-request-id');
    expect(controller.state.isBusy, isFalse);
  });

  test('重发限流采用 Retry-After 且不泄露账号状态', () async {
    final repository = _FakeEmailVerificationRepository(
      resendFailure: const ApiFailure(
        userMessage: '操作太频繁，请稍后再试。',
        businessCode: 42900,
        retryAfter: Duration(seconds: 42),
      ),
    );
    final controller = EmailVerificationController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.requestCode(), isFalse);

    expect(controller.state.resendSecondsRemaining, 42);
    expect(controller.state.failure?.businessCode, 42900);
  });

  test('验证已受理但资料刷新失败时只允许重新确认状态', () async {
    final repository = _FakeEmailVerificationRepository(
      failFirstPostVerificationFetch: true,
    );
    final controller = EmailVerificationController(
      repository,
      autoStart: false,
    );
    addTearDown(controller.dispose);
    await controller.load();

    expect(await controller.verifyCode('654321'), isFalse);
    expect(controller.state.phase, EmailVerificationPhase.failed);
    expect(controller.state.account, isNull);

    await controller.load();
    expect(controller.state.phase, EmailVerificationPhase.ready);
    expect(controller.state.account?.isVerified, isTrue);
  });
}

class _FakeEmailVerificationRepository implements EmailVerificationRepository {
  _FakeEmailVerificationRepository({
    this.resendFailure,
    this.verifyFailure,
    this.failFirstPostVerificationFetch = false,
  });

  final ApiFailure? resendFailure;
  final ApiFailure? verifyFailure;
  bool failFirstPostVerificationFetch;
  final List<String> resends = [];
  final List<String> codes = [];
  int fetches = 0;
  bool verified = false;

  @override
  Future<EmailVerificationAccount> fetchAccount() async {
    fetches += 1;
    if (verified && failFirstPostVerificationFetch) {
      failFirstPostVerificationFetch = false;
      throw const ApiFailure(userMessage: '暂时无法连接温油站，请检查网络。');
    }
    return EmailVerificationAccount(
      email: 'owner@example.com',
      isVerified: verified,
    );
  }

  @override
  Future<void> resendCode({required String email}) async {
    resends.add(email);
    if (resendFailure != null) throw resendFailure!;
  }

  @override
  Future<void> verifyCode({required String code}) async {
    codes.add(code);
    if (verifyFailure != null) throw verifyFailure!;
    verified = true;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/data/email_verification_repository.dart';
import 'package:wenyousite_mobile/features/auth/presentation/email_verification_page.dart';

void main() {
  testWidgets('明确重发、校验验证码并在服务端事实刷新后完成', (tester) async {
    final repository = _FakeEmailVerificationRepository();
    final router = await _pumpVerificationApp(tester, repository);
    addTearDown(router.dispose);

    expect(find.textContaining('o***@example.com'), findsOneWidget);
    expect(repository.resends, isEmpty);

    await tester.tap(find.byKey(const Key('verify-email-resend')));
    await tester.pump();
    expect(repository.resends, ['owner@example.com']);
    expect(find.byKey(const Key('verify-email-code-sent')), findsOneWidget);
    expect(find.text('60 秒后可重发'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('verify-email-code')), '123');
    await tester.tap(find.byKey(const Key('verify-email-submit')));
    await tester.pump();
    expect(find.text('请输入 6 位数字验证码'), findsOneWidget);
    expect(repository.codes, isEmpty);

    await tester.enterText(
      find.byKey(const Key('verify-email-code')),
      '654321',
    );
    await tester.tap(find.byKey(const Key('verify-email-submit')));
    await tester.pump();
    await tester.pump();

    expect(repository.codes, ['654321']);
    expect(repository.fetches, 2);
    expect(find.text('邮箱已验证'), findsOneWidget);
    await tester.tap(find.byKey(const Key('verify-email-finish')));
    await tester.pumpAndSettle();
    expect(find.text('返回目标'), findsOneWidget);
  });

  testWidgets('验证码失败保留输入、专用错误和请求 ID', (tester) async {
    final repository = _FakeEmailVerificationRepository(
      verifyFailure: const ApiFailure(
        userMessage: '验证码不正确，请检查后重试。',
        businessCode: 40112,
        requestId: 'email-verify-id',
      ),
    );
    final router = await _pumpVerificationApp(tester, repository);
    addTearDown(router.dispose);

    await tester.enterText(
      find.byKey(const Key('verify-email-code')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('verify-email-submit')));
    await tester.pump();
    await tester.pump();

    expect(find.text('验证码不正确，请检查后重试。'), findsOneWidget);
    expect(find.text('请求 ID：email-verify-id'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('verify-email-code')))
          .controller!
          .text,
      '123456',
    );
  });

  testWidgets('账号状态加载失败可重试', (tester) async {
    final repository = _FakeEmailVerificationRepository(failFetchOnce: true);
    final router = await _pumpVerificationApp(tester, repository);
    addTearDown(router.dispose);

    expect(find.text('邮箱状态没有加载完成'), findsOneWidget);
    expect(find.text('请求 ID：load-email-id'), findsOneWidget);
    await tester.tap(find.byKey(const Key('verify-email-load-retry')));
    await tester.pumpAndSettle();
    expect(find.text('验证当前邮箱'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 邮箱验证表单无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final router = await _pumpVerificationApp(
        tester,
        _FakeEmailVerificationRepository(),
      );
      addTearDown(router.dispose);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('verify-email-submit')), findsOneWidget);
      expect(find.byKey(const Key('verify-email-resend')), findsOneWidget);
    });
  }
}

Future<GoRouter> _pumpVerificationApp(
  WidgetTester tester,
  EmailVerificationRepository repository,
) async {
  final router = GoRouter(
    initialLocation: '/me/security/verify-email?returnTo=%2Fhome',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('返回目标')),
      ),
      GoRoute(
        path: '/me/security/verify-email',
        builder: (context, state) => EmailVerificationPage(
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        emailVerificationRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

class _FakeEmailVerificationRepository implements EmailVerificationRepository {
  _FakeEmailVerificationRepository({
    this.failFetchOnce = false,
    this.verifyFailure,
  });

  bool failFetchOnce;
  final ApiFailure? verifyFailure;
  final List<String> resends = [];
  final List<String> codes = [];
  int fetches = 0;
  bool verified = false;

  @override
  Future<EmailVerificationAccount> fetchAccount() async {
    fetches += 1;
    if (failFetchOnce) {
      failFetchOnce = false;
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'load-email-id',
      );
    }
    return EmailVerificationAccount(
      email: 'owner@example.com',
      isVerified: verified,
    );
  }

  @override
  Future<void> resendCode({required String email}) async => resends.add(email);

  @override
  Future<void> verifyCode({required String code}) async {
    codes.add(code);
    if (verifyFailure != null) throw verifyFailure!;
    verified = true;
  }
}

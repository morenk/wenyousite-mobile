import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/auth/data/password_recovery_repository.dart';
import 'package:wenyousite_mobile/features/auth/presentation/forgot_password_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/login_page.dart';
import 'package:wenyousite_mobile/features/auth/presentation/reset_password_page.dart';

void main() {
  testWidgets('从登录找回密码、保留目标并完成重置后显示重新登录提示', (tester) async {
    final repository = _FakePasswordRecoveryRepository();
    final container = await _pumpFlow(
      tester,
      repository,
      initialLocation: '/auth/login?returnTo=%2Fcompose%2Fthread',
    );

    await tester.tap(find.byKey(const Key('login-forgot-password')));
    await tester.pumpAndSettle();
    expect(find.text('通过注册邮箱找回'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot-password-email')),
      'not-an-email',
    );
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pump();
    expect(find.text('请输入有效的邮箱地址'), findsOneWidget);
    expect(repository.codeRequests, isEmpty);

    await tester.enterText(
      find.byKey(const Key('forgot-password-email')),
      ' User@Example.COM ',
    );
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pumpAndSettle();

    expect(repository.codeRequests, ['user@example.com']);
    expect(find.text('设置新的登录密码'), findsOneWidget);
    expect(find.text('u***@example.com'), findsOneWidget);
    expect(find.byKey(const Key('reset-password-edit-email')), findsOneWidget);
    expect(find.byKey(const Key('reset-password-code-sent')), findsOneWidget);
    final sendButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('reset-password-request-code')),
    );
    expect(sendButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('reset-password-code')),
      '654321',
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-new')),
      'next-pass9',
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-confirm')),
      'different9',
    );
    await tester.ensureVisible(find.byKey(const Key('reset-password-submit')));
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pump();
    expect(find.text('两次输入的新密码不一致'), findsOneWidget);
    expect(repository.resets, isEmpty);

    await tester.enterText(
      find.byKey(const Key('reset-password-confirm')),
      'next-pass9',
    );
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pumpAndSettle();

    expect(repository.resets, [('user@example.com', '654321', 'next-pass9')]);
    expect(
      find.byKey(const Key('login-password-reset-success')),
      findsOneWidget,
    );
    expect(find.textContaining('所有旧登录终端均已退出'), findsOneWidget);
    await _disposeFlow(tester, container);
  });

  testWidgets('重置页可独立发送验证码且失败保留输入和请求 ID', (tester) async {
    final repository = _FakePasswordRecoveryRepository(
      resetFailure: const ApiFailure(
        userMessage: '验证码不正确，请检查后重试。',
        businessCode: 40112,
        requestId: 'reset-request-id',
      ),
    );
    final container = await _pumpFlow(
      tester,
      repository,
      initialLocation: '/auth/reset-password',
    );

    await tester.tap(find.byKey(const Key('reset-password-request-code')));
    await tester.pump();
    expect(find.text('请输入注册邮箱'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      ' User@Example.COM ',
    );
    await tester.tap(find.byKey(const Key('reset-password-request-code')));
    await tester.pump();
    await tester.pump();
    expect(repository.codeRequests, ['user@example.com']);

    await tester.enterText(
      find.byKey(const Key('reset-password-code')),
      '000000',
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-new')),
      'next-pass9',
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-confirm')),
      'next-pass9',
    );
    await tester.ensureVisible(find.byKey(const Key('reset-password-submit')));
    await tester.tap(find.byKey(const Key('reset-password-submit')));
    await tester.pump();
    await tester.pump();

    expect(find.text('验证码不正确，请检查后重试。'), findsOneWidget);
    expect(find.text('问题编号：reset-request-id'), findsOneWidget);
    expect(find.text('000000'), findsOneWidget);
    expect(find.text('设置新的登录密码'), findsOneWidget);
    await _disposeFlow(tester, container);
  });

  testWidgets('修改邮箱后重发失败保持编辑且不混淆上次投递目标', (tester) async {
    final repository = _FakePasswordRecoveryRepository(
      requestFailure: const ApiFailure(
        userMessage: '验证码发送失败，请稍后重试。',
        requestId: 'request-code-failed',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        passwordRecoveryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ResetPasswordPage(
            initialEmail: 'first@example.com',
            codeRecentlySent: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 61));

    await tester.tap(find.byKey(const Key('reset-password-edit-email')));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, '注册邮箱'),
      'second@example.com',
    );
    await tester.tap(find.byKey(const Key('reset-password-request-code')));
    await tester.pump();
    await tester.pump();

    expect(find.widgetWithText(TextFormField, '注册邮箱'), findsOneWidget);
    expect(find.byKey(const Key('reset-password-email-summary')), findsNothing);
    expect(find.text('second@example.com'), findsOneWidget);
    expect(find.text('f***@example.com'), findsNothing);
    expect(find.byKey(const Key('reset-password-code-sent')), findsNothing);
    expect(find.text('问题编号：request-code-failed'), findsOneWidget);
  });

  for (final width in [320.0, 360.0, 400.0, 600.0]) {
    testWidgets('$width dp 找回与重置页面无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final repository = _FakePasswordRecoveryRepository();
      final container = await _pumpFlow(
        tester,
        repository,
        initialLocation: '/auth/forgot-password',
      );
      expect(tester.takeException(), isNull);

      await tester.enterText(
        find.byKey(const Key('forgot-password-email')),
        'user@example.com',
      );
      await tester.tap(find.byKey(const Key('forgot-password-submit')));
      await tester.pumpAndSettle();

      expect(find.text('设置新的登录密码'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _disposeFlow(tester, container);
    });
  }
}

Future<ProviderContainer> _pumpFlow(
  WidgetTester tester,
  PasswordRecoveryRepository repository, {
  required String initialLocation,
}) async {
  final container = ProviderContainer(
    overrides: [
      passwordRecoveryRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWithValue(_UnusedAuthRepository()),
      tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
      sessionRemoteProvider.overrideWithValue(_UnusedSessionRemote()),
    ],
  );
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          returnTo: state.uri.queryParameters['returnTo'],
          passwordResetSucceeded: state.extra is PasswordResetLoginNotice,
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) =>
            ForgotPasswordPage(returnTo: state.uri.queryParameters['returnTo']),
      ),
      GoRoute(
        path: '/auth/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final routeData = state.extra;
          return ResetPasswordPage(
            returnTo: state.uri.queryParameters['returnTo'],
            initialEmail: routeData is PasswordResetRouteData
                ? routeData.initialEmail
                : null,
            codeRecentlySent:
                routeData is PasswordResetRouteData &&
                routeData.codeRecentlySent,
          );
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _disposeFlow(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  container.dispose();
}

class _FakePasswordRecoveryRepository implements PasswordRecoveryRepository {
  _FakePasswordRecoveryRepository({this.resetFailure, this.requestFailure});

  final ApiFailure? resetFailure;
  final ApiFailure? requestFailure;
  final List<String> codeRequests = [];
  final List<(String, String, String)> resets = [];

  @override
  Future<void> requestCode({required String email}) async {
    codeRequests.add(email);
    if (requestFailure != null) throw requestFailure!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resets.add((email, code, newPassword));
    if (resetFailure != null) throw resetFailure!;
  }
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) => throw UnimplementedError();

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) => throw UnimplementedError();
}

class _MemoryTokenStore implements TokenStore {
  @override
  Future<void> clear() async {}

  @override
  Future<SessionTokens?> read() async => null;

  @override
  Future<void> write(SessionTokens tokens) async {}
}

class _UnusedSessionRemote implements SessionRemote {
  @override
  Future<void> logout(SessionTokens tokens) => throw UnimplementedError();

  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw UnimplementedError();
}

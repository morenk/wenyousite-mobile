import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/settings/data/credential_security_repository.dart';
import 'package:wenyousite_mobile/features/settings/presentation/change_email_page.dart';

void main() {
  testWidgets('校验新邮箱后确认换绑、清除会话并进入登录页', (tester) async {
    final repository = _FakeRepository();
    final harness = await _pumpPage(tester, repository);

    await tester.enterText(
      find.byKey(const Key('change-email-password')),
      'current123',
    );
    await tester.enterText(
      find.byKey(const Key('change-email-address')),
      'not-an-email',
    );
    await tester.tap(find.byKey(const Key('change-email-request-code')));
    await tester.pump();
    expect(find.text('请输入有效的邮箱地址'), findsOneWidget);
    expect(repository.emailCodeRequests, isEmpty);

    await tester.enterText(
      find.byKey(const Key('change-email-address')),
      '  NEXT@Example.COM ',
    );
    await tester.tap(find.byKey(const Key('change-email-request-code')));
    await tester.pump();
    await tester.pump();

    expect(repository.emailCodeRequests, [('next@example.com', 'current123')]);
    expect(find.textContaining('next@example.com'), findsOneWidget);
    expect(find.text('60 秒后可重发'), findsOneWidget);
    final resendButton = tester.widget<TextButton>(
      find.byKey(const Key('change-email-resend-code')),
    );
    expect(resendButton.onPressed, isNull);

    await tester.enterText(find.byKey(const Key('change-email-code')), '12345');
    await tester.tap(find.byKey(const Key('change-email-verify')));
    await tester.pump();
    expect(find.text('请输入 6 位数字验证码'), findsOneWidget);
    expect(repository.emailVerifications, isEmpty);

    await tester.enterText(
      find.byKey(const Key('change-email-code')),
      '654321',
    );
    await tester.tap(find.byKey(const Key('change-email-verify')));
    await tester.pumpAndSettle();

    expect(repository.emailVerifications, [('next@example.com', '654321')]);
    expect(harness.tokenStore.value, isNull);
    expect(find.text('登录页 /me'), findsOneWidget);
  });

  testWidgets('验证码发送失败保留输入、请求 ID 与关闭入口', (tester) async {
    final repository = _FakeRepository(
      requestFailure: const ApiFailure(
        userMessage: '验证码发送没有完成。',
        requestId: 'email-request-id',
      ),
    );
    final harness = await _pumpPage(tester, repository);

    await tester.enterText(
      find.byKey(const Key('change-email-password')),
      'current123',
    );
    await tester.enterText(
      find.byKey(const Key('change-email-address')),
      'next@example.com',
    );
    await tester.tap(find.byKey(const Key('change-email-request-code')));
    await tester.pump();
    await tester.pump();

    expect(find.text('验证码发送没有完成。'), findsOneWidget);
    expect(find.text('请求 ID：email-request-id'), findsOneWidget);
    expect(find.text('next@example.com'), findsOneWidget);
    expect(harness.tokenStore.value, isNotNull);

    await tester.tap(find.byKey(const Key('change-email-error-dismiss')));
    await tester.pump();
    expect(find.text('验证码发送没有完成。'), findsNothing);
  });

  testWidgets('验证码失败保留目标邮箱并允许修改目标', (tester) async {
    final repository = _FakeRepository(
      verifyFailure: const ApiFailure(
        userMessage: '验证码不正确。',
        requestId: 'verify-request-id',
      ),
    );
    await _pumpPage(tester, repository);
    await _reachVerifyStep(tester);

    await tester.enterText(
      find.byKey(const Key('change-email-code')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('change-email-verify')));
    await tester.pump();
    await tester.pump();

    expect(find.text('验证码不正确。'), findsOneWidget);
    expect(find.text('请求 ID：verify-request-id'), findsOneWidget);
    expect(find.textContaining('next@example.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('change-email-edit-address')));
    await tester.pump();
    expect(find.byKey(const Key('change-email-address')), findsOneWidget);
    expect(find.text('next@example.com'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 更换邮箱两步页面无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeRepository());
      expect(tester.takeException(), isNull);

      await _reachVerifyStep(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('确认更换邮箱'), findsOneWidget);

      await tester.tap(find.byKey(const Key('change-email-edit-address')));
      await tester.pump();
    });
  }
}

Future<void> _reachVerifyStep(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('change-email-password')),
    'current123',
  );
  await tester.enterText(
    find.byKey(const Key('change-email-address')),
    'next@example.com',
  );
  await tester.tap(find.byKey(const Key('change-email-request-code')));
  await tester.pump();
  await tester.pump();
}

Future<_Harness> _pumpPage(
  WidgetTester tester,
  CredentialSecurityRepository repository,
) async {
  final tokenStore = _MemoryTokenStore();
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(tokenStore),
      sessionRemoteProvider.overrideWithValue(_UnusedSessionRemote()),
      credentialSecurityRepositoryProvider.overrideWithValue(repository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  final router = GoRouter(
    initialLocation: '/email',
    redirect: (context, state) {
      final authenticated = container
          .read(sessionControllerProvider)
          .isAuthenticated;
      if (!authenticated && state.matchedLocation == '/email') {
        return Uri(
          path: '/auth/login',
          queryParameters: {'returnTo': state.uri.toString()},
        ).toString();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/email',
        builder: (context, state) => const ChangeEmailPage(),
      ),
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => Scaffold(
          body: Text('登录页 ${state.uri.queryParameters['returnTo']}'),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(container.dispose);
  final sessionSubscription = container.listen<SessionState>(
    sessionControllerProvider,
    (_, _) => router.refresh(),
  );
  addTearDown(sessionSubscription.close);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return _Harness(tokenStore);
}

class _Harness {
  const _Harness(this.tokenStore);

  final _MemoryTokenStore tokenStore;
}

class _FakeRepository implements CredentialSecurityRepository {
  _FakeRepository({this.requestFailure, this.verifyFailure});

  final ApiFailure? requestFailure;
  final ApiFailure? verifyFailure;
  final List<(String, String)> emailCodeRequests = [];
  final List<(String, String)> emailVerifications = [];

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) => throw UnimplementedError();

  @override
  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  }) async {
    if (requestFailure != null) throw requestFailure!;
    emailCodeRequests.add((newEmail, oldPassword));
  }

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  }) async {
    emailVerifications.add((newEmail, code));
    if (verifyFailure != null) throw verifyFailure!;
  }
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

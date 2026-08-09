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
import 'package:wenyousite_mobile/features/settings/presentation/change_password_page.dart';

void main() {
  testWidgets('本地校验通过后修改密码、清除会话并进入登录页', (tester) async {
    final repository = _FakeRepository();
    final harness = await _pumpPage(tester, repository);

    await tester.enterText(
      find.byKey(const Key('change-password-old')),
      'current123',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-new')),
      'short',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'short',
    );
    await tester.ensureVisible(find.byKey(const Key('change-password-submit')));
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pump();
    expect(find.text('密码需要 8–100 位'), findsOneWidget);
    expect(repository.passwordChanges, isEmpty);

    await tester.enterText(
      find.byKey(const Key('change-password-new')),
      'next-pass9',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'different9',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pump();
    expect(find.text('两次输入的新密码不一致'), findsOneWidget);
    expect(repository.passwordChanges, isEmpty);

    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'next-pass9',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pumpAndSettle();

    expect(repository.passwordChanges, [('current123', 'next-pass9')]);
    expect(harness.tokenStore.value, isNull);
    expect(find.text('登录页 /me'), findsOneWidget);
  });

  testWidgets('服务端拒绝修改时保留页面与请求 ID', (tester) async {
    final repository = _FakeRepository(
      passwordFailure: const ApiFailure(
        userMessage: '当前密码不正确。',
        requestId: 'password-request-id',
      ),
    );
    final harness = await _pumpPage(tester, repository);

    await tester.enterText(
      find.byKey(const Key('change-password-old')),
      'wrong-password',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-new')),
      'next-pass9',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'next-pass9',
    );
    await tester.ensureVisible(find.byKey(const Key('change-password-submit')));
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('当前密码不正确。'), findsOneWidget);
    expect(find.text('请求 ID：password-request-id'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
    expect(harness.tokenStore.value, isNotNull);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 修改密码页无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('设置新密码'), findsOneWidget);
    });
  }
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
    initialLocation: '/password',
    redirect: (context, state) {
      final authenticated = container
          .read(sessionControllerProvider)
          .isAuthenticated;
      if (!authenticated && state.matchedLocation == '/password') {
        return Uri(
          path: '/auth/login',
          queryParameters: {'returnTo': state.uri.toString()},
        ).toString();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/password',
        builder: (context, state) => const ChangePasswordPage(),
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
  _FakeRepository({this.passwordFailure});

  final ApiFailure? passwordFailure;
  final List<(String, String)> passwordChanges = [];

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (passwordFailure != null) throw passwordFailure!;
    passwordChanges.add((oldPassword, newPassword));
  }

  @override
  Future<void> requestEmailChangeCode({
    required String newEmail,
    required String oldPassword,
  }) => throw UnimplementedError();

  @override
  Future<void> verifyEmailChange({
    required String newEmail,
    required String code,
  }) => throw UnimplementedError();
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

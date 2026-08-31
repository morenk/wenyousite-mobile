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
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';
import 'package:wenyousite_mobile/features/settings/presentation/delete_account_page.dart';

void main() {
  testWidgets('确认短语和最终确认通过后注销并回到游客首页', (tester) async {
    final repository = _FakeAccountDeletionRepository();
    final harness = await _pumpPage(tester, repository);

    await tester.ensureVisible(find.byKey(const Key('delete-account-submit')));
    await tester.tap(find.byKey(const Key('delete-account-submit')));
    await tester.pump();
    expect(find.text('请输入完整的“注销账号”'), findsOneWidget);
    expect(repository.calls, 0);

    await tester.enterText(
      find.byKey(const Key('delete-account-phrase')),
      '注销账号',
    );
    await tester.tap(find.byKey(const Key('delete-account-submit')));
    await tester.pumpAndSettle();
    expect(find.text('最后确认注销账号'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(repository.calls, 0);

    await tester.tap(find.byKey(const Key('delete-account-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-account-confirm')));
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(harness.tokenStore.value, isNull);
    expect(find.text('游客首页'), findsOneWidget);
  });

  testWidgets('服务端失败保留确认文字、会话和请求 ID', (tester) async {
    final repository = _FakeAccountDeletionRepository(
      failure: const ApiFailure(
        userMessage: '账号注销失败，请稍后重试。',
        requestId: 'delete-account-id',
      ),
    );
    final harness = await _pumpPage(tester, repository);
    await _confirmDeletion(tester);

    expect(find.text('账号注销失败，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('问题编号：delete-account-id'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('delete-account-phrase')))
          .controller!
          .text,
      '注销账号',
    );
    expect(harness.tokenStore.value, isNotNull);
  });

  testWidgets('远端已注销时只重试本机清理', (tester) async {
    final repository = _FakeAccountDeletionRepository();
    final harness = await _pumpPage(tester, repository, failFirstClear: true);
    await _confirmDeletion(tester);

    expect(repository.calls, 1);
    expect(
      find.byKey(const Key('delete-account-retry-local-cleanup')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('delete-account-retry-local-cleanup')),
    );
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(harness.tokenStore.value, isNull);
    expect(find.text('游客首页'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 注销页面无布局溢出', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 820);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await _pumpPage(tester, _FakeAccountDeletionRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('这是不可恢复的操作'), findsOneWidget);
      expect(find.byKey(const Key('delete-account-submit')), findsOneWidget);
    });
  }
}

Future<void> _confirmDeletion(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('delete-account-phrase')),
    '注销账号',
  );
  await tester.ensureVisible(find.byKey(const Key('delete-account-submit')));
  await tester.tap(find.byKey(const Key('delete-account-submit')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('delete-account-confirm')));
  await tester.pumpAndSettle();
}

Future<_Harness> _pumpPage(
  WidgetTester tester,
  AccountDeletionRepository repository, {
  bool failFirstClear = false,
}) async {
  final tokenStore = _MemoryTokenStore(failFirstClear: failFirstClear);
  final container = ProviderContainer(
    overrides: [
      tokenStoreProvider.overrideWithValue(tokenStore),
      sessionRemoteProvider.overrideWithValue(_UnusedSessionRemote()),
      accountDeletionRepositoryProvider.overrideWithValue(repository),
    ],
  );
  await container
      .read(sessionControllerProvider.notifier)
      .authenticate(_tokens);
  final router = GoRouter(
    initialLocation: '/delete-account',
    redirect: (context, state) {
      final authenticated = container
          .read(sessionControllerProvider)
          .isAuthenticated;
      if (!authenticated && state.matchedLocation == '/delete-account') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('游客首页')),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (context, state) => const DeleteAccountPage(),
      ),
    ],
  );
  final sessionSubscription = container.listen<SessionState>(
    sessionControllerProvider,
    (_, _) => router.refresh(),
  );
  addTearDown(sessionSubscription.close);
  addTearDown(router.dispose);
  addTearDown(container.dispose);
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

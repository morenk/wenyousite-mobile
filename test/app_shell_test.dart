import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('兼容契约下游客直接进入四栏首页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('公网开发环境已连接'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

    await tester.tap(find.text('搜索'));
    await tester.pumpAndSettle();
    expect(find.text('搜索模块已进入规划'), findsOneWidget);
  });

  testWidgets('未知契约主版本显示不可绕过的升级页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            _FixedMetaRepository(contractVersion: '4.0.0'),
          ),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('需要升级温油站'), findsOneWidget);
    expect(find.textContaining('服务端为 4.0.0'), findsOneWidget);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('启动失败展示请求 ID 并可重试', (tester) async {
    final repository = _RetryMetaRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂时连不上温油站'), findsOneWidget);
    expect(find.text('请求 ID：startup-request-id'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('公网开发环境已连接'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('游客创建主题先登录，成功后恢复创建目标', (tester) async {
    final tokenStore = _MemoryTokenStore();
    final authRepository = _SuccessfulAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.text('欢迎回到温油站'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login-account')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('创建主题'), findsOneWidget);
    expect(authRepository.lastAccount, 'user@example.com');
    expect(tokenStore.value?.accessToken, 'access-token');
    expect(tokenStore.value?.refreshToken, 'refresh-token');
  });

  testWidgets('已登录用户从我的页安全退出并回到游客状态', (tester) async {
    final tokenStore = _MemoryTokenStore(_tokens);
    final sessionRemote = _FakeSessionRemote();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(tokenStore),
          sessionRemoteProvider.overrideWithValue(sessionRemote),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('已恢复登录会话'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();
    expect(find.text('退出当前账号？'), findsOneWidget);
    await tester.tap(find.byKey(const Key('logout-confirm')));
    await tester.pumpAndSettle();

    expect(sessionRemote.logoutCalls, 1);
    expect(tokenStore.value, isNull);
    expect(find.text('当前以游客身份浏览'), findsOneWidget);
    expect(find.text('已安全退出当前账号。'), findsOneWidget);
  });

  testWidgets('服务端退出失败保留会话并展示请求 ID 与本机后备', (tester) async {
    final tokenStore = _MemoryTokenStore(_tokens);
    final sessionRemote = _FakeSessionRemote(
      onLogout: (_) => throw const ApiFailure(
        userMessage: '服务器暂时开小差了，请稍后重试。',
        requestId: 'logout-request-id',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(tokenStore),
          sessionRemoteProvider.overrideWithValue(sessionRemote),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout-confirm')));
    await tester.pumpAndSettle();

    expect(tokenStore.value, same(_tokens));
    expect(find.text('重试安全退出'), findsOneWidget);
    expect(find.text('请求 ID：logout-request-id'), findsOneWidget);
    expect(find.byKey(const Key('logout-local-only')), findsOneWidget);
  });

  testWidgets('会话被撤销时进入登录页并可继续游客浏览', (tester) async {
    final container = ProviderContainer(
      overrides: [
        metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
        tokenStoreProvider.overrideWithValue(_MemoryTokenStore(_tokens)),
        sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const WenyouApp()),
    );
    await tester.pumpAndSettle();

    await container
        .read(sessionControllerProvider.notifier)
        .invalidate(SessionInvalidationReason.revoked);
    await tester.pumpAndSettle();

    expect(find.text('欢迎回到温油站'), findsOneWidget);
    expect(find.text('当前登录已被撤销，请重新登录。'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue-as-guest')));
    await tester.pumpAndSettle();
    expect(find.text('公网开发环境已连接'), findsOneWidget);
  });
}

class _CompatibleMetaRepository implements MetaRepository {
  @override
  Future<ContractInfo> fetch() async {
    return const ContractInfo(
      contractVersion: '3.0.0-dev.test',
      markdownContractVersion: 2,
    );
  }
}

class _FixedMetaRepository implements MetaRepository {
  _FixedMetaRepository({required this.contractVersion});

  final String contractVersion;

  @override
  Future<ContractInfo> fetch() async {
    return ContractInfo(
      contractVersion: contractVersion,
      markdownContractVersion: 2,
    );
  }
}

class _RetryMetaRepository implements MetaRepository {
  int calls = 0;

  @override
  Future<ContractInfo> fetch() async {
    calls += 1;
    if (calls == 1) {
      throw const ApiFailure(
        userMessage: '暂时无法连接温油站，请检查网络。',
        requestId: 'startup-request-id',
      );
    }
    return const ContractInfo(
      contractVersion: '3.0.0-dev.test',
      markdownContractVersion: 2,
    );
  }
}

class _SuccessfulAuthRepository implements AuthRepository {
  String? lastAccount;

  @override
  Future<SessionTokens> login({
    required String account,
    required String password,
  }) async {
    lastAccount = account;
    return const SessionTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
    );
  }
}

const _tokens = SessionTokens(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

class _MemoryTokenStore implements TokenStore {
  _MemoryTokenStore([this.value]);

  SessionTokens? value;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<SessionTokens?> read() async => value;

  @override
  Future<void> write(SessionTokens tokens) async => value = tokens;
}

class _FakeSessionRemote implements SessionRemote {
  _FakeSessionRemote({this.onLogout});

  final Future<void> Function(SessionTokens tokens)? onLogout;
  int logoutCalls = 0;

  @override
  Future<void> logout(SessionTokens tokens) {
    logoutCalls += 1;
    return onLogout?.call(tokens) ?? Future.value();
  }

  @override
  Future<SessionTokens> refresh(String refreshToken) async => _tokens;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/models/cursor_page.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/core/network/session_remote.dart';
import 'package:wenyousite_mobile/core/storage/token_store.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/home/domain/home_models.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/notifications/domain/notification_models.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/users/domain/me_profile_models.dart';

void main() {
  testWidgets('兼容契约下游客直接进入四栏首页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('发现主题'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('通知'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

    await tester.tap(find.text('搜索'));
    await tester.pumpAndSettle();
    expect(find.text('输入关键词开始搜索'), findsOneWidget);
  });

  testWidgets('登录用户底栏展示服务端未读角标并可进入通知列表', (tester) async {
    final notifications = _EmptyNotificationRepository(unreadCount: 7);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore(_tokens)),
          sessionRemoteProvider.overrideWithValue(_FakeSessionRemote()),
          notificationRepositoryProvider.overrideWithValue(notifications),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('7'), findsWidgets);
    await tester.tap(find.text('通知'));
    await tester.pumpAndSettle();
    expect(find.text('暂无通知'), findsOneWidget);
    expect(notifications.fetchCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('未知契约主版本显示不可绕过的升级页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            _FixedMetaRepository(contractVersion: '5.0.0'),
          ),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('需要升级温油站'), findsOneWidget);
    expect(find.textContaining('服务端为 5.0.0'), findsOneWidget);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('启动失败展示请求 ID 并可重试', (tester) async {
    final repository = _RetryMetaRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂时连不上温油站'), findsOneWidget);
    expect(find.text('请求 ID：startup-request-id'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('发现主题'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('低于最低支持构建时优先强制更新且不可跳过', (tester) async {
    final updateService = _FakeMobileUpdateService(build: 7);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            _FixedMetaRepository(
              contractVersion: '5.0.0',
              android: const MobilePlatformPolicy(
                minimumSupportedBuild: 8,
                recommendedBuild: 10,
                updateUrl: _androidUpdateUrl,
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(updateService),
          recommendedUpdateDismissStoreProvider.overrideWithValue(
            _MemoryRecommendedUpdateDismissStore(),
          ),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.text('当前 0.3.0+7'), findsOneWidget);
    expect(find.text('可用构建 10'), findsOneWidget);
    expect(find.byKey(const Key('mobile-update-dismiss')), findsNothing);

    await tester.tap(find.byKey(const Key('mobile-update-start')));
    await tester.pumpAndSettle();
    expect(find.text('系统安装器已打开，请按提示完成更新。'), findsOneWidget);
    expect(updateService.launchCalls, 1);
  });

  testWidgets('推荐更新可跳过并记住该目标构建', (tester) async {
    final dismissStore = _MemoryRecommendedUpdateDismissStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            _FixedMetaRepository(
              contractVersion: '4.4.0-dev.test',
              android: const MobilePlatformPolicy(
                recommendedBuild: 10,
                updateUrl: _androidUpdateUrl,
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(
            _FakeMobileUpdateService(build: 7),
          ),
          recommendedUpdateDismissStoreProvider.overrideWithValue(dismissStore),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('温油站有新版本'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
    await tester.pumpAndSettle();

    expect(find.text('发现主题'), findsOneWidget);
    expect(dismissStore.dismissedBuild, 10);
  });

  testWidgets('iOS 推荐更新交给 TestFlight', (tester) async {
    final updateService = _FakeMobileUpdateService(
      build: 7,
      clientPlatform: MobileClientPlatform.ios,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            _FixedMetaRepository(
              contractVersion: '4.4.0-dev.test',
              ios: const MobilePlatformPolicy(
                recommendedBuild: 8,
                updateUrl: 'https://testflight.apple.com/join/example',
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(updateService),
          recommendedUpdateDismissStoreProvider.overrideWithValue(
            _MemoryRecommendedUpdateDismissStore(),
          ),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('前往 TestFlight'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mobile-update-start')));
    await tester.pumpAndSettle();
    expect(find.text('TestFlight 已打开，请在那里完成更新后返回。'), findsOneWidget);
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
          notificationRepositoryProvider.overrideWithValue(
            _EmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
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

  for (final protectedLocation in [
    '/me/blocks',
    '/me/bookmarks',
    '/me/security/sessions',
    '/me/security/password',
    '/me/security/email',
  ]) {
    testWidgets('游客打开 $protectedLocation 先登录并保留原目标', (tester) async {
      final container = ProviderContainer(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WenyouApp(),
        ),
      );
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);
      router.go(protectedLocation);
      await tester.pumpAndSettle();

      expect(find.text('欢迎回到温油站'), findsOneWidget);
      expect(
        router
            .routerDelegate
            .currentConfiguration
            .uri
            .queryParameters['returnTo'],
        protectedLocation,
      );
    });
  }

  testWidgets('游客完成邮箱注册后建立移动会话并恢复创建目标', (tester) async {
    final tokenStore = _MemoryTokenStore();
    final authRepository = _SuccessfulAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(_CompatibleMetaRepository()),
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryProvider.overrideWithValue(authRepository),
          notificationRepositoryProvider.overrideWithValue(
            _EmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login-register')));
    await tester.pumpAndSettle();
    expect(find.text('创建温油站账号'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('register-email')),
      'new-user@example.com',
    );
    await tester.tap(find.byKey(const Key('register-request-code')));
    await tester.pumpAndSettle();
    expect(find.textContaining('验证码已发送至 new-user@example.com'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('register-code')), '123456');
    await tester.enterText(find.byKey(const Key('register-username')), '新用户2');
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password')),
      'password123',
    );
    final completeButton = find.byKey(const Key('register-complete'));
    await tester.ensureVisible(completeButton);
    await tester.pumpAndSettle();
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(find.text('创建主题'), findsOneWidget);
    expect(authRepository.lastRegistrationEmail, 'new-user@example.com');
    expect(authRepository.lastCode, '123456');
    expect(authRepository.lastUsername, '新用户2');
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
          notificationRepositoryProvider.overrideWithValue(
            _EmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
          meProfileRepositoryProvider.overrideWithValue(
            _FakeMeProfileRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('温柔测试员'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const Key('logout-submit')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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
          notificationRepositoryProvider.overrideWithValue(
            _EmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
          meProfileRepositoryProvider.overrideWithValue(
            _FakeMeProfileRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('logout-submit')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
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
        notificationRepositoryProvider.overrideWithValue(
          _EmptyNotificationRepository(),
        ),
        homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
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
    expect(find.text('发现主题'), findsOneWidget);
  });

  for (final width in [360.0, 400.0, 600.0]) {
    testWidgets('$width dp 下启动状态、应用壳、登录和注册无溢出且主操作可触控', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metaRepositoryProvider.overrideWithValue(_RetryMetaRepository()),
            tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
            homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
          ],
          child: const WenyouApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.widgetWithText(FilledButton, '重试')).height,
        greaterThanOrEqualTo(48),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            metaRepositoryProvider.overrideWithValue(
              _CompatibleMetaRepository(),
            ),
            tokenStoreProvider.overrideWithValue(_MemoryTokenStore()),
            homeRepositoryProvider.overrideWithValue(_EmptyHomeRepository()),
          ],
          child: const WenyouApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('login-submit'))).height,
        greaterThanOrEqualTo(48),
      );

      await tester.tap(find.byKey(const Key('login-register')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('register-request-code'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  }
}

class _CompatibleMetaRepository implements MetaRepository {
  @override
  Future<ContractInfo> fetch() async {
    return const ContractInfo(
      contractVersion: '4.4.0-dev.test',
      markdownContractVersion: 2,
    );
  }
}

class _EmptyHomeRepository implements HomeRepository {
  @override
  Future<List<HomeCategory>> fetchCategories() async => const [];

  @override
  Future<CursorPage<HomeThreadCardModel>> fetchThreads({
    required HomeFeedQuery query,
    String? cursor,
    int limit = 20,
  }) async {
    return const CursorPage(items: [], hasMore: false);
  }
}

class _FakeMeProfileRepository implements MeProfileRepository {
  @override
  Future<MeProfileModel> fetchMe() async => _meProfile;

  @override
  Future<MeProfileUpdateResult> updateMe(MeProfilePatch patch) {
    throw UnimplementedError();
  }
}

final _meProfile = MeProfileModel(
  id: 'user-1',
  email: 'owner@example.com',
  username: '温柔测试员',
  level: 4,
  experience: 150,
  currentLevelExperience: 100,
  nextLevelExperience: 200,
  receivedTipTotal: '18',
  receivedTipCount: 6,
  showRecentReplies: true,
  showPlayedThreads: true,
  showBookmarks: true,
  emailVerified: true,
  followingCount: 7,
  followerCount: 9,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 10),
);

class _FixedMetaRepository implements MetaRepository {
  _FixedMetaRepository({
    required this.contractVersion,
    this.android = const MobilePlatformPolicy(),
    this.ios = const MobilePlatformPolicy(),
  });

  final String contractVersion;
  final MobilePlatformPolicy android;
  final MobilePlatformPolicy ios;

  @override
  Future<ContractInfo> fetch() async {
    return ContractInfo(
      contractVersion: contractVersion,
      markdownContractVersion: 2,
      android: android,
      ios: ios,
    );
  }
}

class _FakeMobileUpdateService implements MobileUpdateService {
  _FakeMobileUpdateService({
    required this.build,
    this.clientPlatform = MobileClientPlatform.android,
  });

  final int build;
  final MobileClientPlatform clientPlatform;
  int launchCalls = 0;

  @override
  MobileClientPlatform get platform => clientPlatform;

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    return InstalledAppInfo(platform: platform, version: '0.3.0', build: build);
  }

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(double progress) onProgress,
  }) async {
    launchCalls += 1;
    onProgress(1);
    return platform == MobileClientPlatform.ios
        ? UpdateLaunchResult.externalPageOpened
        : UpdateLaunchResult.installerOpened;
  }
}

class _MemoryRecommendedUpdateDismissStore
    implements RecommendedUpdateDismissStore {
  int? dismissedBuild;

  @override
  Future<void> dismiss(MobileClientPlatform platform, int build) async {
    dismissedBuild = build;
  }

  @override
  Future<bool> isDismissed(MobileClientPlatform platform, int build) async {
    return dismissedBuild == build;
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
      contractVersion: '4.4.0-dev.test',
      markdownContractVersion: 2,
    );
  }
}

class _SuccessfulAuthRepository implements AuthRepository {
  String? lastAccount;
  String? lastRegistrationEmail;
  String? lastCode;
  String? lastUsername;

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

  @override
  Future<RegistrationCodeInfo> requestRegistrationCode({
    required String email,
  }) async {
    lastRegistrationEmail = email;
    return const RegistrationCodeInfo(expiresIn: Duration(minutes: 15));
  }

  @override
  Future<SessionTokens> completeRegistration({
    required String email,
    required String code,
    required String username,
    required String password,
  }) async {
    lastRegistrationEmail = email;
    lastCode = code;
    lastUsername = username;
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

const _androidUpdateUrl =
    'https://wenyou.site/downloads/mobile/android/app.apk';

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

class _EmptyNotificationRepository implements NotificationRepository {
  _EmptyNotificationRepository({this.unreadCount = 0});

  final int unreadCount;
  int fetchCalls = 0;

  @override
  Future<CursorPage<NotificationListItem>> fetchPage({
    NotificationFilter filter = NotificationFilter.all,
    String? cursor,
  }) async {
    fetchCalls += 1;
    return CursorPage(items: const [], hasMore: false);
  }

  @override
  Future<int> fetchUnreadCount() async => unreadCount;

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> setReadStatus(String id, {required bool isRead}) async {}
}

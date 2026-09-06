import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';
import 'package:wenyousite_mobile/app/app_router.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/users/data/me_profile_repository.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'app_shell_test_support.dart';

void registerAppShellAuthNavigationCases() {
  testWidgets('当前版本仍可用而推荐安装包未就绪时直接进入应用', (tester) async {
    final updateService = AppShellTestFakeMobileUpdateService(
      build: 7,
      releaseAvailable: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.0.0',
              android: const MobilePlatformPolicy(
                recommendedBuild: 10,
                updateUrl: appShellTestAndroidUpdateUrl,
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(updateService),
          recommendedUpdateDismissStoreProvider.overrideWithValue(
            AppShellTestMemoryRecommendedUpdateDismissStore(),
          ),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(find.byKey(const Key('recommended-update-banner')), findsNothing);
  });

  testWidgets('iOS 推荐更新交给 TestFlight', (tester) async {
    final updateService = AppShellTestFakeMobileUpdateService(
      build: 7,
      clientPlatform: MobileClientPlatform.ios,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.0.0-dev.test',
              ios: const MobilePlatformPolicy(
                recommendedBuild: 8,
                updateUrl: 'https://testflight.apple.com/join/example',
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(updateService),
          recommendedUpdateDismissStoreProvider.overrideWithValue(
            AppShellTestMemoryRecommendedUpdateDismissStore(),
          ),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
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
    final tokenStore = AppShellTestMemoryTokenStore();
    final authRepository = AppShellTestSuccessfulAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryProvider.overrideWithValue(authRepository),
          notificationRepositoryProvider.overrideWithValue(
            AppShellTestEmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
          walletRepositoryProvider.overrideWithValue(
            AppShellTestNoopWalletRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('global-publish')));
    await tester.pumpAndSettle();
    expect(find.text('创建可持续讨论的共同创作主题'), findsNothing);
    expect(find.text('分享短文字或最多九张图片'), findsNothing);
    await tester.tap(find.byKey(const Key('global-publish-thread')));
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

    expect(find.text('写主题'), findsOneWidget);
    expect(authRepository.lastAccount, 'user@example.com');
    expect(tokenStore.value?.accessToken, 'access-token');
    expect(tokenStore.value?.refreshToken, 'refresh-token');
  });

  for (final protectedLocation in [
    '/me/edit',
    '/me/settings',
    '/me/blocks',
    '/me/bookmarks',
    '/me/stickers',
    '/me/security/sessions',
    '/me/security/password',
    '/me/security/email',
  ]) {
    testWidgets('游客打开 $protectedLocation 先登录并保留原目标', (tester) async {
      final container = ProviderContainer(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
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
    final tokenStore = AppShellTestMemoryTokenStore();
    final authRepository = AppShellTestSuccessfulAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(tokenStore),
          authRepositoryProvider.overrideWithValue(authRepository),
          notificationRepositoryProvider.overrideWithValue(
            AppShellTestEmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
          walletRepositoryProvider.overrideWithValue(
            AppShellTestNoopWalletRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('global-publish')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('global-publish-thread')));
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

    expect(find.text('写主题'), findsOneWidget);
    expect(authRepository.lastRegistrationEmail, 'new-user@example.com');
    expect(authRepository.lastCode, '123456');
    expect(authRepository.lastUsername, '新用户2');
    expect(tokenStore.value?.refreshToken, 'refresh-token');
  });

  testWidgets('已登录用户从我的页安全退出并回到游客状态', (tester) async {
    final tokenStore = AppShellTestMemoryTokenStore(appShellTestTokens);
    final sessionRemote = AppShellTestFakeSessionRemote();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(tokenStore),
          sessionRemoteProvider.overrideWithValue(sessionRemote),
          notificationRepositoryProvider.overrideWithValue(
            AppShellTestEmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
          meProfileRepositoryProvider.overrideWithValue(
            AppShellTestFakeMeProfileRepository(),
          ),
          walletRepositoryProvider.overrideWithValue(
            AppShellTestNoopWalletRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('温柔测试员'), findsWidgets);
    await tester.tap(find.byKey(const Key('me-open-settings')));
    await tester.pumpAndSettle();

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
    final tokenStore = AppShellTestMemoryTokenStore(appShellTestTokens);
    final sessionRemote = AppShellTestFakeSessionRemote(
      onLogout: (_) => throw const ApiFailure(
        userMessage: '服务器暂时开小差了，请稍后重试。',
        requestId: 'logout-request-id',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(tokenStore),
          sessionRemoteProvider.overrideWithValue(sessionRemote),
          notificationRepositoryProvider.overrideWithValue(
            AppShellTestEmptyNotificationRepository(),
          ),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
          meProfileRepositoryProvider.overrideWithValue(
            AppShellTestFakeMeProfileRepository(),
          ),
          walletRepositoryProvider.overrideWithValue(
            AppShellTestNoopWalletRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('me-open-settings')));
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

    expect(tokenStore.value, same(appShellTestTokens));
    expect(find.text('重试安全退出'), findsOneWidget);
    expect(find.textContaining('问题编号：logout-request-id'), findsOneWidget);
    expect(find.byKey(const Key('logout-local-only')), findsOneWidget);
  });

  testWidgets('会话被撤销时进入登录页并可继续游客浏览', (tester) async {
    final container = ProviderContainer(
      overrides: [
        metaRepositoryProvider.overrideWithValue(
          AppShellTestCompatibleMetaRepository(),
        ),
        tokenStoreProvider.overrideWithValue(
          AppShellTestMemoryTokenStore(appShellTestTokens),
        ),
        sessionRemoteProvider.overrideWithValue(
          AppShellTestFakeSessionRemote(),
        ),
        notificationRepositoryProvider.overrideWithValue(
          AppShellTestEmptyNotificationRepository(),
        ),
        homeRepositoryProvider.overrideWithValue(
          AppShellTestEmptyHomeRepository(),
        ),
        walletRepositoryProvider.overrideWithValue(
          AppShellTestNoopWalletRepository(),
        ),
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
    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
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
            metaRepositoryProvider.overrideWithValue(
              AppShellTestRetryMetaRepository(),
            ),
            tokenStoreProvider.overrideWithValue(
              AppShellTestMemoryTokenStore(),
            ),
            homeRepositoryProvider.overrideWithValue(
              AppShellTestEmptyHomeRepository(),
            ),
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
              AppShellTestCompatibleMetaRepository(),
            ),
            tokenStoreProvider.overrideWithValue(
              AppShellTestMemoryTokenStore(),
            ),
            homeRepositoryProvider.overrideWithValue(
              AppShellTestEmptyHomeRepository(),
            ),
          ],
          child: const WenyouApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('global-publish')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('global-publish-thread')));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('login-submit'))).height,
        greaterThanOrEqualTo(48),
      );
      appShellTestExpectFoundationPictureSize(
        tester,
        WenyouIconIds.identityMember,
        WenyouIconContract.defaultSize,
      );

      await tester.tap(find.byKey(const Key('login-register')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('register-request-code'))).height,
        greaterThanOrEqualTo(48),
      );
      appShellTestExpectFoundationPictureSize(
        tester,
        WenyouIconIds.statusMail,
        WenyouIconContract.defaultSize,
      );
    });
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/startup_gate.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';
import 'package:wenyousite_mobile/features/notifications/data/notification_repository.dart';
import 'package:wenyousite_mobile/features/wallet/data/wallet_repository.dart';
import 'app_shell_test_support.dart';

void registerAppShellStartupUpdatesCases() {
  testWidgets('启动品牌页在真机零尺寸预热帧只保留空白且不产生红屏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Align(
          child: SizedBox.square(
            dimension: 0,
            child: const StartupCheckingPage(),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('startup-brand-mark')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('启动检查快速完成仍先稳定展示品牌首帧且不触发框架红屏', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
          ),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );

    expect(find.byKey(const Key('startup-brand-mark')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 699));
    expect(find.byKey(const Key('startup-brand-mark')), findsOneWidget);
    expect(find.byKey(const Key('home-category-menu')), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('startup-brand-mark')), findsNothing);
    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('兼容契约下游客进入四分支首页并从顶部搜索', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
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
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('动态'), findsOneWidget);
    expect(find.text('搜索'), findsNothing);
    expect(find.text('发布'), findsOneWidget);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byKey(const Key('global-publish')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-open-search')));
    await tester.pumpAndSettle();
    expect(find.text('输入关键词开始搜索'), findsNothing);
  });

  testWidgets('中央发布入口在所有主导航分支都先显示类型选择器', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
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

    for (final destination in ['首页', '动态', '消息', '我的']) {
      await tester.tap(find.text(destination));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('发布内容')), findsOneWidget);

      await tester.tap(find.byKey(const Key('global-publish')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('global-publish-thread')), findsOneWidget);
      expect(find.byKey(const Key('global-publish-moment')), findsOneWidget);

      await tester.tap(find.byKey(const Key('global-publish')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('global-publish-thread')), findsNothing);
      expect(find.byKey(const Key('global-publish-moment')), findsNothing);
    }
  });

  testWidgets('游客可从我的进入外观页并切换黑夜', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestCompatibleMetaRepository(),
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

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-appearance-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('appearance-option-system')), findsOneWidget);

    await tester.tap(find.byKey(const Key('appearance-option-dark')));
    await tester.pump();
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('appearance-option-dark'))),
      ).brightness,
      Brightness.dark,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedTheme && widget.child is ScaffoldMessenger,
        description: 'MaterialApp root AnimatedTheme',
      ),
      findsNothing,
    );
  });

  testWidgets('登录用户底栏展示服务端未读角标并可进入通知列表', (tester) async {
    final notifications = AppShellTestEmptyNotificationRepository(
      unreadCount: 7,
    );
    await tester.pumpWidget(
      ProviderScope(
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
          notificationRepositoryProvider.overrideWithValue(notifications),
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

    expect(find.text('7'), findsWidgets);
    await tester.tap(find.text('消息'));
    await tester.pumpAndSettle();
    expect(find.text('暂无通知'), findsOneWidget);
    expect(notifications.fetchCalls, greaterThanOrEqualTo(1));
  });

  testWidgets('未知契约主版本且新版未就绪时显示友好等待页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(contractVersion: '6.0.0'),
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

    expect(find.text('新版正在准备中'), findsOneWidget);
    expect(find.text('当前版本暂时无法继续使用。新版正在发布，请稍后再试。'), findsOneWidget);
    expect(find.textContaining('兼容信息'), findsNothing);
    expect(find.byKey(const Key('mobile-update-recheck')), findsOneWidget);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('Markdown v4/v5 可启动，未知 Markdown 版本显示升级页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.14.0',
              markdownContractVersion: 4,
            ),
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.14.0',
              markdownContractVersion: 5,
            ),
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.15.0',
              markdownContractVersion: 6,
            ),
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
    expect(find.text('新版正在准备中'), findsOneWidget);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('启动失败展示请求 ID 并可重试', (tester) async {
    final repository = AppShellTestRetryMetaRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(repository),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂时连不上温油站'), findsOneWidget);
    expect(find.textContaining('问题编号：startup-request-id'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('低于最低支持构建时优先强制更新且不可跳过', (tester) async {
    final updateService = AppShellTestFakeMobileUpdateService(build: 7);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.0.0',
              android: const MobilePlatformPolicy(
                minimumSupportedBuild: 8,
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

    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.text('当前 0.3.0+7'), findsOneWidget);
    expect(find.text('可用构建 10'), findsOneWidget);
    expect(find.byKey(const Key('mobile-update-dismiss')), findsNothing);

    await tester.tap(find.byKey(const Key('mobile-update-start')));
    await tester.pumpAndSettle();
    expect(find.text('系统安装器已打开，请按提示完成更新。'), findsOneWidget);
    expect(updateService.launchCalls, 1);
  });

  testWidgets('推荐更新不阻断进入应用且可记住该目标构建', (tester) async {
    final dismissStore = AppShellTestMemoryRecommendedUpdateDismissStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.0.0-dev.test',
              android: const MobilePlatformPolicy(
                recommendedBuild: 10,
                updateUrl: appShellTestAndroidUpdateUrl,
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(build: 7),
          ),
          recommendedUpdateDismissStoreProvider.overrideWithValue(dismissStore),
          tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
          homeRepositoryProvider.overrideWithValue(
            AppShellTestEmptyHomeRepository(),
          ),
        ],
        child: const WenyouApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('温油站有新版本'), findsOneWidget);
    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(find.byKey(const Key('recommended-update-banner')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-category-menu')), findsOneWidget);
    expect(dismissStore.dismissedBuild, 10);
  });

  testWidgets('推荐安装包预检尚未完成时也先进入应用', (tester) async {
    final availability = Completer<MobileUpdateAvailability>();
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
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(
              build: 7,
              availabilityCompleter: availability,
            ),
          ),
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

    availability.complete(
      const MobileUpdateAvailability.available(targetVersion: '0.4.0'),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recommended-update-banner')), findsOneWidget);
    expect(find.textContaining('0.4.0+10'), findsOneWidget);
  });

  testWidgets('必须更新但下载地址尚未发布时等待并允许重新检查', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.0.0',
              android: const MobilePlatformPolicy(
                minimumSupportedBuild: 8,
                recommendedBuild: 10,
              ),
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(build: 7),
          ),
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

    expect(find.text('新版正在准备中'), findsOneWidget);
    expect(find.text('当前 0.3.0+7'), findsOneWidget);
    expect(find.byKey(const Key('mobile-update-start')), findsNothing);
    expect(find.byKey(const Key('mobile-update-recheck')), findsOneWidget);
  });

  testWidgets('安装包尚未上传时等待，重新检查发现安装包后显示更新入口', (tester) async {
    final repository = AppShellTestFixedMetaRepository(
      contractVersion: '6.0.0',
      android: const MobilePlatformPolicy(
        recommendedBuild: 10,
        updateUrl: appShellTestAndroidUpdateUrl,
      ),
    );
    final updateService = AppShellTestFakeMobileUpdateService(
      build: 7,
      releaseAvailable: false,
      targetVersion: '0.4.0',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(repository),
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

    expect(find.text('新版正在准备中'), findsOneWidget);
    expect(updateService.availabilityChecks, 1);

    updateService.releaseAvailable = true;
    await tester.tap(find.byKey(const Key('mobile-update-recheck')));
    await tester.pumpAndSettle();

    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.text('可用0.4.0+10'), findsOneWidget);
    expect(updateService.availabilityChecks, 2);
  });

  testWidgets('等待页在前台定时发现安装包后自动显示更新入口', (tester) async {
    final updateService = AppShellTestFakeMobileUpdateService(
      build: 7,
      releaseAvailable: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '6.0.0',
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
    expect(find.text('新版正在准备中'), findsOneWidget);

    updateService.releaseAvailable = true;
    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();

    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(updateService.availabilityChecks, 2);
  });
}

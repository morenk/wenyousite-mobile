import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/app/wenyou_app.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_release_pages.dart';
import 'package:wenyousite_mobile/features/home/data/home_repository.dart';

import '../../app_shell_fixtures.dart';
import '../../support/deterministic_test_fonts.dart';
import 'mobile_release_test_support.dart';

const _update = MobileUpdateInfo(
  kind: MobileUpdateKind.recommended,
  platform: MobileClientPlatform.android,
  currentVersion: '0.8.0',
  currentBuild: 97,
  targetBuild: 100,
  targetVersion: '0.9.0',
);

void main() {
  setUpAll(loadDeterministicTestFonts);
  setUpAll(() {
    // 主题是应用级缓存；先建立 Android 基线，再切换平台验证入口。
    // 否则 iOS 首个用例会把未注册的系统字体缓存进后续 Android Golden。
    expect(AppTheme.light.platform, TargetPlatform.android);
    expect(AppTheme.dark.platform, TargetPlatform.android);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.windows]) {
    testWidgets('$platform 不展示 Android 历史或读取说明', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final repository = TestReleaseRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mobileReleaseRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MobileReleaseHistoryPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('当前平台暂不提供更新说明'), findsOneWidget);
      expect(repository.cursors, isEmpty);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mobileReleaseRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const MobileReleaseDetailPage(target: releaseTarget),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.detailCalls, 0);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  for (final dark in [false, true]) {
    testWidgets('更新说明360宽${dark ? '暗' : '亮'}色完整内容', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mobileReleaseRepositoryProvider.overrideWithValue(
              TestReleaseRepository()
                ..release = releaseFixture(
                  items: const [
                    '阅读长主题帖时，可以拖动右侧滑块快速浏览。',
                    '优化图片加载，浏览更顺手。',
                    '修复大字号下部分按钮文字显示不完整的问题。',
                  ],
                ),
            ),
            availableMobileReleaseUpdateProvider.overrideWith(
              (ref) async => _update,
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: (dark ? AppTheme.dark : AppTheme.light).copyWith(
              platform: TargetPlatform.android,
            ),
            home: const Scaffold(),
            initialRoute: '/detail',
            routes: {
              '/detail': (_) =>
                  const MobileReleaseDetailPage(target: releaseTarget),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('优化图片加载'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('下载并安装'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/mobile_release_${dark ? 'dark' : 'light'}_360.png',
        ),
      );
    });
  }

  testWidgets('长说明两倍字号可滚动；历史版本不能下载', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);
    final repository = TestReleaseRepository()
      ..release = releaseFixture(
        items: List.generate(
          12,
          (i) => '第${i + 1}项：主题阅读、动态和个人设置的体验调整，长文字在大字号下完整换行。',
        ),
      );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mobileReleaseRepositoryProvider.overrideWithValue(repository),
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(build: 100),
          ),
          availableMobileReleaseUpdateProvider.overrideWith(
            (ref) async => null,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const MobileReleaseDetailPage(target: releaseTarget),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('第12项'), 500);
    expect(find.textContaining('第12项'), findsOneWidget);
    expect(find.text('下载并安装'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('旧历史空态和当前安装版标记，失败支持重试', (tester) async {
    final repository = TestReleaseRepository()
      ..onPage = (_) async => const MobileReleasePage(items: []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mobileReleaseRepositoryProvider.overrideWithValue(repository),
          installedAppInfoProvider.overrideWith(
            (ref) async => const InstalledAppInfo(
              platform: MobileClientPlatform.android,
              version: '0.9.0',
              build: 100,
            ),
          ),
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(build: 100),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MobileReleaseHistoryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('暂无版本历史'), findsOneWidget);
    repository.onPage = (_) async => throw StateError('offline');
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(find.text('更新说明加载失败'), findsOneWidget);
    repository.onPage = (_) async =>
        MobileReleasePage(items: [releaseFixture()]);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('当前版本'), findsOneWidget);
    repository.onPage = (_) async => MobileReleasePage(
      items: [
        releaseFixture(
          target: (
            platform: MobileClientPlatform.android,
            build: 99,
            version: '0.8.0',
          ),
        ),
      ],
      nextCursor: 'next',
    );
    await tester.tap(find.byTooltip('刷新'));
    await tester.pumpAndSettle();
    expect(find.text('当前版本暂无更新说明'), findsNothing);
    repository.onPage = (_) async => const MobileReleasePage(items: []);
    await tester.tap(find.text('加载更多'));
    await tester.pumpAndSettle();
    expect(find.text('当前版本暂无更新说明'), findsOneWidget);
    expect(find.text('0.8.0+99'), findsOneWidget);
    expect(find.text('当前版本'), findsNothing);
  });

  testWidgets('推荐先查看说明再下载，忽略后仍从游客我的进入历史', (tester) async {
    final service = AppShellTestFakeMobileUpdateService(
      build: 97,
      targetVersion: '0.9.0',
    );
    await tester.pumpWidget(_app(service, TestReleaseRepository()));
    await tester.pumpAndSettle();
    expect(find.textContaining(releaseFixture().summary), findsOneWidget);
    expect(find.text('下载并安装'), findsNothing);
    await tester.tap(find.text('查看更新'));
    await tester.pumpAndSettle();
    expect(find.textContaining('**这是纯文本**'), findsOneWidget);
    await tester.ensureVisible(find.text('下载并安装'));
    await tester.tap(find.text('下载并安装'));
    await tester.pumpAndSettle();
    expect(service.launchCalls, 1);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('稍后再说'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('更新说明'));
    await tester.tap(find.text('更新说明'));
    await tester.pumpAndSettle();
    expect(find.text('0.9.0+100'), findsOneWidget);
    await tester.tap(find.text('查看更新'));
    await tester.pumpAndSettle();
    expect(find.text('下载并安装'), findsOneWidget);
    expect(find.byKey(const Key('recommended-update-banner')), findsNothing);
  });

  testWidgets('强制更新说明失败能重试且始终不解除门禁', (tester) async {
    final repository = TestReleaseRepository()
      ..detailError = StateError('offline');
    await tester.pumpWidget(
      _app(
        AppShellTestFakeMobileUpdateService(build: 97, targetVersion: '0.9.0'),
        repository,
        required: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.text('更新说明加载失败'), findsOneWidget);
    expect(find.text('稍后再说'), findsNothing);
    repository.detailError = null;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text(releaseFixture().summary), findsOneWidget);
    expect(find.text('需要更新后继续'), findsOneWidget);
    expect(find.byKey(const Key('home-category-menu')), findsNothing);
  });
}

Widget _app(
  AppShellTestFakeMobileUpdateService service,
  TestReleaseRepository repository, {
  bool required = false,
}) => ProviderScope(
  overrides: [
    metaRepositoryProvider.overrideWithValue(
      AppShellTestFixedMetaRepository(
        contractVersion: '5.0.0',
        android: MobilePlatformPolicy(
          minimumSupportedBuild: required ? 99 : null,
          recommendedBuild: 100,
          updateUrl: appShellTestAndroidUpdateUrl,
        ),
      ),
    ),
    mobileUpdateServiceProvider.overrideWithValue(service),
    mobileReleaseRepositoryProvider.overrideWithValue(repository),
    recommendedUpdateDismissStoreProvider.overrideWithValue(
      AppShellTestMemoryRecommendedUpdateDismissStore(),
    ),
    tokenStoreProvider.overrideWithValue(AppShellTestMemoryTokenStore()),
    homeRepositoryProvider.overrideWithValue(AppShellTestEmptyHomeRepository()),
  ],
  child: const WenyouApp(),
);

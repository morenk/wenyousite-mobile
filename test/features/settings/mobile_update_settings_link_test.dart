import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/presentation/mobile_update_settings_link.dart';

import '../../app_shell_fixtures.dart';
import '../app_shell/mobile_release_test_support.dart';

void main() {
  testWidgets('安装身份读取跨帧完成后仍能检查更新', (tester) async {
    final ready = Completer<void>();
    final service = _Service(installedReady: ready);
    await tester.pumpWidget(_app(service));
    await tester.tap(find.byKey(const Key('settings-check-update')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.text('发现新版本'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
    await tester.pumpAndSettle();
  });

  testWidgets('已取消自动提示仍可手动检查，取消后可再次打开并安装', (tester) async {
    final service = _Service();
    final dismiss = AppShellTestMemoryRecommendedUpdateDismissStore()
      ..dismissedBuild = 100;
    await tester.pumpWidget(_app(service, dismiss: dismiss));
    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.tap(find.byKey(const Key('settings-check-update')));
      await tester.pumpAndSettle();
      expect(find.text('发现新版本'), findsOneWidget);
      expect(find.byKey(const Key('mobile-update-start')), findsOneWidget);
      if (attempt == 0) {
        await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
        await tester.pumpAndSettle();
      }
    }
    await tester.tap(find.byKey(const Key('mobile-update-start')));
    await tester.pumpAndSettle();
    expect(service.launchCalls, 1);
    expect(dismiss.dismissedBuild, 100);
    await tester.tap(find.byKey(const Key('mobile-update-dismiss')));
    await tester.pumpAndSettle();
    service.installedBuild = 100;
    await tester.tap(find.byKey(const Key('settings-check-update')));
    await tester.pumpAndSettle();
    expect(find.text('当前已是最新版本 0.9.0。'), findsOneWidget);
    expect(find.text('发现新版本'), findsNothing);
  });

  testWidgets('检查中不重复请求，失败可重试且不会误报最新版本', (tester) async {
    final pending = Completer<MobileUpdateAvailability>();
    final service = _Service(pending: pending);
    await tester.pumpWidget(_app(service));
    final row = find.byKey(const Key('settings-check-update'));
    await tester.tap(row);
    await tester.pump();
    await tester.tap(row);
    await tester.pump();
    expect(service.availabilityChecks, 1);
    expect(find.text('检查中'), findsOneWidget);
    pending.complete(const MobileUpdateAvailability.preparing());
    await tester.pumpAndSettle();
    expect(find.text('新版正在准备中，请稍后重试。'), findsOneWidget);
    expect(find.textContaining('当前已是最新版本'), findsNothing);
    expect(find.text('检查中'), findsNothing);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(service.availabilityChecks, 2);
  });
}

Widget _app(_Service service, {RecommendedUpdateDismissStore? dismiss}) =>
    ProviderScope(
      overrides: [
        mobileUpdateServiceProvider.overrideWithValue(service),
        metaRepositoryProvider.overrideWithValue(
          AppShellTestFixedMetaRepository(
            contractVersion: '5.44.0',
            android: const MobilePlatformPolicy(
              recommendedBuild: 100,
              updateUrl: appShellTestAndroidUpdateUrl,
            ),
          ),
        ),
        mobileReleaseRepositoryProvider.overrideWithValue(
          TestReleaseRepository(),
        ),
        if (dismiss != null)
          recommendedUpdateDismissStoreProvider.overrideWithValue(dismiss),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: MobileUpdateSettingsLink()),
      ),
    );

class _Service extends AppShellTestFakeMobileUpdateService {
  _Service({Completer<MobileUpdateAvailability>? pending, this.installedReady})
    : super(build: 97, targetVersion: '0.9.0', availabilityCompleter: pending);
  int installedBuild = 97;
  final Completer<void>? installedReady;

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    await installedReady?.future;
    return InstalledAppInfo(
      platform: MobileClientPlatform.android,
      version: installedBuild == 100 ? '0.9.0' : '0.8.0',
      build: installedBuild,
    );
  }
}

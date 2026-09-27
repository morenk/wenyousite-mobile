import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_notice_store.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/data/recommended_update_dismiss_store.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const android = MobileClientPlatform.android;
  const store = SharedPreferencesMobileUpdateNoticeStore();
  const channel = MethodChannel('site.wenyou.app/app_update');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {'version': '0.8.0', 'build': '97'},
    );
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('按平台保存一次记录，不修改旧推荐ignore键', () async {
    SharedPreferences.setMockInitialValues({
      'dismissed_recommended_build_android': 100,
    });
    expect(await store.read(android), isNull);
    final record = const MobileUpdateNoticeRecord(
      lastInstalledBuild: 97,
      pendingInstalledBuild: 97,
    ).presented(MobileUpdateNoticeKind.beforeUpdate, 100);
    await store.write(android, record);
    final loaded = await const SharedPreferencesMobileUpdateNoticeStore().read(
      android,
    );
    expect(loaded!.lastInstalledBuild, 97);
    expect(loaded.pendingInstalledBuild, 97);
    expect(loaded.recommendedShown, {100});
    expect(await store.read(MobileClientPlatform.ios), isNull);
    expect(
      await SharedPreferencesRecommendedUpdateDismissStore().isDismissed(
        android,
        100,
      ),
      isTrue,
    );
  });

  test('损坏和未知schema不伪装成已展示或覆盖原记录', () async {
    const key = 'mobile_update_notice_v1_android';
    for (final raw in [
      'broken',
      '{"schemaVersion":2}',
      '{"schemaVersion":1,"recommendedShown":["97"],"installedShown":[]}',
    ]) {
      SharedPreferences.setMockInitialValues({key: raw});
      await expectLater(store.read(android), throwsFormatException);
      expect((await SharedPreferences.getInstance()).getString(key), raw);
    }
  });

  PackageInfo package({String build = '97'}) => PackageInfo(
    appName: '温油站',
    packageName: 'site.wenyou.app',
    version: '0.8.0',
    buildNumber: build,
    installTime: DateTime.utc(2026, 1, 1),
    updateTime: DateTime.utc(2026, 9, 27),
  );

  test('读取既有plugin的真实覆盖安装时间，先核对实际版本与build', () async {
    final bridge = MethodChannelMobileUpdatePlatformBridge(
      packageInfoReader: () async => package(),
    );
    final installed = await bridge.readInstalledApp(android);
    expect(installed.version, '0.8.0');
    expect(installed.build, 97);
    expect(installed.hasReplacementEvidence, isTrue);
    expect(installed.firstInstallTime, DateTime.utc(2026, 1, 1));
  });

  test('plugin版本身份错配或时间读取异常不干扰原生版本和更新门禁', () async {
    for (final reader in <Future<PackageInfo> Function()>[
      () async => package(build: '96'),
      () async => throw StateError('installation metadata unavailable'),
    ]) {
      final bridge = MethodChannelMobileUpdatePlatformBridge(
        packageInfoReader: reader,
      );
      final installed = await bridge.readInstalledApp(android);
      expect(installed.build, 97);
      expect(installed.firstInstallTime, isNull);
      expect(installed.hasReplacementEvidence, isFalse);
    }
  });

  test('时间相同、缺失或顺序错误不当作覆盖安装', () {
    final first = DateTime.utc(2026, 1, 1);
    for (final last in [first, null, first.subtract(const Duration(days: 1))]) {
      expect(
        InstalledAppInfo(
          platform: android,
          version: '0.8.0',
          build: 97,
          firstInstallTime: first,
          lastUpdateTime: last,
        ).hasReplacementEvidence,
        isFalse,
      );
    }
  });
}

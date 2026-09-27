import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

import '../../app_shell_fixtures.dart';
import 'mobile_release_test_support.dart';

void main() {
  test('说明和当前安装版均要求平台、版本名、构建号精确一致', () {
    final release = releaseFixture();
    for (final target in [
      releaseTarget,
      (platform: MobileClientPlatform.ios, build: 100, version: '0.9.0'),
      (platform: MobileClientPlatform.android, build: 99, version: '0.9.0'),
      (platform: MobileClientPlatform.android, build: 100, version: '0.9.1'),
    ]) {
      expect(
        release.isInstalled(
          InstalledAppInfo(
            platform: target.platform,
            version: target.version,
            build: target.build,
          ),
        ),
        target == releaseTarget,
      );
      expect(
        release.matchesUpdate(
          MobileUpdateInfo(
            kind: MobileUpdateKind.recommended,
            platform: target.platform,
            currentVersion: '0.8.0',
            currentBuild: 97,
            targetBuild: target.build,
            targetVersion: target.version,
          ),
        ),
        target == releaseTarget,
      );
    }
  });

  test('错误目标说明拒绝展示，缺失保持空态，失败重试重新读取', () async {
    final repository = TestReleaseRepository();
    final container = ProviderContainer(
      overrides: [
        mobileReleaseRepositoryProvider.overrideWithValue(repository),
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = mobileReleaseProvider(releaseTarget);
    repository.release = releaseFixture(
      target: (
        platform: MobileClientPlatform.android,
        build: 99,
        version: '0.8.0',
      ),
    );
    container.listen(provider, (_, _) {});
    await expectLater(
      container.read(provider.future),
      throwsA(isA<ApiFailure>()),
    );
    repository.release = null;
    expect(await container.refresh(provider.future), isNull);
    repository.detailError = StateError('offline');
    await expectLater(container.refresh(provider.future), throwsStateError);
    repository.detailError = null;
    repository.release = releaseFixture();
    expect(await container.refresh(provider.future), repository.release);
    expect(repository.detailCalls, 4);
  });
}

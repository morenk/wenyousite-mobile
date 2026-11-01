import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/manual_mobile_update_check.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

import '../../app_shell_fixtures.dart';

void main() {
  for (final policy in [
    const MobilePlatformPolicy(),
    const MobilePlatformPolicy(recommendedBuild: 100),
    const MobilePlatformPolicy(
      recommendedBuild: 100,
      updateUrl: 'http://unsafe',
    ),
  ]) {
    test('缺少策略或安全下载入口不冒报已是最新：$policy', () async {
      final container = ProviderContainer(
        overrides: [
          mobileUpdateServiceProvider.overrideWithValue(
            AppShellTestFakeMobileUpdateService(build: 97),
          ),
          metaRepositoryProvider.overrideWithValue(
            AppShellTestFixedMetaRepository(
              contractVersion: '5.44.0',
              android: policy,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await expectLater(
        container.read(manualMobileUpdateCheckProvider.future),
        throwsA(isA<MobileUpdateException>()),
      );
    });
  }

  test('元信息读取失败原样失败，不返回无更新', () async {
    final container = ProviderContainer(
      overrides: [
        mobileUpdateServiceProvider.overrideWithValue(
          AppShellTestFakeMobileUpdateService(build: 97),
        ),
        metaRepositoryProvider.overrideWithValue(_FailedMeta()),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(
      container.read(manualMobileUpdateCheckProvider.future),
      throwsA(isA<StateError>()),
    );
  });
}

class _FailedMeta implements MetaRepository {
  @override
  Future<ContractInfo> fetch() async => throw StateError('offline');
}

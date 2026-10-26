import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

typedef ManualMobileUpdateResult = ({
  InstalledAppInfo installed,
  MobileUpdateInfo? update,
});

// 手动检查始终重读安装身份和策略，不读取自动提示的忽略记录。
final manualMobileUpdateCheckProvider =
    FutureProvider.autoDispose<ManualMobileUpdateResult>((ref) async {
      final service = ref.watch(mobileUpdateServiceProvider);
      final repository = ref.watch(metaRepositoryProvider);
      if (service.platform == MobileClientPlatform.unsupported) {
        throw const MobileUpdateException('当前平台暂不支持检查更新。');
      }
      final installed = await service.readInstalledApp();
      final contract = await repository.fetch();
      final policy = contract.policyFor(installed.platform);
      if (!policy.isConfigured) {
        throw const MobileUpdateException('暂时无法获取版本信息，请稍后重试。');
      }
      var update = evaluateMobileUpdate(installed: installed, policy: policy);
      if (update == null &&
          (policy.recommendedBuild ?? installed.build) > installed.build) {
        throw const MobileUpdateException('新版正在准备中，请稍后重试。');
      }
      if (update != null &&
          installed.platform == MobileClientPlatform.android) {
        if (!update.canStartUpdate ||
            service is! MobileUpdateAvailabilityChecker) {
          throw const MobileUpdateException('新版正在准备中，请稍后重试。');
        }
        final availability = await (service as MobileUpdateAvailabilityChecker)
            .checkAvailability(update);
        if (!availability.isAvailable || availability.targetVersion == null) {
          throw MobileUpdateException(
            availability.userMessage ?? '新版正在准备中，请稍后重试。',
          );
        }
        update = update.withTargetVersion(availability.targetVersion);
      }
      return (installed: installed, update: update);
    }, dependencies: [mobileUpdateServiceProvider, metaRepositoryProvider]);

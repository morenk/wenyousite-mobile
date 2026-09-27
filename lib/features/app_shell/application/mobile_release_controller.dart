import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_release_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/startup_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_release.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

final installedAppInfoProvider = FutureProvider.autoDispose<InstalledAppInfo>(
  (ref) => ref.watch(mobileUpdateServiceProvider).readInstalledApp(),
  dependencies: [mobileUpdateServiceProvider],
);

final mobileReleaseProvider = FutureProvider.autoDispose
    .family<MobileRelease?, MobileReleaseTarget>((ref, target) async {
      final release = await ref
          .watch(mobileReleaseRepositoryProvider)
          .fetch(target);
      // 说明与 APK 元数据三项精确绑定，禁止以相邻版本替代。
      if (release != null && release.target != target) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'mobile_release_target_mismatch',
        );
      }
      return release;
    }, dependencies: [mobileReleaseRepositoryProvider]);

// 下载前独立复核可用目标；提示去重不影响安全检查或启动门禁。
final availableMobileReleaseUpdateProvider =
    FutureProvider.autoDispose<MobileUpdateInfo?>(
      (ref) async {
        final service = ref.watch(mobileUpdateServiceProvider);
        final repository = ref.watch(metaRepositoryProvider);
        if (service.platform != MobileClientPlatform.android) return null;
        final installed = await ref.watch(installedAppInfoProvider.future);
        final contract = await repository.fetch();
        final update = evaluateMobileUpdate(
          installed: installed,
          policy: contract.policyFor(installed.platform),
        );
        if (update == null || !update.canStartUpdate) return null;
        if (service is! MobileUpdateAvailabilityChecker) return null;
        final availability = await (service as MobileUpdateAvailabilityChecker)
            .checkAvailability(update);
        if (!availability.isAvailable || availability.targetVersion == null) {
          return null;
        }
        return update.withTargetVersion(availability.targetVersion);
      },
      dependencies: [
        mobileUpdateServiceProvider,
        metaRepositoryProvider,
        installedAppInfoProvider,
      ],
    );

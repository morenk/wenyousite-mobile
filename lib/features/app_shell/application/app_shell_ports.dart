import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

abstract interface class MetaRepository {
  Future<ContractInfo> fetch();
}

enum UpdateLaunchResult {
  permissionRequired,
  installerOpened,
  externalPageOpened,
}

enum MobileUpdateStage {
  checking,
  downloading,
  verifying,
  installing,
  openingExternalPage,
}

class MobileUpdateException implements Exception {
  const MobileUpdateException(this.userMessage, [this.cause]);

  final String userMessage;
  final Object? cause;

  @override
  String toString() => userMessage;
}

abstract interface class MobileUpdateService {
  MobileClientPlatform get platform;

  Future<InstalledAppInfo> readInstalledApp();

  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  });
}

/// Optional capability for checking that the advertised release artifact is
/// actually available before presenting an update action.
abstract interface class MobileUpdateAvailabilityChecker {
  Future<MobileUpdateAvailability> checkAvailability(MobileUpdateInfo update);
}

abstract interface class RecommendedUpdateDismissStore {
  Future<bool> isDismissed(MobileClientPlatform platform, int build);

  Future<void> dismiss(MobileClientPlatform platform, int build);
}

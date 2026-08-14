import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

enum MobileUpdateActionStatus {
  idle,
  checking,
  downloading,
  verifying,
  installing,
  openingExternalPage,
  permissionRequired,
  installerOpened,
  externalPageOpened,
  failed,
}

class MobileUpdateActionState {
  const MobileUpdateActionState({
    this.status = MobileUpdateActionStatus.idle,
    this.targetBuild,
    this.progress,
    this.message,
  });

  final MobileUpdateActionStatus status;
  final int? targetBuild;
  final double? progress;
  final String? message;

  bool get isBusy => switch (status) {
    MobileUpdateActionStatus.checking ||
    MobileUpdateActionStatus.downloading ||
    MobileUpdateActionStatus.verifying ||
    MobileUpdateActionStatus.installing ||
    MobileUpdateActionStatus.openingExternalPage => true,
    _ => false,
  };
}

class MobileUpdateController extends StateNotifier<MobileUpdateActionState> {
  MobileUpdateController(this._service)
    : super(const MobileUpdateActionState());

  final MobileUpdateService _service;

  Future<void> start(MobileUpdateInfo update) async {
    if (state.isBusy) return;
    state = MobileUpdateActionState(
      status: update.platform == MobileClientPlatform.android
          ? MobileUpdateActionStatus.checking
          : MobileUpdateActionStatus.openingExternalPage,
      targetBuild: update.targetBuild,
    );
    try {
      final result = await _service.launchUpdate(
        update,
        onStage: (stage) {
          state = MobileUpdateActionState(
            status: switch (stage) {
              MobileUpdateStage.checking => MobileUpdateActionStatus.checking,
              MobileUpdateStage.downloading =>
                MobileUpdateActionStatus.downloading,
              MobileUpdateStage.verifying => MobileUpdateActionStatus.verifying,
              MobileUpdateStage.installing =>
                MobileUpdateActionStatus.installing,
              MobileUpdateStage.openingExternalPage =>
                MobileUpdateActionStatus.openingExternalPage,
            },
            targetBuild: update.targetBuild,
            progress: stage == MobileUpdateStage.downloading ? 0 : null,
          );
        },
        onProgress: (progress) {
          final current = state;
          if (current.targetBuild != update.targetBuild) return;
          state = MobileUpdateActionState(
            status: current.status,
            targetBuild: update.targetBuild,
            progress: progress.clamp(0.0, 1.0).toDouble(),
          );
        },
      );
      state = MobileUpdateActionState(
        status: switch (result) {
          UpdateLaunchResult.permissionRequired =>
            MobileUpdateActionStatus.permissionRequired,
          UpdateLaunchResult.installerOpened =>
            MobileUpdateActionStatus.installerOpened,
          UpdateLaunchResult.externalPageOpened =>
            MobileUpdateActionStatus.externalPageOpened,
        },
        targetBuild: update.targetBuild,
        progress: 1,
      );
    } on MobileUpdateException catch (error) {
      state = MobileUpdateActionState(
        status: MobileUpdateActionStatus.failed,
        targetBuild: update.targetBuild,
        message: error.userMessage,
      );
    } on Object {
      state = MobileUpdateActionState(
        status: MobileUpdateActionStatus.failed,
        targetBuild: update.targetBuild,
        message: '更新没有完成，请稍后重试。',
      );
    }
  }
}

final mobileUpdateServiceProvider = Provider<MobileUpdateService>((ref) {
  return const _UnsupportedMobileUpdateService();
});

final mobileUpdateControllerProvider =
    StateNotifierProvider<MobileUpdateController, MobileUpdateActionState>((
      ref,
    ) {
      return MobileUpdateController(ref.watch(mobileUpdateServiceProvider));
    }, dependencies: [mobileUpdateServiceProvider]);

class _UnsupportedMobileUpdateService implements MobileUpdateService {
  const _UnsupportedMobileUpdateService();

  @override
  MobileClientPlatform get platform => MobileClientPlatform.unsupported;

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) {
    throw UnsupportedError('当前平台不支持应用内更新。');
  }

  @override
  Future<InstalledAppInfo> readInstalledApp() {
    throw UnsupportedError('当前平台不支持读取应用版本。');
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/app_shell/data/mobile_update_service.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

enum MobileUpdateActionStatus {
  idle,
  downloading,
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

  bool get isBusy => status == MobileUpdateActionStatus.downloading;
}

class MobileUpdateController extends StateNotifier<MobileUpdateActionState> {
  MobileUpdateController(this._service)
    : super(const MobileUpdateActionState());

  final MobileUpdateService _service;

  Future<void> start(MobileUpdateInfo update) async {
    if (state.isBusy) return;
    state = MobileUpdateActionState(
      status: MobileUpdateActionStatus.downloading,
      targetBuild: update.targetBuild,
      progress: update.platform == MobileClientPlatform.android ? 0 : null,
    );
    try {
      final result = await _service.launchUpdate(
        update,
        onProgress: (progress) {
          state = MobileUpdateActionState(
            status: MobileUpdateActionStatus.downloading,
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

final mobileUpdateDownloadDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(minutes: 5),
      headers: const {'Accept-Encoding': 'identity'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final mobileUpdateServiceProvider = Provider<MobileUpdateService>((ref) {
  return DeviceMobileUpdateService(ref.watch(mobileUpdateDownloadDioProvider));
});

final mobileUpdateControllerProvider = StateNotifierProvider<
  MobileUpdateController,
  MobileUpdateActionState
>((ref) {
  return MobileUpdateController(ref.watch(mobileUpdateServiceProvider));
});

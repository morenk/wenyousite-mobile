import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

void main() {
  test('控制器映射检查、下载、校验和安装阶段', () async {
    final controller = MobileUpdateController(_StagedUpdateService());
    addTearDown(controller.dispose);
    final statuses = <MobileUpdateActionStatus>[];
    controller.addListener((state) => statuses.add(state.status));

    await controller.start(_update);

    expect(
      statuses,
      containsAllInOrder(const [
        MobileUpdateActionStatus.checking,
        MobileUpdateActionStatus.downloading,
        MobileUpdateActionStatus.verifying,
        MobileUpdateActionStatus.installing,
        MobileUpdateActionStatus.installerOpened,
      ]),
    );
    expect(controller.state.progress, 1);
  });

  test('更新进行中忽略重复点击', () async {
    final service = _PendingUpdateService();
    final controller = MobileUpdateController(service);
    addTearDown(controller.dispose);

    final first = controller.start(_update);
    await Future<void>.delayed(Duration.zero);
    final second = controller.start(_update);
    expect(service.launchCalls, 1);
    service.complete();
    await Future.wait([first, second]);

    expect(controller.state.status, MobileUpdateActionStatus.installerOpened);
  });
}

const _update = MobileUpdateInfo(
  kind: MobileUpdateKind.required,
  platform: MobileClientPlatform.android,
  currentVersion: '0.3.0-dev.36',
  currentBuild: 42,
  targetBuild: 43,
);

class _StagedUpdateService implements MobileUpdateService {
  @override
  MobileClientPlatform get platform => MobileClientPlatform.android;

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) async {
    onStage(MobileUpdateStage.checking);
    onStage(MobileUpdateStage.downloading);
    onProgress(0.5);
    onStage(MobileUpdateStage.verifying);
    onStage(MobileUpdateStage.installing);
    return UpdateLaunchResult.installerOpened;
  }

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    return const InstalledAppInfo(
      platform: MobileClientPlatform.android,
      version: '0.3.0',
      build: 42,
    );
  }
}

class _PendingUpdateService implements MobileUpdateService {
  final _completer = Completer<UpdateLaunchResult>();
  int launchCalls = 0;

  @override
  MobileClientPlatform get platform => MobileClientPlatform.android;

  void complete() => _completer.complete(UpdateLaunchResult.installerOpened);

  @override
  Future<UpdateLaunchResult> launchUpdate(
    MobileUpdateInfo update, {
    required void Function(MobileUpdateStage stage) onStage,
    required void Function(double progress) onProgress,
  }) {
    launchCalls += 1;
    onStage(MobileUpdateStage.downloading);
    return _completer.future;
  }

  @override
  Future<InstalledAppInfo> readInstalledApp() async {
    return const InstalledAppInfo(
      platform: MobileClientPlatform.android,
      version: '0.3.0',
      build: 42,
    );
  }
}

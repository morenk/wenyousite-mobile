import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/application/app_shell_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/contract_info.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';

enum StartupStatus {
  checking,
  ready,
  recommendedUpdate,
  updateRequired,
  incompatible,
  failed,
}

class StartupState {
  const StartupState._(
    this.status, {
    this.contract,
    this.failure,
    this.reason,
    this.update,
  });

  const StartupState.checking() : this._(StartupStatus.checking);

  const StartupState.ready(ContractInfo contract)
    : this._(StartupStatus.ready, contract: contract);

  const StartupState.recommendedUpdate(
    ContractInfo contract,
    MobileUpdateInfo update,
  ) : this._(
        StartupStatus.recommendedUpdate,
        contract: contract,
        update: update,
      );

  const StartupState.updateRequired(
    ContractInfo contract,
    MobileUpdateInfo update,
  ) : this._(StartupStatus.updateRequired, contract: contract, update: update);

  const StartupState.incompatible(
    ContractInfo contract,
    String reason, {
    MobileUpdateInfo? update,
  }) : this._(
         StartupStatus.incompatible,
         contract: contract,
         reason: reason,
         update: update,
       );

  const StartupState.failed(ApiFailure failure)
    : this._(StartupStatus.failed, failure: failure);

  final StartupStatus status;
  final ContractInfo? contract;
  final ApiFailure? failure;
  final String? reason;
  final MobileUpdateInfo? update;
}

class StartupController extends StateNotifier<StartupState> {
  StartupController(
    this._metaRepository,
    this._environment,
    this._sessionController, {
    required this._mobileUpdateService,
    required this._dismissStore,
    bool autoStart = true,
  }) : super(const StartupState.checking()) {
    if (autoStart) unawaited(check());
  }

  final MetaRepository _metaRepository;
  final AppEnvironment _environment;
  final SessionController _sessionController;
  final MobileUpdateService _mobileUpdateService;
  final RecommendedUpdateDismissStore _dismissStore;

  Future<void> check() async {
    state = const StartupState.checking();
    try {
      final contract = await _metaRepository.fetch();
      final update = await _evaluateUpdate(contract);
      if (update?.isRequired ?? false) {
        state = StartupState.updateRequired(contract, update!);
        return;
      }
      if (!_environment.supportsContract(contract.contractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持契约主版本 ${_environment.supportedContractMajor}，'
          '服务端为 ${contract.contractVersion}。',
          update: update,
        );
        return;
      }
      if (!_environment.supportsMarkdown(contract.markdownContractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持 Markdown v${_environment.supportedMarkdownContractVersion}，'
          '服务端为 v${contract.markdownContractVersion}。',
          update: update,
        );
        return;
      }
      await _sessionController.restore();
      if (update != null && !await _isDismissed(update)) {
        state = StartupState.recommendedUpdate(contract, update);
        return;
      }
      state = StartupState.ready(contract);
    } on ApiFailure catch (failure) {
      state = StartupState.failed(failure);
    } on Object catch (error) {
      state = StartupState.failed(
        ApiFailure(userMessage: '启动检查没有完成，请稍后重试。', cause: error),
      );
    }
  }

  Future<void> dismissRecommendedUpdate() async {
    final current = state;
    final update = current.update;
    final contract = current.contract;
    if (current.status != StartupStatus.recommendedUpdate ||
        update == null ||
        contract == null) {
      return;
    }
    try {
      await _dismissStore.dismiss(update.platform, update.targetBuild);
    } on Object {
      // 偏好写入失败不应阻止用户进入应用。
    }
    state = StartupState.ready(contract);
  }

  Future<void> recheckForUpdate() async {
    if (state.status == StartupStatus.checking ||
        state.status == StartupStatus.updateRequired) {
      return;
    }
    try {
      final contract = await _metaRepository.fetch();
      final update = await _evaluateUpdate(contract);
      if (update?.isRequired ?? false) {
        state = StartupState.updateRequired(contract, update!);
        return;
      }
      if (!_environment.supportsContract(contract.contractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持契约主版本 ${_environment.supportedContractMajor}，'
          '服务端为 ${contract.contractVersion}。',
          update: update,
        );
        return;
      }
      if (!_environment.supportsMarkdown(contract.markdownContractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持 Markdown v${_environment.supportedMarkdownContractVersion}，'
          '服务端为 v${contract.markdownContractVersion}。',
          update: update,
        );
        return;
      }
      if (update != null && !await _isDismissed(update)) {
        state = StartupState.recommendedUpdate(contract, update);
      } else if (state.status == StartupStatus.recommendedUpdate) {
        state = StartupState.ready(contract);
      }
    } on Object {
      // 从后台返回时静默检查；短暂断网不能把正在使用的用户踢出应用。
    }
  }

  Future<MobileUpdateInfo?> _evaluateUpdate(ContractInfo contract) async {
    final platform = _mobileUpdateService.platform;
    final policy = contract.policyFor(platform);
    if (platform == MobileClientPlatform.unsupported || !policy.isConfigured) {
      return null;
    }
    final installed = await _mobileUpdateService.readInstalledApp();
    return evaluateMobileUpdate(installed: installed, policy: policy);
  }

  Future<bool> _isDismissed(MobileUpdateInfo update) async {
    try {
      return await _dismissStore.isDismissed(
        update.platform,
        update.targetBuild,
      );
    } on Object {
      return false;
    }
  }
}

final metaRepositoryProvider = Provider<MetaRepository>(
  (ref) => throw StateError('MetaRepository 尚未在应用组合根绑定。'),
);

final recommendedUpdateDismissStoreProvider =
    Provider<RecommendedUpdateDismissStore>(
      (ref) => const _NonPersistingRecommendedUpdateDismissStore(),
    );

final startupControllerProvider =
    StateNotifierProvider<StartupController, StartupState>(
      (ref) {
        return StartupController(
          ref.watch(metaRepositoryProvider),
          ref.watch(appEnvironmentProvider),
          ref.read(sessionControllerProvider.notifier),
          mobileUpdateService: ref.watch(mobileUpdateServiceProvider),
          dismissStore: ref.watch(recommendedUpdateDismissStoreProvider),
        );
      },
      dependencies: [
        metaRepositoryProvider,
        mobileUpdateServiceProvider,
        recommendedUpdateDismissStoreProvider,
      ],
    );

class _NonPersistingRecommendedUpdateDismissStore
    implements RecommendedUpdateDismissStore {
  const _NonPersistingRecommendedUpdateDismissStore();

  @override
  Future<void> dismiss(MobileClientPlatform platform, int build) async {}

  @override
  Future<bool> isDismissed(MobileClientPlatform platform, int build) async {
    return false;
  }
}

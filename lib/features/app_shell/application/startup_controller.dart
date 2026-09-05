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

enum StartupStatus { checking, ready, updateRequired, updateWaiting, failed }

class StartupState {
  const StartupState._(
    this.status, {
    this.contract,
    this.failure,
    this.update,
    this.isRechecking = false,
    this.recheckMessage,
  });

  const StartupState.checking() : this._(StartupStatus.checking);

  const StartupState.ready(ContractInfo contract, {MobileUpdateInfo? update})
    : this._(StartupStatus.ready, contract: contract, update: update);

  const StartupState.updateRequired(
    ContractInfo contract,
    MobileUpdateInfo update,
  ) : this._(StartupStatus.updateRequired, contract: contract, update: update);

  const StartupState.updateWaiting(
    ContractInfo contract, {
    MobileUpdateInfo? update,
    bool isRechecking = false,
    String? recheckMessage,
  }) : this._(
         StartupStatus.updateWaiting,
         contract: contract,
         update: update,
         isRechecking: isRechecking,
         recheckMessage: recheckMessage,
       );

  const StartupState.failed(ApiFailure failure)
    : this._(StartupStatus.failed, failure: failure);

  final StartupStatus status;
  final ContractInfo? contract;
  final ApiFailure? failure;
  final MobileUpdateInfo? update;
  final bool isRechecking;
  final String? recheckMessage;
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
  bool _recheckInFlight = false;
  int _recommendationEpoch = 0;

  Future<void> check() async {
    _recommendationEpoch += 1;
    state = const StartupState.checking();
    try {
      final contract = await _metaRepository.fetch();
      final resolution = await _resolve(
        contract,
        restoreSession: true,
        deferRecommendation: true,
      );
      state = resolution.state;
      final pendingRecommendation = resolution.pendingRecommendation;
      if (pendingRecommendation != null) {
        _startPendingRecommendation(contract, pendingRecommendation);
      }
    } on ApiFailure catch (failure) {
      state = StartupState.failed(failure);
    } on Object catch (error) {
      state = StartupState.failed(
        ApiFailure(userMessage: '启动检查失败，请稍后重试。', cause: error),
      );
    }
  }

  Future<void> dismissRecommendedUpdate() async {
    final current = state;
    final update = current.update;
    final contract = current.contract;
    if (current.status != StartupStatus.ready ||
        update == null ||
        contract == null) {
      return;
    }
    try {
      await _dismissStore.dismiss(update.platform, update.targetBuild);
    } on Object {
      // 偏好写入失败不应阻止用户进入应用。
    }
    _recommendationEpoch += 1;
    state = StartupState.ready(contract);
  }

  Future<void> recheckForUpdate({bool showFailure = false}) async {
    if (state.status == StartupStatus.checking || _recheckInFlight) {
      return;
    }
    final previous = state;
    _recommendationEpoch += 1;
    _recheckInFlight = true;
    if (previous.status == StartupStatus.updateWaiting &&
        previous.contract != null) {
      state = StartupState.updateWaiting(
        previous.contract!,
        update: previous.update,
        isRechecking: true,
      );
    }
    try {
      final contract = await _metaRepository.fetch();
      final resolution = await _resolve(
        contract,
        restoreSession: previous.status != StartupStatus.ready,
        deferRecommendation: previous.status != StartupStatus.ready,
      );
      state = resolution.state;
      final pendingRecommendation = resolution.pendingRecommendation;
      if (pendingRecommendation != null) {
        _startPendingRecommendation(contract, pendingRecommendation);
      }
    } on Object {
      if (previous.status == StartupStatus.updateWaiting &&
          previous.contract != null) {
        state = StartupState.updateWaiting(
          previous.contract!,
          update: previous.update,
          recheckMessage: showFailure
              ? '暂时未能确认新版状态，请检查网络后再试。'
              : previous.recheckMessage,
        );
      }
      // 从后台返回时静默检查；短暂断网不能把正在使用的用户踢出应用。
    } finally {
      _recheckInFlight = false;
    }
  }

  Future<({StartupState state, MobileUpdateInfo? pendingRecommendation})>
  _resolve(
    ContractInfo contract, {
    required bool restoreSession,
    required bool deferRecommendation,
  }) async {
    final update = await _evaluateUpdate(contract);
    final requiresUpdate =
        (update?.isRequired ?? false) ||
        !_environment.supportsContract(contract.contractVersion) ||
        !_environment.supportsMarkdown(contract.markdownContractVersion);
    if (requiresUpdate) {
      if (update != null) {
        final availability = await _checkAvailability(update);
        if (availability.isAvailable) {
          return (
            state: StartupState.updateRequired(contract, availability.update),
            pendingRecommendation: null,
          );
        }
      }
      return (
        state: StartupState.updateWaiting(contract, update: update),
        pendingRecommendation: null,
      );
    }
    if (restoreSession) await _sessionController.restore();
    if (update == null || await _isDismissed(update)) {
      return (state: StartupState.ready(contract), pendingRecommendation: null);
    }
    if (deferRecommendation) {
      return (
        state: StartupState.ready(contract),
        pendingRecommendation: update,
      );
    }
    final availability = await _checkAvailability(update);
    return (
      state: StartupState.ready(
        contract,
        update: availability.isAvailable ? availability.update : null,
      ),
      pendingRecommendation: null,
    );
  }

  Future<({MobileUpdateInfo update, bool isAvailable})> _checkAvailability(
    MobileUpdateInfo update,
  ) async {
    if (!update.canStartUpdate) {
      return (update: update, isAvailable: false);
    }
    final service = _mobileUpdateService;
    final checker = service is MobileUpdateAvailabilityChecker
        ? service as MobileUpdateAvailabilityChecker
        : null;
    if (checker == null) {
      return (update: update, isAvailable: true);
    }
    final availability = await checker.checkAvailability(update);
    if (!availability.isAvailable) {
      return (update: update, isAvailable: false);
    }
    update = update.withTargetVersion(availability.targetVersion);
    return (update: update, isAvailable: true);
  }

  void _startPendingRecommendation(
    ContractInfo contract,
    MobileUpdateInfo update,
  ) {
    final epoch = ++_recommendationEpoch;
    unawaited(_completePendingRecommendation(epoch, contract, update));
  }

  Future<void> _completePendingRecommendation(
    int epoch,
    ContractInfo contract,
    MobileUpdateInfo update,
  ) async {
    try {
      final availability = await _checkAvailability(update);
      final current = state;
      if (epoch != _recommendationEpoch ||
          current.status != StartupStatus.ready ||
          !identical(current.contract, contract) ||
          !availability.isAvailable) {
        return;
      }
      state = StartupState.ready(contract, update: availability.update);
    } on Object {
      // 推荐更新预检不阻止进入应用，也不把临时失败展示成启动错误。
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

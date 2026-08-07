import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/config/app_environment.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/app_shell/data/meta_repository.dart';

enum StartupStatus { checking, ready, incompatible, failed }

class StartupState {
  const StartupState._(this.status, {this.contract, this.failure, this.reason});

  const StartupState.checking() : this._(StartupStatus.checking);

  const StartupState.ready(ContractInfo contract)
    : this._(StartupStatus.ready, contract: contract);

  const StartupState.incompatible(ContractInfo contract, String reason)
    : this._(StartupStatus.incompatible, contract: contract, reason: reason);

  const StartupState.failed(ApiFailure failure)
    : this._(StartupStatus.failed, failure: failure);

  final StartupStatus status;
  final ContractInfo? contract;
  final ApiFailure? failure;
  final String? reason;
}

class StartupController extends StateNotifier<StartupState> {
  StartupController(
    this._metaRepository,
    this._environment,
    this._sessionController, {
    bool autoStart = true,
  }) : super(const StartupState.checking()) {
    if (autoStart) unawaited(check());
  }

  final MetaRepository _metaRepository;
  final AppEnvironment _environment;
  final SessionController _sessionController;

  Future<void> check() async {
    state = const StartupState.checking();
    try {
      final contract = await _metaRepository.fetch();
      if (!_environment.supportsContract(contract.contractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持契约主版本 ${_environment.supportedContractMajor}，'
          '服务端为 ${contract.contractVersion}。',
        );
        return;
      }
      if (!_environment.supportsMarkdown(contract.markdownContractVersion)) {
        state = StartupState.incompatible(
          contract,
          '当前应用支持 Markdown v${_environment.supportedMarkdownContractVersion}，'
          '服务端为 v${contract.markdownContractVersion}。',
        );
        return;
      }
      await _sessionController.restore();
      state = StartupState.ready(contract);
    } on ApiFailure catch (failure) {
      state = StartupState.failed(failure);
    } on Object catch (error) {
      state = StartupState.failed(
        ApiFailure(userMessage: '启动检查没有完成，请稍后重试。', cause: error),
      );
    }
  }
}

final metaRepositoryProvider = Provider<MetaRepository>(
  (ref) => ApiMetaRepository(ref.watch(wenyouApiProvider)),
);

final startupControllerProvider =
    StateNotifierProvider<StartupController, StartupState>((ref) {
      return StartupController(
        ref.watch(metaRepositoryProvider),
        ref.watch(appEnvironmentProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    });

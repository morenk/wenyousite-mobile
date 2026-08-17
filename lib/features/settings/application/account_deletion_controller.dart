import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';

enum AccountDeletionStatus { idle, submitting, failed }

class AccountDeletionState {
  const AccountDeletionState({
    this.status = AccountDeletionStatus.idle,
    this.failure,
    this.remoteDeletionConfirmed = false,
  });

  final AccountDeletionStatus status;
  final ApiFailure? failure;
  final bool remoteDeletionConfirmed;

  bool get isSubmitting => status == AccountDeletionStatus.submitting;
}

class AccountDeletionController extends StateNotifier<AccountDeletionState> {
  AccountDeletionController(this._repository, this._sessionController)
    : super(const AccountDeletionState());

  final AccountDeletionRepository _repository;
  final SessionController _sessionController;

  Future<bool> submit() async {
    if (state.isSubmitting || state.remoteDeletionConfirmed) return false;
    state = const AccountDeletionState(
      status: AccountDeletionStatus.submitting,
    );
    var remoteDeletionConfirmed = false;
    try {
      await _repository.deleteAccount();
      remoteDeletionConfirmed = true;
      await _sessionController.logoutLocally();
      if (mounted) state = const AccountDeletionState();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = AccountDeletionState(
        status: AccountDeletionStatus.failed,
        remoteDeletionConfirmed: remoteDeletionConfirmed,
        failure: _asFailure(
          error,
          remoteDeletionConfirmed
              ? '账号已注销，但清理这台设备的登录信息失败。请重试清理。'
              : '账号注销失败，请稍后重试。',
        ),
      );
      return false;
    }
  }

  Future<bool> retryLocalCleanup() async {
    if (state.isSubmitting || !state.remoteDeletionConfirmed) return false;
    state = const AccountDeletionState(
      status: AccountDeletionStatus.submitting,
      remoteDeletionConfirmed: true,
    );
    try {
      await _sessionController.logoutLocally();
      if (mounted) state = const AccountDeletionState();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = AccountDeletionState(
        status: AccountDeletionStatus.failed,
        remoteDeletionConfirmed: true,
        failure: _asFailure(error, '账号已注销，但清理这台设备的登录信息失败。请重试清理。'),
      );
      return false;
    }
  }

  void clearFailure() {
    if (state.failure == null || state.remoteDeletionConfirmed) return;
    state = const AccountDeletionState();
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return mapApplicationFailure(error, fallback);
  }
}

final accountDeletionControllerProvider =
    StateNotifierProvider.autoDispose<
      AccountDeletionController,
      AccountDeletionState
    >((ref) {
      return AccountDeletionController(
        ref.watch(accountDeletionRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    }, dependencies: [accountDeletionRepositoryProvider]);

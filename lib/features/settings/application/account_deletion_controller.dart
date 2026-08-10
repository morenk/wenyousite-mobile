import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/settings/data/account_deletion_repository.dart';

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
              ? '账号已注销，但本机登录信息没有清理完成。请重试本机清理。'
              : '账号注销没有完成，请稍后重试。',
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
        failure: _asFailure(error, '账号已注销，但本机登录信息没有清理完成。请重试本机清理。'),
      );
      return false;
    }
  }

  void clearFailure() {
    if (state.failure == null || state.remoteDeletionConfirmed) return;
    state = const AccountDeletionState();
  }

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
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
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

enum LogoutStatus { idle, submitting, failed }

class LogoutState {
  const LogoutState._(this.status, {this.failure});

  const LogoutState.idle() : this._(LogoutStatus.idle);

  const LogoutState.submitting() : this._(LogoutStatus.submitting);

  const LogoutState.failed(ApiFailure failure)
    : this._(LogoutStatus.failed, failure: failure);

  final LogoutStatus status;
  final ApiFailure? failure;

  bool get isSubmitting => status == LogoutStatus.submitting;
}

class LogoutController extends StateNotifier<LogoutState> {
  LogoutController(this._sessionController) : super(const LogoutState.idle());

  final SessionController _sessionController;

  Future<bool> submit() async {
    if (state.isSubmitting) return false;
    state = const LogoutState.submitting();
    try {
      await _sessionController.logout();
      state = const LogoutState.idle();
      return true;
    } on ApiFailure catch (failure) {
      state = LogoutState.failed(failure);
      return false;
    } on Object catch (error) {
      state = LogoutState.failed(
        ApiFailure(userMessage: '退出失败，请稍后重试。', cause: error),
      );
      return false;
    }
  }

  Future<void> forceLocalLogout() async {
    await _sessionController.logoutLocally();
    state = const LogoutState.idle();
  }
}

final logoutControllerProvider =
    StateNotifierProvider.autoDispose<LogoutController, LogoutState>((ref) {
      return LogoutController(ref.read(sessionControllerProvider.notifier));
    });

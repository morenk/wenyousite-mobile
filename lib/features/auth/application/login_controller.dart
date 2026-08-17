import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';

enum LoginStatus { idle, submitting, failed }

class LoginState {
  const LoginState._(this.status, {this.failure});

  const LoginState.idle() : this._(LoginStatus.idle);

  const LoginState.submitting() : this._(LoginStatus.submitting);

  const LoginState.failed(ApiFailure failure)
    : this._(LoginStatus.failed, failure: failure);

  final LoginStatus status;
  final ApiFailure? failure;

  bool get isSubmitting => status == LoginStatus.submitting;
}

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repository, this._sessionController)
    : super(const LoginState.idle());

  final AuthRepository _repository;
  final SessionController _sessionController;

  Future<bool> submit({
    required String account,
    required String password,
  }) async {
    if (state.isSubmitting) return false;
    state = const LoginState.submitting();
    try {
      final tokens = await _repository.login(
        account: account.trim(),
        password: password,
      );
      await _sessionController.authenticate(tokens);
      state = const LoginState.idle();
      return true;
    } on ApiFailure catch (failure) {
      state = LoginState.failed(failure);
      return false;
    } on Object catch (error) {
      state = LoginState.failed(
        ApiFailure(userMessage: '登录失败，请稍后重试。', cause: error),
      );
      return false;
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
      return LoginController(
        ref.watch(authRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    }, dependencies: [authRepositoryProvider]);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/settings/application/credential_security_states.dart';
import 'package:wenyousite_mobile/features/settings/application/settings_repository_ports.dart';

export 'package:wenyousite_mobile/features/settings/application/credential_security_states.dart';

class PasswordChangeController extends StateNotifier<PasswordChangeState> {
  PasswordChangeController(this._repository, this._sessionController)
    : super(const PasswordChangeState.idle());

  final CredentialSecurityRepository _repository;
  final SessionController _sessionController;

  Future<bool> submit({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (state.isSubmitting) return false;
    state = const PasswordChangeState.submitting();
    var passwordChanged = false;
    try {
      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      passwordChanged = true;
      await _sessionController.logoutLocally();
      if (mounted) state = const PasswordChangeState.idle();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = PasswordChangeState.failed(
        _asFailure(
          error,
          passwordChanged ? '密码已修改，但本机登录信息清理失败。请重启应用后重新登录。' : '密码修改没有完成，请稍后重试。',
        ),
      );
      return false;
    }
  }
}

class EmailChangeController extends StateNotifier<EmailChangeState> {
  EmailChangeController(this._repository, this._sessionController)
    : super(const EmailChangeState());

  static const resendCooldown = Duration(seconds: 60);

  final CredentialSecurityRepository _repository;
  final SessionController _sessionController;
  Timer? _cooldownTimer;

  Future<bool> requestCode({
    required String newEmail,
    required String oldPassword,
  }) async {
    if (state.isBusy || state.resendSecondsRemaining > 0) return false;
    final normalizedEmail = newEmail.trim().toLowerCase();
    if (state.step == EmailChangeStep.verifyCode &&
        state.email != normalizedEmail) {
      return false;
    }
    state = state.copyWith(
      action: EmailChangeAction.requestingCode,
      clearFailure: true,
    );
    try {
      await _repository.requestEmailChangeCode(
        newEmail: normalizedEmail,
        oldPassword: oldPassword,
      );
      if (!mounted) return false;
      state = EmailChangeState(
        step: EmailChangeStep.verifyCode,
        email: normalizedEmail,
        resendSecondsRemaining: resendCooldown.inSeconds,
      );
      _startCooldown(resendCooldown.inSeconds);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = _asFailure(error, '验证码发送没有完成，请稍后重试。');
      final retrySeconds = failure.retryAfter?.inSeconds ?? 0;
      state = state.copyWith(
        clearAction: true,
        failure: failure,
        resendSecondsRemaining: retrySeconds,
      );
      if (retrySeconds > 0) _startCooldown(retrySeconds);
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
    final email = state.email;
    if (state.isBusy ||
        state.step != EmailChangeStep.verifyCode ||
        email == null) {
      return false;
    }
    state = state.copyWith(
      action: EmailChangeAction.verifying,
      clearFailure: true,
    );
    var emailChanged = false;
    try {
      await _repository.verifyEmailChange(newEmail: email, code: code.trim());
      emailChanged = true;
      _cooldownTimer?.cancel();
      await _sessionController.logoutLocally();
      if (mounted) state = const EmailChangeState();
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        clearAction: true,
        failure: _asFailure(
          error,
          emailChanged ? '邮箱已更换，但本机登录信息清理失败。请重启应用后重新登录。' : '邮箱更换没有完成，请稍后重试。',
        ),
      );
      return false;
    }
  }

  void editEmail() {
    if (state.isBusy) return;
    _cooldownTimer?.cancel();
    state = const EmailChangeState();
  }

  void clearFailure() {
    if (state.failure == null) return;
    state = state.copyWith(clearFailure: true);
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    if (seconds <= 0) return;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = state.resendSecondsRemaining - 1;
      if (next <= 0) timer.cancel();
      state = state.copyWith(resendSecondsRemaining: next < 0 ? 0 : next);
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}

ApiFailure _asFailure(Object error, String fallback) {
  return mapApplicationFailure(error, fallback);
}

final passwordChangeControllerProvider =
    StateNotifierProvider.autoDispose<
      PasswordChangeController,
      PasswordChangeState
    >((ref) {
      return PasswordChangeController(
        ref.watch(credentialSecurityRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    }, dependencies: [credentialSecurityRepositoryProvider]);

final emailChangeControllerProvider =
    StateNotifierProvider.autoDispose<EmailChangeController, EmailChangeState>((
      ref,
    ) {
      return EmailChangeController(
        ref.watch(credentialSecurityRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    }, dependencies: [credentialSecurityRepositoryProvider]);

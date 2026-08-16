import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/application/auth_ports.dart';

enum PasswordRecoveryAction { requestingCode, resetting }

class PasswordRecoverySeed {
  const PasswordRecoverySeed({
    this.initialEmail,
    this.codeRecentlySent = false,
  });

  final String? initialEmail;
  final bool codeRecentlySent;
}

class PasswordRecoveryState {
  const PasswordRecoveryState({
    this.action,
    this.lastRequestedEmail,
    this.resendSecondsRemaining = 0,
    this.failure,
  });

  final PasswordRecoveryAction? action;
  final String? lastRequestedEmail;
  final int resendSecondsRemaining;
  final ApiFailure? failure;

  bool get isBusy => action != null;
  bool get isRequestingCode => action == PasswordRecoveryAction.requestingCode;
  bool get isResetting => action == PasswordRecoveryAction.resetting;

  PasswordRecoveryState copyWith({
    PasswordRecoveryAction? action,
    String? lastRequestedEmail,
    int? resendSecondsRemaining,
    ApiFailure? failure,
    bool clearAction = false,
    bool clearFailure = false,
  }) {
    return PasswordRecoveryState(
      action: clearAction ? null : action ?? this.action,
      lastRequestedEmail: lastRequestedEmail ?? this.lastRequestedEmail,
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

class PasswordRecoveryController extends StateNotifier<PasswordRecoveryState> {
  PasswordRecoveryController(this._repository, PasswordRecoverySeed seed)
    : super(
        PasswordRecoveryState(
          lastRequestedEmail: seed.codeRecentlySent
              ? _normalizeEmail(seed.initialEmail ?? '')
              : null,
          resendSecondsRemaining: seed.codeRecentlySent
              ? resendCooldown.inSeconds
              : 0,
        ),
      ) {
    if (seed.codeRecentlySent) {
      _startCooldown(resendCooldown.inSeconds);
    }
  }

  static const resendCooldown = Duration(seconds: 60);

  final PasswordRecoveryRepository _repository;
  Timer? _cooldownTimer;

  Future<bool> requestCode(String email) async {
    if (state.isBusy || state.resendSecondsRemaining > 0) return false;
    final normalizedEmail = _normalizeEmail(email);
    state = state.copyWith(
      action: PasswordRecoveryAction.requestingCode,
      clearFailure: true,
    );
    try {
      await _repository.requestCode(email: normalizedEmail);
      if (!mounted) return false;
      state = state.copyWith(
        clearAction: true,
        clearFailure: true,
        lastRequestedEmail: normalizedEmail,
        resendSecondsRemaining: resendCooldown.inSeconds,
      );
      _startCooldown(resendCooldown.inSeconds);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      final failure = _asFailure(error, '重置验证码发送没有完成，请稍后重试。');
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

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (state.isBusy) return false;
    state = state.copyWith(
      action: PasswordRecoveryAction.resetting,
      clearFailure: true,
    );
    try {
      await _repository.resetPassword(
        email: _normalizeEmail(email),
        code: code.trim(),
        newPassword: newPassword,
      );
      if (!mounted) return false;
      _cooldownTimer?.cancel();
      state = state.copyWith(clearAction: true, clearFailure: true);
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      state = state.copyWith(
        clearAction: true,
        failure: _asFailure(error, '密码重置没有完成，请稍后重试。'),
      );
      return false;
    }
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

String _normalizeEmail(String email) => email.trim().toLowerCase();

ApiFailure _asFailure(Object error, String fallback) {
  return mapApplicationFailure(error, fallback);
}

final passwordRecoveryControllerProvider = StateNotifierProvider.autoDispose
    .family<
      PasswordRecoveryController,
      PasswordRecoveryState,
      PasswordRecoverySeed
    >((ref, seed) {
      return PasswordRecoveryController(
        ref.watch(passwordRecoveryRepositoryProvider),
        seed,
      );
    }, dependencies: [passwordRecoveryRepositoryProvider]);

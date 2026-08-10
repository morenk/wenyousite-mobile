import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/auth/data/email_verification_repository.dart';

enum EmailVerificationPhase { loading, ready, failed }

enum EmailVerificationAction { requestingCode, verifying }

class EmailVerificationState {
  const EmailVerificationState({
    this.phase = EmailVerificationPhase.loading,
    this.account,
    this.action,
    this.failure,
    this.successMessage,
    this.resendSecondsRemaining = 0,
  });

  final EmailVerificationPhase phase;
  final EmailVerificationAccount? account;
  final EmailVerificationAction? action;
  final ApiFailure? failure;
  final String? successMessage;
  final int resendSecondsRemaining;

  bool get isBusy => action != null;
  bool get isRequestingCode => action == EmailVerificationAction.requestingCode;
  bool get isVerifying => action == EmailVerificationAction.verifying;

  EmailVerificationState copyWith({
    EmailVerificationPhase? phase,
    EmailVerificationAccount? account,
    EmailVerificationAction? action,
    ApiFailure? failure,
    String? successMessage,
    int? resendSecondsRemaining,
    bool clearAction = false,
    bool clearFailure = false,
    bool clearSuccess = false,
  }) {
    return EmailVerificationState(
      phase: phase ?? this.phase,
      account: account ?? this.account,
      action: clearAction ? null : (action ?? this.action),
      failure: clearFailure ? null : (failure ?? this.failure),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
    );
  }
}

class EmailVerificationController
    extends StateNotifier<EmailVerificationState> {
  EmailVerificationController(this._repository, {bool autoStart = true})
    : super(const EmailVerificationState()) {
    if (autoStart) unawaited(load());
  }

  static const resendCooldown = Duration(seconds: 60);

  final EmailVerificationRepository _repository;
  Timer? _cooldownTimer;
  int _epoch = 0;

  Future<void> load() async {
    final epoch = ++_epoch;
    state = EmailVerificationState(
      resendSecondsRemaining: state.resendSecondsRemaining,
    );
    try {
      final account = await _repository.fetchAccount();
      if (!_isCurrent(epoch)) return;
      state = EmailVerificationState(
        phase: EmailVerificationPhase.ready,
        account: account,
        resendSecondsRemaining: state.resendSecondsRemaining,
      );
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return;
      state = EmailVerificationState(
        phase: EmailVerificationPhase.failed,
        failure: _asFailure(error, '邮箱状态没有加载完成，请稍后重试。'),
        resendSecondsRemaining: state.resendSecondsRemaining,
      );
    }
  }

  Future<bool> requestCode() async {
    final account = state.account;
    if (state.phase != EmailVerificationPhase.ready ||
        account == null ||
        account.isVerified ||
        state.isBusy ||
        state.resendSecondsRemaining > 0) {
      return false;
    }
    final epoch = _epoch;
    state = state.copyWith(
      action: EmailVerificationAction.requestingCode,
      clearFailure: true,
      clearSuccess: true,
    );
    try {
      await _repository.resendCode(email: account.email);
      if (!_isCurrent(epoch)) return false;
      state = state.copyWith(
        clearAction: true,
        successMessage: '如果当前邮箱仍待验证，验证码已发送，请在 15 分钟内完成验证。',
        resendSecondsRemaining: resendCooldown.inSeconds,
      );
      _startCooldown(resendCooldown.inSeconds);
      return true;
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return false;
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
    final account = state.account;
    if (state.phase != EmailVerificationPhase.ready ||
        account == null ||
        account.isVerified ||
        state.isBusy) {
      return false;
    }
    final epoch = _epoch;
    state = state.copyWith(
      action: EmailVerificationAction.verifying,
      clearFailure: true,
      clearSuccess: true,
    );
    var verificationAccepted = false;
    try {
      await _repository.verifyCode(code: code.trim());
      verificationAccepted = true;
      final refreshed = await _repository.fetchAccount();
      if (!_isCurrent(epoch)) return false;
      if (!refreshed.isVerified) {
        throw const ApiFailure(userMessage: '验证已提交，但账号状态尚未刷新，请重新确认。');
      }
      _cooldownTimer?.cancel();
      state = EmailVerificationState(
        phase: EmailVerificationPhase.ready,
        account: refreshed,
        successMessage: '邮箱验证成功，现在可以继续发布和互动。',
      );
      return true;
    } on Object catch (error) {
      if (!_isCurrent(epoch)) return false;
      final failure = _asFailure(
        error,
        verificationAccepted ? '验证已提交，但账号状态没有刷新，请重新确认。' : '邮箱验证没有完成，请稍后重试。',
      );
      state = verificationAccepted
          ? EmailVerificationState(
              phase: EmailVerificationPhase.failed,
              failure: failure,
              resendSecondsRemaining: state.resendSecondsRemaining,
            )
          : state.copyWith(clearAction: true, failure: failure);
      return false;
    }
  }

  void clearFeedback() {
    if (state.failure == null && state.successMessage == null) return;
    state = state.copyWith(clearFailure: true, clearSuccess: true);
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

  bool _isCurrent(int epoch) => mounted && epoch == _epoch;

  ApiFailure _asFailure(Object error, String fallback) {
    return error is ApiFailure
        ? error
        : ApiFailure(userMessage: fallback, cause: error);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}

final emailVerificationControllerProvider =
    StateNotifierProvider.autoDispose<
      EmailVerificationController,
      EmailVerificationState
    >((ref) {
      return EmailVerificationController(
        ref.watch(emailVerificationRepositoryProvider),
      );
    });

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/auth/data/auth_repository.dart';

enum RegistrationStep { email, verify }

enum RegistrationStatus { idle, requestingCode, completing, failed }

class RegistrationState {
  const RegistrationState({
    this.step = RegistrationStep.email,
    this.status = RegistrationStatus.idle,
    this.email,
    this.codeExpiresInSeconds,
    this.resendSecondsRemaining = 0,
    this.failure,
  });

  final RegistrationStep step;
  final RegistrationStatus status;
  final String? email;
  final int? codeExpiresInSeconds;
  final int resendSecondsRemaining;
  final ApiFailure? failure;

  bool get isBusy =>
      status == RegistrationStatus.requestingCode ||
      status == RegistrationStatus.completing;

  RegistrationState copyWith({
    RegistrationStep? step,
    RegistrationStatus? status,
    String? email,
    int? codeExpiresInSeconds,
    int? resendSecondsRemaining,
    ApiFailure? failure,
    bool clearFailure = false,
  }) {
    return RegistrationState(
      step: step ?? this.step,
      status: status ?? this.status,
      email: email ?? this.email,
      codeExpiresInSeconds: codeExpiresInSeconds ?? this.codeExpiresInSeconds,
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

class RegistrationController extends StateNotifier<RegistrationState> {
  RegistrationController(this._repository, this._sessionController)
    : super(const RegistrationState());

  static const resendCooldown = Duration(seconds: 60);

  final AuthRepository _repository;
  final SessionController _sessionController;
  Timer? _cooldownTimer;

  Future<bool> requestCode(String email) {
    return _sendCode(email.trim());
  }

  Future<bool> resendCode() {
    final email = state.email;
    if (email == null || state.step != RegistrationStep.verify) {
      return Future.value(false);
    }
    return _sendCode(email);
  }

  Future<bool> _sendCode(String email) async {
    if (state.isBusy || state.resendSecondsRemaining > 0) return false;
    state = state.copyWith(
      status: RegistrationStatus.requestingCode,
      email: email,
      clearFailure: true,
    );
    try {
      final info = await _repository.requestRegistrationCode(email: email);
      state = state.copyWith(
        step: RegistrationStep.verify,
        status: RegistrationStatus.idle,
        email: email,
        codeExpiresInSeconds: info.expiresIn.inSeconds,
        resendSecondsRemaining: resendCooldown.inSeconds,
        clearFailure: true,
      );
      _startCooldown(resendCooldown.inSeconds);
      return true;
    } on ApiFailure catch (failure) {
      final retrySeconds = failure.retryAfter?.inSeconds ?? 0;
      state = state.copyWith(
        status: RegistrationStatus.failed,
        failure: failure,
        resendSecondsRemaining: retrySeconds,
      );
      if (retrySeconds > 0) _startCooldown(retrySeconds);
      return false;
    } on Object catch (error) {
      state = state.copyWith(
        status: RegistrationStatus.failed,
        failure: ApiFailure(userMessage: '验证码请求没有完成，请稍后重试。', cause: error),
      );
      return false;
    }
  }

  Future<bool> complete({
    required String code,
    required String username,
    required String password,
  }) async {
    final email = state.email;
    if (email == null ||
        state.step != RegistrationStep.verify ||
        state.isBusy) {
      return false;
    }
    state = state.copyWith(
      status: RegistrationStatus.completing,
      clearFailure: true,
    );
    try {
      final tokens = await _repository.completeRegistration(
        email: email,
        code: code.trim(),
        username: username.trim(),
        password: password,
      );
      await _sessionController.authenticate(tokens);
      state = state.copyWith(
        status: RegistrationStatus.idle,
        clearFailure: true,
      );
      return true;
    } on ApiFailure catch (failure) {
      state = state.copyWith(
        status: RegistrationStatus.failed,
        failure: failure,
      );
      return false;
    } on Object catch (error) {
      state = state.copyWith(
        status: RegistrationStatus.failed,
        failure: ApiFailure(userMessage: '注册没有完成，请稍后重试。', cause: error),
      );
      return false;
    }
  }

  void editEmail() {
    if (state.isBusy) return;
    _cooldownTimer?.cancel();
    state = const RegistrationState();
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    if (seconds <= 0) return;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

final registrationControllerProvider =
    StateNotifierProvider.autoDispose<
      RegistrationController,
      RegistrationState
    >((ref) {
      return RegistrationController(
        ref.watch(authRepositoryProvider),
        ref.read(sessionControllerProvider.notifier),
      );
    });

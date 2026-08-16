import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum PasswordChangeStatus { idle, submitting, failed }

class PasswordChangeState {
  const PasswordChangeState._(this.status, {this.failure});

  const PasswordChangeState.idle() : this._(PasswordChangeStatus.idle);

  const PasswordChangeState.submitting()
    : this._(PasswordChangeStatus.submitting);

  const PasswordChangeState.failed(ApiFailure failure)
    : this._(PasswordChangeStatus.failed, failure: failure);

  final PasswordChangeStatus status;
  final ApiFailure? failure;

  bool get isSubmitting => status == PasswordChangeStatus.submitting;
}

enum EmailChangeStep { requestCode, verifyCode }

enum EmailChangeAction { requestingCode, verifying }

class EmailChangeState {
  const EmailChangeState({
    this.step = EmailChangeStep.requestCode,
    this.action,
    this.email,
    this.resendSecondsRemaining = 0,
    this.failure,
    this.codeDeliveryUncertain = false,
  });

  final EmailChangeStep step;
  final EmailChangeAction? action;
  final String? email;
  final int resendSecondsRemaining;
  final ApiFailure? failure;
  final bool codeDeliveryUncertain;

  bool get isBusy => action != null;
  bool get isRequestingCode => action == EmailChangeAction.requestingCode;
  bool get isVerifying => action == EmailChangeAction.verifying;

  EmailChangeState copyWith({
    EmailChangeStep? step,
    EmailChangeAction? action,
    String? email,
    int? resendSecondsRemaining,
    ApiFailure? failure,
    bool clearAction = false,
    bool clearFailure = false,
    bool? codeDeliveryUncertain,
  }) {
    return EmailChangeState(
      step: step ?? this.step,
      action: clearAction ? null : action ?? this.action,
      email: email ?? this.email,
      resendSecondsRemaining:
          resendSecondsRemaining ?? this.resendSecondsRemaining,
      failure: clearFailure ? null : failure ?? this.failure,
      codeDeliveryUncertain:
          codeDeliveryUncertain ?? this.codeDeliveryUncertain,
    );
  }
}

import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

ApiFailure mapApplicationFailure(Object error, String fallbackMessage) {
  return switch (error) {
    ApiFailure failure => failure,
    DomainValidationException validation => ApiFailure(
      userMessage: validation.message,
      reason: FailureReason.validation,
      recoveryAction: FailureRecoveryAction.none,
      cause: validation,
    ),
    _ => ApiFailure(
      userMessage: fallbackMessage,
      reason: FailureReason.unknown,
      recoveryAction: FailureRecoveryAction.retry,
      cause: error,
    ),
  };
}

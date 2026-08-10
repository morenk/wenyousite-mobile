import 'package:wenyousite_mobile/core/domain/domain_validation_exception.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

ApiFailure mapApplicationFailure(Object error, String fallbackMessage) {
  return switch (error) {
    ApiFailure failure => failure,
    DomainValidationException validation => ApiFailure(
      userMessage: validation.message,
      cause: validation,
    ),
    _ => ApiFailure(userMessage: fallbackMessage, cause: error),
  };
}

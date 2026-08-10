/// Describes cross-cutting behavior that must travel with an API request.
///
/// Generated API methods merge [extra] into Dio's [RequestOptions.extra].
/// Keeping these flags here avoids feature repositories depending on private
/// interceptor string keys.
enum ApiRequestPolicy {
  standard,
  public,
  idempotentCreate;

  Map<String, dynamic> get extra => switch (this) {
    ApiRequestPolicy.standard => const <String, dynamic>{},
    ApiRequestPolicy.public => const <String, dynamic>{
      ApiRequestExtraKeys.skipAuth: true,
    },
    ApiRequestPolicy.idempotentCreate => const <String, dynamic>{
      ApiRequestExtraKeys.idempotentCreate: true,
    },
  };
}

abstract final class ApiRequestExtraKeys {
  static const skipAuth = 'skipAuth';
  static const idempotentCreate = 'idempotentCreate';
}

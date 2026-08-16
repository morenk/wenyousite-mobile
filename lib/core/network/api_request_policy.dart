/// Describes cross-cutting behavior that must travel with an API request.
///
/// Generated API methods merge [extra] into Dio's [RequestOptions.extra].
/// Keeping these flags here avoids feature repositories depending on private
/// interceptor string keys.
enum ApiRequestPolicy {
  standard,
  public,
  idempotentCreate,
  publicNonReplayable,
  authenticatedNonReplayable;

  Map<String, dynamic> get extra => switch (this) {
    ApiRequestPolicy.standard => const <String, dynamic>{},
    ApiRequestPolicy.public => const <String, dynamic>{
      ApiRequestExtraKeys.skipAuth: true,
    },
    ApiRequestPolicy.idempotentCreate => const <String, dynamic>{
      ApiRequestExtraKeys.idempotentCreate: true,
    },
    ApiRequestPolicy.publicNonReplayable => const <String, dynamic>{
      ApiRequestExtraKeys.skipAuth: true,
      ApiRequestExtraKeys.noAutomaticReplay: true,
    },
    ApiRequestPolicy.authenticatedNonReplayable => const <String, dynamic>{
      ApiRequestExtraKeys.noAutomaticReplay: true,
    },
  };
}

abstract final class ApiRequestExtraKeys {
  static const skipAuth = 'skipAuth';
  static const idempotentCreate = 'idempotentCreate';
  static const noAutomaticReplay = 'noAutomaticReplay';
}

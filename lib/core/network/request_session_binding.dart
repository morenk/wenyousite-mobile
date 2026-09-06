import 'package:dio/dio.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

/// Immutable ownership, retained by Dio across both retry interceptors.
class RequestSessionBinding {
  RequestSessionBinding(this.session) : scope = session.scope;

  static const _key = 'wenyou.request.session';
  final SessionController session;
  final SessionScope scope;

  static bool usesSession(RequestOptions options) =>
      options.extra[ApiRequestExtraKeys.skipAuth] != true;

  static void bind(RequestOptions options, SessionController session) {
    if (usesSession(options)) {
      options.extra.putIfAbsent(_key, () => RequestSessionBinding(session));
    }
  }

  static DioException? cancellation(RequestOptions options) {
    if (options.cancelToken?.cancelError case final error?) return error;
    final binding = options.extra[_key];
    if (binding is RequestSessionBinding &&
        (!binding.session.mounted ||
            binding.session.scope.generation != binding.scope.generation)) {
      return DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'Request session ended.',
      );
    }
    return null;
  }

  static void ensureCurrent(RequestOptions options) {
    if (cancellation(options) case final error?) throw error;
  }
}

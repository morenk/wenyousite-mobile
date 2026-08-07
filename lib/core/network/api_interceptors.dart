import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';

class RequestContextInterceptor extends Interceptor {
  RequestContextInterceptor(
    this._dio,
    this._sessionController, [
    this._uuid = const Uuid(),
  ]);

  static const _retriedKey = 'wenyou.auth.retried';
  final Dio _dio;
  final SessionController _sessionController;
  final Uuid _uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-ID', _uuid.v4);
    final accessToken = _sessionController.tokens?.accessToken;
    if (accessToken != null && options.extra['skipAuth'] != true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (_needsMobileHeader(options.path)) {
      options.headers['X-Client-Platform'] = 'mobile';
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = ApiFailure.fromDio(err);
    if (failure.invalidatesSession) {
      unawaited(
        _sessionController.invalidate(_reasonFor(failure.businessCode)),
      );
      handler.next(err);
      return;
    }
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (failure.isExpiredAccessToken && alreadyRetried) {
      unawaited(
        _sessionController.invalidate(SessionInvalidationReason.refreshFailed),
      );
      handler.next(err);
      return;
    }
    if (!failure.isExpiredAccessToken) {
      handler.next(err);
      return;
    }
    _retryAfterRefresh(err).then(
      handler.resolve,
      onError: (_) {
        handler.next(err);
      },
    );
  }

  Future<Response<Object?>> _retryAfterRefresh(DioException error) async {
    final tokens = await _sessionController.refresh();
    final options = error.requestOptions;
    options.extra[_retriedKey] = true;
    options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    return _dio.fetch<Object?>(options);
  }

  bool _needsMobileHeader(String path) {
    final normalized = Uri.parse(path).path;
    return normalized.endsWith('/auth/login') ||
        normalized.endsWith('/auth/verify-and-complete');
  }

  void _logResponse(Response<Object?> response) {
    final options = response.requestOptions;
    final uri = options.uri.replace(query: '', fragment: '');
    developer.log(
      '${options.method} $uri ${response.statusCode} '
      'requestId=${options.headers['X-Request-ID']} '
      'contract=${response.headers.value('x-api-contract-version') ?? '-'}',
      name: 'wenyou.network',
    );
  }

  SessionInvalidationReason _reasonFor(int? code) {
    return switch (code) {
      40103 => SessionInvalidationReason.revoked,
      40104 => SessionInvalidationReason.compromised,
      40105 => SessionInvalidationReason.locked,
      40106 => SessionInvalidationReason.deactivated,
      _ => SessionInvalidationReason.refreshFailed,
    };
  }
}

class SafeRetryInterceptor extends Interceptor {
  SafeRetryInterceptor(this._dio, {Random? random})
    : _random = random ?? Random.secure();

  static const _attemptKey = 'wenyou.retry.attempt';
  final Dio _dio;
  final Random _random;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final attempt = options.extra[_attemptKey] as int? ?? 0;
    if (attempt >= 2 || !_isRetryable(err)) {
      handler.next(err);
      return;
    }
    options.extra[_attemptKey] = attempt + 1;
    final delay = Duration(
      milliseconds: 250 * (attempt + 1) + _random.nextInt(150),
    );
    Future<void>.delayed(delay)
        .then((_) => _dio.fetch<Object?>(options))
        .then(handler.resolve, onError: (_) => handler.next(err));
  }

  bool _isRetryable(DioException error) {
    final method = error.requestOptions.method.toUpperCase();
    final safeMethod = method == 'GET' || method == 'HEAD';
    final idempotentWrite =
        error.requestOptions.extra['idempotentCreate'] == true;
    final transient =
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
    return transient && (safeMethod || idempotentWrite);
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
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
    if (accessToken != null &&
        options.extra[ApiRequestExtraKeys.skipAuth] != true) {
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
    _logError(err, failure);
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
    if (!_canReplayAfterRefresh(err.requestOptions)) {
      _sessionController.refresh().then(
        (_) => handler.next(err),
        onError: (_) => handler.next(err),
      );
      return;
    }
    _retryAfterRefresh(err).then(
      handler.resolve,
      onError: (_) {
        handler.next(err);
      },
    );
  }

  bool _canReplayAfterRefresh(RequestOptions options) {
    if (options.extra[ApiRequestExtraKeys.noAutomaticReplay] == true) {
      return false;
    }
    final method = options.method.toUpperCase();
    return method == 'GET' ||
        method == 'HEAD' ||
        method == 'PUT' ||
        method == 'DELETE' ||
        options.extra[ApiRequestExtraKeys.idempotentCreate] == true;
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
    final uri = sanitizeNetworkLogUri(options.uri);
    developer.log(
      '${options.method} $uri ${response.statusCode} '
      'requestId=${options.headers['X-Request-ID']} '
      'contract=${response.headers.value('x-api-contract-version') ?? '-'}',
      name: 'wenyou.network',
    );
  }

  void _logError(DioException error, ApiFailure failure) {
    final options = error.requestOptions;
    final uri = sanitizeNetworkLogUri(options.uri);
    final summary =
        '${options.method} $uri failed '
        'type=${error.type.name} status=${failure.httpStatus ?? '-'} '
        'code=${failure.businessCode ?? '-'} requestId=${failure.requestId ?? '-'}';
    developer.log(
      summary,
      name: 'wenyou.network',
      error: error.error,
      stackTrace: error.stackTrace,
    );
    if (kDebugMode) debugPrint('$summary error=${error.error}');
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

String sanitizeNetworkLogUri(Uri uri) {
  final raw = uri.toString();
  final queryIndex = raw.indexOf('?');
  final fragmentIndex = raw.indexOf('#');
  final cutAt =
      [
        if (queryIndex >= 0) queryIndex,
        if (fragmentIndex >= 0) fragmentIndex,
      ].fold<int>(
        raw.length,
        (current, index) => index < current ? index : current,
      );
  final withoutQuery = raw.substring(0, cutAt);
  return withoutQuery.replaceFirstMapped(
    RegExp(r'(/threads/join-by-link/)[^/?#]+'),
    (match) => '${match.group(1)}<redacted>',
  );
}

class SafeRetryInterceptor extends Interceptor {
  SafeRetryInterceptor(
    this._dio, {
    Random? random,
    Future<void> Function(Duration duration)? wait,
  }) : _random = random ?? Random.secure(),
       _wait = wait ?? Future<void>.delayed;

  static const _attemptKey = 'wenyou.retry.attempt';
  final Dio _dio;
  final Random _random;
  final Future<void> Function(Duration duration) _wait;

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
    _wait(delay)
        .then((_) => _dio.fetch<Object?>(options))
        .then(handler.resolve, onError: (_) => handler.next(err));
  }

  bool _isRetryable(DioException error) {
    if (error.requestOptions.extra[ApiRequestExtraKeys.noAutomaticReplay] ==
        true) {
      return false;
    }
    final method = error.requestOptions.method.toUpperCase();
    final safeMethod =
        method == 'GET' ||
        method == 'HEAD' ||
        method == 'PUT' ||
        method == 'DELETE';
    final idempotentWrite =
        error.requestOptions.extra[ApiRequestExtraKeys.idempotentCreate] ==
        true;
    final transient =
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
    return transient && (safeMethod || idempotentWrite);
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/diagnostics/debug_diagnostic_console.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/api_request_policy.dart';
import 'package:wenyousite_mobile/core/network/request_session_binding.dart';
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
    RequestSessionBinding.bind(options, _sessionController);
    options.headers.putIfAbsent('X-Request-ID', _uuid.v4);
    if (_needsMobileHeader(options.path)) {
      options.headers['X-Client-Platform'] = 'mobile';
    }
    _authorize(options).then(
      (_) => handler.next(options),
      onError: (Object error, StackTrace stackTrace) => handler.reject(
        error is DioException
            ? error
            : DioException(
                requestOptions: options,
                error: error,
                stackTrace: stackTrace,
              ),
      ),
    );
  }

  Future<void> _authorize(RequestOptions options) async {
    DiagnosticAttempt.current?.mark(DiagnosticStage.authorize);
    RequestSessionBinding.ensureCurrent(options);
    if (options.extra[ApiRequestExtraKeys.explicitCredentials] == true) return;
    options.headers.removeWhere(
      (key, _) => key.toLowerCase() == 'authorization',
    );
    if (!RequestSessionBinding.usesSession(options)) return;
    var tokens = _sessionController.tokens;
    if (tokens != null && _sessionController.accessTokenNeedsRefresh) {
      tokens = await _sessionController.refresh();
    }
    RequestSessionBinding.ensureCurrent(options);
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    if (RequestSessionBinding.cancellation(response.requestOptions)
        case final error?) {
      handler.reject(error);
      return;
    }
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (RequestSessionBinding.cancellation(err.requestOptions)
        case final error?) {
      handler.next(error);
      return;
    }
    final failure = ApiFailure.fromDio(err);
    _logError(err, failure);
    if (!RequestSessionBinding.usesSession(err.requestOptions)) {
      handler.next(err);
      return;
    }
    if (failure.invalidatesSession) {
      _invalidate(err, handler, _reasonFor(failure.businessCode));
      return;
    }
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (failure.isExpiredAccessToken && alreadyRetried) {
      _invalidate(err, handler, SessionInvalidationReason.refreshFailed);
      return;
    }
    if (!failure.isExpiredAccessToken) {
      handler.next(err);
      return;
    }
    if (!_canReplayAfterRefresh(err.requestOptions)) {
      _sessionController.refresh().then(
        (_) => handler.next(
          RequestSessionBinding.cancellation(err.requestOptions) ?? err,
        ),
        onError: (_) => handler.next(
          RequestSessionBinding.cancellation(err.requestOptions) ?? err,
        ),
      );
      return;
    }
    _retryAfterRefresh(err).then(
      handler.resolve,
      onError: (_) {
        handler.next(
          RequestSessionBinding.cancellation(err.requestOptions) ?? err,
        );
      },
    );
  }

  void _invalidate(
    DioException error,
    ErrorInterceptorHandler handler,
    SessionInvalidationReason reason,
  ) {
    _sessionController
        .invalidate(reason)
        .then(
          (_) => handler.next(error),
          onError: (Object failure, StackTrace stack) => handler.next(
            DioException(
              requestOptions: error.requestOptions,
              error: ApiFailure(
                source: FailureSource.device,
                reason: FailureReason.localPersistence,
                cause: failure,
              ),
              stackTrace: stack,
            ),
          ),
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
    RequestSessionBinding.ensureCurrent(error.requestOptions);
    final tokens = await _sessionController.refresh();
    RequestSessionBinding.ensureCurrent(error.requestOptions);
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
        'source=${failure.effectiveSource.name} '
        'requestId=${failure.requestId ?? '-'}';
    developer.log(
      summary,
      name: 'wenyou.network',
      stackTrace: error.stackTrace,
    );
    if (wenyouFieldDiagnosticsEnabled) {
      DebugDiagnosticBuffer.instance.record('network_failure', {
        'source': failure.effectiveSource.name,
        'reason': failure.reason.name,
        'dioType': error.type.name,
        'httpStatus': failure.httpStatus,
        'businessCode': failure.businessCode,
        'businessName': failure.businessCodeName,
        'requestId': failure.requestId,
        'contractVersion': failure.contractVersion,
      }, stackTrace: error.stackTrace);
    }
    if (kDebugMode) debugPrint(summary);
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
    if (RequestSessionBinding.cancellation(options) case final error?) {
      handler.next(error);
      return;
    }
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
        .then((_) {
          RequestSessionBinding.ensureCurrent(options);
          return _dio.fetch<Object?>(options);
        })
        .then(
          handler.resolve,
          onError: (_) =>
              handler.next(RequestSessionBinding.cancellation(options) ?? err),
        );
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

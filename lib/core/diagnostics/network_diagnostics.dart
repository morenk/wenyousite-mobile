import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// Install after auth/retry interceptors: successful recovery must not create
/// a remote issue. Only UUIDs and status fields are retained, never the URL.
class NetworkDiagnosticInterceptor extends Interceptor {
  NetworkDiagnosticInterceptor({this.diagnostics});
  final FailureDiagnostics? diagnostics;
  FailureDiagnostics get _diagnostics =>
      diagnostics ?? FailureDiagnostics.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra.putIfAbsent(
      'diagnosticGeneration',
      () => _diagnostics.generation,
    );
    options.headers.putIfAbsent('X-Request-ID', const Uuid().v4);
    final attempt = DiagnosticAttempt.current;
    if (attempt != null) {
      attempt.requestId = safeDiagnosticId(options.headers['X-Request-ID']);
      attempt.httpStatus = null;
      attempt.responseReceived = false;
      attempt.apiEnvelopeReceived = false;
      attempt.mark(DiagnosticStage.request);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _response(response);
    handler.next(response);
  }

  void _response(Response<Object?>? response) {
    final attempt = DiagnosticAttempt.current;
    if (attempt == null || response == null) return;
    attempt.responseReceived = true;
    attempt.apiEnvelopeReceived =
        response.data is Map && (response.data as Map)['code'] is num;
    attempt.httpStatus = response.statusCode;
    attempt.requestId =
        safeDiagnosticId(response.headers.value('x-request-id')) ??
        safeDiagnosticId(response.requestOptions.headers['X-Request-ID']);
    attempt.contractVersion = safeDiagnosticVersion(
      response.headers.value('x-api-contract-version'),
    );
    attempt.mark(DiagnosticStage.response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _response(err.response);
    if (DiagnosticAttempt.current == null &&
        err.requestOptions.extra['diagnosticGeneration'] ==
            _diagnostics.generation) {
      _diagnostics.capture(
        err,
        failure: ApiFailure.fromDio(err),
        stackTrace: err.stackTrace,
        operation: const {'GET', 'HEAD'}.contains(err.requestOptions.method)
            ? DiagnosticOperation.apiRead
            : DiagnosticOperation.apiWrite,
      );
    }
    handler.next(err);
  }
}

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:sentry/sentry.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// A dedicated Dart client has no automatic integrations, native SDK, global
/// breadcrumbs or background disk queue. The app owns the scrubbed outbox.
class DiagnosticSentrySender implements DiagnosticSender {
  DiagnosticSentrySender(
    this.dsn, {
    this.enabled = true,
    this.httpClientFactory,
  });
  final String dsn;
  final bool enabled;
  final http.Client Function()? httpClientFactory;
  SentryClient? _client;
  HttpClient? _http;
  http.Client? _wireClient;
  DateTime? _retryNotBefore;

  @override
  bool get available {
    final uri = Uri.tryParse(dsn);
    return enabled &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isNotEmpty &&
        uri.pathSegments.isNotEmpty;
  }

  @override
  Future<bool> send(DiagnosticRecord record) async {
    if (!available) return false;
    if (_retryNotBefore != null && DateTime.now().isBefore(_retryNotBefore!)) {
      return false;
    }
    if (_client == null) {
      _http = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      _wireClient = httpClientFactory?.call() ?? IOClient(_http);
      final options = SentryOptions()
        ..dsn = dsn
        ..httpClient = _wireClient!
        ..sendDefaultPii = false
        ..sendClientReports = false
        ..attachStacktrace = false
        ..enableLogs = false
        ..enableMetrics = false
        ..maxBreadcrumbs = 0
        ..beforeSend = (event, hint) {
          final safe = DiagnosticRecord.fromJson(event.contexts['diagnostic']);
          return safe == null ? null : diagnosticSentryEvent(safe);
        };
      _client = SentryClient(options);
    }
    try {
      final sent = await _client!
          .captureEvent(diagnosticSentryEvent(record))
          .timeout(const Duration(seconds: 12));
      final accepted = sent.toString() == record.id.replaceAll('-', '');
      if (!accepted) {
        _retryNotBefore = DateTime.now().add(const Duration(minutes: 1));
      }
      return accepted;
    } on Object {
      cancel();
      _retryNotBefore = DateTime.now().add(const Duration(minutes: 1));
      return false;
    }
  }

  @override
  void cancel() {
    _http?.close(force: true);
    _wireClient?.close();
    _wireClient = null;
    _http = null;
    _client = null;
  }
}

SentryEvent diagnosticSentryEvent(DiagnosticRecord record) {
  final fields = sanitizeDiagnosticFields(record.fields);
  final context = Contexts();
  context['diagnostic'] = record.toJson();
  return SentryEvent(
    eventId: SentryId.fromId(record.id.replaceAll('-', '')),
    timestamp: record.createdAt,
    platform: 'dart',
    level: record.source == FailureSource.network
        ? SentryLevel.warning
        : SentryLevel.error,
    release: fields['appVersion'] == null
        ? null
        : 'wenyou-mobile@${fields['appVersion']}',
    dist: fields['build'] as String?,
    environment: 'mobile',
    message: SentryMessage('${record.operation.name}.${record.stage.name}'),
    fingerprint: [
      record.operation.name,
      record.stage.name,
      record.source.name,
      '${fields['businessCode'] ?? fields['errorType'] ?? record.reason.name}',
    ],
    tags: {
      'diagnostic_id': record.id,
      'operation': record.operation.name,
      'stage': record.stage.name,
      'source': record.source.name,
      if (fields['requestId'] case final String id) 'request_id': id,
      if (fields['businessCode'] case final int code) 'error_code': '$code',
    },
    contexts: context,
    exceptions: [
      SentryException(
        type: fields['errorType'] as String? ?? 'OperationFailure',
        value: '${record.operation.name}.${record.stage.name}',
        stackTrace: SentryStackTrace(
          frames: [
            for (final frame
                in (fields['stack'] as List<String>? ?? const []).reversed)
              SentryStackFrame(
                fileName: frame.substring(
                  0,
                  frame.lastIndexOf(':', frame.lastIndexOf(':') - 1),
                ),
                lineNo: int.tryParse(frame.split(':').reversed.elementAt(1)),
                colNo: int.tryParse(frame.split(':').last),
                inApp: frame.startsWith('package:wenyousite_mobile/'),
              ),
          ],
        ),
      ),
    ],
  );
}

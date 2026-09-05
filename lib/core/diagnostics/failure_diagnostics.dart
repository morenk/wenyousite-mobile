import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wenyousite_mobile/core/diagnostics/diagnostic_record.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

export 'diagnostic_record.dart';

abstract interface class DiagnosticStore {
  Future<String?> read();
  Future<void> write(String value);
}

abstract interface class DiagnosticSender {
  bool get available;
  Future<bool> send(DiagnosticRecord record);
  void cancel();
}

class FailureDiagnostics extends ChangeNotifier {
  FailureDiagnostics({this.store, this.sender, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static FailureDiagnostics instance = FailureDiagnostics();
  static const maximumRecords = 50;
  static const maximumBytes = 1024 * 1024;
  final DiagnosticStore? store;
  final DiagnosticSender? sender;
  final DateTime Function() _now;
  final _records = <DiagnosticRecord>[];
  final _failureIds = Expando<String>();
  final _requestIds = <String, String>{};
  Map<String, Object?> environment = const {};
  bool automaticSending = true;
  bool storageAvailable = true;
  bool _notifying = false;
  bool _disposed = false;
  int _generation = 0;
  int get generation => _generation;
  Future<void> _work = Future.value();
  Future<void> get settled => _work;
  List<DiagnosticRecord> get records => List.unmodifiable(_records.reversed);
  bool get remoteAvailable => sender?.available ?? false;

  Future<void> initialize() async {
    try {
      final raw = await store?.read();
      if (raw != null) {
        if (utf8.encode(raw).length > maximumBytes) {
          throw const FormatException('diagnostic store too large');
        }
        final json = jsonDecode(raw);
        if (json is! Map<String, Object?>) {
          throw const FormatException('invalid diagnostic store');
        }
        automaticSending = json['automaticSending'] != false;
        final entries = json['records'];
        if (entries is List) {
          _records.addAll(
            entries
                .map(DiagnosticRecord.fromJson)
                .whereType<DiagnosticRecord>(),
          );
        }
      }
      _prune();
    } on Object {
      // Diagnostics must remain usable in memory when its own disk is broken.
      storageAvailable = false;
      automaticSending = false;
    }
    if (storageAvailable) await _persist();
    _changed();
  }

  DiagnosticAttempt attempt(
    DiagnosticOperation operation, {
    String? sessionId,
  }) => DiagnosticAttempt(this, operation, _generation, sessionId: sessionId);

  bool _canAssociate(Object? error) =>
      error != null && error is! String && error is! num && error is! bool;
  String? idFor(Object? error) {
    final id = !_canAssociate(error) ? null : _failureIds[error!];
    return _records.any((record) => record.id == id) ? id : null;
  }

  String? capture(
    Object error, {
    StackTrace? stackTrace,
    ApiFailure? failure,
    DiagnosticStage? stage,
    DiagnosticOperation? operation,
  }) {
    final context = DiagnosticAttempt.current;
    if (context != null && context.generation != _generation) return null;
    final existing = idFor(error);
    if (existing != null) return existing;
    final api =
        failure ??
        (error is ApiFailure
            ? error
            : error is DioException
            ? ApiFailure.fromDio(error)
            : null);
    if (api?.isCancellation ?? false) return null;
    final resolvedOperation =
        operation ?? context?.operation ?? DiagnosticOperation.dartError;
    final dio = error is DioException
        ? error
        : api?.cause is DioException
        ? api!.cause! as DioException
        : null;
    if (dio?.type == DioExceptionType.cancel) return null;
    final requestId = safeDiagnosticId(api?.requestId) ?? context?.requestId;
    final key = requestId == null ? null : '${context?.id ?? ""}:$requestId';
    final previous = key == null ? null : _requestIds[key];
    if (previous != null) {
      if (_canAssociate(error)) _failureIds[error] = previous;
      return previous;
    }
    final id = const Uuid().v4();
    final shouldSend =
        api == null || shouldSendDiagnostic(api, resolvedOperation);
    final fields = sanitizeDiagnosticFields({
      ...environment,
      if (context != null) ...context.fields,
      'requestId': requestId,
      'httpStatus': api?.httpStatus ?? context?.httpStatus,
      'businessCode': api?.businessCode,
      'contractVersion': api?.contractVersion ?? context?.contractVersion,
      'responseReceived':
          dio?.response != null || (context?.responseReceived ?? false),
      'apiEnvelopeReceived':
          (context?.apiEnvelopeReceived ?? false) ||
          (dio?.response?.data is Map &&
              (dio!.response!.data as Map)['code'] is num),
      'errorType': (dio?.error ?? api?.cause ?? error).runtimeType.toString(),
      'stack': safeDiagnosticStack(stackTrace ?? dio?.stackTrace),
    });
    _records.add(
      DiagnosticRecord(
        id: id,
        createdAt: _now().toUtc(),
        operation: resolvedOperation,
        stage:
            stage ??
            (dio?.response != null && (dio!.response!.statusCode ?? 0) < 400
                ? DiagnosticStage.decode
                : context?.stage ?? DiagnosticStage.request),
        source: api?.effectiveSource ?? FailureSource.device,
        reason: api?.reason ?? FailureReason.unknown,
        shouldSend: shouldSend,
        pending: automaticSending && shouldSend,
        fields: fields,
      ),
    );
    if (_canAssociate(error)) _failureIds[error] = id;
    if (api != null) _failureIds[api] = id;
    if (key != null) _requestIds[key] = id;
    context?.failureId = id;
    _prune();
    _changed();
    _enqueue(() async {
      await _persist();
      await _sendPending();
    });
    return id;
  }

  Future<void> setAutomaticSending(bool enabled) async {
    automaticSending = enabled;
    if (!enabled) {
      sender?.cancel();
      for (var i = 0; i < _records.length; i++) {
        _records[i] = _records[i].withPending(false);
      }
    }
    _changed();
    _enqueue(_persist);
    await settled;
  }

  Future<void> clear() async {
    _generation++;
    sender?.cancel();
    _records.clear();
    _requestIds.clear();
    _changed();
    _enqueue(_persist);
    await settled;
  }

  void retryPending() => _enqueue(_sendPending);

  String export({String? id}) => const JsonEncoder.withIndent('  ').convert({
    'schemaVersion': 1,
    'records': records
        .where((record) => id == null || record.id == id)
        .map((record) => record.toJson())
        .toList(),
  });

  Future<void> _sendPending() async {
    _prune();
    if (!automaticSending || !remoteAvailable) return;
    final generation = _generation;
    for (final record in List<DiagnosticRecord>.of(_records)) {
      if (generation != _generation || !automaticSending) return;
      if (!record.pending || !record.shouldSend) continue;
      bool accepted;
      try {
        accepted = await sender!.send(record);
      } on Object {
        accepted = false;
      }
      if (generation != _generation || !automaticSending) return;
      if (!accepted) break;
      final index = _records.indexWhere((item) => item.id == record.id);
      if (index >= 0) _records[index] = record.withPending(false);
      await _persist();
    }
    _changed();
  }

  void _enqueue(Future<void> Function() action) {
    _work = _work.then((_) => action()).catchError((Object _) {
      storageAvailable = false;
      _changed();
    });
  }

  Future<void> _persist() async {
    _prune();
    if (store == null) return;
    try {
      await store?.write(
        jsonEncode({
          'automaticSending': automaticSending,
          'records': _records.map((record) => record.toJson()).toList(),
        }),
      );
      storageAvailable = true;
    } on Object {
      storageAvailable = false;
    }
    _changed();
  }

  void _prune() {
    final cutoff = _now().toUtc().subtract(const Duration(days: 7));
    _records.removeWhere(
      (r) =>
          r.createdAt.isBefore(cutoff) ||
          r.createdAt.isAfter(_now().toUtc().add(const Duration(minutes: 5))),
    );
    while (_records.length > maximumRecords ||
        (_records.isNotEmpty &&
            utf8
                    .encode(
                      jsonEncode(_records.map((r) => r.toJson()).toList()),
                    )
                    .length >
                maximumBytes - 1024)) {
      _records.removeAt(0);
    }
    final retained = _records.map((r) => r.id).toSet();
    _requestIds.removeWhere((key, value) => !retained.contains(value));
  }

  void _changed() {
    if (_notifying || _disposed) return;
    _notifying = true;
    scheduleMicrotask(() {
      _notifying = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    sender?.cancel();
    super.dispose();
  }
}

class DiagnosticAttempt {
  DiagnosticAttempt(
    this.diagnostics,
    this.operation,
    this.generation, {
    this.sessionId,
  }) : id = const Uuid().v4();
  static final _zoneKey = Object();
  static DiagnosticAttempt? get current =>
      Zone.current[_zoneKey] as DiagnosticAttempt?;
  final FailureDiagnostics diagnostics;
  final DiagnosticOperation operation;
  final int generation;
  final String id;
  final String? sessionId;
  final _watch = Stopwatch()..start();
  final _stages = <String>[];
  final statistics = <String, Object?>{};
  DiagnosticStage stage = DiagnosticStage.started;
  String? requestId;
  String? contractVersion;
  String? failureId;
  int? httpStatus;
  bool responseReceived = false;
  bool apiEnvelopeReceived = false;
  void mark(DiagnosticStage value) {
    stage = value;
    _stages.add(value.name);
  }

  Map<String, Object?> get fields => {
    ...statistics,
    'attemptId': id,
    'sessionId': sessionId,
    'elapsedMs': _watch.elapsedMilliseconds,
    'stages': _stages,
  };
  Future<T> run<T>(Future<T> Function() action) =>
      runZoned(action, zoneValues: {_zoneKey: this});
}

final failureDiagnosticsProvider = Provider<FailureDiagnostics>(
  (ref) => FailureDiagnostics.instance,
);

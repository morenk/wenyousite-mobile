import 'package:wenyousite_mobile/core/network/api_failure.dart';

enum DiagnosticOperation {
  apiRead,
  apiWrite,
  postCreate,
  postEdit,
  bodySave,
  mediaUpload,
  editorEncode,
  authRefresh,
  authLogout,
  flutterError,
  dartError,
}

enum DiagnosticStage {
  started,
  picking,
  preparing,
  uploadUrl,
  objectStorage,
  uploadConfirm,
  mediaProcessing,
  encode,
  authorize,
  request,
  response,
  decode,
  complete,
}

/// Only machine fields cross this boundary. Never pass exception messages,
/// document content, request URLs, account identifiers or arbitrary maps.
class DiagnosticRecord {
  const DiagnosticRecord({
    required this.id,
    required this.createdAt,
    required this.operation,
    required this.stage,
    required this.source,
    required this.reason,
    required this.shouldSend,
    required this.fields,
    this.pending = false,
  });

  final String id;
  final DateTime createdAt;
  final DiagnosticOperation operation;
  final DiagnosticStage stage;
  final FailureSource source;
  final FailureReason reason;
  final bool shouldSend;
  final bool pending;
  final Map<String, Object?> fields;

  DiagnosticRecord withPending(bool value) => DiagnosticRecord(
    id: id,
    createdAt: createdAt,
    operation: operation,
    stage: stage,
    source: source,
    reason: reason,
    shouldSend: shouldSend,
    fields: fields,
    pending: value,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'operation': operation.name,
    'stage': stage.name,
    'source': source.name,
    'reason': reason.name,
    'shouldSend': shouldSend,
    'pending': pending,
    'fields': sanitizeDiagnosticFields(fields),
  };

  static DiagnosticRecord? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final id = safeDiagnosticId(json['id']);
    final time = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final operation = _enumValue(DiagnosticOperation.values, json['operation']);
    final stage = _enumValue(DiagnosticStage.values, json['stage']);
    final source = _enumValue(FailureSource.values, json['source']);
    final reason = _enumValue(FailureReason.values, json['reason']);
    if (id == null ||
        time == null ||
        operation == null ||
        stage == null ||
        source == null ||
        reason == null) {
      return null;
    }
    return DiagnosticRecord(
      id: id,
      createdAt: time,
      operation: operation,
      stage: stage,
      source: source,
      reason: reason,
      shouldSend: json['shouldSend'] == true,
      pending: json['pending'] == true,
      fields: sanitizeDiagnosticFields(
        json['fields'] is Map<String, Object?>
            ? json['fields']! as Map<String, Object?>
            : const {},
      ),
    );
  }
}

T? _enumValue<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

String? safeDiagnosticId(Object? value) {
  if (value is! String) return null;
  return RegExp(
        r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$',
      ).hasMatch(value)
      ? value.toLowerCase()
      : null;
}

String? safeDiagnosticVersion(Object? value) =>
    value is String &&
        value.length <= 80 &&
        RegExp(r'^[0-9][0-9a-zA-Z.+_-]*$').hasMatch(value)
    ? value
    : null;

List<String> safeDiagnosticStack(StackTrace? stack) =>
    sanitizeDiagnosticStackLines(stack?.toString().split('\n') ?? const []);

List<String> sanitizeDiagnosticStackLines(Iterable<Object?> lines) {
  // Retain code coordinates only; a frame's function text can be supplied by
  // an exception and can contain arbitrary user input.
  final coordinate = RegExp(
    r'(?:package:(?:wenyousite_mobile|wenyou_api|flutter)/[a-zA-Z0-9_./-]+\.dart|dart:[a-zA-Z0-9_./-]+):(\d+):(\d+)',
  );
  return lines
      .whereType<String>()
      .map((line) => coordinate.firstMatch(line)?.group(0))
      .whereType<String>()
      .take(40)
      .toList(growable: false);
}

Map<String, Object?> sanitizeDiagnosticFields(Map<String, Object?> input) {
  final result = <String, Object?>{};
  for (final key in const ['sessionId', 'attemptId', 'requestId']) {
    final value = safeDiagnosticId(input[key]);
    if (value != null) result[key] = value;
  }
  for (final key in const [
    'appVersion',
    'build',
    'contractVersion',
    'osVersion',
  ]) {
    final value = safeDiagnosticVersion(input[key]);
    if (value != null) result[key] = value;
  }
  if (const [
    'android',
    'ios',
    'windows',
    'macos',
    'linux',
    'unknown',
  ].contains(input['os'])) {
    result['os'] = input['os'];
  }
  for (final key in const [
    'httpStatus',
    'businessCode',
    'elapsedMs',
    'characters',
    'images',
    'blocks',
  ]) {
    final value = input[key];
    if (value is int && value >= 0 && value <= 100000000) result[key] = value;
  }
  for (final key in const ['responseReceived', 'apiEnvelopeReceived']) {
    if (input[key] is bool) result[key] = input[key];
  }
  final type = input['errorType'];
  if (type is String &&
      RegExp(r'^[A-Za-z_][A-Za-z0-9_]{0,79}$').hasMatch(type)) {
    result['errorType'] = type;
  }
  final stack = input['stack'];
  if (stack is List) result['stack'] = sanitizeDiagnosticStackLines(stack);
  final stages = input['stages'];
  if (stages is List) {
    result['stages'] = stages
        .whereType<String>()
        .where(
          (name) => DiagnosticStage.values.any((stage) => stage.name == name),
        )
        .take(30)
        .toList(growable: false);
  }
  return Map.unmodifiable(result);
}

bool shouldSendDiagnostic(ApiFailure failure, DiagnosticOperation operation) {
  if (failure.isCancellation) return false;
  if (const {
        DiagnosticOperation.postCreate,
        DiagnosticOperation.postEdit,
        DiagnosticOperation.bodySave,
      }.contains(operation) &&
      const {40000, 40001, 40006, 40009}.contains(failure.businessCode)) {
    return true;
  }
  if (failure.effectiveSource == FailureSource.expected) return false;
  if (failure.businessCode == null &&
      failure.reason == FailureReason.validation) {
    return false;
  }
  if (failure.effectiveSource == FailureSource.network) {
    return operation != DiagnosticOperation.apiRead &&
        failure.hasUnknownWriteOutcome;
  }
  return true;
}

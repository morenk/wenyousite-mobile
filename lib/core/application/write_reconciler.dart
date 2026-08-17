import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';

/// The user-visible result of one write attempt.
///
/// [confirming] is emitted only through [WriteReconciler.onProgress]. The
/// returned result is always terminal unless the caller marks it discarded
/// because its page or request generation is no longer current.
enum WriteOutcomeStatus { completed, failed, confirming, indeterminate }

class WriteOutcome<WriteValue, Projection> {
  const WriteOutcome._({
    required this.status,
    this.writeValue,
    this.projection,
    this.failure,
    this.wasReconciled = false,
    this.isDiscarded = false,
  });

  const WriteOutcome.completed({
    WriteValue? writeValue,
    Projection? projection,
    bool wasReconciled = false,
  }) : this._(
         status: WriteOutcomeStatus.completed,
         writeValue: writeValue,
         projection: projection,
         wasReconciled: wasReconciled,
       );

  const WriteOutcome.failed(ApiFailure failure)
    : this._(status: WriteOutcomeStatus.failed, failure: failure);

  const WriteOutcome.confirming(ApiFailure failure)
    : this._(status: WriteOutcomeStatus.confirming, failure: failure);

  const WriteOutcome.indeterminate({
    ApiFailure? failure,
    Projection? projection,
    bool isDiscarded = false,
  }) : this._(
         status: WriteOutcomeStatus.indeterminate,
         failure: failure,
         projection: projection,
         isDiscarded: isDiscarded,
       );

  final WriteOutcomeStatus status;
  final WriteValue? writeValue;
  final Projection? projection;
  final ApiFailure? failure;
  final bool wasReconciled;

  /// A discarded result belongs to a disposed owner or an older action.
  /// Callers must not turn it into UI feedback or local state.
  final bool isDiscarded;

  String? get requestId => failure?.requestId;
}

typedef WriteFailureMapper = ApiFailure Function(Object error);

/// Confirms ambiguous writes by reading an authoritative projection once.
///
/// The write is never replayed here. A conflict is eligible for confirmation
/// only when the feature supplies its exact business code. A projection that
/// still shows the opposite state is deliberately inconclusive because the
/// original write may finish later.
class WriteReconciler {
  const WriteReconciler();

  Future<WriteOutcome<WriteValue, Projection>> run<WriteValue, Projection>({
    required Future<WriteValue> Function() write,
    required Future<Projection> Function() read,
    required bool Function(Projection projection) targetReached,
    required String failureMessage,
    Set<int> convergentBusinessCodes = const <int>{},
    bool Function()? isCurrent,
    void Function(WriteOutcome<WriteValue, Projection> outcome)? onProgress,
    WriteFailureMapper? mapFailure,
  }) async {
    bool current() => isCurrent?.call() ?? true;
    ApiFailure failureFor(Object error) =>
        mapFailure?.call(error) ?? mapApplicationFailure(error, failureMessage);

    try {
      final value = await write();
      if (!current()) {
        return const WriteOutcome.indeterminate(isDiscarded: true);
      }
      return WriteOutcome.completed(writeValue: value);
    } on Object catch (error) {
      final failure = failureFor(error);
      final canConverge =
          failure.hasUnknownWriteOutcome ||
          convergentBusinessCodes.contains(failure.businessCode);
      if (!canConverge) return WriteOutcome.failed(failure);
      if (!current()) {
        return WriteOutcome.indeterminate(failure: failure, isDiscarded: true);
      }

      onProgress?.call(WriteOutcome.confirming(failure));
      try {
        final projection = await read();
        if (!current()) {
          return WriteOutcome.indeterminate(
            failure: failure,
            projection: projection,
            isDiscarded: true,
          );
        }
        if (targetReached(projection)) {
          return WriteOutcome.completed(
            projection: projection,
            wasReconciled: true,
          );
        }
        return WriteOutcome.indeterminate(
          failure: failure,
          projection: projection,
        );
      } on Object {
        if (!current()) {
          return WriteOutcome.indeterminate(
            failure: failure,
            isDiscarded: true,
          );
        }
        return WriteOutcome.indeterminate(failure: failure);
      }
    }
  }
}

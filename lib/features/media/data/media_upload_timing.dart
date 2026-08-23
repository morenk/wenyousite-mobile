import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

enum MediaUploadTimingStage {
  inspectInput,
  encodeWebp,
  inspectOutput,
  normalizeTotal,
  requestUploadUrl,
  objectStoragePut,
  confirmUpload,
  remoteProcessing,
  pipelineTotal,
}

enum MediaUploadTimingOutcome { completed, failed }

typedef MediaUploadTimingWriter = void Function(String message);

class MediaUploadTiming {
  const MediaUploadTiming({this.enabled = false, this.writer});

  factory MediaUploadTiming.debug() => MediaUploadTiming(
    enabled: kDebugMode,
    writer: (message) =>
        developer.log(message, name: 'wenyou.media.performance'),
  );

  final bool enabled;
  final MediaUploadTimingWriter? writer;

  Future<T> measure<T>({
    required MediaUploadPurpose purpose,
    required MediaUploadTimingStage stage,
    required Future<T> Function() operation,
    int? inputBytes,
    int? Function(T value)? outputBytes,
  }) async {
    if (!enabled) return operation();
    final stopwatch = Stopwatch()..start();
    var outcome = MediaUploadTimingOutcome.failed;
    late T value;
    try {
      value = await operation();
      outcome = MediaUploadTimingOutcome.completed;
      return value;
    } finally {
      stopwatch.stop();
      record(
        purpose: purpose,
        stage: stage,
        elapsed: stopwatch.elapsed,
        outcome: outcome,
        inputBytes: inputBytes,
        outputBytes:
            outcome == MediaUploadTimingOutcome.completed && outputBytes != null
            ? outputBytes(value)
            : null,
      );
    }
  }

  void record({
    required MediaUploadPurpose purpose,
    required MediaUploadTimingStage stage,
    required Duration elapsed,
    required MediaUploadTimingOutcome outcome,
    int? inputBytes,
    int? outputBytes,
  }) {
    if (!enabled) return;
    final fields = <String>[
      'purpose=${purpose.name}',
      'stage=${stage.name}',
      'outcome=${outcome.name}',
      'elapsedMs=${elapsed.inMilliseconds}',
      if (inputBytes != null) 'inputBytes=$inputBytes',
      if (outputBytes != null) 'outputBytes=$outputBytes',
    ];
    writer?.call(fields.join(' '));
  }
}

final mediaUploadTimingProvider = Provider<MediaUploadTiming>((ref) {
  return MediaUploadTiming.debug();
});

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

enum MediaUploadTaskPhase {
  idle,
  picking,
  preparing,
  uploading,
  confirming,
  processing,
  failed,
}

class MediaUploadFailure {
  const MediaUploadFailure({
    required this.userMessage,
    required this.canRetry,
    this.businessCode,
    this.requestId,
  });

  final String userMessage;
  final bool canRetry;
  final int? businessCode;
  final String? requestId;
}

class MediaUploadTaskState {
  const MediaUploadTaskState({
    this.phase = MediaUploadTaskPhase.idle,
    this.progress,
    this.failure,
  });

  final MediaUploadTaskPhase phase;
  final MediaUploadProgress? progress;
  final MediaUploadFailure? failure;

  bool get isBusy => switch (phase) {
    MediaUploadTaskPhase.picking ||
    MediaUploadTaskPhase.preparing ||
    MediaUploadTaskPhase.uploading ||
    MediaUploadTaskPhase.confirming ||
    MediaUploadTaskPhase.processing => true,
    MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => false,
  };
}

final editorImagePickerPortProvider = Provider<EditorImagePicker>((ref) {
  throw StateError('EditorImagePicker has not been bound at the app boundary.');
});

final mediaUploadGatewayPortProvider = Provider<MediaUploadGateway>((ref) {
  throw StateError(
    'MediaUploadGateway has not been bound at the app boundary.',
  );
});

final mediaUploadTaskControllerProvider = NotifierProvider.autoDispose
    .family<MediaUploadTaskController, MediaUploadTaskState, Object>(
      MediaUploadTaskController.new,
      dependencies: [
        editorImagePickerPortProvider,
        mediaUploadGatewayPortProvider,
      ],
    );

abstract interface class MediaUploadTask {
  MediaUploadTaskState get state;

  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input);

  void cancel();

  void reset();
}

class MediaUploadTaskController
    extends AutoDisposeFamilyNotifier<MediaUploadTaskState, Object>
    implements MediaUploadTask {
  MediaUploadOperation<UploadedEditorImage>? _operation;
  Completer<void>? _cancelSignal;
  MediaUploadInput? _retryInput;
  Future<UploadedEditorImage?>? _activeFuture;
  var _runId = 0;
  var _disposed = false;

  @override
  MediaUploadTaskState build(Object arg) {
    _disposed = false;
    ref.onDispose(_dispose);
    return const MediaUploadTaskState();
  }

  Future<UploadedEditorImage?> pickAndUpload() {
    if (_activeFuture == null) _retryInput = null;
    return _start();
  }

  Future<UploadedEditorImage?> retryUpload() {
    final active = _activeFuture;
    if (active != null) return active;
    final input = _retryInput;
    if (input == null) return Future<UploadedEditorImage?>.value();
    return _start(input: input);
  }

  @override
  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input) {
    if (_activeFuture == null) _retryInput = null;
    return _start(input: input);
  }

  @override
  void cancel() {
    if (!state.isBusy && _operation == null) return;
    _runId += 1;
    _activeFuture = null;
    _retryInput = null;
    final operation = _operation;
    _operation = null;
    final cancelSignal = _cancelSignal;
    _cancelSignal = null;
    state = const MediaUploadTaskState();
    if (cancelSignal != null && !cancelSignal.isCompleted) {
      cancelSignal.complete();
    }
    operation?.cancel();
  }

  @override
  void reset() {
    if (state.isBusy) {
      cancel();
      return;
    }
    _retryInput = null;
    state = const MediaUploadTaskState();
  }

  Future<UploadedEditorImage?> _start({MediaUploadInput? input}) {
    final active = _activeFuture;
    if (active != null) return active;
    late final Future<UploadedEditorImage?> future;
    future = _run(input: input).whenComplete(() {
      if (identical(_activeFuture, future)) _activeFuture = null;
    });
    _activeFuture = future;
    return future;
  }

  Future<UploadedEditorImage?> _run({MediaUploadInput? input}) async {
    final runId = ++_runId;
    final cancelSignal = Completer<void>();
    _cancelSignal = cancelSignal;
    var selected = input;
    var acceptProgress = true;
    try {
      if (selected == null) {
        state = const MediaUploadTaskState(phase: MediaUploadTaskPhase.picking);
        final selection = await _untilCancelled(
          ref.read(editorImagePickerPortProvider).pickFromGallery(),
          cancelSignal,
        );
        if (identical(selection, _cancelled)) return null;
        selected = selection as MediaUploadInput?;
        if (!_isCurrent(runId)) return null;
        if (selected == null) {
          state = const MediaUploadTaskState();
          return null;
        }
      }

      _retryInput = selected;
      const preparing = MediaUploadProgress(stage: MediaUploadStage.preparing);
      state = const MediaUploadTaskState(
        phase: MediaUploadTaskPhase.preparing,
        progress: preparing,
      );
      final operation = ref
          .read(mediaUploadGatewayPortProvider)
          .startImageUpload(
            selected,
            onProgress: (progress) {
              if (!acceptProgress || !_isCurrent(runId)) return;
              state = MediaUploadTaskState(
                phase: _phaseFor(progress.stage),
                progress: progress,
              );
            },
          );
      if (!_isCurrent(runId)) {
        operation.cancel();
        return null;
      }
      _operation = operation;
      final outcome = await _untilCancelled(operation.result, cancelSignal);
      acceptProgress = false;
      if (identical(outcome, _cancelled)) return null;
      final result = outcome as UploadedEditorImage;
      if (!_isCurrent(runId)) return null;
      if (identical(_operation, operation)) _operation = null;
      _retryInput = null;
      state = const MediaUploadTaskState();
      return result;
    } on Object catch (error) {
      acceptProgress = false;
      if (!_isCurrent(runId)) return null;
      _operation = null;
      state = MediaUploadTaskState(
        phase: MediaUploadTaskPhase.failed,
        failure: _failureFor(error, canRetry: _retryInput != null),
      );
      return null;
    } finally {
      acceptProgress = false;
      if (identical(_cancelSignal, cancelSignal)) _cancelSignal = null;
    }
  }

  Future<Object?> _untilCancelled<T>(
    Future<T> operation,
    Completer<void> cancelSignal,
  ) {
    return Future.any<Object?>([
      operation.then<Object?>((value) => value),
      cancelSignal.future.then<Object?>((_) => _cancelled),
    ]);
  }

  bool _isCurrent(int runId) => !_disposed && runId == _runId;

  MediaUploadFailure _failureFor(Object error, {required bool canRetry}) {
    if (error is ApiFailure) {
      return MediaUploadFailure(
        userMessage: error.userMessage,
        canRetry: canRetry,
        businessCode: error.businessCode,
        requestId: error.requestId,
      );
    }
    return MediaUploadFailure(userMessage: '图片没有上传成功，请重试。', canRetry: canRetry);
  }

  MediaUploadTaskPhase _phaseFor(MediaUploadStage stage) => switch (stage) {
    MediaUploadStage.preparing => MediaUploadTaskPhase.preparing,
    MediaUploadStage.uploading => MediaUploadTaskPhase.uploading,
    MediaUploadStage.confirming => MediaUploadTaskPhase.confirming,
    MediaUploadStage.processing => MediaUploadTaskPhase.processing,
  };

  void _dispose() {
    _disposed = true;
    _runId += 1;
    _activeFuture = null;
    _retryInput = null;
    final operation = _operation;
    _operation = null;
    final cancelSignal = _cancelSignal;
    _cancelSignal = null;
    if (cancelSignal != null && !cancelSignal.isCompleted) {
      cancelSignal.complete();
    }
    operation?.cancel();
  }
}

const _cancelled = Object();

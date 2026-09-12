import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/failure_mapping.dart';
import 'package:wenyousite_mobile/core/application/user_facing_failure.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
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
  processingPending,
  failed,
}

class MediaUploadFailure {
  const MediaUploadFailure({
    required this.failure,
    required this.presentation,
    required this.canRetry,
    this.diagnosticId,
  });

  /// Keep the typed cause and its diagnostic association intact across features.
  final ApiFailure failure;
  final UserFacingFailure presentation;
  final bool canRetry;
  final String? diagnosticId;

  UserFacingFailure get resolvedPresentation => presentation;
  String get userMessage => presentation.message;
  int? get businessCode => failure.businessCode;
  String? get requestId => failure.requestId;
}

class MediaUploadTaskState {
  const MediaUploadTaskState({
    this.phase = MediaUploadTaskPhase.idle,
    this.progress,
    this.failure,
    this.pendingUpload,
  });

  final PendingMediaUpload? pendingUpload;
  final MediaUploadTaskPhase phase;
  final MediaUploadProgress? progress;
  final MediaUploadFailure? failure;

  bool get isBusy => switch (phase) {
    MediaUploadTaskPhase.picking ||
    MediaUploadTaskPhase.preparing ||
    MediaUploadTaskPhase.uploading ||
    MediaUploadTaskPhase.confirming ||
    MediaUploadTaskPhase.processing => true,
    MediaUploadTaskPhase.idle ||
    MediaUploadTaskPhase.processingPending ||
    MediaUploadTaskPhase.failed => false,
  };

  String get progressLabel => switch (phase) {
    MediaUploadTaskPhase.picking => '正在打开相册…',
    MediaUploadTaskPhase.preparing => '正在准备图片…',
    MediaUploadTaskPhase.uploading when progress?.fraction != null =>
      '正在上传图片 ${((progress!.fraction ?? 0) * 100).round()}%',
    MediaUploadTaskPhase.uploading => '正在上传图片…',
    MediaUploadTaskPhase.confirming => '正在确认图片…',
    MediaUploadTaskPhase.processing => '图片正在安全处理中…',
    MediaUploadTaskPhase.processingPending => '图片仍在处理中，可稍后继续查询。',
    MediaUploadTaskPhase.idle || MediaUploadTaskPhase.failed => '',
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

/// 组合根注入账号代次；访问令牌刷新不应取消上传。
final mediaUploadSessionScopePortProvider = Provider<Object?>((ref) => null);

final mediaUploadTaskControllerProvider = NotifierProvider.autoDispose
    .family<MediaUploadTaskController, MediaUploadTaskState, Object>(
      MediaUploadTaskController.new,
      dependencies: [
        editorImagePickerPortProvider,
        mediaUploadGatewayPortProvider,
        mediaUploadSessionScopePortProvider,
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
  PendingMediaUpload? _pendingUpload;
  Future<UploadedEditorImage?>? _activeFuture;
  var _runId = 0;
  var _disposed = false;

  @override
  MediaUploadTaskState build(Object arg) {
    ref.watch(mediaUploadSessionScopePortProvider);
    _disposed = false;
    ref.onDispose(_dispose);
    return const MediaUploadTaskState();
  }

  Future<UploadedEditorImage?> pickAndUpload() {
    if (_activeFuture == null) {
      _retryInput = null;
      _pendingUpload = null;
    }
    return _start();
  }

  Future<UploadedEditorImage?> retryUpload() {
    final active = _activeFuture;
    if (active != null) return active;
    if (_pendingUpload != null && state.failure?.canRetry == false) {
      return Future.value();
    }
    final input = _retryInput;
    if (input == null) return Future<UploadedEditorImage?>.value();
    return _start(input: input, pending: _pendingUpload);
  }

  @override
  Future<UploadedEditorImage?> uploadInput(MediaUploadInput input) {
    if (_activeFuture == null) {
      _retryInput = null;
      _pendingUpload = null;
    }
    return _start(input: input);
  }

  @override
  void cancel() {
    if (!state.isBusy && _operation == null && _pendingUpload == null) return;
    _runId += 1;
    _activeFuture = null;
    _retryInput = null;
    _pendingUpload = null;
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
    _pendingUpload = null;
    state = const MediaUploadTaskState();
  }

  Future<UploadedEditorImage?> _start({
    MediaUploadInput? input,
    PendingMediaUpload? pending,
  }) {
    final active = _activeFuture;
    if (active != null) return active;
    late final Future<UploadedEditorImage?> future;
    future = _run(input: input, pending: pending).whenComplete(() {
      if (identical(_activeFuture, future)) _activeFuture = null;
    });
    _activeFuture = future;
    return future;
  }

  Future<UploadedEditorImage?> _run({
    MediaUploadInput? input,
    PendingMediaUpload? pending,
  }) async {
    final runId = ++_runId;
    final cancelSignal = Completer<void>();
    _cancelSignal = cancelSignal;
    var selected = input;
    var acceptProgress = true;
    try {
      if (selected == null) {
        DiagnosticAttempt.current?.mark(DiagnosticStage.picking);
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
      DiagnosticAttempt.current?.mark(DiagnosticStage.preparing);
      const preparing = MediaUploadProgress(stage: MediaUploadStage.preparing);
      state = const MediaUploadTaskState(
        phase: MediaUploadTaskPhase.preparing,
        progress: preparing,
      );
      if (!selected.isMaterialized) {
        final materialized = await _untilCancelled(
          selected.materialize(),
          cancelSignal,
        );
        if (identical(materialized, _cancelled)) return null;
        selected = materialized as MediaUploadInput;
        if (!_isCurrent(runId)) return null;
        _retryInput = selected;
      }
      void onProgress(MediaUploadProgress progress) {
        if (!acceptProgress || !_isCurrent(runId)) return;
        state = MediaUploadTaskState(
          phase: _phaseFor(progress.stage),
          progress: progress,
        );
      }

      final gateway = ref.read(mediaUploadGatewayPortProvider);
      final operation = pending == null
          ? gateway.startImageUpload(selected, onProgress: onProgress)
          : gateway is ResumableMediaUploadGateway
          ? (gateway as ResumableMediaUploadGateway).resumeImageProcessing(
              pending,
              onProgress: onProgress,
            )
          : throw const ApiFailure(
              source: FailureSource.device,
              reason: FailureReason.unknown,
              recoveryAction: FailureRecoveryAction.reopen,
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
      _pendingUpload = null;
      state = const MediaUploadTaskState();
      return result;
    } on MediaProcessingLookupFailure catch (lookup) {
      acceptProgress = false;
      if (!_isCurrent(runId)) return null;
      _operation = null;
      _pendingUpload = lookup.upload;
      final cause = mapApplicationFailure(lookup.cause, '图片查询失败，请稍后继续查询。');
      final canRetry =
          !{
            FailureReason.unauthenticated,
            FailureReason.sessionInvalid,
            FailureReason.permissionDenied,
            FailureReason.notFound,
          }.contains(cause.reason) &&
          !{401, 403, 404}.contains(cause.httpStatus);
      state = MediaUploadTaskState(
        phase: MediaUploadTaskPhase.failed,
        pendingUpload: lookup.upload,
        failure: MediaUploadFailure(
          failure: cause,
          canRetry: canRetry,
          presentation: UserFacingFailure.fromApi(
            cause,
            title: '图片查询失败',
            retainContent: true,
          ),
        ),
      );
      return null;
    } on MediaProcessingPending catch (pending) {
      acceptProgress = false;
      if (!_isCurrent(runId)) return null;
      _operation = null;
      _pendingUpload = pending.upload;
      state = MediaUploadTaskState(
        phase: MediaUploadTaskPhase.processingPending,
        pendingUpload: pending.upload,
        failure: const MediaUploadFailure(
          failure: ApiFailure(
            source: FailureSource.expected,
            reason: FailureReason.timeout,
          ),
          presentation: UserFacingFailure(
            title: '图片仍在处理中',
            message: '已保留上传结果，继续查询无需重新上传。',
            recoveryAction: FailureRecoveryAction.retry,
            placement: FailurePresentationPlacement.inline,
            retainContent: true,
            actionLabel: '继续查询',
          ),
          canRetry: true,
        ),
      );
      return null;
    } on Object catch (error, stack) {
      acceptProgress = false;
      if (!_isCurrent(runId)) return null;
      _pendingUpload = null;
      _operation = null;
      state = MediaUploadTaskState(
        phase: MediaUploadTaskPhase.failed,
        failure: _failureFor(error, stack, canRetry: _retryInput != null),
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

  MediaUploadFailure _failureFor(
    Object error,
    StackTrace stack, {
    required bool canRetry,
  }) {
    final diagnosticId = FailureDiagnostics.instance.capture(
      error,
      stackTrace: stack,
      operation: DiagnosticOperation.mediaUpload,
    );
    if (error is ApiFailure) {
      return MediaUploadFailure(
        failure: error,
        diagnosticId: diagnosticId,
        presentation: UserFacingFailure.fromApi(
          error,
          title: '图片上传失败',
          objectName: '图片',
          operationName: '上传图片',
          retainContent: true,
          treatAsWrite: true,
        ),
        canRetry: canRetry,
      );
    }
    return MediaUploadFailure(
      failure: mapApplicationFailure(error, '图片没有上传成功，请重试。'),
      diagnosticId: diagnosticId,
      presentation: const UserFacingFailure(
        title: '图片上传失败',
        message: '图片没有上传成功，请重试。',
        recoveryAction: FailureRecoveryAction.retry,
        placement: FailurePresentationPlacement.inline,
        retainContent: true,
        actionLabel: '重试',
      ),
      canRetry: canRetry,
    );
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
    _pendingUpload = null;
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

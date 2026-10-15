import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/diagnostics/network_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/media_display_mapper.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_timing.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_normalizer.dart';

typedef MediaUploadDelay = Future<void> Function(Duration duration);

const _mediaProcessingFailure = ApiFailure(
  source: FailureSource.service,
  reason: FailureReason.validation,
  recoveryAction: FailureRecoveryAction.retry,
  diagnosticCode: 'media_processing_failed',
);

abstract interface class MediaUploadRepository {
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  });
}

abstract interface class ResumableMediaUploadRepository {
  Future<UploadedEditorImage> resumeImageProcessing(
    PendingMediaUpload upload, {
    CancelToken? cancelToken,
  });
}

abstract interface class RetryableMediaUploadRepository {
  Future<UploadedEditorImage> retryImageUpload(
    MediaUploadInput input,
    PendingMediaUpload upload, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  });
}

class ApiMediaUploadRepository
    implements
        MediaUploadRepository,
        ResumableMediaUploadRepository,
        RetryableMediaUploadRepository {
  ApiMediaUploadRepository(
    this._api,
    this._uploadDio, {
    MediaUploadDelay? delay,
    int maxPollAttempts = 30,
    this.timing = const MediaUploadTiming(),
    MediaUploadWorkCoordinator? workCoordinator,
  }) : _delay = delay ?? Future<void>.delayed,
       workCoordinator = workCoordinator ?? MediaUploadWorkCoordinator(),
       _maxPollAttempts = maxPollAttempts < 1 ? 1 : maxPollAttempts;

  static const maxImageBytes = maxMediaImageBytes;
  static const allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  };
  static const _allowedInsecureMediaHosts = {
    'localhost',
    '127.0.0.1',
    '::1',
    '10.0.2.2',
  };
  final MediaApi _api;
  final Dio _uploadDio;
  final MediaUploadDelay _delay;
  final int _maxPollAttempts;
  final MediaUploadTiming timing;
  final MediaUploadWorkCoordinator workCoordinator;

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) => _uploadImage(input, cancelToken: cancelToken, onProgress: onProgress);

  Future<UploadedEditorImage> _uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
    PendingMediaUpload? existingUpload,
  }) async {
    final size = input.bytes.length;
    if (size < 1) {
      throw const ApiFailure(userMessage: '图片文件不能为空。');
    }
    if (size > maxImageBytes) {
      throw const ApiFailure(userMessage: '图片大小不能超过 10MB。');
    }
    final contentType = _contentTypeFor(input);
    if (contentType == null) {
      throw const ApiFailure(userMessage: '仅支持 JPG、PNG、GIF 和 WebP 图片。');
    }
    _throwIfCancelled(cancelToken);

    try {
      onProgress?.call(
        const MediaUploadProgress(stage: MediaUploadStage.preparing),
      );
      final upload = await timing.measure<UploadUrlResponseDto?>(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.requestUploadUrl,
        inputBytes: size,
        operation: () async => existingUpload != null
            ? (await _api.mediaReissueUploadUrl(
                id: existingUpload.mediaId,
                cancelToken: cancelToken,
              )).data?.data
            : (await _api.mediaGetUploadUrl(
                createUploadUrlDto: CreateUploadUrlDto(
                  (builder) => builder
                    ..filename = input.filename
                    ..contentType = _contentTypeEnum(contentType)
                    ..size = size
                    ..purpose = _purposeEnum(input.purpose),
                ),
                cancelToken: cancelToken,
              )).data?.data,
      );
      if (upload == null) {
        throw const ApiFailure(userMessage: '图片上传失败，请重试。');
      }
      if (existingUpload != null && upload.mediaId != existingUpload.mediaId) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'media_reissue_identity_mismatch',
        );
      }
      final contentSha256 = sha256.convert(input.bytes).toString();
      final pendingTransfer = PendingMediaUpload(
        mediaId: upload.mediaId,
        purpose: input.purpose,
        needsTransfer: true,
        contentSha256: contentSha256,
      );
      onProgress?.call(
        MediaUploadProgress(
          stage: MediaUploadStage.preparing,
          pendingUpload: pendingTransfer,
        ),
      );
      final uploadUri = Uri.tryParse(upload.uploadUrl);
      if (uploadUri == null || !_isSafeMediaUri(uploadUri)) {
        throw const ApiFailure(userMessage: '图片上传地址无法安全使用。');
      }
      try {
        onProgress?.call(
          MediaUploadProgress(
            stage: MediaUploadStage.uploading,
            sentBytes: 0,
            totalBytes: size,
            pendingUpload: pendingTransfer,
          ),
        );
        await timing.measure<void>(
          purpose: input.purpose,
          stage: MediaUploadTimingStage.objectStoragePut,
          inputBytes: size,
          operation: () => _uploadDio.putUri<void>(
            uploadUri,
            data: input.bytes,
            options: Options(
              contentType: contentType,
              headers: {'Content-Length': size},
              responseType: ResponseType.plain,
              sendTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(seconds: 20),
            ),
            cancelToken: cancelToken,
            onSendProgress: (sent, total) {
              onProgress?.call(
                MediaUploadProgress(
                  stage: MediaUploadStage.uploading,
                  sentBytes: sent,
                  totalBytes: total > 0 ? total : size,
                ),
              );
            },
          ),
        );
      } on DioException catch (error) {
        if (CancelToken.isCancel(error)) rethrow;
        throw MediaProcessingLookupFailure(
          pendingTransfer,
          ApiFailure.fromDio(error),
          transferFailed: true,
        );
      }

      _throwIfCancelled(cancelToken);
      final pendingConfirmation = PendingMediaUpload(
        mediaId: upload.mediaId,
        purpose: input.purpose,
        needsConfirmation: true,
        contentSha256: contentSha256,
      );
      onProgress?.call(
        MediaUploadProgress(
          stage: MediaUploadStage.confirming,
          sentBytes: size,
          totalBytes: size,
          pendingUpload: pendingConfirmation,
        ),
      );
      final confirmEnvelope = await timing.measure(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.confirmUpload,
        inputBytes: size,
        operation: () => _api
            .mediaConfirmUpload(
              confirmUploadDto: ConfirmUploadDto(
                (builder) => builder.mediaId = upload.mediaId,
              ),
              cancelToken: cancelToken,
            )
            .catchError((Object error) {
              if (cancelToken?.isCancelled == true) throw error;
              throw _confirmationFailure(pendingConfirmation, error);
            }),
      );
      final confirmation = confirmEnvelope.data?.data;
      if (confirmation == null) {
        throw MediaProcessingLookupFailure(
          pendingConfirmation,
          const ApiFailure(userMessage: '图片上传失败，请重试。'),
        );
      }
      final confirmed = confirmation.media;
      _validateUploadIdentity(confirmed, upload.mediaId, input.purpose);
      if (confirmed.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(confirmed, input.purpose);
      }
      if (confirmed.status == MediaResponseDtoStatusEnum.FAILED) {
        throw _mediaProcessingFailure;
      }

      onProgress?.call(
        MediaUploadProgress(
          stage: MediaUploadStage.processing,
          sentBytes: size,
          totalBytes: size,
          pendingUpload: PendingMediaUpload(
            mediaId: upload.mediaId,
            purpose: input.purpose,
          ),
        ),
      );
      return timing.measure(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.remoteProcessing,
        inputBytes: size,
        operation: () => _waitForCompletedUpload(
          mediaId: upload.mediaId,
          purpose: input.purpose,
          cancelToken: cancelToken,
        ),
      );
    } on ApiFailure {
      rethrow;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw ApiFailure(userMessage: '图片上传已取消。', cause: error);
      }
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<UploadedEditorImage> retryImageUpload(
    MediaUploadInput input,
    PendingMediaUpload upload, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) async {
    try {
      _throwIfCancelled(cancelToken);
      if (input.purpose != upload.purpose) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'media_retry_purpose_mismatch',
        );
      }
      final response = await workCoordinator.query(
        () => _api.mediaGetMedia(id: upload.mediaId, cancelToken: cancelToken),
      );
      final media = response.data?.data;
      if (media == null) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'media_query_missing_data',
        );
      }
      _validateUploadIdentity(media, upload.mediaId, upload.purpose);
      if (media.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(media, upload.purpose);
      }
      if (media.status == MediaResponseDtoStatusEnum.FAILED) {
        throw _mediaProcessingFailure;
      }
      if (media.status != MediaResponseDtoStatusEnum.UPLOADING) {
        onProgress?.call(
          MediaUploadProgress(
            stage: MediaUploadStage.processing,
            pendingUpload: PendingMediaUpload(
              mediaId: upload.mediaId,
              purpose: upload.purpose,
            ),
          ),
        );
        return await _waitForCompletedUpload(
          mediaId: upload.mediaId,
          purpose: upload.purpose,
          cancelToken: cancelToken,
        );
      }
      // 同一对象必须仍对应同一归一化输入，不能把新文件写到旧身份。
      if (media.size != input.bytes.length ||
          media.contentType != _contentTypeFor(input) ||
          (upload.contentSha256 != null &&
              upload.contentSha256 != sha256.convert(input.bytes).toString())) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'media_retry_input_mismatch',
        );
      }
      return await _uploadImage(
        input,
        existingUpload: upload,
        cancelToken: cancelToken,
        onProgress: onProgress,
      );
    } on MediaProcessingLookupFailure {
      rethrow;
    } on MediaProcessingPending {
      rethrow;
    } on Object catch (error) {
      if (cancelToken?.isCancelled == true) rethrow;
      throw MediaProcessingLookupFailure(
        upload,
        error is DioException ? ApiFailure.fromDio(error) : error,
      );
    }
  }

  MediaProcessingLookupFailure _confirmationFailure(
    PendingMediaUpload upload,
    Object error,
  ) {
    final cause = error is DioException ? ApiFailure.fromDio(error) : error;
    final missing = cause is ApiFailure && cause.businessCode == 40419;
    return MediaProcessingLookupFailure(
      missing
          ? PendingMediaUpload(
              mediaId: upload.mediaId,
              purpose: upload.purpose,
              needsTransfer: true,
              contentSha256: upload.contentSha256,
            )
          : upload,
      cause,
    );
  }

  Future<UploadedEditorImage> _waitForCompletedUpload({
    required String mediaId,
    required MediaUploadPurpose purpose,
    CancelToken? cancelToken,
  }) async {
    final pending = PendingMediaUpload(mediaId: mediaId, purpose: purpose);
    await _wait(const Duration(milliseconds: 500), cancelToken);
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      final statusEnvelope = await workCoordinator
          .query(() {
            _throwIfCancelled(cancelToken);
            return _api.mediaGetMedia(id: mediaId, cancelToken: cancelToken);
          })
          .catchError((Object error) {
            if (cancelToken?.isCancelled == true) throw error;
            throw MediaProcessingLookupFailure(
              pending,
              error is DioException ? ApiFailure.fromDio(error) : error,
            );
          });
      final media = statusEnvelope.data?.data;
      if (media == null) {
        throw MediaProcessingLookupFailure(
          pending,
          const ApiFailure.invalidResponse(
            diagnosticCode: 'media_query_missing_data',
          ),
        );
      }
      if (media.id != mediaId) {
        throw const ApiFailure.invalidResponse(
          diagnosticCode: 'media_query_identity_mismatch',
        );
      }
      if (media.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(media, purpose);
      }
      if (media.status == MediaResponseDtoStatusEnum.FAILED) {
        throw _mediaProcessingFailure;
      }
      if (attempt + 1 < _maxPollAttempts) {
        await _wait(const Duration(seconds: 1), cancelToken);
      }
    }
    throw MediaProcessingPending(pending);
  }

  @override
  Future<UploadedEditorImage> resumeImageProcessing(
    PendingMediaUpload upload, {
    CancelToken? cancelToken,
  }) async {
    if (upload.needsConfirmation || upload.needsTransfer) {
      MediaResponseDto? media;
      try {
        final existing = await workCoordinator.query(() {
          _throwIfCancelled(cancelToken);
          return _api.mediaGetMedia(
            id: upload.mediaId,
            cancelToken: cancelToken,
          );
        });
        media = existing.data?.data;
        if (media == null || media.id != upload.mediaId) {
          throw const ApiFailure.invalidResponse(
            diagnosticCode: 'media_query_identity_mismatch',
          );
        }
        _validateUploadIdentity(media, upload.mediaId, upload.purpose);
        if (media.status == MediaResponseDtoStatusEnum.UPLOADING) {
          if (upload.needsTransfer) {
            throw const ApiFailure(
              source: FailureSource.expected,
              diagnosticCode: 'media_transfer_pending',
            );
          }
          final result = await workCoordinator.transfer(() {
            _throwIfCancelled(cancelToken);
            return _api.mediaConfirmUpload(
              confirmUploadDto: ConfirmUploadDto(
                (builder) => builder.mediaId = upload.mediaId,
              ),
              cancelToken: cancelToken,
            );
          });
          media = result.data?.data.media;
        }
        if (media == null) {
          throw const ApiFailure.invalidResponse(
            diagnosticCode: 'media_confirmation_missing_data',
          );
        }
      } on Object catch (error) {
        if (cancelToken?.isCancelled == true) rethrow;
        throw _confirmationFailure(upload, error);
      }
      _validateUploadIdentity(media, upload.mediaId, upload.purpose);
      if (media.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(media, upload.purpose);
      }
      if (media.status == MediaResponseDtoStatusEnum.FAILED) {
        throw _mediaProcessingFailure;
      }
    }
    return _waitForCompletedUpload(
      mediaId: upload.mediaId,
      purpose: upload.purpose,
      cancelToken: cancelToken,
    );
  }

  String? _contentTypeFor(MediaUploadInput input) {
    final declared = input.declaredContentType?.toLowerCase().trim();
    final detected = lookupMimeType(
      '',
      headerBytes: input.bytes.take(32).toList(growable: false),
    )?.toLowerCase();
    if (!allowedContentTypes.contains(detected)) return null;
    if (allowedContentTypes.contains(declared) && declared != detected) {
      return null;
    }
    return detected;
  }

  void _validateUploadIdentity(
    MediaResponseDto media,
    String mediaId,
    MediaUploadPurpose purpose,
  ) {
    if (media.id != mediaId) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'media_confirmation_identity_mismatch',
      );
    }
    if (!_matchesPurpose(media.purpose, purpose)) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'media_confirmation_purpose_mismatch',
      );
    }
  }

  CreateUploadUrlDtoContentTypeEnum _contentTypeEnum(String value) {
    return switch (value) {
      'image/jpeg' => CreateUploadUrlDtoContentTypeEnum.imageSlashJpeg,
      'image/png' => CreateUploadUrlDtoContentTypeEnum.imageSlashPng,
      'image/gif' => CreateUploadUrlDtoContentTypeEnum.imageSlashGif,
      'image/webp' => CreateUploadUrlDtoContentTypeEnum.imageSlashWebp,
      _ => throw const ApiFailure(userMessage: '图片类型不受支持。'),
    };
  }

  CreateUploadUrlDtoPurposeEnum _purposeEnum(MediaUploadPurpose purpose) {
    return switch (purpose) {
      MediaUploadPurpose.avatar => CreateUploadUrlDtoPurposeEnum.AVATAR,
      MediaUploadPurpose.profileCover =>
        CreateUploadUrlDtoPurposeEnum.PROFILE_COVER,
      MediaUploadPurpose.directMessage =>
        CreateUploadUrlDtoPurposeEnum.DIRECT_MESSAGE,
      MediaUploadPurpose.moment => CreateUploadUrlDtoPurposeEnum.MOMENT,
      MediaUploadPurpose.momentComment =>
        CreateUploadUrlDtoPurposeEnum.MOMENT_COMMENT,
      MediaUploadPurpose.richContent =>
        CreateUploadUrlDtoPurposeEnum.RICH_CONTENT,
      MediaUploadPurpose.stickerSource =>
        CreateUploadUrlDtoPurposeEnum.STICKER_SOURCE,
    };
  }

  UploadedEditorImage _completedImage(
    MediaResponseDto media,
    MediaUploadPurpose expectedPurpose,
  ) {
    if (!_matchesPurpose(media.purpose, expectedPurpose)) {
      throw const ApiFailure(userMessage: '图片用途与当前操作不一致，请重新选择。');
    }
    if (media.display case final display?) _safeUrl(display.url);
    return UploadedEditorImage(
      display: mapMediaDisplay(media.display),
      mediaId: media.id,
      url: _safeUrl(media.url),
      thumbnailUrl: _optionalSafeUrl(media.thumbnailUrl),
      feedUrl: _optionalSafeUrl(media.feedUrl),
      mediumUrl: _optionalSafeUrl(media.mediumUrl),
      contentType: media.contentType,
      animated: media.animated,
      width: media.width?.toInt(),
      height: media.height?.toInt(),
    );
  }

  bool _matchesPurpose(
    MediaResponseDtoPurposeEnum actual,
    MediaUploadPurpose expected,
  ) {
    return switch (expected) {
      MediaUploadPurpose.avatar => actual == MediaResponseDtoPurposeEnum.AVATAR,
      MediaUploadPurpose.profileCover =>
        actual == MediaResponseDtoPurposeEnum.PROFILE_COVER,
      MediaUploadPurpose.directMessage =>
        actual == MediaResponseDtoPurposeEnum.DIRECT_MESSAGE,
      MediaUploadPurpose.moment => actual == MediaResponseDtoPurposeEnum.MOMENT,
      MediaUploadPurpose.momentComment =>
        actual == MediaResponseDtoPurposeEnum.MOMENT_COMMENT,
      MediaUploadPurpose.richContent =>
        actual == MediaResponseDtoPurposeEnum.RICH_CONTENT,
      MediaUploadPurpose.stickerSource =>
        actual == MediaResponseDtoPurposeEnum.STICKER_SOURCE,
    };
  }

  String _safeUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !_isSafeMediaUri(uri)) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'media_url_unsafe',
      );
    }
    return uri.toString();
  }

  bool _isSafeMediaUri(Uri uri) {
    if (!uri.hasAuthority || uri.host.isEmpty || uri.userInfo.isNotEmpty) {
      return false;
    }
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https') return true;
    return scheme == 'http' &&
        _allowedInsecureMediaHosts.contains(uri.host.toLowerCase());
  }

  String? _optionalSafeUrl(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return _safeUrl(normalized);
  }

  Future<void> _wait(Duration duration, CancelToken? cancelToken) async {
    _throwIfCancelled(cancelToken);
    await _delay(duration);
    _throwIfCancelled(cancelToken);
  }

  void _throwIfCancelled(CancelToken? cancelToken) {
    if (cancelToken?.isCancelled ?? false) {
      throw ApiFailure(
        userMessage: '图片上传已取消。',
        cause: cancelToken?.cancelError,
      );
    }
  }
}

final mediaUploadDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.addAll([NetworkDiagnosticInterceptor()]);
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final mediaUploadRepositoryProvider = Provider<MediaUploadRepository>((ref) {
  return ApiMediaUploadRepository(
    ref.watch(wenyouApiProvider).getMediaApi(),
    ref.watch(mediaUploadDioProvider),
    timing: ref.watch(mediaUploadTimingProvider),
    workCoordinator: ref.watch(mediaUploadWorkCoordinatorProvider),
  );
});

class RepositoryMediaUploadGateway
    implements
        MediaUploadGateway,
        ResumableMediaUploadGateway,
        RetryableMediaUploadGateway {
  RepositoryMediaUploadGateway(
    this._repository, {
    this.normalizer = const PassThroughMediaUploadNormalizer(),
    this.timing = const MediaUploadTiming(),
    MediaUploadWorkCoordinator? workCoordinator,
  }) : workCoordinator = workCoordinator ?? MediaUploadWorkCoordinator();

  final MediaUploadRepository _repository;
  final MediaUploadNormalizer normalizer;
  final MediaUploadTiming timing;
  final MediaUploadWorkCoordinator workCoordinator;

  @override
  MediaUploadOperation<UploadedEditorImage> retryImageUpload(
    MediaUploadInput input,
    PendingMediaUpload upload, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final cancelToken = CancelToken();
    return _DioMediaUploadOperation(
      result: _diagnosticUpload(
        input,
        cancelToken: cancelToken,
        onProgress: onProgress,
        pendingUpload: upload,
      ),
      cancelToken: cancelToken,
    );
  }

  @override
  MediaUploadOperation<UploadedEditorImage> resumeImageProcessing(
    PendingMediaUpload upload, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final cancelToken = CancelToken();
    onProgress?.call(
      MediaUploadProgress(
        stage: MediaUploadStage.processing,
        pendingUpload: upload,
      ),
    );
    final repository = _repository;
    return _DioMediaUploadOperation(
      result: repository is ResumableMediaUploadRepository
          ? (repository as ResumableMediaUploadRepository)
                .resumeImageProcessing(upload, cancelToken: cancelToken)
          : Future.error(
              const ApiFailure(
                source: FailureSource.device,
                reason: FailureReason.unknown,
                recoveryAction: FailureRecoveryAction.reopen,
              ),
            ),
      cancelToken: cancelToken,
    );
  }

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final cancelToken = CancelToken();
    return _DioMediaUploadOperation(
      result: _diagnosticUpload(
        input,
        cancelToken: cancelToken,
        onProgress: onProgress,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<UploadedEditorImage> _diagnosticUpload(
    MediaUploadInput input, {
    required CancelToken cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
    PendingMediaUpload? pendingUpload,
  }) {
    final diagnostics = FailureDiagnostics.instance;
    final attempt =
        DiagnosticAttempt.current ??
        diagnostics.attempt(DiagnosticOperation.mediaUpload);
    return attempt.run(() async {
      try {
        return await _normalizeAndUpload(
          input,
          cancelToken: cancelToken,
          onProgress: onProgress,
          pendingUpload: pendingUpload,
        );
      } on MediaProcessingLookupFailure catch (lookup, stack) {
        diagnostics.capture(
          lookup.cause,
          stackTrace: stack,
          operation: DiagnosticOperation.mediaUpload,
        );
        rethrow;
      } on MediaProcessingPending {
        rethrow;
      } on Object catch (error, stack) {
        diagnostics.capture(
          error,
          stackTrace: stack,
          operation: DiagnosticOperation.mediaUpload,
        );
        if (pendingUpload != null && !cancelToken.isCancelled) {
          throw MediaProcessingLookupFailure(pendingUpload, error);
        }
        rethrow;
      }
    });
  }

  Future<UploadedEditorImage> _normalizeAndUpload(
    MediaUploadInput input, {
    required CancelToken cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
    PendingMediaUpload? pendingUpload,
  }) {
    return timing.measure(
      purpose: input.purpose,
      stage: MediaUploadTimingStage.pipelineTotal,
      inputBytes: input.bytes.length,
      operation: () async {
        onProgress?.call(
          const MediaUploadProgress(stage: MediaUploadStage.queued),
        );
        final normalized = await workCoordinator.prepare(() {
          _throwIfUploadCanceled(cancelToken);
          onProgress?.call(
            const MediaUploadProgress(stage: MediaUploadStage.preparing),
          );
          return normalizer.normalize(input);
        });
        if (cancelToken.isCancelled) {
          throw ApiFailure(
            userMessage: '图片上传已取消。',
            cause: cancelToken.cancelError,
          );
        }
        onProgress?.call(
          const MediaUploadProgress(stage: MediaUploadStage.queued),
        );
        final transferred = Completer<void>();
        return workCoordinator.transfer(() {
          _throwIfUploadCanceled(cancelToken);
          void progressChanged(MediaUploadProgress progress) {
            if (progress.stage == MediaUploadStage.processing &&
                !transferred.isCompleted) {
              transferred.complete();
            }
            onProgress?.call(progress);
          }

          final repository = _repository;
          if (pendingUpload != null) {
            if (repository is! RetryableMediaUploadRepository) {
              throw const ApiFailure(
                source: FailureSource.device,
                reason: FailureReason.unknown,
                recoveryAction: FailureRecoveryAction.reopen,
              );
            }
            return (repository as RetryableMediaUploadRepository)
                .retryImageUpload(
                  normalized,
                  pendingUpload,
                  cancelToken: cancelToken,
                  onProgress: progressChanged,
                );
          }
          return repository.uploadImage(
            normalized,
            cancelToken: cancelToken,
            onProgress: progressChanged,
          );
        }, releaseWhen: transferred.future);
      },
    );
  }
}

void _throwIfUploadCanceled(CancelToken cancelToken) {
  if (!cancelToken.isCancelled) return;
  throw ApiFailure(userMessage: '图片上传已取消。', cause: cancelToken.cancelError);
}

class _DioMediaUploadOperation
    implements MediaUploadOperation<UploadedEditorImage> {
  const _DioMediaUploadOperation({
    required this.result,
    required this.cancelToken,
  });

  @override
  final Future<UploadedEditorImage> result;
  final CancelToken cancelToken;

  @override
  void cancel() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('media-upload-task-cancelled');
    }
  }
}

final mediaUploadGatewayAdapterProvider = Provider<MediaUploadGateway>((ref) {
  return RepositoryMediaUploadGateway(
    ref.watch(mediaUploadRepositoryProvider),
    normalizer: ref.watch(mediaUploadNormalizerProvider),
    timing: ref.watch(mediaUploadTimingProvider),
    workCoordinator: ref.watch(mediaUploadWorkCoordinatorProvider),
  );
});

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_timing.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_normalizer.dart';

typedef MediaUploadDelay = Future<void> Function(Duration duration);

abstract interface class MediaUploadRepository {
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  });
}

class ApiMediaUploadRepository implements MediaUploadRepository {
  ApiMediaUploadRepository(
    this._api,
    this._uploadDio, {
    MediaUploadDelay? delay,
    int maxPollAttempts = 30,
    this.timing = const MediaUploadTiming(),
  }) : _delay = delay ?? Future<void>.delayed,
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

  @override
  Future<UploadedEditorImage> uploadImage(
    MediaUploadInput input, {
    CancelToken? cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
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
      final uploadEnvelope = await timing.measure(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.requestUploadUrl,
        inputBytes: size,
        operation: () => _api.mediaGetUploadUrl(
          createUploadUrlDto: CreateUploadUrlDto(
            (builder) => builder
              ..filename = input.filename
              ..contentType = _contentTypeEnum(contentType)
              ..size = size
              ..purpose = _purposeEnum(input.purpose),
          ),
          cancelToken: cancelToken,
        ),
      );
      final upload = uploadEnvelope.data?.data;
      if (upload == null) {
        throw const ApiFailure(userMessage: '图片上传失败，请重试。');
      }
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
        throw ApiFailure(userMessage: '图片直传失败，请检查网络后重试。', cause: error);
      }

      _throwIfCancelled(cancelToken);
      onProgress?.call(
        MediaUploadProgress(
          stage: MediaUploadStage.confirming,
          sentBytes: size,
          totalBytes: size,
        ),
      );
      final confirmEnvelope = await timing.measure(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.confirmUpload,
        inputBytes: size,
        operation: () => _api.mediaConfirmUpload(
          confirmUploadDto: ConfirmUploadDto(
            (builder) => builder.mediaId = upload.mediaId,
          ),
          cancelToken: cancelToken,
        ),
      );
      final confirmation = confirmEnvelope.data?.data;
      if (confirmation == null) {
        throw const ApiFailure(userMessage: '图片上传失败，请重试。');
      }
      final confirmed = confirmation.media;
      if (confirmed.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(confirmed, input.purpose);
      }
      if (confirmed.status == MediaResponseDtoStatusEnum.FAILED) {
        throw const ApiFailure(userMessage: '图片处理失败，请重新选择后上传。');
      }

      onProgress?.call(
        MediaUploadProgress(
          stage: MediaUploadStage.processing,
          sentBytes: size,
          totalBytes: size,
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

  Future<UploadedEditorImage> _waitForCompletedUpload({
    required String mediaId,
    required MediaUploadPurpose purpose,
    CancelToken? cancelToken,
  }) async {
    await _wait(const Duration(milliseconds: 500), cancelToken);
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      final statusEnvelope = await _api.mediaGetMedia(
        id: mediaId,
        cancelToken: cancelToken,
      );
      final media = statusEnvelope.data?.data;
      if (media == null) {
        throw const ApiFailure(userMessage: '图片处理失败，请重试。');
      }
      if (media.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(media, purpose);
      }
      if (media.status == MediaResponseDtoStatusEnum.FAILED) {
        throw const ApiFailure(userMessage: '图片处理失败，请重新选择后上传。');
      }
      if (attempt + 1 < _maxPollAttempts) {
        await _wait(const Duration(seconds: 1), cancelToken);
      }
    }
    throw const ApiFailure(userMessage: '图片仍在处理中，请稍后重新尝试插入。');
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
    return UploadedEditorImage(
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
      throw const ApiFailure(userMessage: '图片处理完成，但公开地址不安全。');
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
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final mediaUploadRepositoryProvider = Provider<MediaUploadRepository>((ref) {
  return ApiMediaUploadRepository(
    ref.watch(wenyouApiProvider).getMediaApi(),
    ref.watch(mediaUploadDioProvider),
    timing: ref.watch(mediaUploadTimingProvider),
  );
});

class RepositoryMediaUploadGateway implements MediaUploadGateway {
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
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final cancelToken = CancelToken();
    return _DioMediaUploadOperation(
      result: _normalizeAndUpload(
        input,
        cancelToken: cancelToken,
        onProgress: onProgress,
      ),
      cancelToken: cancelToken,
    );
  }

  Future<UploadedEditorImage> _normalizeAndUpload(
    MediaUploadInput input, {
    required CancelToken cancelToken,
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    return timing.measure(
      purpose: input.purpose,
      stage: MediaUploadTimingStage.pipelineTotal,
      inputBytes: input.bytes.length,
      operation: () async {
        onProgress?.call(
          const MediaUploadProgress(stage: MediaUploadStage.preparing),
        );
        final normalized = await workCoordinator.prepare(() {
          _throwIfUploadCanceled(cancelToken);
          return normalizer.normalize(input);
        });
        if (cancelToken.isCancelled) {
          throw ApiFailure(
            userMessage: '图片上传已取消。',
            cause: cancelToken.cancelError,
          );
        }
        return workCoordinator.transfer(() {
          _throwIfUploadCanceled(cancelToken);
          return _repository.uploadImage(
            normalized,
            cancelToken: cancelToken,
            onProgress: onProgress,
          );
        });
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

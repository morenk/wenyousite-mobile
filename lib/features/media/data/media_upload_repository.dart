import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

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
  }) : _delay = delay ?? Future<void>.delayed,
       _maxPollAttempts = maxPollAttempts < 1 ? 1 : maxPollAttempts;

  static const maxImageBytes = maxMediaImageBytes;
  static const allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/avif',
  };

  final MediaApi _api;
  final Dio _uploadDio;
  final MediaUploadDelay _delay;
  final int _maxPollAttempts;

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
      throw const ApiFailure(userMessage: '仅支持 JPG、PNG、GIF、WebP 和 AVIF 图片。');
    }
    _throwIfCancelled(cancelToken);

    try {
      onProgress?.call(
        const MediaUploadProgress(stage: MediaUploadStage.preparing),
      );
      final uploadEnvelope = await _api.mediaGetUploadUrl(
        createUploadUrlDto: CreateUploadUrlDto(
          (builder) => builder
            ..filename = input.filename
            ..contentType = _contentTypeEnum(contentType)
            ..size = size,
        ),
        cancelToken: cancelToken,
      );
      final upload = uploadEnvelope.data?.data;
      if (upload == null) {
        throw const ApiFailure(userMessage: '服务端没有返回图片上传地址，请重试。');
      }
      final uploadUri = Uri.tryParse(upload.uploadUrl);
      if (uploadUri == null ||
          !uploadUri.hasScheme ||
          (uploadUri.scheme != 'https' && uploadUri.scheme != 'http')) {
        throw const ApiFailure(userMessage: '服务端返回了不安全的图片上传地址。');
      }

      try {
        onProgress?.call(
          MediaUploadProgress(
            stage: MediaUploadStage.uploading,
            sentBytes: 0,
            totalBytes: size,
          ),
        );
        await _uploadDio.putUri<void>(
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
      final confirmEnvelope = await _api.mediaConfirmUpload(
        confirmUploadDto: ConfirmUploadDto(
          (builder) => builder.mediaId = upload.mediaId,
        ),
        cancelToken: cancelToken,
      );
      final confirmation = confirmEnvelope.data?.data;
      if (confirmation == null) {
        throw const ApiFailure(userMessage: '图片上传确认结果不完整，请重试。');
      }
      final confirmed = confirmation.media;
      if (confirmed.status == MediaResponseDtoStatusEnum.COMPLETED) {
        return _completedImage(confirmed);
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
      await _wait(const Duration(milliseconds: 500), cancelToken);
      for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
        final statusEnvelope = await _api.mediaGetMedia(
          id: upload.mediaId,
          cancelToken: cancelToken,
        );
        final media = statusEnvelope.data?.data;
        if (media == null) {
          throw const ApiFailure(userMessage: '图片处理状态返回不完整，请重试。');
        }
        if (media.status == MediaResponseDtoStatusEnum.COMPLETED) {
          return _completedImage(media);
        }
        if (media.status == MediaResponseDtoStatusEnum.FAILED) {
          throw const ApiFailure(userMessage: '图片处理失败，请重新选择后上传。');
        }
        if (attempt + 1 < _maxPollAttempts) {
          await _wait(const Duration(seconds: 1), cancelToken);
        }
      }
      throw const ApiFailure(userMessage: '图片仍在处理中，请稍后重新尝试插入。');
    } on ApiFailure {
      rethrow;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw ApiFailure(userMessage: '图片上传已取消。', cause: error);
      }
      throw ApiFailure.fromDio(error);
    }
  }

  String? _contentTypeFor(MediaUploadInput input) {
    final declared = input.declaredContentType?.toLowerCase().trim();
    final detected = lookupMimeType(
      input.filename,
      headerBytes: input.bytes.take(32).toList(growable: false),
    )?.toLowerCase();
    final contentType = allowedContentTypes.contains(declared)
        ? declared
        : detected;
    return allowedContentTypes.contains(contentType) ? contentType : null;
  }

  CreateUploadUrlDtoContentTypeEnum _contentTypeEnum(String value) {
    return switch (value) {
      'image/jpeg' => CreateUploadUrlDtoContentTypeEnum.imageSlashJpeg,
      'image/png' => CreateUploadUrlDtoContentTypeEnum.imageSlashPng,
      'image/gif' => CreateUploadUrlDtoContentTypeEnum.imageSlashGif,
      'image/webp' => CreateUploadUrlDtoContentTypeEnum.imageSlashWebp,
      'image/avif' => CreateUploadUrlDtoContentTypeEnum.imageSlashAvif,
      _ => throw const ApiFailure(userMessage: '图片类型不受支持。'),
    };
  }

  UploadedEditorImage _completedImage(MediaResponseDto media) {
    final uri = Uri.tryParse(media.url);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const ApiFailure(userMessage: '图片处理完成，但公开地址不安全。');
    }
    return UploadedEditorImage(
      mediaId: media.id,
      url: media.url,
      width: media.width?.toInt(),
      height: media.height?.toInt(),
    );
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
  );
});

class RepositoryMediaUploadGateway implements MediaUploadGateway {
  RepositoryMediaUploadGateway(this._repository);

  final MediaUploadRepository _repository;

  @override
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  }) {
    final cancelToken = CancelToken();
    return _DioMediaUploadOperation(
      result: _repository.uploadImage(
        input,
        cancelToken: cancelToken,
        onProgress: onProgress,
      ),
      cancelToken: cancelToken,
    );
  }
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
  return RepositoryMediaUploadGateway(ref.watch(mediaUploadRepositoryProvider));
});

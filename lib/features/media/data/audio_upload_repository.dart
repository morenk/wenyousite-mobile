import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyou_api/wenyou_api.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/core/network/network_providers.dart';
import 'package:wenyousite_mobile/features/media/application/audio_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/data/audio_transfer_timing.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

export 'package:wenyousite_mobile/features/media/application/audio_upload_ports.dart';

class ApiAudioUploadRepository implements AudioUploadRepository {
  ApiAudioUploadRepository(
    this.api,
    this.storage, {
    required this.coordinator,
    this.timing = const AudioTransferTiming(),
    this.delay = waitForAudioProcessing,
  });

  final MediaApi api;

  /// 独立无账号鉴权的对象存储客户端。
  final Dio storage;
  final MediaUploadWorkCoordinator coordinator;
  final AudioTransferTiming timing;
  final Future<void> Function(Duration, CancelToken) delay;

  @override
  Future<MediaAudio> upload(
    AudioUploadInput? input,
    AudioUploadPolicy? policy, {
    required CancelToken cancelToken,
    required Future<void> Function(PendingAudioUpload pending) savePending,
    PendingAudioUpload? pending,
    void Function(AudioUploadProgress progress)? onProgress,
  }) async {
    _check(cancelToken);
    try {
      var current = pending;
      if (current != null) {
        final media = await _query(current.mediaId, cancelToken);
        final completed = _finished(media, current.mediaId);
        if (completed != null) return completed;
        if (media.status != MediaResponseDtoStatusEnum.UPLOADING) {
          current = PendingAudioUpload(
            current.mediaId,
            AudioUploadStage.processing,
          );
        }
      }
      if (current == null || current.stage == AudioUploadStage.uploading) {
        if (policy == null) {
          throw const AudioUploadFailure(AudioUploadFailureReason.unavailable);
        }
        if (input == null ||
            input.size < 1 ||
            input.size > policy.maxBytes ||
            !policy.contentTypes.contains(input.contentType)) {
          throw const AudioUploadFailure(AudioUploadFailureReason.invalidInput);
        }
        if (!await File(input.path).exists() ||
            await File(input.path).length() != input.size) {
          throw const AudioUploadFailure(AudioUploadFailureReason.fileChanged);
        }
        final previous = current;
        current = await coordinator.transfer(() async {
          _check(cancelToken);
          onProgress?.call(
            const AudioUploadProgress(AudioUploadStage.preparing),
          );
          final upload = previous == null
              ? (await api.mediaGetUploadUrl(
                  createUploadUrlDto: CreateUploadUrlDto(
                    (b) => b
                      ..filename = input.filename
                      ..size = input.size
                      ..contentType = _type(input.contentType)
                      ..purpose =
                          CreateUploadUrlDtoPurposeEnum.RICH_CONTENT_AUDIO,
                  ),
                  cancelToken: cancelToken,
                )).data?.data
              : (await api.mediaReissueUploadUrl(
                  id: previous.mediaId,
                  cancelToken: cancelToken,
                )).data?.data;
          if (upload == null ||
              !isSafeAudioUrl(upload.uploadUrl) ||
              (previous != null && previous.mediaId != upload.mediaId)) {
            throw const ApiFailure.invalidResponse(
              diagnosticCode: 'audio_upload_url_invalid',
            );
          }
          final identity = PendingAudioUpload(
            upload.mediaId,
            AudioUploadStage.uploading,
          );
          await savePending(identity);
          _check(cancelToken);
          final transfer = AudioTransferGuard(cancelToken, timing);
          try {
            await transfer.wait(
              storage.putUri<void>(
                Uri.parse(upload.uploadUrl),
                data: input.openRead(),
                options: Options(
                  contentType: input.contentType,
                  headers: {'Content-Length': input.size},
                  responseType: ResponseType.plain,
                  sendTimeout: timing.total,
                  receiveTimeout: timing.idle,
                ),
                cancelToken: transfer.token,
                onSendProgress: (sent, _) {
                  transfer.progress(sent);
                  onProgress?.call(
                    AudioUploadProgress(
                      AudioUploadStage.uploading,
                      sent: sent,
                      total: input.size,
                    ),
                  );
                },
              ),
            );
          } on AudioTransferTimeout {
            throw const AudioUploadFailure(AudioUploadFailureReason.timeout);
          } finally {
            transfer.dispose();
          }
          _check(cancelToken);
          final uploaded = PendingAudioUpload(
            upload.mediaId,
            AudioUploadStage.confirming,
          );
          await savePending(uploaded);
          return uploaded;
        });
      }
      _check(cancelToken);
      final transferred = current!;
      if (transferred.stage == AudioUploadStage.confirming) {
        onProgress?.call(
          const AudioUploadProgress(AudioUploadStage.confirming),
        );
        final result = await api.mediaConfirmUpload(
          confirmUploadDto: ConfirmUploadDto(
            (b) => b.mediaId = transferred.mediaId,
          ),
          cancelToken: cancelToken,
        );
        final media = result.data?.data.media;
        if (media == null) {
          throw const ApiFailure.invalidResponse(
            diagnosticCode: 'audio_confirmation_missing',
          );
        }
        final completed = _finished(media, transferred.mediaId);
        if (completed != null) return completed;
      }
      current = PendingAudioUpload(
        transferred.mediaId,
        AudioUploadStage.processing,
      );
      await savePending(current);
      onProgress?.call(const AudioUploadProgress(AudioUploadStage.processing));
      var seconds = 1;
      while (true) {
        await delay(Duration(seconds: seconds), cancelToken);
        _check(cancelToken);
        final completed = _finished(
          await _query(current.mediaId, cancelToken),
          current.mediaId,
        );
        if (completed != null) return completed;
        seconds = (seconds * 2).clamp(1, 10);
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw ApiFailure.fromDio(
        error,
        featureMessages: const {
          42901: '正在处理的音频较多，请稍后重试。',
          42902: '今日音频上传额度已用完，请在 UTC 次日重试。',
        },
      );
    }
  }

  Future<MediaResponseDto> _query(String id, CancelToken cancel) =>
      coordinator.query(() async {
        _check(cancel);
        final media = (await api.mediaGetMedia(
          id: id,
          cancelToken: cancel,
        )).data?.data;
        if (media == null) {
          throw const ApiFailure.invalidResponse(
            diagnosticCode: 'audio_query_missing',
          );
        }
        return media;
      });

  MediaAudio? _finished(MediaResponseDto media, String id) {
    if (media.id != id ||
        media.purpose != MediaResponseDtoPurposeEnum.RICH_CONTENT_AUDIO) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'audio_identity_mismatch',
      );
    }
    if (media.status == MediaResponseDtoStatusEnum.FAILED) {
      throw AudioProcessingFailed(switch (media.failureCode) {
        MediaResponseDtoFailureCodeEnum.AUDIO_TOO_LONG => '音频不能超过 10 分钟，请重新选择。',
        MediaResponseDtoFailureCodeEnum.AUDIO_INVALID => '音频无法解码，请重新选择文件。',
        _ => '音频处理失败，请重新选择文件。',
      });
    }
    if (media.status != MediaResponseDtoStatusEnum.COMPLETED) return null;
    final result = MediaAudio.parse({
      'sourceUrl': media.url,
      'mediaId': id,
      'contentType': media.contentType,
      'size': media.size,
      'durationMs': media.durationMs,
    });
    if (result == null) {
      throw const ApiFailure.invalidResponse(
        diagnosticCode: 'audio_projection_invalid',
      );
    }
    return result;
  }

  static void _check(CancelToken cancel) {
    if (cancel.isCancelled) throw cancel.cancelError!;
  }

  static CreateUploadUrlDtoContentTypeEnum _type(String type) => switch (type) {
    'audio/mpeg' => CreateUploadUrlDtoContentTypeEnum.audioSlashMpeg,
    'audio/mp4' => CreateUploadUrlDtoContentTypeEnum.audioSlashMp4,
    'audio/wav' => CreateUploadUrlDtoContentTypeEnum.audioSlashWav,
    'audio/ogg' => CreateUploadUrlDtoContentTypeEnum.audioSlashOgg,
    'audio/flac' => CreateUploadUrlDtoContentTypeEnum.audioSlashFlac,
    _ => throw const AudioUploadFailure(
      AudioUploadFailureReason.unsupportedType,
    ),
  };
}

// 音频传输的时限独立于图片，不修改图片客户端的现有配置。
final audioUploadDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(connectTimeout: AudioTransferTiming.connect));
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final apiAudioUploadRepositoryProvider = Provider<AudioUploadRepository>(
  (ref) => ApiAudioUploadRepository(
    ref.watch(wenyouApiProvider).getMediaApi(),
    ref.watch(audioUploadDioProvider),
    coordinator: ref.watch(mediaUploadWorkCoordinatorProvider),
  ),
);

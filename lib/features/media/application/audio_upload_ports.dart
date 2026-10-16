import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

enum AudioUploadFailureReason {
  unavailable,
  invalidInput,
  fileChanged,
  unsupportedType,
  timeout,
  localFileSave,
  documentSave,
  draftSave,
}

/// 上传端口只传递失败分类，具体操作提示由编辑器展示层决定。
class AudioUploadFailure extends ApiFailure {
  const AudioUploadFailure(this.audioReason)
    : super(
        source: audioReason == AudioUploadFailureReason.timeout
            ? FailureSource.network
            : FailureSource.device,
        reason: audioReason == AudioUploadFailureReason.timeout
            ? FailureReason.timeout
            : audioReason == AudioUploadFailureReason.localFileSave ||
                  audioReason == AudioUploadFailureReason.documentSave ||
                  audioReason == AudioUploadFailureReason.draftSave
            ? FailureReason.localPersistence
            : FailureReason.validation,
      );

  final AudioUploadFailureReason audioReason;
}

abstract interface class AudioUploadRepository {
  Future<MediaAudio> upload(
    AudioUploadInput? input,
    AudioUploadPolicy? policy, {
    required CancelToken cancelToken,
    required Future<void> Function(PendingAudioUpload pending) savePending,
    PendingAudioUpload? pending,
    void Function(AudioUploadProgress progress)? onProgress,
  });
}

final audioUploadRepositoryProvider = Provider<AudioUploadRepository>(
  (ref) => throw StateError(
    'AudioUploadRepository must be bound by the composition root',
  ),
);

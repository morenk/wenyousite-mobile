import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_upload_models.dart';

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

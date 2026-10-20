import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';

class AudioSaveException implements Exception {
  const AudioSaveException();
}

abstract interface class AudioSaveOperation {
  Future<bool> get result;
  Future<void> cancel();
}

abstract interface class AudioDownload {
  bool get isSupported;
  AudioSaveOperation save(MediaAudio audio, String label);
}

final audioDownloadProvider = Provider<AudioDownload>(
  (ref) => const _UnsupportedAudioDownload(),
);

class _UnsupportedAudioDownload implements AudioDownload {
  const _UnsupportedAudioDownload();
  @override
  bool get isSupported => false;
  @override
  AudioSaveOperation save(MediaAudio audio, String label) =>
      throw const AudioSaveException();
}

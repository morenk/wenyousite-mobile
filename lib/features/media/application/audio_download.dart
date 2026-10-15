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

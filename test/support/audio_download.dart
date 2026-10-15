import 'dart:async';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/application/audio_download.dart';

class FakeAudioDownload implements AudioDownload {
  final operations = <FakeAudioSave>[];
  final labels = <String>[];
  @override
  bool get isSupported => true;
  @override
  AudioSaveOperation save(MediaAudio audio, String label) {
    labels.add(label);
    final operation = FakeAudioSave();
    operations.add(operation);
    return operation;
  }
}

class FakeAudioSave implements AudioSaveOperation {
  final completion = Completer<bool>();
  bool cancelled = false;
  @override
  Future<bool> get result => completion.future;
  @override
  Future<void> cancel() async {
    cancelled = true;
    if (!completion.isCompleted) completion.complete(false);
  }
}

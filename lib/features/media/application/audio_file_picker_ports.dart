import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/media/audio_file_selection_policy.dart';

export 'package:wenyousite_mobile/core/media/audio_file_selection_policy.dart';

enum AudioFileSelectionFailure { unavailable, unreadable, empty, tooLarge }

class AudioFileSelectionException implements Exception {
  const AudioFileSelectionException(this.failure);
  final AudioFileSelectionFailure failure;
}

/// 仅代表本机临时副本。交给草稿私有存储后由调用者释放，不删除用户原文件。
class SelectedAudioFile {
  const SelectedAudioFile({
    required this.filename,
    required this.path,
    required this.size,
    required this.release,
    this.declaredContentType,
  });

  final String filename;
  final String path;
  final int size;
  final String? declaredContentType;
  final Future<void> Function() release;
  Stream<List<int>> openRead() => File(path).openRead();
}

abstract interface class AudioFilePickOperation {
  Future<SelectedAudioFile?> get result;
  Future<void> cancel();
}

abstract interface class AudioFilePicker {
  AudioFilePickOperation pick(AudioFileSelectionPolicy policy);
}

final audioFilePickerProvider = Provider<AudioFilePicker>(
  (ref) =>
      throw StateError('AudioFilePicker must be bound by the composition root'),
);

import 'dart:io';

/// 限制由已协商的上传能力传入，选择器不自行猜测服务端预算。
class AudioFileSelectionPolicy {
  AudioFileSelectionPolicy({
    required this.maximumBytes,
    required List<String> contentTypes,
  }) : contentTypes = List.unmodifiable(contentTypes) {
    if (maximumBytes <= 0 || contentTypes.isEmpty) {
      throw ArgumentError('音频选择需要明确大小和类型限制。');
    }
  }

  final int maximumBytes;
  final List<String> contentTypes;
}

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

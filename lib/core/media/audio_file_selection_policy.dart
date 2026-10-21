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

/// 正文授权响应提供的音频投影；扩展名和任意外链不能自行成为播放器。
class MediaAudio {
  const MediaAudio._({
    required this.sourceUrl,
    required this.mediaId,
    required this.size,
    required this.durationMs,
  });

  final String sourceUrl;
  final String mediaId;
  final int size;
  final int durationMs;
  String get contentType => 'audio/mpeg';

  Map<String, Object?> toJson() => {
    'sourceUrl': sourceUrl,
    'mediaId': mediaId,
    'contentType': contentType,
    'size': size,
    'durationMs': durationMs,
  };

  static MediaAudio? parse(Object? value) {
    if (value is! Map) return null;
    final source = value['sourceUrl'];
    final id = value['mediaId'];
    final size = _integer(value['size']);
    final duration = _integer(value['durationMs']);
    if (source is! String ||
        !isSafeAudioUrl(source) ||
        id is! String ||
        id.trim().isEmpty ||
        value['contentType'] != 'audio/mpeg' ||
        size == null ||
        size <= 0 ||
        duration == null ||
        duration <= 0 ||
        duration > 600000) {
      return null;
    }
    return MediaAudio._(
      sourceUrl: source,
      mediaId: id,
      size: size,
      durationMs: duration,
    );
  }

  static int? _integer(Object? value) =>
      value is num && value.isFinite && value == value.toInt()
      ? value.toInt()
      : null;
}

bool isSafeAudioUrl(String value) {
  if (value != value.trim()) return false;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !uri.hasAuthority ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return false;
  }
  return uri.scheme == 'https' ||
      (uri.scheme == 'http' &&
          const {
            'localhost',
            '127.0.0.1',
            '::1',
            '10.0.2.2',
          }.contains(uri.host));
}

Map<String, MediaAudio> mediaAudiosFromJson(Object? value) {
  if (value is! Iterable) return const {};
  final result = <String, MediaAudio>{};
  for (final item in value) {
    if (MediaAudio.parse(item) case final audio?) {
      result.putIfAbsent(audio.sourceUrl, () => audio);
    }
  }
  return Map.unmodifiable(result);
}

List<Map<String, Object?>> mediaAudiosToJson(Map<String, MediaAudio> audios) =>
    [for (final audio in audios.values) audio.toJson()];

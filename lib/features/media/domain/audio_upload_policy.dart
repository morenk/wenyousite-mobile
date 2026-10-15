import 'package:wenyousite_mobile/features/media/application/audio_file_picker.dart';

/// 缺少可识别的服务端能力时不开放选择和上传。
class AudioUploadPolicy {
  const AudioUploadPolicy._({
    required this.maxBytes,
    required this.maxDurationMs,
    required this.contentTypes,
  });

  final int maxBytes;
  final int maxDurationMs;
  final Set<String> contentTypes;
  static const supportedContentTypes = {
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/ogg',
    'audio/flac',
  };

  AudioFileSelectionPolicy get selection => AudioFileSelectionPolicy(
    maximumBytes: maxBytes,
    contentTypes: [
      for (final type in contentTypes) ...[
        type,
        ...switch (type) {
          'audio/mpeg' => const ['audio/mp3', 'audio/x-mp3', 'audio/x-mpeg'],
          'audio/mp4' => const ['audio/m4a', 'audio/x-m4a', 'video/mp4'],
          'audio/wav' => const ['audio/x-wav', 'audio/wave', 'audio/vnd.wave'],
          'audio/ogg' => const ['application/ogg'],
          'audio/flac' => const ['audio/x-flac'],
          _ => const <String>[],
        },
      ],
    ],
  );

  static AudioUploadPolicy? parse(Object? value) {
    if (value is! Map ||
        value['version'] != 1 ||
        value['outputContentType'] != 'audio/mpeg') {
      return null;
    }
    final bytes = value['maxBytes'];
    final duration = value['maxDurationMs'];
    final types = value['contentTypes'];
    if (bytes is! num ||
        bytes <= 0 ||
        bytes > 31457280 ||
        bytes != bytes.toInt() ||
        duration is! num ||
        duration <= 0 ||
        duration > 600000 ||
        duration != duration.toInt() ||
        types is! Iterable) {
      return null;
    }
    final allowed = types.whereType<String>().toSet()
      ..retainAll(supportedContentTypes);
    if (allowed.isEmpty) return null;
    return AudioUploadPolicy._(
      maxBytes: bytes.toInt(),
      maxDurationMs: duration.toInt(),
      contentTypes: Set.unmodifiable(allowed),
    );
  }

  String? normalizeContentType(String? declared, String filename) {
    final type = declared?.split(';').first.trim().toLowerCase();
    final normalized = switch (type) {
      'audio/mp3' || 'audio/x-mp3' || 'audio/x-mpeg' => 'audio/mpeg',
      'audio/m4a' || 'audio/x-m4a' || 'video/mp4' => 'audio/mp4',
      'audio/x-wav' || 'audio/wave' || 'audio/vnd.wave' => 'audio/wav',
      'application/ogg' => 'audio/ogg',
      'audio/x-flac' => 'audio/flac',
      _ => type,
    };
    if (contentTypes.contains(normalized)) return normalized;
    // 部分 SAF 提供者只返回通用类型，最终格式仍由服务端检查实际内容。
    if (type != null && type.isNotEmpty && type != 'application/octet-stream') {
      return null;
    }
    final guessed = switch (filename.split('.').last.toLowerCase()) {
      'mp3' => 'audio/mpeg',
      'm4a' || 'mp4' => 'audio/mp4',
      'wav' => 'audio/wav',
      'ogg' => 'audio/ogg',
      'flac' => 'audio/flac',
      _ => null,
    };
    return contentTypes.contains(guessed) ? guessed : null;
  }
}

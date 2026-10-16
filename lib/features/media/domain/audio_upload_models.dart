import 'dart:io';

enum AudioUploadStage { preparing, uploading, confirming, processing }

class AudioUploadInput {
  const AudioUploadInput({
    required this.filename,
    required this.path,
    required this.size,
    required this.contentType,
  });
  final String filename;
  final String path;
  final int size;
  final String contentType;
  Stream<List<int>> openRead() => File(path).openRead();

  Map<String, Object?> toJson() => {
    'filename': filename,
    'path': path,
    'size': size,
    'contentType': contentType,
  };

  static AudioUploadInput? parse(Object? value) {
    if (value is! Map) return null;
    final name = value['filename'];
    final path = value['path'];
    final size = value['size'];
    final type = value['contentType'];
    if (name is! String ||
        path is! String ||
        path.isEmpty ||
        size is! int ||
        size < 1 ||
        size > 31457280 ||
        type is! String) {
      return null;
    }
    return AudioUploadInput(
      filename: name,
      path: path,
      size: size,
      contentType: type,
    );
  }
}

class PendingAudioUpload {
  const PendingAudioUpload(this.mediaId, this.stage);
  final String mediaId;
  final AudioUploadStage stage;
  Map<String, Object?> toJson() => {'mediaId': mediaId, 'stage': stage.name};
  static PendingAudioUpload? parse(Object? value) {
    if (value is! Map ||
        value['mediaId'] is! String ||
        (value['mediaId'] as String).isEmpty) {
      return null;
    }
    final stage = AudioUploadStage.values
        .where((s) => s.name == value['stage'])
        .firstOrNull;
    return stage == null
        ? null
        : PendingAudioUpload(value['mediaId'] as String, stage);
  }
}

class AudioUploadProgress {
  const AudioUploadProgress(this.stage, {this.sent = 0, this.total = 0});
  final AudioUploadStage stage;
  final int sent;
  final int total;
  double? get fraction => stage == AudioUploadStage.uploading && total > 0
      ? (sent / total).clamp(0, 1)
      : null;
}

/// 服务端媒体已终结，继续查询同一身份不能恢复。
class AudioProcessingFailed implements Exception {
  const AudioProcessingFailed(this.message);
  final String message;
}

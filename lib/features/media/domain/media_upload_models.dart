import 'dart:typed_data';

enum MediaUploadStage { preparing, uploading, confirming, processing }

class MediaUploadInput {
  const MediaUploadInput({
    required this.filename,
    required this.bytes,
    this.declaredContentType,
  });

  final String filename;
  final Uint8List bytes;
  final String? declaredContentType;
}

class MediaUploadProgress {
  const MediaUploadProgress({
    required this.stage,
    this.sentBytes,
    this.totalBytes,
  });

  final MediaUploadStage stage;
  final int? sentBytes;
  final int? totalBytes;

  double? get fraction {
    final sent = sentBytes;
    final total = totalBytes;
    if (sent == null || total == null || total <= 0) return null;
    return (sent / total).clamp(0, 1);
  }
}

class UploadedEditorImage {
  const UploadedEditorImage({
    required this.mediaId,
    required this.url,
    this.width,
    this.height,
  });

  final String mediaId;
  final String url;
  final int? width;
  final int? height;
}

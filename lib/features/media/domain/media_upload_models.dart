import 'dart:typed_data';

const maxMediaImageBytes = 10 * 1024 * 1024;

enum MediaUploadStage { preparing, uploading, confirming, processing }

enum MediaUploadPurpose {
  avatar,
  profileCover,
  directMessage,
  moment,
  momentComment,
  richContent,
  stickerSource,
}

class MediaUploadInput {
  const MediaUploadInput({
    required this.filename,
    required this.bytes,
    this.declaredContentType,
    this.purpose = MediaUploadPurpose.richContent,
  });

  final String filename;
  final Uint8List bytes;
  final String? declaredContentType;
  final MediaUploadPurpose purpose;

  MediaUploadInput withPurpose(MediaUploadPurpose purpose) {
    return MediaUploadInput(
      filename: filename,
      bytes: bytes,
      declaredContentType: declaredContentType,
      purpose: purpose,
    );
  }
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
    this.thumbnailUrl,
    this.feedUrl,
    this.mediumUrl,
    this.contentType,
    this.animated = false,
    this.width,
    this.height,
  });

  final String mediaId;
  final String url;
  final String? thumbnailUrl;
  final String? feedUrl;
  final String? mediumUrl;
  final String? contentType;
  final bool animated;
  final int? width;
  final int? height;

  List<String> get previewUrls =>
      _orderedUrls([thumbnailUrl, feedUrl, mediumUrl, url]);
}

List<String> _orderedUrls(Iterable<String?> values) {
  final result = <String>[];
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        !result.contains(normalized)) {
      result.add(normalized);
    }
  }
  return List.unmodifiable(result);
}

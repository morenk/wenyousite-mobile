import 'dart:io';
import 'dart:typed_data';

import 'package:wenyousite_mobile/core/media/media_display.dart';

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

class PickedMediaSource {
  const PickedMediaSource.file({
    required this.filename,
    required this.path,
    required this.length,
    this.declaredContentType,
    this.purpose = MediaUploadPurpose.richContent,
  });

  final String filename;
  final String path;
  final int length;
  final String? declaredContentType;
  final MediaUploadPurpose purpose;

  PickedMediaSource withPurpose(MediaUploadPurpose purpose) {
    return PickedMediaSource.file(
      filename: filename,
      path: path,
      length: length,
      declaredContentType: declaredContentType,
      purpose: purpose,
    );
  }

  Future<Uint8List> readBytes() => File(path).readAsBytes();
}

class MediaUploadInput {
  factory MediaUploadInput({
    required String filename,
    required Uint8List bytes,
    String? declaredContentType,
    MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
  }) => MediaUploadInput._(filename, bytes, declaredContentType, purpose, null);

  const MediaUploadInput._(
    this.filename,
    this._bytes,
    this.declaredContentType,
    this.purpose,
    this.source,
  );

  MediaUploadInput.fromPickedSource(PickedMediaSource source)
    : this._(
        source.filename,
        null,
        source.declaredContentType,
        source.purpose,
        source,
      );

  final String filename;
  final Uint8List? _bytes;
  final String? declaredContentType;
  final MediaUploadPurpose purpose;
  final PickedMediaSource? source;

  bool get isMaterialized => _bytes != null;

  int get byteLength => _bytes?.length ?? source?.length ?? 0;

  String? get sourcePath => source?.path;

  Uint8List get requiredBytes {
    final value = _bytes;
    if (value == null) {
      throw StateError('Picked media must be materialized before byte access.');
    }
    return value;
  }

  Uint8List get bytes => requiredBytes;

  Future<MediaUploadInput> materialize() async {
    if (_bytes != null) return this;
    final currentSource = source;
    if (currentSource == null) {
      throw StateError(
        'Media upload input has neither bytes nor a file source.',
      );
    }
    final loaded = await currentSource.readBytes();
    return MediaUploadInput(
      filename: filename,
      bytes: loaded,
      declaredContentType: declaredContentType,
      purpose: purpose,
    );
  }

  MediaUploadInput withPurpose(MediaUploadPurpose purpose) {
    final currentSource = source;
    if (currentSource != null) {
      return MediaUploadInput.fromPickedSource(
        currentSource.withPurpose(purpose),
      );
    }
    return MediaUploadInput(
      filename: filename,
      bytes: requiredBytes,
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
    this.display,
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
  final MediaDisplay? display;
  final String? thumbnailUrl;
  final String? feedUrl;
  final String? mediumUrl;
  final String? contentType;
  final bool animated;
  final int? width;
  final int? height;

  List<String> get previewUrls => _orderedUrls([
    for (final preview in [thumbnailUrl, feedUrl, mediumUrl])
      if (display == null || preview != url) preview,
    display?.url ?? url,
  ]);
}

/// 已确认上传的媒体仍在处理；后续只能查询这个身份，不能重复上传。
class PendingMediaUpload {
  const PendingMediaUpload({required this.mediaId, required this.purpose});

  final String mediaId;
  final MediaUploadPurpose purpose;
}

class MediaProcessingPending implements Exception {
  const MediaProcessingPending(this.upload);

  final PendingMediaUpload upload;
}

/// 查询失败不等于仍在处理；保留身份用于允许的显式恢复。
class MediaProcessingLookupFailure implements Exception {
  const MediaProcessingLookupFailure(this.upload, this.cause);
  final PendingMediaUpload upload;
  final Object cause;
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

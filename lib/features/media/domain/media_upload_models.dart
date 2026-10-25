import 'dart:io';
import 'dart:typed_data';

import 'package:wenyousite_mobile/core/media/media_display.dart';

const maxMediaImageBytes = 10 * 1024 * 1024;

enum MediaUploadStage { queued, preparing, uploading, confirming, processing }

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
    this.pendingUpload,
  });

  final MediaUploadStage stage;
  final int? sentBytes;
  final int? totalBytes;
  final PendingMediaUpload? pendingUpload;

  double? get fraction {
    if (stage != MediaUploadStage.uploading) return null;
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

/// 已分配的媒体身份；恢复必须继续使用该身份，不能另建记录。
class PendingMediaUpload {
  const PendingMediaUpload({
    required this.mediaId,
    required this.purpose,
    this.needsConfirmation = false,
    this.needsTransfer = false,
    this.contentSha256,
  });

  final String mediaId;
  final MediaUploadPurpose purpose;

  /// 对象已传完但确认响应未收到时，恢复同一身份而不是重新直传。
  final bool needsConfirmation;

  /// PUT 未成功或结果不明；只允许用户明确重试时重签同一对象。
  final bool needsTransfer;

  /// 仅供本机核对归一化文件；不包含临时上传地址。
  final String? contentSha256;

  Map<String, Object?> toJson() => {
    'mediaId': mediaId,
    'purpose': purpose.name,
    'needsConfirmation': needsConfirmation,
    if (needsTransfer) 'needsTransfer': true,
    if (contentSha256 != null) 'contentSha256': contentSha256,
  };

  static PendingMediaUpload? fromJson(Map<String, Object?> json) {
    final mediaId = json['mediaId'];
    final purpose = MediaUploadPurpose.values
        .where((value) => value.name == json['purpose'])
        .firstOrNull;
    if (mediaId is! String || mediaId.isEmpty || purpose == null) return null;
    return PendingMediaUpload(
      mediaId: mediaId,
      purpose: purpose,
      needsConfirmation: json['needsConfirmation'] == true,
      needsTransfer: json['needsTransfer'] == true,
      contentSha256: switch (json['contentSha256']) {
        final String value when RegExp(r'^[a-f0-9]{64}$').hasMatch(value) =>
          value,
        _ => null,
      },
    );
  }
}

class MediaProcessingPending implements Exception {
  const MediaProcessingPending(this.upload);

  final PendingMediaUpload upload;
}

/// 查询失败不等于仍在处理；保留身份用于允许的显式恢复。
class MediaProcessingLookupFailure implements Exception {
  const MediaProcessingLookupFailure(
    this.upload,
    this.cause, {
    this.transferFailed = false,
  });
  final PendingMediaUpload upload;
  final Object cause;

  /// 对象存储拒绝旧签名仍可重签，不等同业务 API 的媒体访问被禁止。
  final bool transferFailed;
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

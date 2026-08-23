import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_normalizer.dart';

abstract interface class StaticWebpEncoder {
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  });
}

class FlutterStaticWebpEncoder implements StaticWebpEncoder {
  const FlutterStaticWebpEncoder();

  @override
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  }) {
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: quality,
      rotate: 0,
      autoCorrectionAngle: true,
      format: CompressFormat.webp,
      keepExif: false,
    );
  }
}

class FlutterMediaUploadNormalizer implements MediaUploadNormalizer {
  FlutterMediaUploadNormalizer({
    this.encoder = const FlutterStaticWebpEncoder(),
  });

  static const maximumEdge = 2560;
  static const standardQuality = 85;
  static const profileCoverQuality = 92;

  final StaticWebpEncoder encoder;
  final Expando<Future<MediaUploadInput>> _cache = Expando();

  @override
  Future<MediaUploadInput> normalize(MediaUploadInput input) {
    final cached = _cache[input];
    if (cached != null) return cached;
    final future = _normalize(input);
    _cache[input] = future;
    future.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {
        if (identical(_cache[input], future)) _cache[input] = null;
      },
    );
    return future;
  }

  Future<MediaUploadInput> _normalize(MediaUploadInput input) async {
    try {
      final inspection = (await compute(
        inspectMediaInputForIsolate,
        input,
      )).unwrap();
      if (inspection.isGif) {
        return MediaUploadInput(
          filename: input.filename,
          bytes: input.bytes,
          declaredContentType: 'image/gif',
          purpose: input.purpose,
        );
      }

      final quality = input.purpose == MediaUploadPurpose.profileCover
          ? profileCoverQuality
          : standardQuality;
      final (targetWidth, targetHeight) = _targetSize(inspection);
      final bytes = await encoder.encode(
        input.bytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        quality: quality,
      );
      if (bytes.isEmpty || bytes.length > maxMediaImageBytes) {
        throw const ApiFailure(userMessage: '图片处理后仍然过大，请缩小后重试。');
      }
      final output = MediaUploadInput(
        filename: '${_filenameStem(input.filename)}.webp',
        bytes: bytes,
        declaredContentType: 'image/webp',
        purpose: input.purpose,
      );
      final normalized = (await compute(
        inspectMediaInputForIsolate,
        output,
      )).unwrap();
      if (normalized.contentType != 'image/webp' || normalized.isGif) {
        throw const ApiFailure(userMessage: '图片处理失败，请重新选择后重试。');
      }
      return output;
    } on ApiFailure {
      rethrow;
    } on Object catch (error) {
      throw ApiFailure(userMessage: '图片处理失败，请重新选择后重试。', cause: error);
    }
  }

  String _filenameStem(String filename) {
    final leaf = filename.split(RegExp(r'[\\/]')).last.trim();
    final dot = leaf.lastIndexOf('.');
    final stem = (dot > 0 ? leaf.substring(0, dot) : leaf).trim();
    return stem.isEmpty ? 'image-upload' : stem;
  }

  (int, int) _targetSize(MediaImageInspection inspection) {
    final longestEdge = inspection.width > inspection.height
        ? inspection.width
        : inspection.height;
    if (longestEdge <= maximumEdge) {
      return (inspection.width, inspection.height);
    }
    final scale = maximumEdge / longestEdge;
    return (
      (inspection.width * scale).round().clamp(1, maximumEdge).toInt(),
      (inspection.height * scale).round().clamp(1, maximumEdge).toInt(),
    );
  }
}

final mediaUploadNormalizerProvider = Provider<MediaUploadNormalizer>((ref) {
  return FlutterMediaUploadNormalizer();
});

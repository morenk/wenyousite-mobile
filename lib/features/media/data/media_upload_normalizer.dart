import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/engine_media_image.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_timing.dart';
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
    this.timing = const MediaUploadTiming(),
  });

  static const maximumEdge = 2560;
  static const standardQuality = 85;
  static const profileCoverQuality = 92;

  final StaticWebpEncoder encoder;
  final MediaUploadTiming timing;
  final Expando<Future<MediaUploadInput>> _cache = Expando();

  @override
  Future<MediaUploadInput> normalize(MediaUploadInput input) {
    final cached = _cache[input];
    if (cached != null) return cached;
    final future = timing.measure(
      purpose: input.purpose,
      stage: MediaUploadTimingStage.normalizeTotal,
      inputBytes: input.bytes.length,
      outputBytes: (output) => output.bytes.length,
      operation: () => _normalize(input),
    );
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
    EngineMediaImage? source;
    try {
      final opened = await timing.measure<EngineMediaImage>(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.inspectInput,
        inputBytes: input.bytes.length,
        operation: () => EngineMediaImage.open(input),
      );
      source = opened;
      if (opened.inspection.isGif) {
        final firstFrame = await opened.decode(maximumEdge: maximumEdge);
        firstFrame.dispose();
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
      final (targetWidth, targetHeight) = opened.targetSize(maximumEdge);
      final bytes = await timing.measure(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.encodeWebp,
        inputBytes: input.bytes.length,
        outputBytes: (output) => output.length,
        operation: () async {
          final pixels = await opened.decode(maximumEdge: maximumEdge);
          late final Uint8List canonical;
          try {
            // 编码器仅接收引擎输出的标准 PNG，避免不同入口再次解释原始元数据。
            canonical = await mediaImagePng(pixels);
          } finally {
            pixels.dispose();
          }
          return encoder.encode(
            canonical,
            targetWidth: targetWidth,
            targetHeight: targetHeight,
            quality: quality,
          );
        },
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
      await timing.measure<void>(
        purpose: input.purpose,
        stage: MediaUploadTimingStage.inspectOutput,
        inputBytes: output.bytes.length,
        operation: () async {
          final normalized = await EngineMediaImage.open(output);
          try {
            final inspection = normalized.inspection;
            if (inspection.contentType != 'image/webp' ||
                inspection.width != targetWidth ||
                inspection.height != targetHeight) {
              throw const ApiFailure(userMessage: '图片处理失败，请重新选择后重试。');
            }
            // 头信息有效不代表像素可读，必须解码成品后才能进入上传。
            final pixels = await normalized.decode();
            pixels.dispose();
          } finally {
            normalized.dispose();
          }
        },
      );
      return output;
    } on ApiFailure {
      rethrow;
    } on Object catch (error) {
      throw ApiFailure(userMessage: '图片处理失败，请重新选择后重试。', cause: error);
    } finally {
      source?.dispose();
    }
  }

  String _filenameStem(String filename) {
    final leaf = filename.split(RegExp(r'[\\/]')).last.trim();
    final dot = leaf.lastIndexOf('.');
    final stem = (dot > 0 ? leaf.substring(0, dot) : leaf).trim();
    return stem.isEmpty ? 'image-upload' : stem;
  }
}

final mediaUploadNormalizerProvider = Provider<MediaUploadNormalizer>((ref) {
  return FlutterMediaUploadNormalizer(
    timing: ref.watch(mediaUploadTimingProvider),
  );
});

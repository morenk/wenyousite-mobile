import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

/// 静态图与界面预览共用引擎解码，不修补用户文件的 JPEG 字节。
class EngineMediaImage {
  EngineMediaImage._(this._buffer, this._descriptor, this.inspection);

  final ui.ImmutableBuffer _buffer;
  final ui.ImageDescriptor _descriptor;
  final MediaImageInspection inspection;

  static Future<EngineMediaImage> open(MediaUploadInput input) async {
    final contentType = validateMediaImageHeader(input);
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      // GIF 保持独立动画预算，不能在转码时悄悄丢失后续帧。
      if (contentType == 'image/gif') {
        (await compute(inspectMediaInputForIsolate, input)).unwrap();
      }
      buffer = await ui.ImmutableBuffer.fromUint8List(input.bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final width = descriptor.width;
      final height = descriptor.height;
      if (width < 2 || height < 2) {
        throw const ApiFailure(userMessage: '图片尺寸无效，请选择其他图片。');
      }
      if (width * height > maxStaticImagePixels) {
        throw const ApiFailure(userMessage: '图片像素过大，请缩小后重试。');
      }
      return EngineMediaImage._(
        buffer,
        descriptor,
        MediaImageInspection(
          width: width,
          height: height,
          contentType: contentType,
          isGif: contentType == 'image/gif',
        ),
      );
    } on Object catch (error) {
      descriptor?.dispose();
      buffer?.dispose();
      if (error is ApiFailure) rethrow;
      throw mediaImageDecodeFailure(error);
    }
  }

  (int, int) targetSize(int maximumEdge) {
    final width = inspection.width;
    final height = inspection.height;
    final longest = width > height ? width : height;
    if (longest <= maximumEdge) return (width, height);
    final scale = maximumEdge / longest;
    return (
      (width * scale).round().clamp(1, maximumEdge),
      (height * scale).round().clamp(1, maximumEdge),
    );
  }

  Future<ui.Image> decode({int? maximumEdge}) async {
    ui.Codec? codec;
    try {
      final (width, height) = maximumEdge == null
          ? (inspection.width, inspection.height)
          : targetSize(maximumEdge);
      codec = await _descriptor.instantiateCodec(
        targetWidth: width,
        targetHeight: height,
      );
      if (!inspection.isGif && codec.frameCount > 1) {
        throw const ApiFailure(userMessage: '暂不支持这种动图，请改用 GIF 动图。');
      }
      return (await codec.getNextFrame()).image;
    } on Object catch (error) {
      if (error is ApiFailure) rethrow;
      throw mediaImageDecodeFailure(error);
    } finally {
      codec?.dispose();
    }
  }

  void dispose() {
    _descriptor.dispose();
    _buffer.dispose();
  }
}

ApiFailure mediaImageDecodeFailure(Object error) => ApiFailure(
  userMessage: '图片读取失败，请重新导出图片后再选择。',
  reason: FailureReason.validation,
  recoveryAction: FailureRecoveryAction.none,
  cause: error,
);

Future<Uint8List> mediaImagePng(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) {
    throw mediaImageDecodeFailure(StateError('Image PNG encoding failed'));
  }
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

/// 在已校正方向的像素坐标内裁剪；PNG 中间图避免最终 WebP 前再次有损编码。
Future<Uint8List> renderMediaCrop(
  ui.Image source,
  ui.Rect crop, {
  required int width,
  required int height,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawImageRect(
    source,
    crop,
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()
      ..blendMode = ui.BlendMode.src
      ..filterQuality = ui.FilterQuality.high,
  );
  final picture = recorder.endRecording();
  ui.Image? output;
  try {
    output = await picture.toImage(width, height);
    return await mediaImagePng(output);
  } finally {
    output?.dispose();
    picture.dispose();
  }
}

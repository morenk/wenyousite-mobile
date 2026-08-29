import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class IsolateImageCropProcessor implements ImageCropProcessor {
  const IsolateImageCropProcessor();

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async {
    final materialized = await input.materialize();
    return compute(_prepareCropSource, materialized);
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) {
    return compute(_cropAvatar, (source, crop));
  }

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) {
    return compute(_cropImage, (source, crop));
  }

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) {
    return compute(_cropProfileCover, (source, webCrop, mobileCrop));
  }
}

CropImageSource _prepareCropSource(MediaUploadInput input) {
  final inspection = inspectMediaInput(input);
  final oriented = _decodeFirstFrameOrThrow(input);
  const maxPreviewEdge = 1024;
  final longestEdge = oriented.width > oriented.height
      ? oriented.width
      : oriented.height;
  final preview = longestEdge <= maxPreviewEdge
      ? oriented
      : image.copyResize(
          oriented,
          width: oriented.width >= oriented.height ? maxPreviewEdge : null,
          height: oriented.height > oriented.width ? maxPreviewEdge : null,
          interpolation: image.Interpolation.cubic,
        );
  return CropImageSource(
    original: input,
    previewBytes: image.encodePng(preview),
    width: oriented.width,
    height: oriented.height,
    canCrop: !inspection.isGif,
  );
}

MediaUploadInput _cropAvatar((CropImageSource, NormalizedCropRect) request) {
  final (source, crop) = request;
  return _renderCrop(
    source,
    crop,
    outputWidth: 512,
    outputHeight: 512,
    filename: 'avatar.png',
  );
}

MediaUploadInput _cropImage((CropImageSource, NormalizedCropRect) request) {
  final (source, crop) = request;
  if (!source.canCrop) return source.original;
  final oriented = _decodeOrThrow(source.original);
  var output = _cropSource(oriented, crop);
  const maximumEdge = 2560;
  if (output.width > maximumEdge || output.height > maximumEdge) {
    output = image.copyResize(
      output,
      width: output.width >= output.height ? maximumEdge : null,
      height: output.height > output.width ? maximumEdge : null,
      interpolation: image.Interpolation.cubic,
    );
  }

  final preserveAlpha = output.hasAlpha;
  var bytes = preserveAlpha
      ? image.encodePng(output)
      : image.encodeJpg(output, quality: 92);
  while (bytes.length > maxMediaImageBytes &&
      output.width > 640 &&
      output.height > 640) {
    output = image.copyResize(
      output,
      width: (output.width * .82).round(),
      height: (output.height * .82).round(),
      interpolation: image.Interpolation.cubic,
    );
    bytes = preserveAlpha
        ? image.encodePng(output)
        : image.encodeJpg(output, quality: 88);
  }
  if (bytes.length > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '裁剪后的图片超过 10MB，请缩小取景范围或更换图片。');
  }
  return MediaUploadInput(
    filename: preserveAlpha ? 'cropped-image.png' : 'cropped-image.jpg',
    declaredContentType: preserveAlpha ? 'image/png' : 'image/jpeg',
    bytes: bytes,
    purpose: source.original.purpose,
  );
}

ProfileCoverImageSelection _cropProfileCover(
  (CropImageSource, NormalizedCropRect, NormalizedCropRect) request,
) {
  final (source, webCrop, mobileCrop) = request;
  final oriented = _decodeOrThrow(source.original);
  return ProfileCoverImageSelection(
    web: _renderCropFromOriented(
      source,
      oriented,
      webCrop,
      outputWidth: 1920,
      outputHeight: 640,
      filenameStem: 'profile-cover-web',
    ),
    mobile: _renderCropFromOriented(
      source,
      oriented,
      mobileCrop,
      outputWidth: 1600,
      outputHeight: 800,
      filenameStem: 'profile-cover-mobile',
    ),
  );
}

MediaUploadInput _renderCrop(
  CropImageSource source,
  NormalizedCropRect crop, {
  required int outputWidth,
  required int outputHeight,
  required String filename,
}) {
  final oriented = _decodeOrThrow(source.original);
  return _renderCropFromOriented(
    source,
    oriented,
    crop,
    outputWidth: outputWidth,
    outputHeight: outputHeight,
    filenameStem: filename.replaceFirst(RegExp(r'\.[^.]+$'), ''),
  );
}

MediaUploadInput _renderCropFromOriented(
  CropImageSource source,
  image.Image oriented,
  NormalizedCropRect crop, {
  required int outputWidth,
  required int outputHeight,
  required String filenameStem,
}) {
  final cropped = _cropSource(oriented, crop);
  final resized = image.copyResize(
    cropped,
    width: outputWidth,
    height: outputHeight,
    interpolation: image.Interpolation.cubic,
  );
  final preserveAlpha = resized.hasAlpha;
  final bytes = preserveAlpha
      ? image.encodePng(resized)
      : image.encodeJpg(resized, quality: 94);
  if (bytes.length > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '裁剪后的图片超过 10MB，请更换图片。');
  }
  return MediaUploadInput(
    filename: preserveAlpha ? '$filenameStem.png' : '$filenameStem.jpg',
    declaredContentType: preserveAlpha ? 'image/png' : 'image/jpeg',
    bytes: bytes,
    purpose: source.original.purpose,
  );
}

image.Image _cropSource(image.Image oriented, NormalizedCropRect crop) {
  final left = (crop.left.clamp(0, 1) * oriented.width).floor();
  final top = (crop.top.clamp(0, 1) * oriented.height).floor();
  final right = (crop.right.clamp(0, 1) * oriented.width).ceil();
  final bottom = (crop.bottom.clamp(0, 1) * oriented.height).ceil();
  final cropWidth = (right - left).clamp(1, oriented.width - left);
  final cropHeight = (bottom - top).clamp(1, oriented.height - top);
  return image.copyCrop(
    oriented,
    x: left,
    y: top,
    width: cropWidth,
    height: cropHeight,
  );
}

image.Image _decodeOrThrow(MediaUploadInput input) {
  final decoded = image.decodeImage(input.bytes);
  if (decoded == null) {
    throw const ApiFailure(userMessage: '图片无法解析，请选择其他图片。');
  }
  final oriented = image.bakeOrientation(decoded);
  if (oriented.width < 2 || oriented.height < 2) {
    throw const ApiFailure(userMessage: '图片尺寸无效，请选择其他图片。');
  }
  return oriented;
}

image.Image _decodeFirstFrameOrThrow(MediaUploadInput input) {
  final decoder = image.findDecoderForData(input.bytes);
  if (decoder == null || decoder.startDecode(input.bytes) == null) {
    throw const ApiFailure(userMessage: '图片无法解析，请选择其他图片。');
  }
  final decoded = decoder.decodeFrame(0);
  if (decoded == null) {
    throw const ApiFailure(userMessage: '图片无法解析，请选择其他图片。');
  }
  final oriented = image.bakeOrientation(decoded);
  if (oriented.width < 2 || oriented.height < 2) {
    throw const ApiFailure(userMessage: '图片尺寸无效，请选择其他图片。');
  }
  return oriented;
}

final imageCropProcessorProvider = Provider<ImageCropProcessor>((ref) {
  return const IsolateImageCropProcessor();
});

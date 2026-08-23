import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

const maxStaticImagePixels = 64 * 1000 * 1000;
const maxGifEdge = 2560;
const maxGifFrames = 300;
const maxGifDurationMs = 60 * 1000;
const maxGifTotalPixels = 100 * 1000 * 1000;

class MediaImageInspection {
  const MediaImageInspection({
    required this.width,
    required this.height,
    required this.contentType,
    required this.isGif,
  });

  final int width;
  final int height;
  final String contentType;
  final bool isGif;
}

class MediaImageInspectionResult {
  const MediaImageInspectionResult.success(this.inspection)
    : errorMessage = null;

  const MediaImageInspectionResult.failure(this.errorMessage)
    : inspection = null;

  final MediaImageInspection? inspection;
  final String? errorMessage;

  MediaImageInspection unwrap() {
    final value = inspection;
    if (value != null) return value;
    throw ApiFailure(userMessage: errorMessage ?? '图片无法解析，请选择其他图片。');
  }
}

MediaImageInspectionResult inspectMediaInputForIsolate(MediaUploadInput input) {
  try {
    return MediaImageInspectionResult.success(inspectMediaInput(input));
  } on ApiFailure catch (error) {
    return MediaImageInspectionResult.failure(error.userMessage);
  } on Object {
    return const MediaImageInspectionResult.failure('图片无法解析，请选择其他图片。');
  }
}

MediaImageInspection inspectMediaInput(MediaUploadInput input) {
  final size = input.bytes.length;
  if (size < 1) {
    throw const ApiFailure(userMessage: '图片文件不能为空。');
  }
  if (size > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '图片大小不能超过 10MB。');
  }
  final decoder = image.findDecoderForData(input.bytes);
  if (decoder == null) {
    throw const ApiFailure(userMessage: '图片无法解析，请选择其他图片。');
  }
  final info = decoder.startDecode(input.bytes);
  if (info == null || info.width < 2 || info.height < 2) {
    throw const ApiFailure(userMessage: '图片尺寸无效，请选择其他图片。');
  }

  final format = decoder.format;
  final isGif = format == image.ImageFormat.gif;
  final isWebp = format == image.ImageFormat.webp;
  final contentType = switch (format) {
    image.ImageFormat.jpg => 'image/jpeg',
    image.ImageFormat.png => 'image/png',
    image.ImageFormat.gif => 'image/gif',
    image.ImageFormat.webp => 'image/webp',
    _ => null,
  };
  if (contentType == null) {
    throw const ApiFailure(userMessage: '仅支持 JPG、PNG、GIF 和 WebP 图片。');
  }

  if (isGif) {
    final gifInfo = (decoder as image.GifDecoder).info;
    final frameCount = gifInfo?.numFrames ?? 0;
    final durationMs =
        gifInfo?.frames.fold<int>(
          0,
          (sum, frame) => sum + frame.duration * 10,
        ) ??
        0;
    if (frameCount < 1) {
      throw const ApiFailure(userMessage: 'GIF 动图无法解析，请选择其他图片。');
    }
    if (info.width > maxGifEdge || info.height > maxGifEdge) {
      throw const ApiFailure(userMessage: 'GIF 动图最长边不能超过 2560 像素。');
    }
    if (frameCount > maxGifFrames) {
      throw const ApiFailure(userMessage: 'GIF 动图不能超过 300 帧。');
    }
    if (durationMs > maxGifDurationMs) {
      throw const ApiFailure(userMessage: 'GIF 动图时长不能超过 60 秒。');
    }
    if (info.width * info.height * frameCount > maxGifTotalPixels) {
      throw const ApiFailure(userMessage: 'GIF 动图画面过大，请压缩后重试。');
    }
  } else {
    final animatedWebp = isWebp && info is image.WebPInfo && info.hasAnimation;
    if (animatedWebp || info.numFrames > 1) {
      throw const ApiFailure(userMessage: '暂不支持动态 WebP，请改用 GIF 动图。');
    }
    if (info.width * info.height > maxStaticImagePixels) {
      throw const ApiFailure(userMessage: '图片像素过大，请缩小后重试。');
    }
  }

  return MediaImageInspection(
    width: info.width,
    height: info.height,
    contentType: contentType,
    isGif: isGif,
  );
}

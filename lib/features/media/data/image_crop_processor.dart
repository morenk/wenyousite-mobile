import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/diagnostics/failure_diagnostics.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/engine_media_image.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_work_coordinator.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class EngineImageCropProcessor implements ImageCropProcessor {
  EngineImageCropProcessor({MediaUploadWorkCoordinator? workCoordinator})
    : _workCoordinator = workCoordinator ?? MediaUploadWorkCoordinator();

  final MediaUploadWorkCoordinator _workCoordinator;

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) {
    return _run(() async {
      final original = await input.materialize();
      final source = await EngineMediaImage.open(original);
      try {
        final preview = await source.decode(maximumEdge: 1024);
        try {
          return CropImageSource(
            original: original,
            previewBytes: await mediaImagePng(preview),
            width: source.inspection.width,
            height: source.inspection.height,
            canCrop: !source.inspection.isGif,
          );
        } finally {
          preview.dispose();
        }
      } finally {
        source.dispose();
      }
    });
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) => _withPixels(
    source,
    (pixels) => _render(source, pixels, crop, 512, 512, 'avatar'),
  );

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) {
    if (!source.canCrop) return Future.value(source.original);
    return _withPixels(source, (pixels) async {
      final rect = _pixelCrop(pixels, crop);
      final longest = rect.width > rect.height ? rect.width : rect.height;
      final scale = longest > 2560 ? 2560 / longest : 1.0;
      var width = (rect.width * scale).round().clamp(1, 2560);
      var height = (rect.height * scale).round().clamp(1, 2560);
      var bytes = await renderMediaCrop(
        pixels,
        rect,
        width: width,
        height: height,
      );
      while (bytes.length > maxMediaImageBytes && width > 640 && height > 640) {
        width = (width * .82).round();
        height = (height * .82).round();
        bytes = await renderMediaCrop(
          pixels,
          rect,
          width: width,
          height: height,
        );
      }
      if (bytes.length > maxMediaImageBytes) {
        throw const ApiFailure(userMessage: '裁剪后的图片超过 10MB，请缩小取景范围。');
      }
      return MediaUploadInput(
        filename: 'cropped-image.png',
        declaredContentType: 'image/png',
        bytes: bytes,
        purpose: source.original.purpose,
      );
    });
  }

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) => _withPixels(source, (pixels) async {
    // 两个画幅复用一次原始像素解码，避免大图内存峰值叠加。
    return ProfileCoverImageSelection(
      web: await _render(
        source,
        pixels,
        webCrop,
        1920,
        640,
        'profile-cover-web',
      ),
      mobile: await _render(
        source,
        pixels,
        mobileCrop,
        1600,
        800,
        'profile-cover-mobile',
      ),
    );
  });

  Future<T> _withPixels<T>(
    CropImageSource source,
    Future<T> Function(ui.Image) operation,
  ) => _run(() async {
    final image = await EngineMediaImage.open(source.original);
    try {
      final pixels = await image.decode();
      try {
        return await operation(pixels);
      } finally {
        pixels.dispose();
      }
    } finally {
      image.dispose();
    }
  });

  Future<T> _run<T>(Future<T> Function() operation) {
    final diagnostics = FailureDiagnostics.instance;
    final attempt = diagnostics.attempt(DiagnosticOperation.mediaUpload);
    return attempt.run(
      () => _workCoordinator.prepare(() async {
        try {
          return await operation();
        } on Object catch (error, stack) {
          diagnostics.capture(
            error,
            stackTrace: stack,
            stage: DiagnosticStage.preparing,
            operation: DiagnosticOperation.mediaUpload,
          );
          rethrow;
        }
      }),
    );
  }
}

Future<MediaUploadInput> _render(
  CropImageSource source,
  ui.Image pixels,
  NormalizedCropRect crop,
  int width,
  int height,
  String filename,
) async {
  final bytes = await renderMediaCrop(
    pixels,
    _pixelCrop(pixels, crop),
    width: width,
    height: height,
  );
  if (bytes.length > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '裁剪后的图片超过 10MB，请更换图片。');
  }
  return MediaUploadInput(
    filename: '$filename.png',
    declaredContentType: 'image/png',
    bytes: bytes,
    purpose: source.original.purpose,
  );
}

ui.Rect _pixelCrop(ui.Image image, NormalizedCropRect crop) {
  if (![
        crop.left,
        crop.top,
        crop.width,
        crop.height,
      ].every((v) => v.isFinite) ||
      crop.width <= 0 ||
      crop.height <= 0) {
    throw const ApiFailure(userMessage: '取景范围无效，请重新调整。');
  }
  final left = (crop.left.clamp(0, 1) * image.width).floor().clamp(
    0,
    image.width - 1,
  );
  final top = (crop.top.clamp(0, 1) * image.height).floor().clamp(
    0,
    image.height - 1,
  );
  final right = (crop.right.clamp(0, 1) * image.width).ceil().clamp(
    left + 1,
    image.width,
  );
  final bottom = (crop.bottom.clamp(0, 1) * image.height).ceil().clamp(
    top + 1,
    image.height,
  );
  return ui.Rect.fromLTRB(
    left.toDouble(),
    top.toDouble(),
    right.toDouble(),
    bottom.toDouble(),
  );
}

final imageCropProcessorProvider = Provider<ImageCropProcessor>((ref) {
  return EngineImageCropProcessor(
    workCoordinator: ref.watch(mediaUploadWorkCoordinatorProvider),
  );
});

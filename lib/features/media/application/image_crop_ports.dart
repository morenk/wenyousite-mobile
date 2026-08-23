import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class NormalizedCropRect {
  const NormalizedCropRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
}

class CropImageSource {
  const CropImageSource({
    required this.original,
    required this.previewBytes,
    required this.width,
    required this.height,
    this.canCrop = true,
  });

  final MediaUploadInput original;
  final Uint8List previewBytes;
  final int width;
  final int height;
  final bool canCrop;
}

abstract interface class ImageCropProcessor {
  Future<CropImageSource> prepare(MediaUploadInput input);

  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  );

  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  );

  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  });
}

final imageCropProcessorPortProvider = Provider<ImageCropProcessor>((ref) {
  throw StateError(
    'ImageCropProcessor has not been bound at the app boundary.',
  );
});

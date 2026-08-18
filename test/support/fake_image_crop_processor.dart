import 'dart:convert';
import 'dart:typed_data';

import 'package:wenyousite_mobile/features/media/application/image_crop_ports.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class FakePassThroughImageCropProcessor implements ImageCropProcessor {
  const FakePassThroughImageCropProcessor();

  @override
  Future<CropImageSource> prepare(MediaUploadInput input) async {
    return CropImageSource(
      original: input,
      previewBytes: _previewBytes(),
      width: 40,
      height: 20,
    );
  }

  @override
  Future<MediaUploadInput> cropAvatar(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => source.original;

  @override
  Future<MediaUploadInput> cropImage(
    CropImageSource source,
    NormalizedCropRect crop,
  ) async => source.original;

  @override
  Future<ProfileCoverImageSelection> cropProfileCover(
    CropImageSource source, {
    required NormalizedCropRect webCrop,
    required NormalizedCropRect mobileCrop,
  }) async {
    return ProfileCoverImageSelection(
      web: source.original,
      mobile: source.original,
    );
  }
}

Uint8List _previewBytes() {
  return Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAIAAAABCAYAAAD0In+KAAAAFElEQVR42mP8z8Dwn4GBgYGJAQoAHgQCAWc8uS8AAAAASUVORK5CYII=',
    ),
  );
}

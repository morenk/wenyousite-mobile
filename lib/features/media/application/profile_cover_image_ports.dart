import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class ProfileCoverImageSelection {
  const ProfileCoverImageSelection({required this.web, required this.mobile});

  final MediaUploadInput web;
  final MediaUploadInput mobile;
}

abstract interface class ProfileCoverImagePicker {
  Future<MediaUploadInput?> pickProfileCoverFromGallery();
}

final profileCoverImagePickerPortProvider = Provider<ProfileCoverImagePicker>((
  ref,
) {
  throw StateError(
    'ProfileCoverImagePicker has not been bound at the app boundary.',
  );
});

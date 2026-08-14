import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class AvatarImagePicker {
  Future<MediaUploadInput?> pickAvatarFromGallery();
}

final avatarImagePickerPortProvider = Provider<AvatarImagePicker>((ref) {
  throw StateError('AvatarImagePicker has not been bound at the app boundary.');
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_policy.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class SystemProfileCoverImagePicker implements ProfileCoverImagePicker {
  SystemProfileCoverImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<MediaUploadInput?> pickProfileCoverFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final size = await file.length();
    if (size < 1) {
      throw const ApiFailure(userMessage: '背景图片文件不能为空。');
    }
    if (size > maxMediaImageBytes) {
      throw const ApiFailure(userMessage: '背景图片大小不能超过 10MB。');
    }
    return validateProfileCoverImageInput(
      MediaUploadInput(
        filename: file.name,
        declaredContentType: file.mimeType,
        bytes: await file.readAsBytes(),
      ),
    );
  }
}

final profileCoverImagePickerProvider = Provider<ProfileCoverImagePicker>((
  ref,
) {
  return SystemProfileCoverImagePicker(ImagePicker());
});

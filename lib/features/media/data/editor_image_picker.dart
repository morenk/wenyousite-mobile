import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

export 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart'
    show AvatarImagePicker;
export 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart'
    show EditorImagePicker;

class SystemEditorImagePicker implements EditorImagePicker, AvatarImagePicker {
  SystemEditorImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final size = await file.length();
    if (size < 1) {
      throw const ApiFailure(userMessage: '图片文件不能为空。');
    }
    if (size > maxMediaImageBytes) {
      throw const ApiFailure(userMessage: '图片大小不能超过 10MB。');
    }
    return MediaUploadInput(
      filename: file.name,
      declaredContentType: file.mimeType,
      bytes: await file.readAsBytes(),
    );
  }

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final size = await file.length();
    if (size < 1) {
      throw const ApiFailure(userMessage: '头像文件不能为空。');
    }
    if (size > maxMediaImageBytes) {
      throw const ApiFailure(userMessage: '头像大小不能超过 10MB。');
    }
    return MediaUploadInput(
      filename: file.name,
      declaredContentType: file.mimeType,
      bytes: await file.readAsBytes(),
    );
  }
}

final editorImagePickerProvider = Provider<EditorImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

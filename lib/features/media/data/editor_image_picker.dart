import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class EditorImagePicker {
  Future<MediaUploadInput?> pickFromGallery();
}

class SystemEditorImagePicker implements EditorImagePicker {
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
    if (size > ApiMediaUploadRepository.maxImageBytes) {
      throw const ApiFailure(userMessage: '图片大小不能超过 10MB。');
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

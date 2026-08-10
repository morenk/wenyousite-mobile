import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_repository.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class EditorImagePicker {
  Future<MediaUploadInput?> pickFromGallery();
}

abstract interface class AvatarImagePicker {
  Future<MediaUploadInput?> pickAvatarFromGallery();
}

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
    if (size > ApiMediaUploadRepository.maxImageBytes) {
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
    if (size > ApiMediaUploadRepository.maxImageBytes) {
      throw const ApiFailure(userMessage: '头像大小不能超过 10MB。');
    }
    return validateAvatarImageInput(
      MediaUploadInput(
        filename: file.name,
        declaredContentType: file.mimeType,
        bytes: await file.readAsBytes(),
      ),
    );
  }
}

MediaUploadInput validateAvatarImageInput(MediaUploadInput input) {
  if (input.bytes.isEmpty) {
    throw const ApiFailure(userMessage: '头像文件不能为空。');
  }
  if (input.bytes.length > ApiMediaUploadRepository.maxImageBytes) {
    throw const ApiFailure(userMessage: '头像大小不能超过 10MB。');
  }
  const allowed = {'image/jpeg', 'image/png', 'image/webp'};
  final declared = input.declaredContentType?.trim().toLowerCase();
  final detected = lookupMimeType(
    input.filename,
    headerBytes: input.bytes.take(32).toList(growable: false),
  )?.toLowerCase();
  if (detected != null && !allowed.contains(detected)) {
    throw const ApiFailure(userMessage: '头像仅支持 JPG、PNG 和 WebP 图片。');
  }
  final contentType = allowed.contains(detected) ? detected : declared;
  if (!allowed.contains(contentType)) {
    throw const ApiFailure(userMessage: '头像仅支持 JPG、PNG 和 WebP 图片。');
  }
  return MediaUploadInput(
    filename: input.filename,
    declaredContentType: contentType,
    bytes: input.bytes,
  );
}

final editorImagePickerProvider = Provider<EditorImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

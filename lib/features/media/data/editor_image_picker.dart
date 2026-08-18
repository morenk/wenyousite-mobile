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

class SystemEditorImagePicker
    implements EditorImagePicker, MultiEditorImagePicker, AvatarImagePicker {
  SystemEditorImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<MediaUploadInput?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return _readFile(file, emptyMessage: '图片文件不能为空。');
  }

  @override
  Future<List<MediaUploadInput>> pickManyFromGallery({
    required int limit,
  }) async {
    final files = await _picker.pickMultiImage(limit: limit);
    final inputs = <MediaUploadInput>[];
    for (final file in files) {
      inputs.add(await _readFile(file, emptyMessage: '图片文件不能为空。'));
    }
    return List.unmodifiable(inputs);
  }

  Future<MediaUploadInput> _readFile(
    XFile file, {
    required String emptyMessage,
  }) async {
    final size = await file.length();
    if (size < 1) {
      throw ApiFailure(userMessage: emptyMessage);
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
    return _readFile(file, emptyMessage: '头像文件不能为空。');
  }
}

final editorImagePickerProvider = Provider<EditorImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_picker_recovery_ports.dart';
import 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart';
import 'package:wenyousite_mobile/features/media/data/shared_preferences_media_picker_recovery_context_store.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

export 'package:wenyousite_mobile/features/media/application/avatar_image_ports.dart'
    show AvatarImagePicker;
export 'package:wenyousite_mobile/features/media/application/media_upload_ports.dart'
    show EditorImagePicker;

class SystemEditorImagePicker
    implements
        EditorImagePicker,
        MultiEditorImagePicker,
        RecoveryAwareEditorImagePicker,
        AvatarImagePicker {
  SystemEditorImagePicker(
    this._picker, {
    this._contextStore =
        const SharedPreferencesMediaPickerRecoveryContextStore(),
  });

  final ImagePicker _picker;
  final MediaPickerRecoveryContextStore _contextStore;

  @override
  Future<MediaUploadInput?> pickFromGallery() =>
      pickFromGalleryFor(MediaUploadPurpose.richContent);

  @override
  Future<MediaUploadInput?> pickFromGalleryFor(
    MediaUploadPurpose purpose,
  ) async {
    await _contextStore.begin(purpose);
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return null;
      return mediaUploadInputFromXFile(
        file,
        emptyMessage: '图片文件不能为空。',
        purpose: purpose,
      );
    } finally {
      await _contextStore.clear();
    }
  }

  @override
  Future<List<MediaUploadInput>> pickManyFromGallery({required int limit}) =>
      pickManyFromGalleryFor(
        limit: limit,
        purpose: MediaUploadPurpose.richContent,
      );

  @override
  Future<List<MediaUploadInput>> pickManyFromGalleryFor({
    required int limit,
    required MediaUploadPurpose purpose,
  }) async {
    await _contextStore.begin(purpose);
    try {
      final files = await _picker.pickMultiImage(limit: limit);
      final inputs = <MediaUploadInput>[];
      for (final file in files) {
        inputs.add(
          await mediaUploadInputFromXFile(
            file,
            emptyMessage: '图片文件不能为空。',
            purpose: purpose,
          ),
        );
      }
      return List.unmodifiable(inputs);
    } finally {
      await _contextStore.clear();
    }
  }

  @override
  Future<MediaUploadInput?> pickAvatarFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final input = await mediaUploadInputFromXFile(
      file,
      emptyMessage: '头像文件不能为空。',
    );
    return input.materialize();
  }
}

Future<MediaUploadInput> mediaUploadInputFromXFile(
  XFile file, {
  required String emptyMessage,
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
}) async {
  final size = await file.length();
  if (size < 1) {
    throw ApiFailure(
      userMessage: emptyMessage,
      reason: FailureReason.validation,
      recoveryAction: FailureRecoveryAction.none,
    );
  }
  if (size > maxMediaImageBytes) {
    throw const ApiFailure(
      userMessage: '图片大小不能超过 10MB。',
      reason: FailureReason.validation,
      recoveryAction: FailureRecoveryAction.none,
    );
  }
  if (file.path.trim().isEmpty) {
    return MediaUploadInput(
      filename: file.name,
      declaredContentType: file.mimeType,
      purpose: purpose,
      bytes: await file.readAsBytes(),
    );
  }
  return MediaUploadInput.fromPickedSource(
    PickedMediaSource.file(
      filename: file.name,
      path: file.path,
      length: size,
      declaredContentType: file.mimeType,
      purpose: purpose,
    ),
  );
}

final editorImagePickerProvider = Provider<EditorImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

final avatarImagePickerProvider = Provider<AvatarImagePicker>((ref) {
  return SystemEditorImagePicker(ImagePicker());
});

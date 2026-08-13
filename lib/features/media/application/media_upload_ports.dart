import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class EditorImagePicker {
  Future<MediaUploadInput?> pickFromGallery();
}

abstract interface class MediaUploadGateway {
  MediaUploadOperation<UploadedEditorImage> startImageUpload(
    MediaUploadInput input, {
    void Function(MediaUploadProgress progress)? onProgress,
  });
}

abstract interface class MediaUploadOperation<T> {
  Future<T> get result;

  void cancel();
}

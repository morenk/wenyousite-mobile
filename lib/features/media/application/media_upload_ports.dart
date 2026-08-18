import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class EditorImagePicker {
  Future<MediaUploadInput?> pickFromGallery();
}

/// Optional capability for product surfaces that accept a gallery rather than
/// a single attachment. Single-image test doubles and platform adapters can
/// continue to implement [EditorImagePicker] only.
abstract interface class MultiEditorImagePicker {
  Future<List<MediaUploadInput>> pickManyFromGallery({required int limit});
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

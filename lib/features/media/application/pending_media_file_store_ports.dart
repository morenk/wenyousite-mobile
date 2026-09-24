import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class PendingMediaFileStore {
  Future<MediaUploadInput> persist(
    MediaUploadInput input, {
    required String accountId,
    required String target,
    required String attachmentId,
  });

  Future<Map<String, Object?>?> read({
    required String accountId,
    required String target,
  });

  Future<void> write({
    required String accountId,
    required String target,
    required Map<String, Object?> payload,
  });

  Future<void> delete({required String accountId, required String target});
}

final pendingMediaFileStoreProvider = Provider<PendingMediaFileStore>((ref) {
  throw StateError(
    'PendingMediaFileStore has not been bound at the app boundary.',
  );
});

Map<String, Object?> encodePendingMediaInput(MediaUploadInput input) {
  final path = input.sourcePath;
  if (path == null) {
    throw StateError('Persist the image privately before saving its metadata.');
  }
  return {
    'filename': input.filename,
    'path': path,
    'length': input.byteLength,
    'contentType': input.declaredContentType,
    'purpose': input.purpose.name,
  };
}

/// 保留缺失文件的元数据，让编辑器展示可恢复/移除的占位。
MediaUploadInput? decodePendingMediaInput(Map<String, Object?> json) {
  final filename = json['filename'];
  final path = json['path'];
  final length = json['length'];
  final contentType = json['contentType'];
  final purpose = MediaUploadPurpose.values
      .where((value) => value.name == json['purpose'])
      .firstOrNull;
  if (filename is! String ||
      path is! String ||
      path.isEmpty ||
      length is! int ||
      length < 0 ||
      (contentType != null && contentType is! String) ||
      purpose == null) {
    return null;
  }
  return MediaUploadInput.fromPickedSource(
    PickedMediaSource.file(
      filename: filename,
      path: path,
      length: length,
      declaredContentType: contentType as String?,
      purpose: purpose,
    ),
  );
}

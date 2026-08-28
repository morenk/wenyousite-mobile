import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class MediaPickerRecoveryContextStore {
  Future<void> begin(MediaUploadPurpose purpose);

  Future<MediaUploadPurpose?> read();

  Future<void> clear();
}

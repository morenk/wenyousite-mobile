import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

abstract interface class MediaUploadNormalizer {
  Future<MediaUploadInput> normalize(MediaUploadInput input);
}

class PassThroughMediaUploadNormalizer implements MediaUploadNormalizer {
  const PassThroughMediaUploadNormalizer();

  @override
  Future<MediaUploadInput> normalize(MediaUploadInput input) async => input;
}

import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

MediaUploadInput validateProfileCoverImageInput(MediaUploadInput input) {
  if (input.bytes.isEmpty) {
    throw const ApiFailure(userMessage: '背景图片文件不能为空。');
  }
  if (input.bytes.length > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '背景图片大小不能超过 10MB。');
  }
  const allowed = {'image/jpeg', 'image/png', 'image/webp'};
  final contentType = validateMediaImageHeader(input);
  if (!allowed.contains(contentType)) {
    throw const ApiFailure(userMessage: '背景图片仅支持 JPG、PNG 和 WebP。');
  }
  return MediaUploadInput(
    filename: input.filename,
    declaredContentType: contentType,
    bytes: input.bytes,
    purpose: MediaUploadPurpose.profileCover,
  );
}

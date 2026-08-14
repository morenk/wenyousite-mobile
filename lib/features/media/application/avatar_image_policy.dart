import 'package:mime/mime.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

MediaUploadInput validateAvatarImageInput(MediaUploadInput input) {
  if (input.bytes.isEmpty) {
    throw const ApiFailure(userMessage: '头像文件不能为空。');
  }
  if (input.bytes.length > maxMediaImageBytes) {
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

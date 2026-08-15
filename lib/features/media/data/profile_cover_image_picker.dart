import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
import 'package:wenyousite_mobile/features/media/data/profile_cover_image_policy.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class SystemProfileCoverImagePicker implements ProfileCoverImagePicker {
  SystemProfileCoverImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<ProfileCoverImageSelection?> pickProfileCoverFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final size = await file.length();
    if (size < 1) {
      throw const ApiFailure(userMessage: '背景图片文件不能为空。');
    }
    if (size > maxMediaImageBytes) {
      throw const ApiFailure(userMessage: '背景图片大小不能超过 10MB。');
    }
    final source = validateProfileCoverImageInput(
      MediaUploadInput(
        filename: file.name,
        declaredContentType: file.mimeType,
        bytes: await file.readAsBytes(),
      ),
    );
    return createCenteredProfileCoverCrops(source);
  }
}

Future<ProfileCoverImageSelection> createCenteredProfileCoverCrops(
  MediaUploadInput source,
) {
  return compute(_createCenteredProfileCoverCrops, source);
}

ProfileCoverImageSelection _createCenteredProfileCoverCrops(
  MediaUploadInput source,
) {
  final decoded = image.decodeImage(source.bytes);
  if (decoded == null) {
    throw const ApiFailure(userMessage: '背景图片无法解析，请选择其他图片。');
  }
  final oriented = image.bakeOrientation(decoded);
  if (oriented.width < 2 || oriented.height < 1) {
    throw const ApiFailure(userMessage: '背景图片尺寸无效，请选择其他图片。');
  }
  final web = _centerCrop(
    oriented,
    ratio: 3,
    maxHeight: 500,
    filename: 'profile-cover-web.png',
  );
  final mobile = _centerCrop(
    oriented,
    ratio: 2,
    maxHeight: 600,
    filename: 'profile-cover-mobile.png',
  );
  return ProfileCoverImageSelection(web: web, mobile: mobile);
}

MediaUploadInput _centerCrop(
  image.Image source, {
  required int ratio,
  required int maxHeight,
  required String filename,
}) {
  final sourceWidth = source.width;
  final sourceHeight = source.height;
  final sourceRatio = sourceWidth / sourceHeight;
  final cropWidth = sourceRatio > ratio ? sourceHeight * ratio : sourceWidth;
  final cropHeight = sourceRatio > ratio ? sourceHeight : sourceWidth ~/ ratio;
  final left = (sourceWidth - cropWidth) ~/ 2;
  final top = (sourceHeight - cropHeight) ~/ 2;
  final outputHeight = cropHeight.clamp(1, maxHeight);
  final outputWidth = outputHeight * ratio;
  final cropped = image.copyCrop(
    source,
    x: left,
    y: top,
    width: cropWidth,
    height: cropHeight,
  );
  final resized = cropped.width == outputWidth && cropped.height == outputHeight
      ? cropped
      : image.copyResize(
          cropped,
          width: outputWidth,
          height: outputHeight,
          interpolation: image.Interpolation.cubic,
        );
  final bytes = image.encodePng(resized);
  if (bytes.length > maxMediaImageBytes) {
    throw const ApiFailure(userMessage: '裁剪后的背景图片超过 10MB，请选择其他图片。');
  }
  return MediaUploadInput(
    filename: filename,
    declaredContentType: 'image/png',
    bytes: bytes,
  );
}

final profileCoverImagePickerProvider = Provider<ProfileCoverImagePicker>((
  ref,
) {
  return SystemProfileCoverImagePicker(ImagePicker());
});

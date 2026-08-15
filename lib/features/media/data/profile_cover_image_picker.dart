import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_policy.dart';
import 'package:wenyousite_mobile/features/media/application/profile_cover_image_ports.dart';
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
) async {
  final codec = await ui.instantiateImageCodec(source.bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    if (image.width < 2 || image.height < 1) {
      throw const ApiFailure(userMessage: '背景图片尺寸无效，请选择其他图片。');
    }
    final web = await _centerCrop(
      image,
      ratio: 3,
      maxHeight: 500,
      filename: 'profile-cover-web.png',
    );
    final mobile = await _centerCrop(
      image,
      ratio: 2,
      maxHeight: 600,
      filename: 'profile-cover-mobile.png',
    );
    return ProfileCoverImageSelection(web: web, mobile: mobile);
  } finally {
    image.dispose();
    codec.dispose();
  }
}

Future<MediaUploadInput> _centerCrop(
  ui.Image image, {
  required int ratio,
  required int maxHeight,
  required String filename,
}) async {
  final sourceWidth = image.width.toDouble();
  final sourceHeight = image.height.toDouble();
  final sourceRatio = sourceWidth / sourceHeight;
  final cropWidth = sourceRatio > ratio ? sourceHeight * ratio : sourceWidth;
  final cropHeight = sourceRatio > ratio ? sourceHeight : sourceWidth / ratio;
  final left = (sourceWidth - cropWidth) / 2;
  final top = (sourceHeight - cropHeight) / 2;
  final outputHeight = cropHeight.floor().clamp(1, maxHeight);
  final outputWidth = outputHeight * ratio;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(left, top, cropWidth, cropHeight),
    ui.Rect.fromLTWH(0, 0, outputWidth.toDouble(), outputHeight.toDouble()),
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  final cropped = await recorder.endRecording().toImage(
    outputWidth,
    outputHeight,
  );
  try {
    final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      throw const ApiFailure(userMessage: '背景图片裁剪失败，请选择其他图片。');
    }
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    if (bytes.length > maxMediaImageBytes) {
      throw const ApiFailure(userMessage: '裁剪后的背景图片超过 10MB，请选择其他图片。');
    }
    return MediaUploadInput(
      filename: filename,
      declaredContentType: 'image/png',
      bytes: bytes,
    );
  } finally {
    cropped.dispose();
  }
}

final profileCoverImagePickerProvider = Provider<ProfileCoverImagePicker>((
  ref,
) {
  return SystemProfileCoverImagePicker(ImagePicker());
});

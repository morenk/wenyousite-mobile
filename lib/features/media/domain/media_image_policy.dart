import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MediaImageHeader {
  const MediaImageHeader.success(this.contentType) : errorMessage = null;
  const MediaImageHeader.failure(this.errorMessage) : contentType = null;

  final String? contentType;
  final String? errorMessage;
}

/// 仅按真实头字节识别已有上传格式，扩展名不能把未知文件变成图片。
MediaImageHeader inspectMediaImageHeader(MediaUploadInput input) {
  if (input.bytes.isEmpty) {
    return const MediaImageHeader.failure('图片文件不能为空。');
  }
  if (input.bytes.length > maxMediaImageBytes) {
    return const MediaImageHeader.failure('图片大小不能超过 10MB。');
  }
  const allowed = {'image/jpeg', 'image/png', 'image/gif', 'image/webp'};
  final detected = lookupMimeType('', headerBytes: input.bytes);
  if (!allowed.contains(detected)) {
    return const MediaImageHeader.failure('仅支持 JPG、PNG、GIF 和 WebP 图片。');
  }
  final declared = input.declaredContentType?.trim().toLowerCase();
  if (allowed.contains(declared) && declared != detected) {
    return const MediaImageHeader.failure('图片格式不符，请重新导出后选择。');
  }
  final bytes = input.bytes;
  if (detected == 'image/png' && _hasPngAnimation(bytes)) {
    return const MediaImageHeader.failure('暂不支持这种动图，请改用 GIF 动图。');
  }
  // 扩展 WebP 的动画标志无需解码像素即可识别，损坏动画也不能按静态图接收。
  if (detected == 'image/webp' &&
      bytes.length >= 21 &&
      bytes[12] == 0x56 &&
      bytes[13] == 0x50 &&
      bytes[14] == 0x38 &&
      bytes[15] == 0x58 &&
      bytes[20] & 2 != 0) {
    return const MediaImageHeader.failure('暂不支持动态 WebP，请改用 GIF 动图。');
  }
  return MediaImageHeader.success(detected!);
}

bool _hasPngAnimation(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  var offset = 8;
  while (offset + 12 <= bytes.length) {
    final length = data.getUint32(offset);
    if (length > bytes.length - offset - 12) return false;
    if (data.getUint32(offset + 4) == 0x6163544c) return true; // acTL
    offset += length + 12;
  }
  return false;
}

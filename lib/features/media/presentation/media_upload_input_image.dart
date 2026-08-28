import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class MediaUploadInputImage extends StatelessWidget {
  const MediaUploadInputImage({
    required this.input,
    required this.fit,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.gaplessPlayback = false,
    this.errorBuilder,
    super.key,
  });

  final MediaUploadInput input;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool gaplessPlayback;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final path = input.sourcePath;
    if (!input.isMaterialized && path != null) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        gaplessPlayback: gaplessPlayback,
        errorBuilder: errorBuilder,
      );
    }
    return Image.memory(
      input.bytes,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      gaplessPlayback: gaplessPlayback,
      errorBuilder: errorBuilder,
    );
  }
}

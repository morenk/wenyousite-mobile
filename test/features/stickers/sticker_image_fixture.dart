import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/stickers/domain/sticker_models.dart';

/// 离线合成缩略图，只注入图片缓存，不读取用户表情或发起网络请求。
Future<void> cacheStickerFixtures(
  WidgetTester tester,
  List<UserSticker> stickers,
  int cacheWidth,
) async {
  await tester.runAsync(() async {
    for (final (index, sticker) in stickers.indexed) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final color = const [
        Color(0xffffdca8),
        Color(0xffd1c6ee),
        Color(0xffbce4d5),
        Color(0xfff3c3d4),
      ][index % 4];
      canvas.drawCircle(const Offset(48, 48), 35, Paint()..color = color);
      final ink = Paint()
        ..color = const Color(0xff493e50)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(const Offset(36, 43), 3, ink);
      canvas.drawCircle(const Offset(60, 43), 3, ink);
      if (index.isEven) {
        canvas.drawArc(
          const Rect.fromLTWH(34, 48, 28, 20),
          0,
          3.14,
          false,
          ink..style = PaintingStyle.stroke,
        );
      } else {
        canvas.drawOval(const Rect.fromLTWH(43, 54, 10, 12), ink);
      }
      final picture = recorder.endRecording();
      final bitmap = await picture.toImage(96, 96);
      picture.dispose();
      final provider = CachedNetworkImageProvider(
        sticker.asset.thumbnailUrl,
        cacheKey: sticker.asset.thumbnailUrl,
      );
      for (final image in <ImageProvider>[
        provider,
        ResizeImage.resizeIfNeeded(cacheWidth, null, provider),
      ]) {
        final key = await image.obtainKey(ImageConfiguration.empty);
        PaintingBinding.instance.imageCache.putIfAbsent(
          key,
          () => OneFrameImageStreamCompleter(
            Future.value(ImageInfo(image: bitmap.clone())),
          ),
        );
      }
      bitmap.dispose();
    }
  });
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}

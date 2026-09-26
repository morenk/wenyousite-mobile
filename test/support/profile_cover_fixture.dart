import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> cacheProfileCover(WidgetTester tester) async {
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.teal, BlendMode.src);
    final picture = recorder.endRecording();
    final bitmap = await picture.toImage(16, 8);
    picture.dispose();
    const provider = CachedNetworkImageProvider(
      'https://cdn.example.com/cover-mobile.webp',
    );
    for (final image in <ImageProvider>[
      provider,
      ResizeImage.resizeIfNeeded(1200, 600, provider),
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
  });
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}

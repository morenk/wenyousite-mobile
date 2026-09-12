import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/thread_feed/application/cover_animation_source_ports.dart';

const playbackTestPoster = 'https://cdn.example/multiplay-poster.webp';

class RecordingCoverSource implements CoverAnimationSource {
  final urls = <String>[];
  final tokens = <CancelToken>[];
  @override
  Future<CoverAnimationData> load(String url, CancelToken cancel) {
    urls.add(url);
    tokens.add(cancel);
    return Completer<CoverAnimationData>().future;
  }

  @override
  Future<void> invalidate(String url) async {}
  @override
  void changeViewer(String? accountId, {required bool purge}) {}
  @override
  void releaseMemory() {}
  @override
  void dispose() {}
}

Future<void> cachePlaybackTestPoster(WidgetTester tester) async {
  await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    final bitmap = await picture.toImage(16, 16);
    picture.dispose();
    const provider = CachedNetworkImageProvider(playbackTestPoster);
    for (final image in <ImageProvider>[
      provider,
      ResizeImage.resizeIfNeeded(540, null, provider),
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
    await Future<void>.delayed(Duration.zero);
  });
  addTearDown(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
}

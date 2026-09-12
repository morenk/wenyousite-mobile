import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as image;

class MomentAnimationFixture {
  MomentAnimationFixture._(this.directory, this.previous);
  final Directory directory;
  final BaseCacheManager previous;
  late final CacheManager cache;
  final requests = <String>[];
  final failures = <String>{};
  final responseBytes = <String, int>{};

  static Future<void> run(
    WidgetTester tester,
    Future<void> Function(MomentAnimationFixture fixture) body, {
    Map<String, Uint8List> resources = const {},
  }) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('moment-animation-'),
    ))!;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
    final fixture = MomentAnimationFixture._(
      directory,
      CachedNetworkImageProvider.defaultCacheManager,
    );
    final red = image.Image(width: 12, height: 12)..frameDuration = 100;
    red.clear(image.ColorRgb8(255, 0, 0));
    red.addFrame()
      ..frameDuration = 100
      ..clear(image.ColorRgb8(0, 0, 255));
    final gif = Uint8List.fromList(image.encodeGif(red));
    final png = Uint8List.fromList(
      image.encodePng(red.frames.first, singleFrame: true),
    );
    final still = image.Image(width: 100, height: 50)
      ..clear(image.ColorRgb8(255, 0, 0));
    final stillPng = image.encodePng(still);
    fixture.cache = CacheManager(
      Config(
        directory.path.split(Platform.pathSeparator).last,
        // 全展示源回归只测 HTTP/解码；内存文件系统避免把 Windows 索引
        // 定时落盘混入这些场景，磁盘缓存另由专门的 source 测试覆盖。
        repo: resources.isEmpty
            ? JsonCacheInfoRepository.withFile(
                File('${directory.path}/cache.json'),
              )
            : NonStoringObjectProvider(),
        fileSystem: resources.isEmpty
            ? IOFileSystem(directory.path.split(Platform.pathSeparator).last)
            : MemoryCacheSystem(),
        fileService: HttpFileService(
          httpClient: MockClient((request) async {
            final url = request.url.toString();
            fixture.requests.add(url);
            if (fixture.failures.contains(url)) {
              return http.Response('failed', 503);
            }
            if (resources[url] case final Uint8List resource) {
              fixture.responseBytes.update(
                url,
                (value) => value + resource.length,
                ifAbsent: () => resource.length,
              );
              return http.Response.bytes(
                resource,
                200,
                headers: {
                  'content-type': url.endsWith('.webp')
                      ? 'image/webp'
                      : url.endsWith('.gif')
                      ? 'image/gif'
                      : 'image/png',
                },
              );
            }
            final isStill = url.contains('still');
            final isAnimation = !url.contains('thumb') && !isStill;
            return http.Response.bytes(
              isStill ? stillPng : (isAnimation ? gif : png),
              200,
              headers: {
                'content-type': isAnimation ? 'image/gif' : 'image/png',
              },
            );
          }),
        ),
      ),
    );
    CachedNetworkImageProvider.defaultCacheManager = fixture.cache;
    try {
      await body(fixture);
    } finally {
      await tester.pumpWidget(const SizedBox());
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      // CacheStore.dispose 不取消其 10 秒清理定时器；先在测试时钟内排空。
      await tester.pump(const Duration(seconds: 11));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.runAsync(fixture.cache.dispose);
      CachedNetworkImageProvider.defaultCacheManager = fixture.previous;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      );
      await tester.runAsync(() async {
        for (var attempt = 0; ; attempt++) {
          try {
            await directory.delete(recursive: true);
            break;
          } on PathAccessException {
            if (attempt >= 5) rethrow;
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
        }
      });
    }
  }
}

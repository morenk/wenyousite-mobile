import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/image_gallery.dart';
import 'package:wenyousite_mobile/core/platform/device_image_gallery.dart';

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'wenyou_image_gallery_test_',
    );
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('原地址失败后下载回退原图并按真实格式交给系统相册', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      if (request.uri.path == '/missing') {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(_pngBytes);
      }
      await request.response.close();
    });
    final bridge = _GalleryBridge();
    final service = DeviceImageGalleryService(
      dio: Dio(),
      bridge: bridge,
      temporaryDirectory: () async => temporaryDirectory,
    );

    await service
        .startSave(
          ImageGallerySource(
            url: 'http://127.0.0.1:${server.port}/missing',
            fallbackUrls: ['http://127.0.0.1:${server.port}/fallback'],
          ),
        )
        .result;

    expect(bridge.mimeType, 'image/png');
    expect(bridge.fileName, endsWith('.png'));
    expect(bridge.savedBytes, _pngBytes);
    expect(
      Directory(
        '${temporaryDirectory.path}${Platform.pathSeparator}wenyou_gallery',
      ).listSync(),
      isEmpty,
    );
  });

  test('重定向到非安全图片地址时拒绝保存', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set(
        HttpHeaders.locationHeader,
        'http://cdn.example.com/image.png',
      );
      await request.response.close();
    });
    final bridge = _GalleryBridge();
    final service = DeviceImageGalleryService(
      dio: Dio(),
      bridge: bridge,
      temporaryDirectory: () async => temporaryDirectory,
    );

    await expectLater(
      service
          .startSave(
            ImageGallerySource(url: 'http://127.0.0.1:${server.port}/redirect'),
          )
          .result,
      throwsA(
        isA<ImageGalleryException>().having(
          (failure) => failure.userMessage,
          'userMessage',
          '图片地址不安全，无法保存。',
        ),
      ),
    );
    expect(bridge.savedBytes, isNull);
  });

  test('权限被永久拒绝时不下载并提示打开设置', () async {
    final bridge = _GalleryBridge(permission: 'settingsRequired');
    final service = DeviceImageGalleryService(
      dio: Dio(),
      bridge: bridge,
      temporaryDirectory: () async => temporaryDirectory,
    );

    await expectLater(
      service
          .startSave(
            const ImageGallerySource(url: 'https://cdn.example.com/image.png'),
          )
          .result,
      throwsA(
        isA<ImageGalleryException>()
            .having(
              (failure) => failure.settingsRequired,
              'settingsRequired',
              isTrue,
            )
            .having(
              (failure) => failure.userMessage,
              'userMessage',
              contains('系统设置'),
            ),
      ),
    );
    expect(bridge.savedBytes, isNull);
  });
}

class _GalleryBridge implements ImageGalleryPlatformBridge {
  _GalleryBridge({this.permission = 'granted'});

  final String permission;
  List<int>? savedBytes;
  String? fileName;
  String? mimeType;

  @override
  Future<void> openSettings() async {}

  @override
  Future<String> requestAddPermission() async => permission;

  @override
  Future<void> saveImage({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    savedBytes = await File(filePath).readAsBytes();
    this.fileName = fileName;
    this.mimeType = mimeType;
  }
}

const _pngBytes = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00];

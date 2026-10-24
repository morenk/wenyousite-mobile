import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/application/photo_library_ports.dart';
import 'package:wenyousite_mobile/features/media/data/device_photo_library.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.fluttercandies/photo_manager');
  final calls = <MethodCall>[];
  String? filePath;
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'fetchEntityProperties' => {
              'id': 'photo',
              'type': 1,
              'width': 4,
              'height': 2,
              'title': 'animated.gif',
            },
            'getFullFile' => filePath,
            'requestPermissionExtend' || 'getPermissionState' => 3,
            _ => null,
          };
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test('仅请求图片，不请求视频和位置', () async {
    final library = DevicePhotoLibrary(isAndroid: true);
    expect(await library.permission(request: true), PhotoLibraryAccess.full);
    expect(await library.permission(request: false), PhotoLibraryAccess.full);
    for (final call in calls) {
      final args = call.arguments as Map;
      expect(args['androidPermission'], {'type': 1, 'mediaLocation': false});
    }
  });

  for (final android in [true, false]) {
    test('预览缩略图保留完整横竖比例 Android=$android', () async {
      final library = DevicePhotoLibrary(isAndroid: android);
      await library.thumbnail(
        const LocalPhoto('photo'),
        size: 1440,
        preserveAspect: true,
      );
      final option = (calls.last.arguments as Map)['option'] as Map;
      expect(option['width'], 1440);
      expect(option['height'], 720);
      await library.thumbnail(const LocalPhoto('photo'), size: 240);
      final gridOption = (calls.last.arguments as Map)['option'] as Map;
      expect(gridOption['width'], 240);
      expect(gridOption['height'], 240);
      expect(calls.any((call) => call.method == 'getFullFile'), isFalse);
    });
    test('确认取文件 Android=$android；GIF 不重编码、大小延迟实体化', () async {
      final directory = await Directory.systemTemp.createTemp('gallery-input-');
      addTearDown(() => directory.delete(recursive: true));
      final frame = image.Image(width: 4, height: 2)
        ..clear(image.ColorRgb8(255, 0, 0));
      frame.addFrame().clear(image.ColorRgb8(0, 0, 255));
      final gif = Uint8List.fromList(image.encodeGif(frame));
      final file = await File(
        '${directory.path}/cached-random.gif',
      ).writeAsBytes(gif);
      filePath = file.path;
      bool? requestedOriginal;
      final library = DevicePhotoLibrary(
        isAndroid: android,
        fileReader: (asset, {required original}) async {
          requestedOriginal = original;
          return File(filePath!);
        },
      );
      final input = await library.resolve(
        const LocalPhoto('photo'),
        MediaUploadPurpose.stickerSource,
      );
      expect(requestedOriginal, !android);
      expect(input.isMaterialized, isFalse);
      expect(input.filename, 'animated.gif');
      expect((await input.materialize()).bytes, gif);
      expect(input.purpose, MediaUploadPurpose.stickerSource);
      await file.writeAsBytes(Uint8List(maxMediaImageBytes + 1));
      await expectLater(
        library.resolve(
          const LocalPhoto('photo'),
          MediaUploadPurpose.richContent,
        ),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.userMessage,
            'message',
            contains('10MB'),
          ),
        ),
      );
      await file.delete();
      await expectLater(
        library.resolve(
          const LocalPhoto('photo'),
          MediaUploadPurpose.richContent,
        ),
        throwsA(isA<Exception>()),
      );
    });
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:wenyousite_mobile/core/network/api_failure.dart';
import 'package:wenyousite_mobile/features/media/data/media_image_validation.dart';
import 'package:wenyousite_mobile/features/media/data/media_upload_normalizer.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

void main() {
  test('静态图按用途转为 WebP 且同一输入重试不重复压缩', () async {
    final encoder = _RecordingWebpEncoder();
    final normalizer = FlutterMediaUploadNormalizer(encoder: encoder);
    final input = _staticInput(purpose: MediaUploadPurpose.moment);

    final first = await normalizer.normalize(input);
    final second = await normalizer.normalize(input);

    expect(first, same(second));
    expect(first.filename, 'scene.webp');
    expect(first.declaredContentType, 'image/webp');
    expect(first.purpose, MediaUploadPurpose.moment);
    expect(encoder.calls, 1);
    expect(encoder.targetWidth, 40);
    expect(encoder.targetHeight, 20);
    expect(encoder.quality, 85);
  });

  test('横长静态图按原比例收束到 2560 最长边', () async {
    final encoder = _RecordingWebpEncoder();
    final normalizer = FlutterMediaUploadNormalizer(encoder: encoder);
    final source = image.Image(width: 4000, height: 1000)
      ..clear(image.ColorRgb8(240, 120, 80));

    await normalizer.normalize(
      MediaUploadInput(filename: 'wide.png', bytes: image.encodePng(source)),
    );

    expect(encoder.targetWidth, 2560);
    expect(encoder.targetHeight, 640);
  });

  test('个人页背景图使用 92 质量参数', () async {
    final encoder = _RecordingWebpEncoder();
    final normalizer = FlutterMediaUploadNormalizer(encoder: encoder);

    await normalizer.normalize(
      _staticInput(purpose: MediaUploadPurpose.profileCover),
    );

    expect(encoder.quality, 92);
  });

  test('GIF 校验通过后保留文件名与原始字节且不调用静态编码器', () async {
    final animation = image.Image(width: 20, height: 10)..frameDuration = 80;
    animation.clear(image.ColorRgb8(255, 0, 0));
    animation.addFrame()
      ..frameDuration = 120
      ..clear(image.ColorRgb8(0, 0, 255));
    final bytes = image.encodeGif(animation);
    final input = MediaUploadInput(
      filename: 'wave.gif',
      bytes: bytes,
      declaredContentType: 'image/gif',
      purpose: MediaUploadPurpose.directMessage,
    );
    final encoder = _RecordingWebpEncoder();

    final output = await FlutterMediaUploadNormalizer(
      encoder: encoder,
    ).normalize(input);

    expect(output.filename, 'wave.gif');
    expect(output.declaredContentType, 'image/gif');
    expect(output.bytes, same(bytes));
    expect(output.purpose, MediaUploadPurpose.directMessage);
    expect(encoder.calls, 0);
  });

  test('GIF 在上传前执行尺寸、帧数与时长限制', () {
    final tooWide = image.Image(width: 2561, height: 2)
      ..clear(image.ColorRgb8(255, 0, 0));
    expect(
      () => inspectMediaInput(
        MediaUploadInput(filename: 'wide.gif', bytes: image.encodeGif(tooWide)),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('2560'),
        ),
      ),
    );

    final tooManyFrames = image.Image(width: 2, height: 2)..frameDuration = 100;
    for (var index = 1; index < 301; index++) {
      tooManyFrames.addFrame().frameDuration = 100;
    }
    expect(
      () => inspectMediaInput(
        MediaUploadInput(
          filename: 'frames.gif',
          bytes: image.encodeGif(tooManyFrames),
        ),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('300 帧'),
        ),
      ),
    );

    final tooLong = image.Image(width: 2, height: 2)..frameDuration = 30010;
    tooLong.addFrame().frameDuration = 30010;
    expect(
      () => inspectMediaInput(
        MediaUploadInput(filename: 'long.gif', bytes: image.encodeGif(tooLong)),
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('60 秒'),
        ),
      ),
    );
  });

  test('动态 WebP 在编码和网络请求前被拒绝', () async {
    final encoder = _RecordingWebpEncoder();
    final input = MediaUploadInput(
      filename: 'animated.webp',
      bytes: _animatedWebpHeader(),
      declaredContentType: 'image/webp',
    );

    await expectLater(
      FlutterMediaUploadNormalizer(encoder: encoder).normalize(input),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.userMessage,
          'message',
          contains('动态 WebP'),
        ),
      ),
    );
    expect(encoder.calls, 0);
  });

  test('静态编码失败时不会退回上传原文件', () async {
    final encoder = _ThrowingWebpEncoder();
    final normalizer = FlutterMediaUploadNormalizer(encoder: encoder);
    final input = _staticInput();

    await expectLater(normalizer.normalize(input), throwsA(isA<ApiFailure>()));
    await expectLater(normalizer.normalize(input), throwsA(isA<ApiFailure>()));
    expect(encoder.calls, 2);
  });
}

MediaUploadInput _staticInput({
  MediaUploadPurpose purpose = MediaUploadPurpose.richContent,
}) {
  final source = image.Image(width: 40, height: 20)
    ..clear(image.ColorRgb8(240, 120, 80));
  return MediaUploadInput(
    filename: 'scene.png',
    bytes: image.encodePng(source),
    declaredContentType: 'image/png',
    purpose: purpose,
  );
}

class _RecordingWebpEncoder implements StaticWebpEncoder {
  int calls = 0;
  int? targetWidth;
  int? targetHeight;
  int? quality;

  @override
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  }) async {
    calls += 1;
    this.targetWidth = targetWidth;
    this.targetHeight = targetHeight;
    this.quality = quality;
    return image.encodeWebP(image.decodeImage(bytes)!);
  }
}

class _ThrowingWebpEncoder implements StaticWebpEncoder {
  int calls = 0;

  @override
  Future<Uint8List> encode(
    Uint8List bytes, {
    required int targetWidth,
    required int targetHeight,
    required int quality,
  }) {
    calls += 1;
    return Future<Uint8List>.error(StateError('encode failed'));
  }
}

Uint8List _animatedWebpHeader() {
  final chunks = BytesBuilder(copy: false)
    ..add(_webpChunk('VP8X', [2, 0, 0, 0, 1, 0, 0, 1, 0, 0]))
    ..add(_webpChunk('ANIM', [0, 0, 0, 0, 0, 0]))
    ..add(
      _webpChunk('ANMF', [0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 100, 0, 0, 0]),
    );
  final body = chunks.takeBytes();
  final output = BytesBuilder(copy: false)
    ..add(ascii.encode('RIFF'))
    ..add(_uint32LittleEndian(body.length + 4))
    ..add(ascii.encode('WEBP'))
    ..add(body);
  return output.takeBytes();
}

Uint8List _webpChunk(String tag, List<int> payload) {
  final output = BytesBuilder(copy: false)
    ..add(ascii.encode(tag))
    ..add(_uint32LittleEndian(payload.length))
    ..add(payload);
  if (payload.length.isOdd) output.addByte(0);
  return output.takeBytes();
}

Uint8List _uint32LittleEndian(int value) => Uint8List.fromList([
  value & 0xff,
  (value >> 8) & 0xff,
  (value >> 16) & 0xff,
  (value >> 24) & 0xff,
]);

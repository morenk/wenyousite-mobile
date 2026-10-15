import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/media/media_audio.dart';
import 'package:wenyousite_mobile/features/media/application/audio_download.dart';
import 'package:wenyousite_mobile/features/media/data/device_audio_download.dart';
import 'package:wenyousite_mobile/features/media/domain/audio_download_filename.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/audio-save');
  late Directory directory;
  late Dio dio;
  late DeviceAudioDownload service;
  final audio = MediaAudio.parse({
    'sourceUrl': 'https://storage.example/a.mp3',
    'mediaId': 'a',
    'contentType': 'audio/mpeg',
    'size': 6,
    'durationMs': 1000,
  })!;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('audio-download-test-');
    dio = Dio();
    service = DeviceAudioDownload(
      dio: dio,
      platform: TargetPlatform.android,
      channel: channel,
      temporaryDirectory: () async => directory,
    );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    dio.close(force: true);
    await directory.delete(recursive: true);
  });
  void response({
    String mime = 'audio/mpeg',
    List<int> bytes = const [1, 2, 3, 4, 5, 6],
    int? length,
  }) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(
            options.headers.keys.map((e) => e.toLowerCase()),
            isNot(anyOf(contains('authorization'), contains('cookie'))),
          );
          expect(options.responseType, ResponseType.stream);
          handler.resolve(
            Response<ResponseBody>(
              requestOptions: options,
              statusCode: 200,
              headers: Headers.fromMap({
                'content-type': [mime],
                if (length != null) 'content-length': ['$length'],
              }),
              data: ResponseBody(
                Stream.fromIterable([
                  Uint8List.fromList(bytes.take(3).toList()),
                  Uint8List.fromList(bytes.skip(3).toList()),
                ]),
                200,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> emptyCache() async => expect(
    await directory.list(recursive: true).where((e) => e is File).toList(),
    isEmpty,
  );
  test('文件名保留原主体、真实mp3扩展且无路径/保留名/方向控制', () {
    expect(audioDownloadFilename('雨夜 [原声].wav'), '雨夜 [原声].mp3');
    expect(audioDownloadFilename('track.v2.FLAC'), 'track.v2.mp3');
    expect(audioDownloadFilename('CON.wav'), '_CON.mp3');
    expect(audioDownloadFilename('NUL. '), '_NUL.mp3');
    expect(audioDownloadFilename('../a\\b\u202emp3.wav'), '.._a_b_mp3.mp3');
    expect(audioDownloadFilename('...'), '音频.mp3');
  });
  test('点选后流式无认证下载，再系统导出，结果前清临时文件', () async {
    response();
    var saves = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          saves++;
          expect(call.method, 'saveAudio');
          expect(call.arguments['fileName'], '原声.mp3');
          expect(
            await File(call.arguments['filePath'] as String).readAsBytes(),
            [1, 2, 3, 4, 5, 6],
          );
          return true;
        });
    expect(await service.save(audio, '原声.wav').result, isTrue);
    expect(saves, 1);
    await emptyCache();
  });
  for (final kind in ['wrong-mime', 'oversize', 'truncated', 'header']) {
    test('$kind 拒绝保存且清理临时文件', () async {
      response(
        mime: kind == 'wrong-mime' ? 'text/html' : 'audio/mpeg',
        bytes: kind == 'oversize'
            ? List.filled(7, 0)
            : kind == 'truncated'
            ? [1]
            : [1, 2, 3, 4, 5, 6],
        length: kind == 'header' ? 100 : null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => fail('不得打开保存器'));
      await expectLater(
        service.save(audio, 'a.mp3').result,
        throwsA(isA<AudioSaveException>()),
      );
      await emptyCache();
    });
  }
  test('系统取消无失败，原生失败清理后显式可重试', () async {
    response();
    var failure = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          if (failure) throw PlatformException(code: 'failed');
          return false;
        });
    expect(await service.save(audio, 'a').result, isFalse);
    await emptyCache();
    failure = true;
    await expectLater(
      service.save(audio, 'a').result,
      throwsA(isA<AudioSaveException>()),
    );
    await emptyCache();
  });
  test('取消与引擎关闭不会产生unawaited异常或误报成功', () async {
    response();
    final entered = Completer<void>();
    final finish = Completer<bool>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'saveAudio') {
            entered.complete();
            return finish.future;
          }
          throw MissingPluginException();
        });
    final operation = service.save(audio, 'a');
    await entered.future;
    await operation.cancel();
    finish.complete(false);
    expect(await operation.result, isFalse);
    await emptyCache();
  });
  test('下载期间取消终止等待并清临时源', () async {
    final entered = Completer<void>();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          entered.complete();
          options.cancelToken!.whenCancel.then(handler.reject);
        },
      ),
    );
    final operation = service.save(audio, 'a');
    await entered.future;
    await operation.cancel();
    expect(await operation.result, isFalse);
    await emptyCache();
  });
}

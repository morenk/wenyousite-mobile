import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/media/audio_upload_policy.dart';
import 'package:wenyousite_mobile/features/media/application/audio_file_picker_ports.dart';
import 'package:wenyousite_mobile/features/media/data/system_audio_file_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/audio_picker');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final policy = AudioUploadPolicy.parse({
    'version': 1,
    'maxBytes': 31457280,
    'maxDurationMs': 600000,
    'contentTypes': [
      'audio/mpeg',
      'audio/mp4',
      'audio/wav',
      'audio/flac',
      'audio/ogg',
    ],
    'outputContentType': 'audio/mpeg',
  })!;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  test('原生选择端口收到预算与同格式别名，只返回文件句柄', () async {
    String? released;
    messenger.setMockMethodCallHandler(channel, (call) async {
      final arguments = call.arguments as Map;
      if (call.method == 'release') {
        released = arguments['id'] as String;
        return null;
      }
      expect(arguments['maximumBytes'], 31457280);
      expect(
        arguments['contentTypes'],
        containsAll(['audio/x-wav', 'audio/x-flac', 'audio/x-m4a']),
      );
      return {
        'id': arguments['id'],
        'filename': '声.wav',
        'path': 'owned-cache.wav',
        'size': 128,
        'contentType': 'audio/x-wav',
      };
    });
    final file = await const SystemAudioFilePicker(
      channel: channel,
      platform: TargetPlatform.android,
    ).pick(policy.selection).result;
    expect(file?.path, 'owned-cache.wav');
    expect(
      policy.normalizeContentType(file?.declaredContentType, file!.filename),
      'audio/wav',
    );
    await file.release();
    expect(released, isNotEmpty);
  });
  test('取消与迟到结果竞态释放本次句柄，结果为空', () async {
    final picked = Completer<Map<String, Object?>>();
    String? id;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'pick') {
        id = (call.arguments as Map)['id'] as String;
        return picked.future;
      }
      return null;
    });
    final operation = const SystemAudioFilePicker(
      channel: channel,
      platform: TargetPlatform.android,
    ).pick(policy.selection);
    await Future<void>.delayed(Duration.zero);
    await operation.cancel();
    picked.complete({
      'id': id,
      'filename': '声.mp3',
      'path': 'owned-cache.mp3',
      'size': 128,
      'contentType': 'audio/mpeg',
    });
    expect(await operation.result, isNull);
    expect(calls, ['pick', 'cancel', 'release']);
  });
  test('无效原生大小拒绝并清理句柄', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method != 'pick') return null;
      return {
        'id': (call.arguments as Map)['id'],
        'filename': '声.mp3',
        'path': 'owned-cache.mp3',
        'size': 31457281,
      };
    });
    final result = const SystemAudioFilePicker(
      channel: channel,
      platform: TargetPlatform.android,
    ).pick(policy.selection).result;
    await expectLater(result, throwsA(isA<AudioFileSelectionException>()));
    expect(calls, ['pick', 'release']);
  });
}

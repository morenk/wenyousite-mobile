import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/posts/application/post_render_diagnostics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('帖子渲染失败阶段使用稳定日志值', () {
    expect(PostRenderFailureStage.values.map((stage) => stage.wireValue), [
      'fetch',
      'parse',
      'layout',
      'media_decode',
      'webview_process',
      'draw',
    ]);
  });

  testWidgets(
    '帖子渲染事件包含运行环境与阶段且不携带内容标识',
    (tester) async {
      const channel = MethodChannel('site.wenyou.app/test_runtime_diagnostics');
      var runtimeReads = 0;
      final logs = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'getRuntimeInfo');
            runtimeReads += 1;
            return <String, Object?>{
              'appVersion': '0.4.1-dev.1',
              'buildNumber': '89',
              'operatingSystem': 'Android 16 (API 36)',
              'deviceModel': 'HONOR Magic8',
              'renderer': 'flutter-native',
            };
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
      final diagnostics = LogcatPostRenderDiagnostics(
        channel: channel,
        sink: logs.add,
      );

      const event = PostRenderDiagnosticEvent(
        succeeded: false,
        fetchSucceeded: true,
        contentType: 'rich_markdown',
        contentBlockCount: 4,
        containerWidth: 360.4,
        containerHeight: 0,
        keyboardInset: 320,
        duration: Duration(milliseconds: 245),
        failureStage: PostRenderFailureStage.layout,
        errorCode: 'phantom_ime_inset',
      );
      await diagnostics.record(event);
      await diagnostics.record(event);

      expect(runtimeReads, 1);
      expect(logs, hasLength(2));
      final payload = jsonDecode(logs.first) as Map<String, dynamic>;
      expect(payload, {
        'event': 'post_detail_render_result',
        'appVersion': '0.4.1-dev.1',
        'buildNumber': '89',
        'operatingSystem': 'Android 16 (API 36)',
        'deviceModel': 'HONOR Magic8',
        'renderer': 'flutter-native',
        'rendererVariant': 'unspecified',
        'succeeded': false,
        'fetchSucceeded': true,
        'contentType': 'rich_markdown',
        'contentBlockCount': 4,
        'containerWidth': 360,
        'containerHeight': 0,
        'keyboardInset': 320,
        'failureStage': 'layout',
        'errorCode': 'phantom_ime_inset',
        'durationMs': 245,
      });
      expect(payload.keys, isNot(contains('postId')));
      expect(payload.keys, isNot(contains('content')));
      expect(payload.keys, isNot(contains('token')));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}

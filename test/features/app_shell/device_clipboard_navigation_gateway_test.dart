import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/app_shell/data/device_clipboard_navigation_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('site.wenyou.app/clipboard_navigation');
  const gateway = DeviceClipboardNavigationGateway();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  for (final token in [
    'android:123:550e8400-e29b-41d4-a716-446655440000',
    'ios:42',
  ]) {
    test('单次原生写入保留文本并返回对应事件 $token', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return token;
      });
      const text = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
      expect(await gateway.writeText(text), token);
      expect(calls, hasLength(1));
      expect(calls.single.method, 'writeText');
      expect(calls.single.arguments, {'text': text});
    });
  }

  test('复制失败向入口报告，写入成功但无法验证事件返回空标识', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'clipboard_unavailable'),
    );
    await expectLater(
      gateway.writeText('link'),
      throwsA(isA<PlatformException>()),
    );
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await gateway.writeText('link'), isNull);
  });

  test('读取保持原生事件版本，即使外部保留marker但timestamp变化仍不同', () async {
    const marker = '550e8400-e29b-41d4-a716-446655440000';
    var timestamp = 100;
    messenger.setMockMethodCallHandler(channel, (call) async {
      final token = 'android:$timestamp:$marker';
      return call.method == 'readSnapshot'
          ? {'text': 'link', 'changeToken': token}
          : token;
    });
    final first = await gateway.readChangeToken();
    timestamp += 1;
    expect(await gateway.readChangeToken(), isNot(first));
    expect((await gateway.readSnapshot())?.changeToken, 'android:101:$marker');
  });
}

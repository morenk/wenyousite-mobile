import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/data/handled_clipboard_navigation_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageKey = 'clipboard_navigation.handled.v1';
  const fingerprint =
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('只持久化复制版本和不可逆指纹并可跨实例读取', () async {
    const store = SharedPreferencesHandledClipboardNavigationStore();
    const value = HandledClipboardNavigation(
      changeToken: 'android:123456',
      fingerprint: fingerprint,
    );

    await store.write(value);
    final restored =
        await const SharedPreferencesHandledClipboardNavigationStore().read();
    final raw = (await SharedPreferences.getInstance()).getString(storageKey)!;

    expect(restored?.changeToken, value.changeToken);
    expect(restored?.fingerprint, value.fingerprint);
    expect(raw, contains(fingerprint));
    expect(raw, isNot(contains('/join/')));
    expect(raw, isNot(contains('wenyou.site')));
  });

  test('损坏、未知版本或非哈希记录都安全忽略', () async {
    final invalidValues = <String>[
      '{',
      jsonEncode({'schema': 2, 'fingerprint': fingerprint}),
      jsonEncode({'schema': 1, 'fingerprint': 'invite-token'}),
      jsonEncode({
        'schema': 1,
        'fingerprint': fingerprint,
        'changeToken': List<String>.filled(2, 'invalid'),
      }),
    ];

    for (final raw in invalidValues) {
      SharedPreferences.setMockInitialValues({storageKey: raw});
      final restored =
          await const SharedPreferencesHandledClipboardNavigationStore().read();
      expect(restored, isNull, reason: raw);
    }
  });
}

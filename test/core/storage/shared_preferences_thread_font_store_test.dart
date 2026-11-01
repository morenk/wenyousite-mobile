import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_thread_font_store.dart';

void main() {
  const store = SharedPreferencesThreadFontStore();
  const key = SharedPreferencesThreadFontStore.storageKey;

  test('旧默认改为 15，显式字号保持，读取不改写', () async {
    for (final entry in {
      'small': 14,
      'standard': 15,
      'size15': 15,
      'size16': 16,
      'size13': 13,
      'size14': 14,
      'size17': 17,
      'size18': 18,
      'size19': 19,
      'large': 18,
      'extraLarge': 19,
      'largest': 19,
    }.entries) {
      SharedPreferences.setMockInitialValues({key: entry.key});
      expect((await store.read()).fontSize, entry.value);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(key), entry.key);
    }
  });

  test('缺省、未知档位和错误类型均安全使用默认字号', () async {
    for (final value in [null, 'future-size', 999, true]) {
      SharedPreferences.setMockInitialValues({key: ?value});
      expect(await store.read(), ThreadFontPreference.standard);
    }
  });

  test('每档跨存储实例恢复，恢复默认移除覆盖且保留其他偏好', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.preference.v1': 'dark',
    });
    for (final preference in ThreadFontPreference.values) {
      await store.write(preference);
      expect(await const SharedPreferencesThreadFontStore().read(), preference);
    }
    await store.write(ThreadFontPreference.standard);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey(key), isFalse);
    expect(preferences.getString('appearance.preference.v1'), 'dark');
  });
}

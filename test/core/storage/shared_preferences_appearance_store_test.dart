import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_appearance_store.dart';

void main() {
  const store = SharedPreferencesAppearanceStore();

  test('缺失或未知本地值安全回退跟随系统', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await store.read(), AppearancePreference.system);

    SharedPreferences.setMockInitialValues({
      SharedPreferencesAppearanceStore.storageKey: 'future-mode',
    });
    expect(await store.read(), AppearancePreference.system);
  });

  test('显式模式持久化，跟随系统移除覆盖值', () async {
    SharedPreferences.setMockInitialValues({});

    await store.write(AppearancePreference.dark);
    expect(await store.read(), AppearancePreference.dark);
    var preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(SharedPreferencesAppearanceStore.storageKey),
      'dark',
    );

    await store.write(AppearancePreference.system);
    expect(await store.read(), AppearancePreference.system);
    preferences = await SharedPreferences.getInstance();
    expect(
      preferences.containsKey(SharedPreferencesAppearanceStore.storageKey),
      isFalse,
    );
  });
}

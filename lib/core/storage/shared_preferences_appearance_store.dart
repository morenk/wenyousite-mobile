import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';
import 'package:wenyousite_mobile/core/storage/environment_storage.dart';

class SharedPreferencesAppearanceStore implements AppearancePreferenceStore {
  const SharedPreferencesAppearanceStore();

  static const storageKey = 'appearance.preference.v1';

  @override
  Future<AppearancePreference> read() async {
    final preferences = await SharedPreferences.getInstance();
    return AppearancePreference.fromStorage(
      preferences.getString(environmentPreferenceKey(storageKey)),
    );
  }

  @override
  Future<void> write(AppearancePreference preference) async {
    final preferences = await SharedPreferences.getInstance();
    final succeeded = preference == AppearancePreference.system
        ? await preferences.remove(environmentPreferenceKey(storageKey))
        : await preferences.setString(
            environmentPreferenceKey(storageKey),
            preference.name,
          );
    if (!succeeded) {
      throw StateError('外观设置写入失败');
    }
  }
}

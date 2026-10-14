import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';

class SharedPreferencesThreadFontStore implements ThreadFontPreferenceStore {
  const SharedPreferencesThreadFontStore();

  static const storageKey = 'reading.threadFont.v1';

  @override
  Future<ThreadFontPreference> read() async {
    final preferences = await SharedPreferences.getInstance();
    return ThreadFontPreference.fromStorage(preferences.get(storageKey));
  }

  @override
  Future<void> write(ThreadFontPreference preference) async {
    final preferences = await SharedPreferences.getInstance();
    final succeeded = preference == ThreadFontPreference.standard
        ? await preferences.remove(storageKey)
        : await preferences.setString(storageKey, preference.name);
    if (!succeeded) throw StateError('字号设置保存失败');
  }
}

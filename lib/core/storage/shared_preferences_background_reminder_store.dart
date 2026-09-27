import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/storage/environment_storage.dart';

class SharedPreferencesBackgroundReminderStore
    implements BackgroundReminderPreferenceStore {
  const SharedPreferencesBackgroundReminderStore();

  static const storageKey = 'background.reminder.enabled.v1';

  @override
  Future<bool> read() async {
    return (await SharedPreferences.getInstance()).getBool(
          environmentPreferenceKey(storageKey),
        ) ??
        true;
  }

  @override
  Future<void> write(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(
      environmentPreferenceKey(storageKey),
      enabled,
    )) {
      throw StateError('Cannot save background reminder preference');
    }
  }
}

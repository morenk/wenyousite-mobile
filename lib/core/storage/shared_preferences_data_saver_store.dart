import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';

class SharedPreferencesDataSaverStore implements DataSaverPreferenceStore {
  const SharedPreferencesDataSaverStore();

  static const storageKey = 'media.dataSaver.v1';

  @override
  Future<bool> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(storageKey) ?? false;
  }

  @override
  Future<void> write(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(storageKey, enabled)) {
      throw StateError('Cannot save data saver preference');
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/media/application/media_picker_recovery_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class SharedPreferencesMediaPickerRecoveryContextStore
    implements MediaPickerRecoveryContextStore {
  const SharedPreferencesMediaPickerRecoveryContextStore();

  static const storageKey = 'media.picker.pending-purpose.v1';

  @override
  Future<void> begin(MediaUploadPurpose purpose) async {
    final preferences = await SharedPreferences.getInstance();
    final written = await preferences.setString(storageKey, purpose.name);
    if (!written) throw StateError('Unable to record media picker context.');
  }

  @override
  Future<MediaUploadPurpose?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(storageKey);
    if (stored == null) return null;
    for (final purpose in MediaUploadPurpose.values) {
      if (purpose.name == stored) return purpose;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    final removed = await preferences.remove(storageKey);
    if (!removed && preferences.containsKey(storageKey)) {
      throw StateError('Unable to clear media picker context.');
    }
  }
}

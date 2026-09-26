import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/storage/environment_storage.dart';
import 'package:wenyousite_mobile/features/media/application/media_picker_recovery_ports.dart';
import 'package:wenyousite_mobile/features/media/domain/media_upload_models.dart';

class SharedPreferencesMediaPickerRecoveryContextStore
    implements MediaPickerRecoveryContextStore {
  const SharedPreferencesMediaPickerRecoveryContextStore();

  static const storageKey = 'media.picker.pending-purpose.v1';
  static const _ownerKey = 'media.picker.environment.v1';

  @override
  Future<void> begin(MediaUploadPurpose purpose) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(
      _ownerKey,
      environmentPreferenceKey(storageKey),
    )) {
      throw StateError('Unable to record media picker environment.');
    }
    final written = await preferences.setString(
      environmentPreferenceKey(storageKey),
      purpose.name,
    );
    if (!written) throw StateError('Unable to record media picker context.');
  }

  @override
  Future<MediaUploadPurpose?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final owner = preferences.getString(_ownerKey);
    final key = environmentPreferenceKey(storageKey);
    // 无标记的旧线上选择仍在原环境恢复，预览不得读取。
    if (owner != key && !(owner == null && key == storageKey)) return null;
    final stored = preferences.getString(environmentPreferenceKey(storageKey));
    if (stored == null) return null;
    for (final purpose in MediaUploadPurpose.values) {
      if (purpose.name == stored) return purpose;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    final removed = await preferences.remove(
      environmentPreferenceKey(storageKey),
    );
    if (!removed &&
        preferences.containsKey(environmentPreferenceKey(storageKey))) {
      throw StateError('Unable to clear media picker context.');
    }
  }
}

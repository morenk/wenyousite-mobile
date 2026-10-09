import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/app_shell/application/mobile_update_notice_ports.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update.dart';
import 'package:wenyousite_mobile/features/app_shell/domain/mobile_update_notice.dart';

class SharedPreferencesMobileUpdateNoticeStore
    implements MobileUpdateNoticeStore {
  const SharedPreferencesMobileUpdateNoticeStore();

  String _key(MobileClientPlatform platform) =>
      'mobile_update_notice_v1_${platform.name}';

  @override
  Future<MobileUpdateNoticeRecord?> read(MobileClientPlatform platform) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_key(platform));
    if (value == null) return null;
    return MobileUpdateNoticeRecord.fromJson(jsonDecode(value));
  }

  @override
  Future<void> write(
    MobileClientPlatform platform,
    MobileUpdateNoticeRecord record,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(
      _key(platform),
      jsonEncode(record.toJson()),
    )) {
      throw StateError('Update notice preference was not persisted.');
    }
  }
}

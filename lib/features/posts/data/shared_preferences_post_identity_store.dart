import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/storage/environment_storage.dart';
import 'package:wenyousite_mobile/features/posts/application/post_identity_preference_ports.dart';

class SharedPreferencesPostIdentityStore
    implements PostIdentityPreferenceStore {
  final _values = <String, String?>{};
  Future<void> _writes = Future.value();

  String _key(String accountId, String threadId) => environmentPreferenceKey(
    'post_identity_choice_v1:${jsonEncode([accountId, threadId])}',
  );

  @override
  Future<String?> read(String accountId, String threadId) async {
    final key = _key(accountId, threadId);
    if (_values.containsKey(key)) return _values[key];
    try {
      final preferences = await SharedPreferences.getInstance();
      // 等待插件期间的新选择优先，旧磁盘结果不能覆盖它。
      return _values.putIfAbsent(key, () => preferences.getString(key));
    } on Object {
      return _values[key];
    }
  }

  @override
  Future<void> write(String accountId, String threadId, String? identityId) {
    final key = _key(accountId, threadId);
    _values[key] = identityId;
    _writes = _writes.then((_) async {
      try {
        final preferences = await SharedPreferences.getInstance();
        if (identityId == null) {
          await preferences.remove(key);
        } else {
          await preferences.setString(key, identityId);
        }
      } on Object {
        // 偏好写盘失败仍保留本次运行的选择，不阻止写作与发表。
      }
    });
    return _writes;
  }
}

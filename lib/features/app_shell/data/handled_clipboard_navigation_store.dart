import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/app_shell/application/clipboard_navigation_ports.dart';

class SharedPreferencesHandledClipboardNavigationStore
    implements HandledClipboardNavigationStore {
  const SharedPreferencesHandledClipboardNavigationStore();

  static const _storageKey = 'clipboard_navigation.handled.v1';
  static final _fingerprintPattern = RegExp(r'^[a-f0-9]{64}$');

  @override
  Future<HandledClipboardNavigation?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic> || json['schema'] != 1) return null;
      final fingerprint = json['fingerprint'];
      final changeToken = json['changeToken'];
      if (fingerprint is! String ||
          !_fingerprintPattern.hasMatch(fingerprint) ||
          (changeToken != null &&
              (changeToken is! String ||
                  changeToken.isEmpty ||
                  changeToken.length > 160))) {
        return null;
      }
      return HandledClipboardNavigation(
        changeToken: changeToken as String?,
        fingerprint: fingerprint,
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(HandledClipboardNavigation value) async {
    final preferences = await SharedPreferences.getInstance();
    final succeeded = await preferences.setString(
      _storageKey,
      jsonEncode({
        'schema': 1,
        'changeToken': value.changeToken,
        'fingerprint': value.fingerprint,
      }),
    );
    if (!succeeded) {
      throw StateError('剪贴板导航选择保存失败');
    }
  }
}

final sharedPreferencesHandledClipboardNavigationStoreProvider =
    Provider<HandledClipboardNavigationStore>(
      (ref) => const SharedPreferencesHandledClipboardNavigationStore(),
    );

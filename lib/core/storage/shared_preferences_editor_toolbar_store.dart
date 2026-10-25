import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';

class SharedPreferencesEditorToolbarStore
    implements EditorToolbarPreferenceStore {
  const SharedPreferencesEditorToolbarStore();
  static const storageKey = 'editor.toolbar.layout.v1';

  @override
  Future<EditorToolbarLayout> read() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.get(storageKey);
    if (raw is! String) return const EditorToolbarLayout.defaults();
    try {
      return EditorToolbarLayout.fromJson(jsonDecode(raw));
    } on FormatException {
      return const EditorToolbarLayout.defaults();
    }
  }

  @override
  Future<void> write(EditorToolbarLayout layout) async {
    final preferences = await SharedPreferences.getInstance();
    final succeeded = layout.isDefault
        ? await preferences.remove(storageKey)
        : await preferences.setString(storageKey, jsonEncode(layout.toJson()));
    if (!succeeded) throw StateError('工具栏设置保存失败');
  }
}

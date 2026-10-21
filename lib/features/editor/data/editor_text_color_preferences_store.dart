import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';

class SharedPreferencesEditorTextColorStore
    implements EditorTextColorPreferenceStore {
  const SharedPreferencesEditorTextColorStore();

  static String storageKey(String accountId) =>
      'editor.textColor.v1.${Uri.encodeComponent(accountId)}';

  @override
  Future<List<String>> read(String accountId) async =>
      (await SharedPreferences.getInstance()).getStringList(
        storageKey(accountId),
      ) ??
      const [];

  @override
  Future<void> write(String accountId, List<String> colors) async {
    final saved = await (await SharedPreferences.getInstance()).setStringList(
      storageKey(accountId),
      colors,
    );
    if (!saved) throw StateError('最近使用颜色保存失败');
  }
}

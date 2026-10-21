import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_editor_toolbar_store.dart';

void main() {
  const store = SharedPreferencesEditorToolbarStore();
  const key = SharedPreferencesEditorToolbarStore.storageKey;

  test('两组及各自顺序跨存储实例恢复，默认删除覆盖键并保持默认语义', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.preference.v1': 'dark',
    });
    final layout = const EditorToolbarLayout.defaults()
        .move(EditorTool.image, EditorToolbarGroup.expanded, 0)
        .move(EditorTool.sticker, EditorToolbarGroup.primary, 0);
    await store.write(layout);
    expect(await const SharedPreferencesEditorToolbarStore().read(), layout);
    await store.write(const EditorToolbarLayout.defaults());
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey(key), isFalse);
    expect(
      (await const SharedPreferencesEditorToolbarStore().read()).isDefault,
      isTrue,
    );
    expect(preferences.get('appearance.preference.v1'), 'dark');
  });

  test('缺省、损坏JSON、未知版本和错误类型只读回退默认，不覆盖旧值', () async {
    for (final value in [null, '{bad', '[]', '{"version":2}', true, 12]) {
      SharedPreferences.setMockInitialValues({key: ?value});
      expect((await store.read()).isDefault, isTrue);
      expect((await SharedPreferences.getInstance()).get(key), value);
    }
  });
}

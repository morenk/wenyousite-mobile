import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/data/editor_text_color_preferences_store.dart';

void main() {
  test('最近色去重、排序并限制长度', () {
    expect(
      rememberEditorTextColor(
        ['#112233', '#445566', '#778899', '#AABBCC'],
        '#445566',
        maximum: 4,
      ),
      ['#445566', '#112233', '#778899', '#AABBCC'],
    );
    expect(
      rememberEditorTextColor(
        ['#112233', '#445566', '#778899', '#AABBCC'],
        '#000000',
        maximum: 4,
      ),
      ['#000000', '#112233', '#445566', '#778899'],
    );
  });
  test('本机颜色按账号隔离并可重开', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesEditorTextColorStore();
    await store.write('account-a', ['#112233']);
    await store.write('account-b', ['#445566']);
    expect(await store.read('account-a'), ['#112233']);
    expect(await store.read('account-b'), ['#445566']);
    expect(await store.read('account-c'), isEmpty);
  });
}

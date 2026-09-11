import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/data_saver_preference.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_data_saver_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('默认所有网络允许，设备偏好跨实例保存', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesDataSaverStore();
    expect((await loadInitialDataSaverPreference(store)).enabled, isFalse);
    final container = ProviderContainer(
      overrides: [dataSaverPreferenceStoreProvider.overrideWithValue(store)],
    );
    final controller = container.read(
      dataSaverPreferenceControllerProvider.notifier,
    );
    await controller.select(true);
    expect(
      container.read(dataSaverPreferenceControllerProvider).enabled,
      isTrue,
    );
    expect(
      (await loadInitialDataSaverPreference(
        const SharedPreferencesDataSaverStore(),
      )).enabled,
      isTrue,
    );
    container.dispose();
  });
  test('读取失败暂停自动播放，双向保存失败均保持当前会话选择', () async {
    final store = _FailingStore();
    final state = await loadInitialDataSaverPreference(store);
    expect(state.enabled, isTrue);
    expect(state.readFailed, isTrue);
    final container = ProviderContainer(
      overrides: [
        dataSaverPreferenceStoreProvider.overrideWithValue(store),
        initialDataSaverPreferenceStateProvider.overrideWithValue(state),
      ],
    );
    final controller = container.read(
      dataSaverPreferenceControllerProvider.notifier,
    );
    await controller.select(false);
    expect(
      container.read(dataSaverPreferenceControllerProvider).enabled,
      isFalse,
    );
    expect(
      container.read(dataSaverPreferenceControllerProvider).failureMessage,
      contains('保存失败'),
    );
    await controller.select(true);
    expect(
      container.read(dataSaverPreferenceControllerProvider).enabled,
      isTrue,
    );
    container.dispose();
  });
}

class _FailingStore implements DataSaverPreferenceStore {
  @override
  Future<bool> read() async => throw StateError('read');
  @override
  Future<void> write(bool enabled) async => throw StateError('write');
}

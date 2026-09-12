import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class DataSaverPreferenceStore {
  Future<bool> read();
  Future<void> write(bool enabled);
}

class DataSaverPreferenceState {
  const DataSaverPreferenceState({
    this.enabled = false,
    this.isSaving = false,
    this.failureMessage,
    this.readFailed = false,
  });

  final bool enabled;
  final bool isSaving;
  final String? failureMessage;
  final bool readFailed;
}

Future<DataSaverPreferenceState> loadInitialDataSaverPreference(
  DataSaverPreferenceStore store,
) async {
  try {
    return DataSaverPreferenceState(enabled: await store.read());
  } on Object {
    // 无法确认用户的既有偏好时，先不自动下载动画。
    return const DataSaverPreferenceState(
      enabled: true,
      readFailed: true,
      failureMessage: '省流量设置读取失败，已暂停封面自动播放。',
    );
  }
}

class DataSaverPreferenceController extends Notifier<DataSaverPreferenceState> {
  bool _disposed = false;
  late DataSaverPreferenceStore _store;

  @override
  DataSaverPreferenceState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _store = ref.read(dataSaverPreferenceStoreProvider);
    return ref.read(initialDataSaverPreferenceStateProvider);
  }

  Future<void> select(bool enabled) async {
    if (state.isSaving) return;
    state = DataSaverPreferenceState(enabled: enabled, isSaving: true);
    try {
      await _store.write(enabled);
      if (!_disposed) state = DataSaverPreferenceState(enabled: enabled);
    } on Object {
      if (!_disposed) {
        state = DataSaverPreferenceState(
          enabled: enabled,
          failureMessage: '保存失败，本次使用仍按当前选择生效。',
        );
      }
    }
  }

  Future<void> retryRead() async {
    if (state.isSaving) return;
    state = DataSaverPreferenceState(enabled: state.enabled, isSaving: true);
    final result = await loadInitialDataSaverPreference(_store);
    if (!_disposed) state = result;
  }
}

class _MemoryDataSaverStore implements DataSaverPreferenceStore {
  bool _enabled = false;
  @override
  Future<bool> read() async => _enabled;
  @override
  Future<void> write(bool enabled) async => _enabled = enabled;
}

final dataSaverPreferenceStoreProvider = Provider<DataSaverPreferenceStore>(
  (ref) => _MemoryDataSaverStore(),
);
final initialDataSaverPreferenceStateProvider =
    Provider<DataSaverPreferenceState>(
      (ref) => const DataSaverPreferenceState(),
    );
final dataSaverPreferenceControllerProvider =
    NotifierProvider<DataSaverPreferenceController, DataSaverPreferenceState>(
      DataSaverPreferenceController.new,
    );

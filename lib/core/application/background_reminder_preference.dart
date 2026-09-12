import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class BackgroundReminderPreferenceStore {
  Future<bool> read();
  Future<void> write(bool enabled);
}

class BackgroundReminderPreferenceState {
  const BackgroundReminderPreferenceState({
    this.enabled = true,
    this.isSaving = false,
    this.readFailed = false,
    this.failureMessage,
  });

  final bool enabled;
  final bool isSaving;
  final bool readFailed;
  final String? failureMessage;
}

Future<BackgroundReminderPreferenceState>
loadInitialBackgroundReminderPreference(
  BackgroundReminderPreferenceStore store,
) async {
  try {
    return BackgroundReminderPreferenceState(enabled: await store.read());
  } on Object {
    // 无法读取时不覆盖用户可能已关闭的选择。
    return const BackgroundReminderPreferenceState(
      enabled: false,
      readFailed: true,
      failureMessage: '后台消息提醒设置读取失败，请重试。',
    );
  }
}

class BackgroundReminderPreferenceController
    extends Notifier<BackgroundReminderPreferenceState> {
  bool _disposed = false;

  @override
  BackgroundReminderPreferenceState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return ref.read(initialBackgroundReminderPreferenceProvider);
  }

  Future<void> select(bool enabled) async {
    if (state.isSaving) return;
    final previous = state;
    // 关闭立即停止本次运行；开启则必须先保存成功才允许启动。
    state = BackgroundReminderPreferenceState(
      enabled: enabled && previous.enabled,
      isSaving: true,
    );
    try {
      await ref.read(backgroundReminderPreferenceStoreProvider).write(enabled);
      if (!_disposed) {
        state = BackgroundReminderPreferenceState(enabled: enabled);
      }
    } on Object {
      if (!_disposed) {
        state = BackgroundReminderPreferenceState(
          enabled: previous.enabled,
          readFailed: previous.readFailed,
          failureMessage: '保存失败，后台消息提醒设置未更改，请重试。',
        );
      }
    }
  }

  Future<void> retryRead() async {
    if (state.isSaving) return;
    state = BackgroundReminderPreferenceState(
      enabled: state.enabled,
      isSaving: true,
    );
    final result = await loadInitialBackgroundReminderPreference(
      ref.read(backgroundReminderPreferenceStoreProvider),
    );
    if (!_disposed) state = result;
  }
}

class _MemoryBackgroundReminderStore
    implements BackgroundReminderPreferenceStore {
  bool _enabled = true;
  @override
  Future<bool> read() async => _enabled;
  @override
  Future<void> write(bool enabled) async => _enabled = enabled;
}

final backgroundReminderPreferenceStoreProvider =
    Provider<BackgroundReminderPreferenceStore>(
      (ref) => _MemoryBackgroundReminderStore(),
    );
final initialBackgroundReminderPreferenceProvider =
    Provider<BackgroundReminderPreferenceState>(
      (ref) => const BackgroundReminderPreferenceState(),
    );
final backgroundReminderPreferenceProvider =
    NotifierProvider<
      BackgroundReminderPreferenceController,
      BackgroundReminderPreferenceState
    >(BackgroundReminderPreferenceController.new);

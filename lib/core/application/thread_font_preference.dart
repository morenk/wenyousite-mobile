import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// 设备阅读偏好只覆盖主题帖正文，不改变全局文字角色或系统缩放。
enum ThreadFontPreference {
  small('小', -1),
  standard('标准', 0),
  large('大', 1),
  extraLarge('特大', 2),
  largest('超大', 3);

  const ThreadFontPreference(this.label, this.step);

  final String label;
  final int step;

  // 默认沿用 Foundation body（16sp），比原 reading（17sp）小一号。
  double get fontSize =>
      WenyouFoundationTypography.mobileSizes['body']! + step * 2;

  String get displayLabel => this == standard ? '标准（默认）' : label;

  static ThreadFontPreference fromStorage(Object? value) => values.firstWhere(
    (preference) => preference.name == value,
    orElse: () => standard,
  );
}

abstract interface class ThreadFontPreferenceStore {
  Future<ThreadFontPreference> read();
  Future<void> write(ThreadFontPreference preference);
}

final threadFontPreferenceStoreProvider = Provider<ThreadFontPreferenceStore>(
  (ref) => _MemoryThreadFontStore(),
);

class _MemoryThreadFontStore implements ThreadFontPreferenceStore {
  var _value = ThreadFontPreference.standard;

  @override
  Future<ThreadFontPreference> read() async => _value;

  @override
  Future<void> write(ThreadFontPreference preference) async =>
      _value = preference;
}

class ThreadFontPreferenceState {
  const ThreadFontPreferenceState({
    this.preference = ThreadFontPreference.standard,
    this.isSaving = false,
    this.readFailed = false,
    this.failedPreference,
    this.failureMessage,
  });

  final ThreadFontPreference preference;
  final bool isSaving;
  final bool readFailed;
  final ThreadFontPreference? failedPreference;
  final String? failureMessage;
}

Future<ThreadFontPreferenceState> loadInitialThreadFontPreference(
  ThreadFontPreferenceStore store,
) async {
  try {
    return ThreadFontPreferenceState(preference: await store.read());
  } on Object {
    return const ThreadFontPreferenceState(
      readFailed: true,
      failureMessage: '字号设置加载失败，当前使用默认字号。',
    );
  }
}

final initialThreadFontPreferenceProvider = Provider<ThreadFontPreferenceState>(
  (ref) => const ThreadFontPreferenceState(),
);

class ThreadFontPreferenceController
    extends Notifier<ThreadFontPreferenceState> {
  bool _disposed = false;
  late ThreadFontPreferenceStore _store;

  @override
  ThreadFontPreferenceState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _store = ref.read(threadFontPreferenceStoreProvider);
    return ref.read(initialThreadFontPreferenceProvider);
  }

  Future<void> select(ThreadFontPreference preference) async {
    if (state.isSaving) return;
    if (state.preference == preference && !state.readFailed) return;
    await _persist(preference);
  }

  Future<void> retry() async {
    if (state.isSaving) return;
    if (state.readFailed) {
      state = ThreadFontPreferenceState(
        preference: state.preference,
        isSaving: true,
      );
      final loaded = await loadInitialThreadFontPreference(_store);
      if (!_disposed) state = loaded;
    } else if (state.failedPreference case final preference?) {
      await _persist(preference);
    }
  }

  Future<void> _persist(ThreadFontPreference preference) async {
    final previous = state.preference;
    state = ThreadFontPreferenceState(preference: preference, isSaving: true);
    try {
      await _store.write(preference);
      if (!_disposed) state = ThreadFontPreferenceState(preference: preference);
    } on Object {
      if (_disposed) return;
      state = ThreadFontPreferenceState(
        preference: previous,
        failedPreference: preference,
        failureMessage: '字号设置保存失败，请重试。',
      );
    }
  }
}

final threadFontPreferenceControllerProvider =
    NotifierProvider<ThreadFontPreferenceController, ThreadFontPreferenceState>(
      ThreadFontPreferenceController.new,
    );

final threadBodyFontSizeProvider = Provider<double>(
  (ref) => ref.watch(
    threadFontPreferenceControllerProvider.select(
      (state) => state.preference.fontSize,
    ),
  ),
);

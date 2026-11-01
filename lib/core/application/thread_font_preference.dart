import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

/// 设备字号偏好覆盖主题帖阅读与编辑正文，不改变全局文字角色或系统缩放。
enum ThreadFontPreference {
  size13(-3),
  size14(-2),
  standard(-1),
  size16(0),
  size17(1),
  size18(2),
  size19(3);

  const ThreadFontPreference(this.step);

  final int step;

  // 档位继续基于 Foundation body（16sp），产品默认选择 15sp。
  double get fontSize => WenyouFoundationTypography.mobileSizes['body']! + step;

  String get label => fontSize.toStringAsFixed(0);

  String get semanticLabel => this == standard ? '$label，默认字号' : label;

  static ThreadFontPreference fromStorage(Object? value) {
    // 旧档位保留实际字号，已移除的 20／22 收敛到新的上限。
    return switch (value) {
      'size15' => standard,
      'small' => size14,
      'large' => size18,
      'extraLarge' || 'largest' => size19,
      _ => values.firstWhere(
        (preference) => preference.name == value,
        orElse: () => standard,
      ),
    };
  }
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

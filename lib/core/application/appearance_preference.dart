import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_foundation/wenyousite_foundation.dart';

enum AppearancePreference {
  system,
  light,
  dark;

  static AppearancePreference fromStorage(String? value) {
    return AppearancePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppearancePreference.system,
    );
  }

  String get label => WenyouFoundationTheme.labels[name]!;

  String get icon => WenyouFoundationTheme.icons[name]!;

  ThemeMode get themeMode => switch (this) {
    AppearancePreference.system => ThemeMode.system,
    AppearancePreference.light => ThemeMode.light,
    AppearancePreference.dark => ThemeMode.dark,
  };
}

abstract interface class AppearancePreferenceStore {
  Future<AppearancePreference> read();

  Future<void> write(AppearancePreference preference);
}

final appearancePreferenceStoreProvider = Provider<AppearancePreferenceStore>(
  (ref) => _VolatileAppearancePreferenceStore(),
);

class _VolatileAppearancePreferenceStore implements AppearancePreferenceStore {
  var _preference = AppearancePreference.system;

  @override
  Future<AppearancePreference> read() async => _preference;

  @override
  Future<void> write(AppearancePreference preference) async {
    _preference = preference;
  }
}

class AppearancePreferenceState {
  const AppearancePreferenceState({
    required this.preference,
    this.isSaving = false,
    this.failedPreference,
    this.failureMessage,
    this.readFailed = false,
  });

  final AppearancePreference preference;
  final bool isSaving;
  final AppearancePreference? failedPreference;
  final String? failureMessage;
  final bool readFailed;

  AppearancePreferenceState copyWith({
    AppearancePreference? preference,
    bool? isSaving,
    AppearancePreference? failedPreference,
    bool clearFailedPreference = false,
    String? failureMessage,
    bool clearFailureMessage = false,
    bool? readFailed,
  }) {
    return AppearancePreferenceState(
      preference: preference ?? this.preference,
      isSaving: isSaving ?? this.isSaving,
      failedPreference: clearFailedPreference
          ? null
          : failedPreference ?? this.failedPreference,
      failureMessage: clearFailureMessage
          ? null
          : failureMessage ?? this.failureMessage,
      readFailed: readFailed ?? this.readFailed,
    );
  }
}

Future<AppearancePreferenceState> loadInitialAppearancePreference(
  AppearancePreferenceStore store,
) async {
  try {
    return AppearancePreferenceState(preference: await store.read());
  } on Object {
    return const AppearancePreferenceState(
      preference: AppearancePreference.system,
      failureMessage: '未能读取保存的外观设置，当前已跟随系统。',
      readFailed: true,
    );
  }
}

final initialAppearancePreferenceStateProvider =
    Provider<AppearancePreferenceState>(
      (ref) => const AppearancePreferenceState(
        preference: AppearancePreference.system,
      ),
    );

class AppearancePreferenceController
    extends StateNotifier<AppearancePreferenceState> {
  AppearancePreferenceController(this._store, AppearancePreferenceState initial)
    : super(initial);

  final AppearancePreferenceStore _store;

  Future<void> select(AppearancePreference preference) async {
    if (state.isSaving || preference == state.preference) return;
    await _persist(preference);
  }

  Future<void> retry() async {
    if (state.isSaving) return;
    if (state.readFailed) {
      await _reload();
      return;
    }
    await _persist(state.failedPreference ?? state.preference);
  }

  Future<void> _reload() async {
    state = state.copyWith(
      isSaving: true,
      clearFailedPreference: true,
      clearFailureMessage: true,
      readFailed: false,
    );
    try {
      state = AppearancePreferenceState(preference: await _store.read());
    } on Object {
      state = const AppearancePreferenceState(
        preference: AppearancePreference.system,
        failureMessage: '未能读取保存的外观设置，当前已跟随系统。',
        readFailed: true,
      );
    }
  }

  Future<void> _persist(AppearancePreference preference) async {
    final previousPreference = state.preference;
    state = state.copyWith(
      preference: preference,
      isSaving: true,
      clearFailedPreference: true,
      clearFailureMessage: true,
      readFailed: false,
    );
    try {
      await _store.write(preference);
      state = AppearancePreferenceState(preference: preference);
    } on Object {
      state = AppearancePreferenceState(
        preference: previousPreference,
        failedPreference: preference,
        failureMessage: '外观设置保存失败，请重试。',
      );
    }
  }
}

final appearancePreferenceControllerProvider =
    StateNotifierProvider<
      AppearancePreferenceController,
      AppearancePreferenceState
    >((ref) {
      return AppearancePreferenceController(
        ref.watch(appearancePreferenceStoreProvider),
        ref.watch(initialAppearancePreferenceStateProvider),
      );
    });

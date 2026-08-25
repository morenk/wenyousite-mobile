import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/appearance_preference.dart';

void main() {
  test('偏好值映射 Foundation 文案、图标和 Flutter ThemeMode', () {
    expect(AppearancePreference.fromStorage(null), AppearancePreference.system);
    expect(
      AppearancePreference.fromStorage('unknown'),
      AppearancePreference.system,
    );
    expect(AppearancePreference.system.label, '跟随系统');
    expect(AppearancePreference.light.label, '亮色');
    expect(AppearancePreference.dark.label, '黑夜');
    expect(AppearancePreference.system.icon, 'appearance.system');
    expect(AppearancePreference.light.themeMode, ThemeMode.light);
    expect(AppearancePreference.dark.themeMode, ThemeMode.dark);
  });

  test('启动读取成功直接恢复保存偏好', () async {
    final store = _FakeAppearanceStore(AppearancePreference.dark);

    final state = await loadInitialAppearancePreference(store);

    expect(state.preference, AppearancePreference.dark);
    expect(state.failureMessage, isNull);
    expect(store.readCalls, 1);
  });

  test('启动读取失败回退跟随系统并保留可重试状态', () async {
    final store = _FakeAppearanceStore(
      AppearancePreference.dark,
      failRead: true,
    );

    final state = await loadInitialAppearancePreference(store);

    expect(state.preference, AppearancePreference.system);
    expect(state.readFailed, isTrue);
    expect(state.failureMessage, contains('跟随系统'));
  });

  test('选择时立即切换主题，写入完成后结束保存状态', () async {
    final store = _FakeAppearanceStore(AppearancePreference.system)
      ..writeCompleter = Completer<void>();
    final controller = AppearancePreferenceController(
      store,
      const AppearancePreferenceState(preference: AppearancePreference.system),
    );

    final selecting = controller.select(AppearancePreference.dark);

    expect(controller.state.preference, AppearancePreference.dark);
    expect(controller.state.isSaving, isTrue);
    expect(store.writes, [AppearancePreference.dark]);
    store.writeCompleter!.complete();
    await selecting;
    expect(controller.state.preference, AppearancePreference.dark);
    expect(controller.state.isSaving, isFalse);
  });

  test('写入失败回滚原偏好，重试复用目标偏好', () async {
    final store = _FakeAppearanceStore(
      AppearancePreference.light,
      failWrite: true,
    );
    final controller = AppearancePreferenceController(
      store,
      const AppearancePreferenceState(preference: AppearancePreference.light),
    );

    await controller.select(AppearancePreference.dark);

    expect(controller.state.preference, AppearancePreference.light);
    expect(controller.state.failedPreference, AppearancePreference.dark);
    expect(controller.state.failureMessage, contains('保存失败'));
    store.failWrite = false;
    await controller.retry();
    expect(controller.state.preference, AppearancePreference.dark);
    expect(controller.state.failureMessage, isNull);
    expect(store.writes, [
      AppearancePreference.dark,
      AppearancePreference.dark,
    ]);
  });

  test('启动读取失败后的重试重新读取，不覆盖已有保存值', () async {
    final store = _FakeAppearanceStore(
      AppearancePreference.dark,
      failRead: true,
    );
    final initial = await loadInitialAppearancePreference(store);
    final controller = AppearancePreferenceController(store, initial);
    store.failRead = false;

    await controller.retry();

    expect(controller.state.preference, AppearancePreference.dark);
    expect(controller.state.failureMessage, isNull);
    expect(store.writes, isEmpty);
    expect(store.readCalls, 2);
  });
}

class _FakeAppearanceStore implements AppearancePreferenceStore {
  _FakeAppearanceStore(
    this.value, {
    this.failRead = false,
    this.failWrite = false,
  });

  AppearancePreference value;
  bool failRead;
  bool failWrite;
  int readCalls = 0;
  final List<AppearancePreference> writes = [];
  Completer<void>? writeCompleter;

  @override
  Future<AppearancePreference> read() async {
    readCalls++;
    if (failRead) throw StateError('read failed');
    return value;
  }

  @override
  Future<void> write(AppearancePreference preference) async {
    writes.add(preference);
    if (failWrite) throw StateError('write failed');
    await writeCompleter?.future;
    value = preference;
  }
}

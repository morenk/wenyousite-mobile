import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wenyousite_mobile/core/application/background_reminder_preference.dart';
import 'package:wenyousite_mobile/core/storage/shared_preferences_background_reminder_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('默认开启，关闭选择跨容器及存储实例保留且不依赖账号', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesBackgroundReminderStore();
    expect(
      (await loadInitialBackgroundReminderPreference(store)).enabled,
      isTrue,
    );
    final first = ProviderContainer(
      overrides: [
        backgroundReminderPreferenceStoreProvider.overrideWithValue(store),
      ],
    );
    await first
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(false);
    first.dispose();
    final saved = await loadInitialBackgroundReminderPreference(
      const SharedPreferencesBackgroundReminderStore(),
    );
    final second = ProviderContainer(
      overrides: [
        initialBackgroundReminderPreferenceProvider.overrideWithValue(saved),
      ],
    );
    addTearDown(second.dispose);
    expect(second.read(backgroundReminderPreferenceProvider).enabled, isFalse);
  });

  test('读取失败不擅自开启；重试读取恢复既有选择', () async {
    final store = _Store()..readFailure = true;
    final initial = await loadInitialBackgroundReminderPreference(store);
    expect(initial.enabled, isFalse);
    expect(initial.readFailed, isTrue);
    final container = ProviderContainer(
      overrides: [
        backgroundReminderPreferenceStoreProvider.overrideWithValue(store),
        initialBackgroundReminderPreferenceProvider.overrideWithValue(initial),
      ],
    );
    addTearDown(container.dispose);
    store.readFailure = false;
    await container
        .read(backgroundReminderPreferenceProvider.notifier)
        .retryRead();
    expect(
      container.read(backgroundReminderPreferenceProvider).enabled,
      isTrue,
    );
    expect(
      container.read(backgroundReminderPreferenceProvider).readFailed,
      isFalse,
    );
  });

  for (final previous in [true, false]) {
    test('保存等待时立即停止、禁止重复写入；失败恢复 $previous', () async {
      final store = _Store()..pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          backgroundReminderPreferenceStoreProvider.overrideWithValue(store),
          initialBackgroundReminderPreferenceProvider.overrideWithValue(
            BackgroundReminderPreferenceState(enabled: previous),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        backgroundReminderPreferenceProvider.notifier,
      );
      final operation = controller.select(!previous);
      expect(
        container.read(backgroundReminderPreferenceProvider).enabled,
        isFalse,
      );
      expect(
        container.read(backgroundReminderPreferenceProvider).isSaving,
        isTrue,
      );
      await controller.select(previous);
      expect(store.writes, 1);
      store.pending!.completeError(StateError('disk'));
      await operation;
      final result = container.read(backgroundReminderPreferenceProvider);
      expect(result.enabled, previous);
      expect(result.isSaving, isFalse);
      expect(result.failureMessage, contains('保存失败'));
    });
  }

  test('开启必须等待保存成功，销毁后迟到结果不写状态', () async {
    final store = _Store()..pending = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        backgroundReminderPreferenceStoreProvider.overrideWithValue(store),
        initialBackgroundReminderPreferenceProvider.overrideWithValue(
          const BackgroundReminderPreferenceState(enabled: false),
        ),
      ],
    );
    final operation = container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(true);
    expect(
      container.read(backgroundReminderPreferenceProvider).enabled,
      isFalse,
    );
    store.pending!.complete();
    await operation;
    expect(
      container.read(backgroundReminderPreferenceProvider).enabled,
      isTrue,
    );
    store.pending = Completer<void>();
    final lateOperation = container
        .read(backgroundReminderPreferenceProvider.notifier)
        .select(false);
    container.dispose();
    store.pending!.complete();
    await lateOperation;
  });
}

class _Store implements BackgroundReminderPreferenceStore {
  bool readFailure = false;
  int writes = 0;
  Completer<void>? pending;
  @override
  Future<bool> read() async {
    if (readFailure) throw StateError('disk');
    return true;
  }

  @override
  Future<void> write(bool enabled) async {
    writes++;
    await pending?.future;
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';

import '../../support/thread_font_store.dart';

void main() {
  test('七档按 1sp 等距递增，默认 15 且只用数字标记', () {
    expect(ThreadFontPreference.standard.fontSize, 15);
    expect(ThreadFontPreference.values.map((value) => value.fontSize), [
      13,
      14,
      15,
      16,
      17,
      18,
      19,
    ]);
    expect(ThreadFontPreference.standard.index, 2);
    expect(ThreadFontPreference.values.map((value) => value.label), [
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
    ]);
  });

  test('冷启动恢复保存字号，读取失败采用默认并可重读且不写入', () async {
    final store = TestThreadFontStore()
      ..saved = ThreadFontPreference.size19
      ..failRead = true;
    final initial = await loadInitialThreadFontPreference(store);
    final container = _container(store, initial);
    final controller = container.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    expect(container.read(threadBodyFontSizeProvider), 15);
    expect(initial.readFailed, isTrue);
    store.failRead = false;
    await controller.retry();
    expect(container.read(threadBodyFontSizeProvider), 19);
    expect(store.writes, isEmpty);
    expect(
      (await loadInitialThreadFontPreference(store)).preference,
      ThreadFontPreference.size19,
    );
  });

  test('保存即生效、失败回滚且重试原目标；恢复默认可保存', () async {
    final store = TestThreadFontStore()..failWrite = true;
    final container = _container(store);
    final controller = container.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    final save = controller.select(ThreadFontPreference.size18);
    expect(container.read(threadBodyFontSizeProvider), 18);
    await save;
    expect(container.read(threadBodyFontSizeProvider), 15);
    expect(
      container.read(threadFontPreferenceControllerProvider).failedPreference,
      ThreadFontPreference.size18,
    );
    store.failWrite = false;
    await controller.retry();
    expect(container.read(threadBodyFontSizeProvider), 18);
    await controller.select(ThreadFontPreference.standard);
    expect(store.saved, ThreadFontPreference.standard);
  });

  test('重复选择和保存中不重复写入，销毁后完成不更新状态', () async {
    final store = TestThreadFontStore()..pending = Completer<void>();
    final container = ProviderContainer(
      overrides: [threadFontPreferenceStoreProvider.overrideWithValue(store)],
    );
    final controller = container.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    await controller.select(ThreadFontPreference.standard);
    expect(store.writes, isEmpty);
    final save = controller.select(ThreadFontPreference.size18);
    await controller.select(ThreadFontPreference.size14);
    expect(store.writes, [ThreadFontPreference.size18]);
    container.dispose();
    store.pending!.complete();
    await expectLater(save, completes);
  });

  test('读失败后主动恢复默认允许覆盖未知的旧值', () async {
    final store = TestThreadFontStore()..saved = ThreadFontPreference.size19;
    final container = _container(
      store,
      const ThreadFontPreferenceState(readFailed: true),
    );
    await container
        .read(threadFontPreferenceControllerProvider.notifier)
        .select(ThreadFontPreference.standard);
    expect(store.writes, [ThreadFontPreference.standard]);
    expect(
      container.read(threadFontPreferenceControllerProvider).readFailed,
      isFalse,
    );
  });
}

ProviderContainer _container(
  TestThreadFontStore store, [
  ThreadFontPreferenceState initial = const ThreadFontPreferenceState(),
]) {
  final container = ProviderContainer(
    overrides: [
      threadFontPreferenceStoreProvider.overrideWithValue(store),
      initialThreadFontPreferenceProvider.overrideWithValue(initial),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/thread_font_preference.dart';

import '../../support/thread_font_store.dart';

void main() {
  test('默认比原 17sp 小一号，五档连续递增', () {
    expect(ThreadFontPreference.standard.fontSize, 16);
    expect(ThreadFontPreference.values.map((value) => value.fontSize), [
      14,
      16,
      18,
      20,
      22,
    ]);
  });

  test('冷启动恢复保存字号，读取失败采用默认并可重读且不写入', () async {
    final store = TestThreadFontStore()
      ..saved = ThreadFontPreference.largest
      ..failRead = true;
    final initial = await loadInitialThreadFontPreference(store);
    final container = _container(store, initial);
    final controller = container.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    expect(container.read(threadBodyFontSizeProvider), 16);
    expect(initial.readFailed, isTrue);
    store.failRead = false;
    await controller.retry();
    expect(container.read(threadBodyFontSizeProvider), 22);
    expect(store.writes, isEmpty);
    expect(
      (await loadInitialThreadFontPreference(store)).preference,
      ThreadFontPreference.largest,
    );
  });

  test('保存即生效、失败回滚且重试原目标；恢复默认可保存', () async {
    final store = TestThreadFontStore()..failWrite = true;
    final container = _container(store);
    final controller = container.read(
      threadFontPreferenceControllerProvider.notifier,
    );
    final save = controller.select(ThreadFontPreference.large);
    expect(container.read(threadBodyFontSizeProvider), 18);
    await save;
    expect(container.read(threadBodyFontSizeProvider), 16);
    expect(
      container.read(threadFontPreferenceControllerProvider).failedPreference,
      ThreadFontPreference.large,
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
    final save = controller.select(ThreadFontPreference.large);
    await controller.select(ThreadFontPreference.small);
    expect(store.writes, [ThreadFontPreference.large]);
    container.dispose();
    store.pending!.complete();
    await expectLater(save, completes);
  });

  test('读失败后主动恢复默认允许覆盖未知的旧值', () async {
    final store = TestThreadFontStore()..saved = ThreadFontPreference.largest;
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

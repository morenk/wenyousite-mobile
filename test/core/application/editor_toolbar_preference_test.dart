import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';

import '../../support/editor_toolbar_store.dart';

void main() {
  final custom = const EditorToolbarLayout.defaults().move(
    EditorTool.sticker,
    EditorToolbarGroup.primary,
    0,
  );
  ProviderContainer containerFor(
    TestEditorToolbarStore store, {
    EditorToolbarPreferenceState initial = const EditorToolbarPreferenceState(),
  }) => ProviderContainer(
    overrides: [
      editorToolbarPreferenceStoreProvider.overrideWithValue(store),
      initialEditorToolbarPreferenceProvider.overrideWithValue(initial),
    ],
  );

  test('选择即时应用并持久化，重复选择不写，重建恢复布局', () async {
    final store = TestEditorToolbarStore();
    final container = containerFor(store);
    addTearDown(container.dispose);
    final controller = container.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    await controller.select(custom);
    await controller.select(custom);
    expect(store.writes, 1);
    final reopened = containerFor(
      store,
      initial: await loadInitialEditorToolbarPreference(store),
    );
    addTearDown(reopened.dispose);
    expect(reopened.read(editorToolbarLayoutProvider), custom);
    await reopened
        .read(editorToolbarPreferenceControllerProvider.notifier)
        .select(const EditorToolbarLayout.defaults());
    expect(store.saved.isDefault, isTrue);
  });

  test('保存失败回滚并保留目标供重试，保存期间阻止并发覆盖', () async {
    final store = TestEditorToolbarStore()
      ..pendingWrite = Completer<void>()
      ..failWrite = true;
    final container = containerFor(store);
    addTearDown(container.dispose);
    final controller = container.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    final save = controller.select(custom);
    expect(container.read(editorToolbarLayoutProvider), custom);
    await controller.select(const EditorToolbarLayout.defaults());
    expect(store.writes, 1);
    store.pendingWrite!.complete();
    await save;
    expect(container.read(editorToolbarLayoutProvider).isDefault, isTrue);
    expect(
      container.read(editorToolbarPreferenceControllerProvider).failedLayout,
      custom,
    );
    store.failWrite = false;
    await controller.retry();
    expect(store.saved, custom);
    expect(
      container.read(editorToolbarPreferenceControllerProvider).failureMessage,
      isNull,
    );
  });

  test('加载失败可只读重试，失败后主动保存失败仍重试原目标', () async {
    final store = TestEditorToolbarStore()
      ..saved = custom
      ..failRead = true;
    final initial = await loadInitialEditorToolbarPreference(store);
    expect(initial.readFailed, isTrue);
    final container = containerFor(store, initial: initial);
    addTearDown(container.dispose);
    final controller = container.read(
      editorToolbarPreferenceControllerProvider.notifier,
    );
    store.failWrite = true;
    await controller.select(custom);
    store.failWrite = false;
    await controller.retry();
    expect(store.saved, custom);
    expect(
      container.read(editorToolbarPreferenceControllerProvider).readFailed,
      isFalse,
    );

    final reload = containerFor(store, initial: initial);
    addTearDown(reload.dispose);
    final writes = store.writes;
    store.failRead = false;
    await reload
        .read(editorToolbarPreferenceControllerProvider.notifier)
        .retry();
    expect(reload.read(editorToolbarLayoutProvider), custom);
    expect(store.writes, writes);
  });

  test('写入完成时容器已释放不更新销毁状态', () async {
    final store = TestEditorToolbarStore()..pendingWrite = Completer<void>();
    final container = containerFor(store);
    final save = container
        .read(editorToolbarPreferenceControllerProvider.notifier)
        .select(custom);
    container.dispose();
    store.pendingWrite!.complete();
    await expectLater(save, completes);
  });
}

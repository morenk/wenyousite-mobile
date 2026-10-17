import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';

abstract interface class EditorToolbarPreferenceStore {
  Future<EditorToolbarLayout> read();
  Future<void> write(EditorToolbarLayout layout);
}

final editorToolbarPreferenceStoreProvider =
    Provider<EditorToolbarPreferenceStore>((ref) => _MemoryToolbarStore());

class _MemoryToolbarStore implements EditorToolbarPreferenceStore {
  EditorToolbarLayout _layout = const EditorToolbarLayout.defaults();
  @override
  Future<EditorToolbarLayout> read() async => _layout;
  @override
  Future<void> write(EditorToolbarLayout layout) async => _layout = layout;
}

class EditorToolbarPreferenceState {
  const EditorToolbarPreferenceState({
    this.layout = const EditorToolbarLayout.defaults(),
    this.isSaving = false,
    this.readFailed = false,
    this.failedLayout,
    this.failureMessage,
  });

  final EditorToolbarLayout layout;
  final bool isSaving;
  final bool readFailed;
  final EditorToolbarLayout? failedLayout;
  final String? failureMessage;
}

Future<EditorToolbarPreferenceState> loadInitialEditorToolbarPreference(
  EditorToolbarPreferenceStore store,
) async {
  try {
    return EditorToolbarPreferenceState(layout: await store.read());
  } on Object {
    return const EditorToolbarPreferenceState(
      readFailed: true,
      failureMessage: '工具栏设置加载失败，当前使用默认布局。',
    );
  }
}

final initialEditorToolbarPreferenceProvider =
    Provider<EditorToolbarPreferenceState>(
      (ref) => const EditorToolbarPreferenceState(),
    );

class EditorToolbarPreferenceController
    extends Notifier<EditorToolbarPreferenceState> {
  bool _disposed = false;
  late EditorToolbarPreferenceStore _store;

  @override
  EditorToolbarPreferenceState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _store = ref.read(editorToolbarPreferenceStoreProvider);
    return ref.read(initialEditorToolbarPreferenceProvider);
  }

  Future<void> select(EditorToolbarLayout layout) async {
    if (state.isSaving || (state.layout == layout && !state.readFailed)) return;
    await _persist(layout);
  }

  Future<void> retry() async {
    if (state.isSaving) return;
    if (state.failedLayout case final layout?) {
      await _persist(layout);
    } else if (state.readFailed) {
      state = EditorToolbarPreferenceState(
        layout: state.layout,
        isSaving: true,
      );
      final loaded = await loadInitialEditorToolbarPreference(_store);
      if (!_disposed) state = loaded;
    }
  }

  Future<void> _persist(EditorToolbarLayout layout) async {
    final previous = state.layout;
    final previousReadFailed = state.readFailed;
    state = EditorToolbarPreferenceState(layout: layout, isSaving: true);
    try {
      await _store.write(layout);
      if (!_disposed) state = EditorToolbarPreferenceState(layout: layout);
    } on Object {
      if (_disposed) return;
      state = EditorToolbarPreferenceState(
        layout: previous,
        readFailed: previousReadFailed,
        failedLayout: layout,
        failureMessage: '工具栏设置保存失败，请重试。',
      );
    }
  }
}

final editorToolbarPreferenceControllerProvider =
    NotifierProvider<
      EditorToolbarPreferenceController,
      EditorToolbarPreferenceState
    >(EditorToolbarPreferenceController.new);

final editorToolbarLayoutProvider = Provider<EditorToolbarLayout>(
  (ref) => ref.watch(
    editorToolbarPreferenceControllerProvider.select((state) => state.layout),
  ),
);

import 'dart:async';

import 'package:wenyousite_mobile/core/application/editor_toolbar_layout.dart';
import 'package:wenyousite_mobile/core/application/editor_toolbar_preference.dart';

EditorToolbarLayout customEditorToolbarTestLayout() =>
    EditorToolbarLayout.custom(
      primary: [
        EditorTool.sticker,
        EditorTool.image,
        EditorTool.dice,
        EditorTool.bold,
        EditorTool.heading,
        EditorTool.drafts,
      ],
      expanded: [
        EditorTool.quote,
        EditorTool.strike,
        EditorTool.alignCenter,
        EditorTool.alignRight,
        EditorTool.link,
        EditorTool.italic,
        EditorTool.inlineCode,
        EditorTool.horizontalRule,
      ],
    );

class TestEditorToolbarStore implements EditorToolbarPreferenceStore {
  EditorToolbarLayout saved = const EditorToolbarLayout.defaults();
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;
  Completer<void>? pendingWrite;

  @override
  Future<EditorToolbarLayout> read() async {
    if (failRead) throw StateError('读取失败');
    return saved;
  }

  @override
  Future<void> write(EditorToolbarLayout layout) async {
    writes++;
    if (pendingWrite case final pending?) await pending.future;
    if (failWrite) throw StateError('保存失败');
    saved = layout;
  }
}

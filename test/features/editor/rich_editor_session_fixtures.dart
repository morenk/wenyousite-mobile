import 'dart:async';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';

List<String> richEditorSessionTestDiceNodeIds(String markdown) => RegExp(
  r'\[\[dice:v1:([0-9a-f-]{36}):',
).allMatches(markdown).map((match) => match.group(1)!).toList();

class RichEditorSessionTestMemoryEditorClipboardGateway
    implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);
  Completer<EditorClipboardSnapshot>? richEditorSessionTestPendingRead;

  void delayReads() {
    richEditorSessionTestPendingRead = Completer<EditorClipboardSnapshot>();
  }

  void completeRead(EditorClipboardSnapshot value) {
    richEditorSessionTestPendingRead!.complete(value);
  }

  @override
  Future<EditorClipboardSnapshot> read() async =>
      richEditorSessionTestPendingRead?.future ?? snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}

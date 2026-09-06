import 'package:flutter_quill/flutter_quill.dart';

/// Exercises Quill's real paste entry point, including its fallback contract.
Future<bool> pasteEditorClipboard(QuillController controller) {
  // Retains the existing test exception at this single Quill integration edge.
  // ignore: experimental_member_use
  return controller.clipboardPaste();
}

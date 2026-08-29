import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_reader_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  testWidgets('输入法剪贴板历史直接提交文字时不冒充结构化粘贴', (tester) async {
    const scope = SessionScope(accountId: 'ime-account', generation: 1);
    final store = WenyouEditorClipboardStore();
    final gateway = _MemoryEditorClipboardGateway();
    await copyReaderMarkdownToClipboard(
      markdown: '## 标题\n\n* **项目**',
      scope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    final fallback = gateway.snapshot.text!;
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
      clipboardScope: scope,
      clipboardGateway: gateway,
      clipboardStore: store,
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: const QuillEditorConfig(scrollable: false),
          ),
        ),
      ),
    );
    session.focusNode.requestFocus();
    await tester.pump();

    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: '$fallback\n',
        selection: TextSelection.collapsed(offset: fallback.length),
      ),
    );
    await tester.idle();
    await tester.pump();

    final delta = session.controller.document.toDelta();
    expect(session.controller.document.toPlainText(), '$fallback\n');
    expect(
      delta.operations.any(
        (operation) =>
            operation.attributes?['header'] != null ||
            operation.attributes?['list'] != null ||
            operation.attributes?['bold'] != null,
      ),
      isFalse,
    );
    expect(await session.flush(), isTrue);
  });
}

class _MemoryEditorClipboardGateway implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);

  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}

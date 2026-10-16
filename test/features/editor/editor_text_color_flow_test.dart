import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/features/editor/application/editor_text_color_preferences_ports.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_heading_tray.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

class _MemoryColors implements EditorTextColorPreferenceStore {
  List<String> colors = [];
  @override
  Future<List<String>> read(String accountId) async => colors;
  @override
  Future<void> write(String accountId, List<String> values) async {
    colors = values;
  }
}

void main() {
  testWidgets('T 内取色应用、选区、草稿重开、单步撤销及最近色', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '前面 **选中文字** 后面',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final store = _MemoryColors();
    const selection = TextSelection(baseOffset: 3, extentOffset: 7);
    session.controller.updateSelection(selection, ChangeSource.local);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: QuillEditor.basic(
                  controller: session.controller,
                  focusNode: session.focusNode,
                ),
              ),
              WenyouEditorToolbar(
                controller: session.controller,
                onInsertImage: () async {},
                onSaveDraft: () async {},
                enabled: true,
                editorFocusNode: session.focusNode,
                textColor: EditorTextColorConfiguration(
                  presets: const [(label: '测试颜色', rgb: '#123456')],
                  maximumRecentColors: 4,
                  accountId: 'test-account',
                  store: store,
                  writeEnabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-heading')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor-color-custom')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('editor-color-r')), '17');
    await tester.enterText(find.byKey(const Key('editor-color-g')), '34');
    await tester.enterText(find.byKey(const Key('editor-color-b')), '51');
    expect(
      session.controller.document.toDelta().operations.every(
        (op) => op.attributes?['color'] == null,
      ),
      isTrue,
    );
    await tester.tap(find.byKey(const Key('editor-color-apply')));
    await tester.pumpAndSettle();
    expect(session.controller.selection, selection);
    expect(await session.flush(), isTrue);
    expect(
      session.localMarkdown,
      contains('<span data-wenyou-color-v1="#112233">**选中文字**</span>'),
    );
    expect(store.colors, ['#112233']);
    final reopened = RichEditorSession(
      initialMarkdown: session.localMarkdown,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(
      reopened.controller.document
          .collectStyle(3, 4)
          .attributes['color']
          ?.value,
      '#112233',
    );
    session.controller.undo();
    expect(
      session.controller.document.collectStyle(3, 4).attributes['color']?.value,
      isNull,
    );
    expect(
      session.controller.document.collectStyle(3, 4).attributes['bold']?.value,
      isTrue,
    );
    session.controller.redo();
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 7),
      ChangeSource.local,
    );
    session.focusNode.requestFocus();
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '前面 选中文字中 后面\n',
        selection: TextSelection.collapsed(offset: 8),
        composing: TextRange(start: 7, end: 8),
      ),
    );
    await tester.pump();
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '前面 选中文字中 后面\n',
        selection: TextSelection.collapsed(offset: 8),
      ),
    );
    await tester.pump();
    expect(
      session.controller.document.collectStyle(7, 1).attributes['color'],
      isNull,
    );
    expect(
      session.controller.document.collectStyle(3, 4).attributes['color']?.value,
      '#112233',
    );
    expect(await session.flush(), isTrue);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await session.flush();
    await reopened.flush();
    await tester.pump(const Duration(milliseconds: 200));
  });

  test('站内 v2 剪贴板保留颜色和组合格式，附加属性不授予颜色', () {
    const parser = WenyouSiteClipboardParser();
    final delta = parser.parse(
      '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor"><p><span data-wenyou-color-v1="#123456"><strong>文字</strong></span></p></div>',
    );
    expect(delta, isNotNull);
    expect(delta!.operations.first.attributes?['color'], '#123456');
    expect(delta.operations.first.attributes?['bold'], isTrue);
    final unsafe = parser.parse(
      '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor"><p><span data-wenyou-color-v1="#123456" style="color:red">文字</span></p></div>',
    );
    expect(unsafe!.operations.first.attributes?['color'], isNull);
  });
}

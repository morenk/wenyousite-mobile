import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/editor.dart';

void main() {
  testWidgets('关闭后的编辑态提及显示账号，序列化仍保留原标签', (tester) async {
    const source = '[@白鸦](/users/player) 与 [@夜渡](/users/player)';
    final controller = QuillController(
      document: Document.fromDelta(MarkdownDeltaCodec.decode(source).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    final focus = FocusNode();
    final scroll = ScrollController();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuillEditor(
            controller: controller,
            focusNode: focus,
            scrollController: scroll,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(
                mentionLabels: const {
                  'player\u0000白鸦': '站内账号',
                  'player\u0000夜渡': '站内账号',
                },
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('@站内账号'), findsNWidgets(2));
    expect(find.text('@白鸦'), findsNothing);
    expect(MarkdownDeltaCodec.encode(controller.document.toDelta()), source);
    expect(tester.takeException(), isNull);
  });
}

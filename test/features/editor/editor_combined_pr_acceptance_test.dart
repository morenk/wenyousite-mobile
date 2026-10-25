import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';
import '../../support/text_color_assertions.dart';

class _Clipboard implements EditorClipboardGateway {
  @override
  Future<EditorClipboardSnapshot> read() async =>
      const EditorClipboardSnapshot(text: '<new>');

  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('失效范围之后在分隔线旁粘贴：字体、实体标签、单步历史与保存重开共存', () async {
    const font = 'tfv_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final session = RichEditorSession(
      initialMarkdown:
          '<span data-wenyou-font-v2="$font">**&lt;tag&gt;**</span>\n\n---\n\n尾',
      onMarkdownChanged: (_) {},
      clipboardGateway: _Clipboard(),
    );
    addTearDown(session.dispose);
    expect(session.isSourceProtected, isFalse);
    final controller = session.controller;
    expect(controller.document.toPlainText(), '<tag>\n\n\uFFFC\n\n尾\n');
    final divider = controller.document.toPlainText().indexOf('\uFFFC');
    controller.updateSelection(
      TextSelection.collapsed(offset: divider + 1),
      ChangeSource.local,
    );
    controller.useFontForTyping(font);
    controller.useColorForTyping('#D14343');
    controller.document.history.clear();
    final before = controller.document.toDelta();
    final selection = controller.selection;
    final typing = controller.captureTypingStyle();
    for (final (index, length) in [
      (-1, 1),
      (controller.document.length, 0),
      (divider, controller.document.length),
    ]) {
      controller.replaceText(
        index,
        length,
        '拒绝',
        const TextSelection.collapsed(offset: 1),
      );
      expect(controller.document.toDelta(), before);
      expect(controller.selection, selection);
      expect(controller.captureTypingStyle(), typing);
      expect(controller.document.history.stack.undo, isEmpty);
    }

    expect(await pasteEditorClipboard(controller), isTrue);
    expect(session.operationFailure, isNull);
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    const plain = '<tag>\n\n\uFFFC\n<new>\n\n尾\n';
    expect(controller.document.toPlainText(), plain);
    _expectEditableBlocks(controller.document);
    expect(
      controller.selection,
      TextSelection.collapsed(offset: plain.indexOf('<new>') + '<new>'.length),
    );
    final expected = colorExpectedUnits([
      ('<tag>', {'font': font, 'bold': true}),
      ('<new>', {'font': font, 'color': '#D14343'}),
      ('尾', {}),
    ]);
    expect(colorDeltaUnits(controller.document.toDelta()), expected);
    final nodes = colorReaderNodes(session.localMarkdown);
    expect(colorReaderUnits(nodes), expected);
    expect(nodes.whereType<md.Element>().map((node) => node.tag), [
      'p',
      'hr',
      'p',
      'p',
    ]);
    expect(controller.document.history.stack.undo, hasLength(1));
    final edited = controller.document.toDelta();
    controller.undo();
    expect(controller.document.toDelta(), before);
    expect(controller.selection, selection);
    controller.redo();
    expect(controller.document.toDelta(), edited);
    expect(await session.flush(), isTrue, reason: session.codecFailure);

    final reopened = RichEditorSession(
      initialMarkdown: session.localMarkdown,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(reopened.isSourceProtected, isFalse);
    // 重开会按持久化 Markdown 重建源码分隔符，原始换行位置并非编辑块身份。
    // 仅跳过明确标记的源码分隔行，真实空段仍参与断言。
    _expectEditableBlocks(reopened.controller.document);
    expect(colorDeltaUnits(reopened.controller.document.toDelta()), expected);
    expect(await reopened.flush(), isTrue);
    expect(reopened.localMarkdown, session.localMarkdown);
  });
}

void _expectEditableBlocks(Document document) {
  expect(document.root.children.every((node) => node is Line), isTrue);
  final lines = document.root.children.cast<Line>();
  expect(
    lines
        .where(
          (line) =>
              line.toPlainText() != '\n' ||
              line
                      .style
                      .attributes[MarkdownDeltaLineMetadata
                          .sourceSeparatorAttribute]
                      ?.value !=
                  true,
        )
        .map((line) => line.toPlainText()),
    ['<tag>\n', '\uFFFC\n', '<new>\n', '尾\n'],
  );
  final divider = lines.singleWhere((line) => line.toPlainText() == '\uFFFC\n');
  expect(
    divider.style.attributes.keys.where(
      const {'header', 'list', 'blockquote', 'align', 'font', 'color'}.contains,
    ),
    isEmpty,
  );
}

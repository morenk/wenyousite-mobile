import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';

const _red = '#D14343';
const _green = '#25855A';

class _Gateway implements EditorClipboardGateway {
  _Gateway(this.version, this.font);
  final int version;
  final String font;

  @override
  Future<EditorClipboardSnapshot> read() async => EditorClipboardSnapshot(
    text: '来源',
    html:
        '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
        '<span data-wenyou-font-v$version="$font" data-wenyou-color-v1="$_green">'
        '<strong>来源</strong></span></div>',
  );

  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final (version, typingFont, sourceFont) in [
    (1, 'wenkai', 'zhuque'),
    (
      2,
      'tfv_00000000000000000000000000000001',
      'tfv_00000000000000000000000000000002',
    ),
  ]) {
    test('字体 v$version 的失效替换保留输入意图，结构化粘贴和续写各保留来源', () async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardGateway: _Gateway(version, sourceFont),
        preparePastedFonts: (delta) async => delta,
      );
      addTearDown(session.dispose);
      final c = session.controller;
      expect(EditorTextFontPolicy.apply(c, c.selection, typingFont), isTrue);
      c.useColorForTyping(_red);
      final before = c.document.toDelta();
      final selection = c.selection;
      final style = c.captureTypingStyle();
      c.replaceText(
        c.document.length,
        0,
        Delta()..insert('拒绝', {'font': sourceFont, 'color': _green}),
        const TextSelection.collapsed(offset: 2),
      );
      expect(c.document.toDelta(), before);
      expect(c.selection, selection);
      expect(c.captureTypingStyle(), style);
      expect(c.document.history.stack.undo, isEmpty);
      expect(c.document.history.stack.redo, isEmpty);

      expect(await pasteEditorClipboard(c), isTrue);
      expect(c.document.toPlainText(), '来源\n');
      expect(
        c.document.collectStyle(0, 2).attributes['font']?.value,
        sourceFont,
      );
      expect(c.document.collectStyle(0, 2).attributes['color']?.value, _green);
      expect(c.document.collectStyle(0, 2).attributes['bold']?.value, isTrue);
      expect(c.captureTypingStyle().font, typingFont);
      expect(c.typingColor, _red);
      c.document.history.lastRecorded = 0;
      final pasted = c.document.toDelta();
      c.replaceText(2, 0, '续😀', const TextSelection.collapsed(offset: 5));
      expect(c.document.toPlainText(), '来源续😀\n');
      expect(
        c.document.collectStyle(2, 3).attributes['font']?.value,
        typingFont,
      );
      expect(c.document.collectStyle(2, 3).attributes['color']?.value, _red);
      c.undo();
      expect(c.document.toDelta(), pasted);
      c.redo();
      expect(c.document.toPlainText(), '来源续😀\n');
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      final document = reopened.controller.document;
      expect(document.toPlainText(), '来源续😀\n');
      expect(document.collectStyle(0, 2).attributes['font']?.value, sourceFont);
      expect(document.collectStyle(0, 2).attributes['color']?.value, _green);
      expect(document.collectStyle(2, 3).attributes['font']?.value, typingFont);
      expect(document.collectStyle(2, 3).attributes['color']?.value, _red);
    });

    test('字体 v$version 粘贴验证等待期间正文同长变更，原范围仍有效也拒绝迟到提交', () async {
      final ready = Completer<Delta>();
      final checked = Completer<Delta>();
      final session = RichEditorSession(
        initialMarkdown: '甲乙',
        onMarkdownChanged: (_) {},
        clipboardGateway: _Gateway(version, sourceFont),
        preparePastedFonts: (delta) {
          ready.complete(delta);
          return checked.future;
        },
      );
      addTearDown(session.dispose);
      final c = session.controller;
      c.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 2),
        ChangeSource.local,
      );
      final pending = pasteEditorClipboard(c);
      final candidate = await ready.future;
      // 文本长度和选区保持，只有字体变化；等待中的提交仍必须检查完整正文签名。
      c.formatText(0, 2, Attribute.clone(Attribute.font, typingFont));
      final before = c.document.toDelta();
      final selection = c.selection;
      final undo = List.of(c.document.history.stack.undo);
      checked.complete(candidate);
      expect(await pending, isTrue);
      expect(c.document.toDelta(), before);
      expect(c.selection, selection);
      expect(c.document.toPlainText(), '甲乙\n');
      expect(c.document.history.stack.undo, undo);
      expect(
        c.document.collectStyle(0, 2).attributes['font']?.value,
        typingFont,
      );
    });
  }
}

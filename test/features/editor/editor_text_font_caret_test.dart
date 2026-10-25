import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_font_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('纯文本粘贴采用当前输入字体，换行和原子不携带；只读后旧快照失效', () {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final c = session.controller;
    const id = 'tfv_00000000000000000000000000000001';
    EditorTextFontPolicy.apply(c, c.selection, id);
    final pasted = c.stylePlainTextPaste(Delta()..insert('甲\n乙'));
    expect(pasted.toJson(), [
      {
        'insert': '甲',
        'attributes': {'font': id},
      },
      {'insert': '\n'},
      {
        'insert': '乙',
        'attributes': {'font': id},
      },
    ]);
    final saved = c.captureTypingStyle();
    c.readOnly = true;
    expect(EditorTextFontPolicy.apply(c, c.selection, id), isFalse);
    c.readOnly = false;
    c.restoreToolSelection(c.selection, snapshot: saved);
    c.replaceText(0, 0, '默认', const TextSelection.collapsed(offset: 2));
    expect(c.document.collectStyle(0, 2).attributes['font'], isNull);
  });

  test('空编辑器先选字体，输入与换段保持，保存重开保留正文样式', () async {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final c = session.controller;
    expect(EditorTextFontPolicy.apply(c, c.selection, 'wenkai'), isTrue);
    expect(c.document.toPlainText(), '\n');
    expect(c.document.history.stack.undo, isEmpty);
    c.replaceText(0, 0, '中文', const TextSelection.collapsed(offset: 2));
    c.replaceText(2, 0, '\n', const TextSelection.collapsed(offset: 3));
    c.replaceText(
      3,
      0,
      '日本語\nEnglish',
      const TextSelection.collapsed(offset: 14),
    );
    for (final op in c.document.toDelta().operations) {
      if (op.data is String && (op.data! as String).trim().isNotEmpty) {
        expect(op.attributes?['font'], 'wenkai');
      } else {
        expect(op.attributes?['font'], isNull);
      }
    }
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    final reopened = RichEditorSession(
      initialMarkdown: session.localMarkdown,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(
      reopened.controller.document.toPlainText(),
      c.document.toPlainText(),
    );
    expect(
      reopened.controller.document.collectStyle(0, 2).attributes['font']?.value,
      'wenkai',
    );
  });

  test('显式默认不继承邻字字体，保留颜色；主动移位和撤销退出临时字体', () {
    final session = RichEditorSession(
      initialMarkdown: '<span data-wenyou-font-v1="wenkai">甲乙</span>末',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final c = session.controller;
    c.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    c.useColorForTyping('#D14343');
    expect(EditorTextFontPolicy.apply(c, c.selection, null), isTrue);
    c.replaceText(1, 0, '默认', const TextSelection.collapsed(offset: 3));
    expect(c.document.collectStyle(1, 2).attributes['font'], isNull);
    expect(c.document.collectStyle(1, 2).attributes['color']?.value, '#D14343');
    expect(c.document.collectStyle(0, 1).attributes['font']?.value, 'wenkai');
    EditorTextFontPolicy.apply(c, c.selection, 'zhuque');
    c.updateSelection(
      const TextSelection.collapsed(offset: 5),
      ChangeSource.local,
    );
    c.replaceText(5, 0, '移', const TextSelection.collapsed(offset: 6));
    expect(c.document.collectStyle(5, 1).attributes['font'], isNull);
    EditorTextFontPolicy.apply(c, c.selection, 'zhuque');
    c.undo();
    c.redo();
    c.replaceText(
      c.selection.start,
      0,
      '撤',
      TextSelection.collapsed(offset: c.selection.start + 1),
    );
    expect(c.document.toDelta().toJson().toString(), isNot(contains('zhuque')));
  });

  test('IME 替换、同光标回报保持字体；结构化粘贴保留源字体', () {
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final c = session.controller;
    expect(EditorTextFontPolicy.apply(c, c.selection, 'wenkai'), isTrue);
    c.replaceText(0, 0, 'pin', const TextSelection.collapsed(offset: 3));
    c.updateSelection(c.selection, ChangeSource.local);
    c.replaceText(0, 3, '拼', const TextSelection.collapsed(offset: 1));
    expect(c.document.collectStyle(0, 1).attributes['font']?.value, 'wenkai');
    c.replaceText(
      1,
      0,
      Delta()..insert('粘贴', {'font': 'zhuque'}),
      const TextSelection.collapsed(offset: 3),
    );
    expect(c.document.collectStyle(1, 2).attributes['font']?.value, 'zhuque');
    c.replaceText(3, 0, '续', const TextSelection.collapsed(offset: 4));
    expect(c.document.collectStyle(3, 1).attributes['font']?.value, 'wenkai');
  });
}

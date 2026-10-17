import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/text_color_assertions.dart';

const _red = '#D14343';
const _green = '#25855A';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final explicit in [false, true]) {
    test('彩色与默认边界空格仅显式输入色继续着色 $explicit', () async {
      final session = _session(
        '<span data-wenyou-color-v1="$_green">绿</span>白',
      );
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      if (explicit) _choose(session, _green);
      _type(session, ' ');
      _type(session, '续');
      final expected = colorExpectedUnits([
        ('绿', {'color': _green}),
        (' 续', {if (explicit) 'color': _green}),
        ('白', {}),
      ]);
      expect(colorDeltaUnits(session.controller.document.toDelta()), expected);
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      expect(
        colorReaderUnits(colorReaderNodes(session.localMarkdown)),
        expected,
      );
    });
  }
  test('空正文先选色不改文档、草稿或撤销栈，实际输入可单步撤销重做', () async {
    final session = _session('');
    final editor = session.controller;
    final before = editor.document.toDelta();
    expect(EditorTextColorPolicy.selection(editor).enabled, isTrue);
    _choose(session, _red);
    expect(editor.document.toDelta(), before);
    expect(editor.document.history.stack.undo, isEmpty);
    expect(session.isDirty, isFalse);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, '');
    _type(session, '中文😀');
    final expected = colorExpectedUnits([
      ('中文😀', {'color': _red}),
    ]);
    expect(colorDeltaUnits(editor.document.toDelta()), expected);
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    expect(colorReaderUnits(colorReaderNodes(session.localMarkdown)), expected);
    final reopened = _session(session.localMarkdown);
    expect(colorDeltaUnits(reopened.controller.document.toDelta()), expected);
    editor.undo();
    expect(editor.document.toDelta(), before);
    editor.redo();
    expect(colorDeltaUnits(editor.document.toDelta()), expected);
    _type(session, '续');
    expect(_color(session, 4), _red);
  });

  test('默认 T 只清后续颜色，保留当前粗体斜体并且不改已输入内容', () {
    final session = _session('');
    session.controller.formatSelection(Attribute.bold);
    session.controller.formatSelection(Attribute.italic);
    _choose(session, _red);
    _type(session, '红');
    session.controller.formatSelection(Attribute.bold);
    session.controller.formatSelection(Attribute.italic);
    final before = session.controller.document.toDelta();
    _choose(session, null);
    expect(session.controller.document.toDelta(), before);
    _type(session, '默认');
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([
        ('红', {'color': _red, 'bold': true, 'italic': true}),
        ('默认', {'bold': true, 'italic': true}),
      ]),
    );
  });

  test('同光标焦点恢复与 IME selection-only 保留输入色，主动移位重新取样', () {
    final session = _session('<span data-wenyou-color-v1="$_green">绿</span>白');
    final editor = session.controller;
    editor.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    _choose(session, _red);
    editor.updateSelection(editor.selection, ChangeSource.local);
    editor.updateSelection(editor.selection, ChangeSource.remote);
    expect(EditorTextColorPolicy.selection(editor).color, _red);
    _type(session, '红');
    expect(_color(session, 2), _red);
    editor.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    expect(EditorTextColorPolicy.selection(editor).color, _green);
    _type(session, '续');
    expect(_color(session, 1), _green);
  });

  test('中文 IME 替换 n→ni→你及 emoji 保色，码点语义和重开独立一致', () async {
    final session = _session('');
    _choose(session, _red);
    var previous = '';
    for (final next in ['n', 'ni', '你', '你好😀']) {
      session.controller.replaceText(
        0,
        previous.length,
        next,
        TextSelection.collapsed(offset: next.length),
      );
      session.controller.updateSelection(
        session.controller.selection,
        ChangeSource.local,
      );
      expect(
        colorDeltaUnits(session.controller.document.toDelta()),
        colorExpectedUnits([
          (next, {'color': _red}),
        ]),
      );
      previous = next;
    }
    expect(await session.flush(), isTrue);
    expect(
      colorDeltaUnits(MarkdownDeltaCodec.decode(session.localMarkdown).delta),
      colorExpectedUnits([
        ('你好😀', {'color': _red}),
      ]),
    );
  });

  test('范围改色不激活输入色，同选区恢复后直接替换保持默认', () {
    final session = _session('**文字**');
    final editor = session.controller;
    const selected = TextSelection(baseOffset: 0, extentOffset: 2);
    editor.updateSelection(selected, ChangeSource.local);
    EditorTextColorPolicy.apply(editor, selected, _red);
    editor.updateSelection(selected, ChangeSource.local);
    editor.replaceText(0, 2, '替换', const TextSelection.collapsed(offset: 2));
    expect(
      colorDeltaUnits(editor.document.toDelta()),
      colorExpectedUnits([
        ('替换', {'bold': true}),
      ]),
    );
  });

  test('替换整个文档清除未落地输入色，即使新旧光标数字相同', () async {
    final session = _session('原文');
    _choose(session, _red);
    session.applyExternalMarkdown('新文');
    _type(session, '默认');
    expect(_color(session, 0), isNull);
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, '默认新文');
  });

  test('两次独立输入连续撤销重做保持各自前后选区，输入色不污染历史归属', () {
    final session = _session('甲乙丙');
    final editor = session.controller;
    const firstBefore = TextSelection.collapsed(offset: 1);
    const firstAfter = TextSelection.collapsed(offset: 2);
    const secondBefore = TextSelection(baseOffset: 2, extentOffset: 4);
    const secondAfter = TextSelection.collapsed(offset: 3);
    editor.updateSelection(firstBefore, ChangeSource.local);
    _choose(session, _red);
    _type(session, '红');
    editor.document.history.lastRecorded = 0;
    editor.updateSelection(secondBefore, ChangeSource.local);
    editor.replaceText(2, 2, '换', secondAfter);
    final finalDelta = editor.document.toDelta();
    editor.undo();
    expect(editor.selection, secondBefore);
    expect(editor.document.toPlainText(), '甲红乙丙\n');
    editor.undo();
    expect(editor.selection, firstBefore);
    expect(editor.document.toPlainText(), '甲乙丙\n');
    editor.redo();
    expect(editor.selection, firstAfter);
    expect(editor.document.toPlainText(), '甲红乙丙\n');
    editor.redo();
    expect(editor.selection, secondAfter);
    expect(editor.document.toDelta(), finalDelta);
  });

  test('默认输入色保留行内代码与链接，实际保存逐字不丢其他 marks', () async {
    final session = _session(
      '<span data-wenyou-color-v1="$_red">[`代码`](https://example.com/a)</span>',
    );
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    _choose(session, null);
    _type(session, '默认');
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([
        ('代', {'color': _red, 'code': true, 'link': 'https://example.com/a'}),
        ('默认', {'code': true, 'link': 'https://example.com/a'}),
        ('码', {'color': _red, 'code': true, 'link': 'https://example.com/a'}),
      ]),
    );
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    expect(
      colorReaderUnits(colorReaderNodes(session.localMarkdown)),
      colorDeltaUnits(session.controller.document.toDelta()),
    );
  });

  for (final style in <Attribute?>[
    null,
    Attribute.h2,
    Attribute.h3,
    Attribute.blockQuote,
    Attribute.ul,
    Attribute.ol,
    Attribute.centerAlignment,
  ]) {
    test('连续手输与换行保留显式输入色且换行不着色：$style', () async {
      final session = _session('甲');
      if (style != null) session.controller.formatSelection(style);
      _choose(session, _red);
      _type(session, '一');
      _type(session, '\n');
      _type(session, '二😀');
      final delta = session.controller.document.toDelta();
      expect(session.controller.document.toPlainText(), '一\n二😀甲\n');
      final textOperations = delta.operations.where((op) => op.data is String);
      for (final op in textOperations) {
        if ((op.data as String).contains('\n')) {
          expect(op.attributes?['color'], isNull);
        }
      }
      expect(
        colorDeltaUnits(delta),
        colorExpectedUnits([
          ('一二😀', {'color': _red}),
          ('甲', {}),
        ]),
      );
      if (style != null) {
        expect(
          session.controller.document
              .collectStyle(1, 1)
              .attributes[style.key]
              ?.value,
          style.value,
        );
        expect(
          session.controller.document
              .collectStyle(6, 1)
              .attributes[style.key]
              ?.value,
          style.key == 'align' ? null : style.value,
        );
      }
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      expect(
        colorDeltaUnits(MarkdownDeltaCodec.decode(session.localMarkdown).delta),
        colorDeltaUnits(delta),
      );
    });
  }

  test('光标先选色再手输完整站内链接，原子不带颜色，后续输入仍保留显式色', () async {
    final session = _session('');
    _choose(session, _red);
    _type(session, 'https://wenyou.site/threads/c111111111111111111111111');
    final atom = session.controller.document.toDelta().operations.first;
    expect(atom.data, isA<Map>());
    expect(atom.attributes?['color'], isNull);
    _type(session, '尾');
    expect(_color(session, 1), _red);
    expect(await session.flush(), isTrue);
  });
}

RichEditorSession _session(String source) {
  final session = RichEditorSession(
    initialMarkdown: source,
    onMarkdownChanged: (_) {},
  );
  addTearDown(session.dispose);
  expect(session.isSourceProtected, isFalse, reason: source);
  return session;
}

void _choose(RichEditorSession session, String? color) =>
    EditorTextColorPolicy.apply(
      session.controller,
      session.controller.selection,
      color,
    );

void _type(RichEditorSession session, String text) {
  final editor = session.controller;
  final at = editor.selection.start;
  editor.replaceText(
    at,
    editor.selection.end - at,
    text,
    TextSelection.collapsed(offset: at + text.length),
  );
}

String? _color(RichEditorSession session, int at) =>
    session.controller.document.collectStyle(at, 1).attributes['color']?.value
        as String?;

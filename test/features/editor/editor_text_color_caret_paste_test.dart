import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';
import '../../support/text_color_assertions.dart';

const _red = '#D14343';
const _green = '#25855A';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('纯文本整段采用提交时输入色，首字、emoji、换行和撤销独立验证', () async {
    final gateway = _Gateway()
      ..snapshot = const EditorClipboardSnapshot(text: '中文😀\n尾');
    final session = _session(gateway);
    final before = session.controller.document.toDelta();
    _choose(session, _red);
    await pasteEditorClipboard(session.controller);
    final expected = colorExpectedUnits([
      ('中文😀尾', {'color': _red}),
    ]);
    expect(colorDeltaUnits(session.controller.document.toDelta()), expected);
    expect(session.controller.document.toPlainText(), '中文😀\n尾\n');
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    expect(
      colorReaderUnits(
        colorReaderNodes(session.localMarkdown),
      ).whereType<Map>().where((unit) => unit['text'] != '\n'),
      expected,
    );
    session.controller.undo();
    expect(session.controller.document.toDelta(), before);
    session.controller.redo();
    expect(colorDeltaUnits(session.controller.document.toDelta()), expected);
  });

  for (final color in <String?>[null, _green]) {
    test('站内结构化片段保留源色，待输入色不污染第一个字符 $color', () async {
      final fragment = Delta()..insert('来源😀', {'color': ?color, 'bold': true});
      final store = WenyouEditorClipboardStore();
      store.capture(
        delta: fragment,
        plainTextFallback: '来源😀',
        operation: WenyouEditorClipboardOperation.copy,
        marker: 'source',
        scope: 'account',
      );
      final gateway = _Gateway()
        ..snapshot = const EditorClipboardSnapshot(
          text: '来源😀',
          marker: 'source',
        );
      final session = _session(gateway, store: store);
      _choose(session, _red);
      await pasteEditorClipboard(session.controller);
      expect(
        colorDeltaUnits(session.controller.document.toDelta()),
        colorExpectedUnits([
          ('来源😀', {'color': ?color, 'bold': true}),
        ]),
      );
      final at = session.controller.selection.start;
      session.controller.replaceText(
        at,
        0,
        '手输',
        TextSelection.collapsed(offset: at + 2),
      );
      expect(
        session.controller.document
            .collectStyle(at, 2)
            .attributes['color']
            ?.value,
        _red,
      );
      expect(await session.flush(), isTrue, reason: session.codecFailure);
    });
  }

  test('异步读取期间换色按实际提交时状态应用，验证与实际写入相同', () async {
    final gateway = _Gateway()..pending = Completer<EditorClipboardSnapshot>();
    final session = _session(gateway);
    _choose(session, _red);
    final paste = pasteEditorClipboard(session.controller);
    _choose(session, _green);
    gateway.pending!.complete(const EditorClipboardSnapshot(text: '提交😀'));
    await paste;
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([
        ('提交😀', {'color': _green}),
      ]),
    );
    expect(await session.flush(), isTrue);
    expect(session.localMarkdown, contains('"$_green"'));
    expect(session.localMarkdown, isNot(contains('"$_red"')));
  });

  test('输入色增加序列化长度时超限整次拒绝，不把无色候选当有色实写', () async {
    final gateway = _Gateway()
      ..snapshot = const EditorClipboardSnapshot(text: '文字');
    final session = _session(gateway, maximum: 10);
    _choose(session, _red);
    await pasteEditorClipboard(session.controller);
    expect(session.controller.document.toPlainText(), '\n');
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.contentTooLong,
    );
    expect(session.controller.document.history.stack.undo, isEmpty);
  });

  test('读取期间主动移位仍拒绝粘贴，不让颜色选择绕过选区竞态', () async {
    final gateway = _Gateway()..pending = Completer<EditorClipboardSnapshot>();
    final session = _session(gateway, source: '原文');
    _choose(session, _red);
    final paste = pasteEditorClipboard(session.controller);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );
    gateway.pending!.complete(const EditorClipboardSnapshot(text: '不可粘贴'));
    await paste;
    expect(session.controller.document.toPlainText(), '原文\n');
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.documentChanged,
    );
  });

  test('能力关闭清除临时色，不能留下隐形彩色输入；恢复能力也不复活', () {
    final session = _session(_Gateway());
    _choose(session, _red);
    session.controller.textColorInputEnabled = false;
    expect(
      EditorTextColorPolicy.selection(session.controller).enabled,
      isFalse,
    );
    expect(
      EditorTextColorPolicy.apply(
        session.controller,
        session.controller.selection,
        _green,
      ),
      isFalse,
    );
    session.controller.replaceText(
      0,
      0,
      '默认',
      const TextSelection.collapsed(offset: 2),
    );
    session.controller.textColorInputEnabled = true;
    session.controller.replaceText(
      2,
      0,
      '继续',
      const TextSelection.collapsed(offset: 4),
    );
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([('默认继续', {})]),
    );
  });

  test('只读和无效光标不能设置输入色', () {
    final session = _session(_Gateway());
    _choose(session, _red);
    final beforeReadonly = session.controller.captureTypingStyle();
    session.readOnly = true;
    expect(
      EditorTextColorPolicy.selection(session.controller).enabled,
      isFalse,
    );
    expect(
      EditorTextColorPolicy.apply(
        session.controller,
        session.controller.selection,
        _red,
      ),
      isFalse,
    );
    session.readOnly = false;
    session.controller.restoreToolSelection(
      session.controller.selection,
      snapshot: beforeReadonly,
    );
    session.controller.replaceText(
      0,
      0,
      '默认',
      const TextSelection.collapsed(offset: 2),
    );
    expect(
      colorDeltaUnits(session.controller.document.toDelta()),
      colorExpectedUnits([('默认', {})]),
    );
    session.controller.document.history.clear();
    expect(
      EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection.collapsed(offset: -1),
        _red,
      ),
      isFalse,
    );
    expect(
      EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection.collapsed(offset: 10),
        _red,
      ),
      isFalse,
    );
    expect(session.controller.document.history.stack.undo, isEmpty);
  });
}

RichEditorSession _session(
  _Gateway gateway, {
  WenyouEditorClipboardStore? store,
  String source = '',
  int maximum = 10000,
}) {
  final session = RichEditorSession(
    initialMarkdown: source,
    onMarkdownChanged: (_) {},
    clipboardGateway: gateway,
    clipboardStore: store ?? WenyouEditorClipboardStore(),
    clipboardScope: 'account',
    maximumSerializedLength: maximum,
  );
  addTearDown(session.dispose);
  return session;
}

void _choose(RichEditorSession session, String? color) =>
    EditorTextColorPolicy.apply(
      session.controller,
      session.controller.selection,
      color,
    );

class _Gateway implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);
  Completer<EditorClipboardSnapshot>? pending;
  @override
  Future<EditorClipboardSnapshot> read() async => pending?.future ?? snapshot;
  @override
  Future<void> write({required String text, required String marker}) async =>
      snapshot = EditorClipboardSnapshot(text: text, marker: marker);
}

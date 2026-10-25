import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_divider_structure.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';
import '../../support/text_color_assertions.dart';

class _Gateway implements EditorClipboardGateway {
  const _Gateway(this.snapshot);
  final EditorClipboardSnapshot snapshot;
  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;
  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final version in [1, 2]) {
    final font = version == 1
        ? 'wenkai'
        : 'tfv_00000000000000000000000000000001';
    for (final input in ['typing', 'plain-paste', 'structured-paste']) {
      test('分隔线旁 $input 保留字体 v$version、颜色、标题和单步历史', () async {
        final structured = input == 'structured-paste';
        final color = structured ? '#D14343' : '#25855A';
        final session = RichEditorSession(
          initialMarkdown: '## 前\n\n---\n\n后',
          onMarkdownChanged: (_) {},
          clipboardStore: WenyouEditorClipboardStore(),
          clipboardGateway: _Gateway(
            EditorClipboardSnapshot(
              text: '新😀',
              html: structured
                  ? '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
                        '<span data-wenyou-font-v$version="$font" data-wenyou-color-v1="$color"><strong>新😀</strong></span></div>'
                  : null,
            ),
          ),
          // 此离线入口代表已通过字体目录检查的粘贴片段，不下载资源。
          preparePastedFonts: (delta) async => delta,
        );
        addTearDown(session.dispose);
        final c = session.controller;
        final before = c.document.toDelta();
        final divider = c.document.toPlainText().indexOf('\uFFFC');
        c.updateSelection(
          TextSelection.collapsed(offset: divider + 1),
          ChangeSource.local,
        );
        final originalSelection = c.selection;
        c.useColorForTyping('#25855A');
        c.useFontForTyping(structured ? 'zhuque' : font);
        if (input == 'typing') {
          c.replaceText(
            divider + 1,
            0,
            '新😀',
            TextSelection.collapsed(offset: divider + 4),
          );
        } else {
          expect(await pasteEditorClipboard(c), isTrue);
          expect(session.operationFailure, isNull);
        }
        expect(await session.flush(), isTrue, reason: session.codecFailure);
        expect(c.document.toPlainText().replaceAll('\n', ''), '前\uFFFC新😀后');
        expect(
          c.selection,
          TextSelection.collapsed(
            offset: c.document.toPlainText().indexOf('新') + 3,
          ),
        );
        final expected = colorExpectedUnits([
          ('前', {}),
          ('新😀', {'font': font, 'color': color, if (structured) 'bold': true}),
          ('后', {}),
        ]);
        expect(colorDeltaUnits(c.document.toDelta()), expected);
        _expectBlocks(c.document);
        final saved = session.localMarkdown;
        final nodes = colorReaderNodes(saved);
        expect(colorReaderUnits(nodes), expected);
        expect(nodes.whereType<md.Element>().map((node) => node.tag), [
          'h2',
          'hr',
          'p',
          'p',
        ]);
        final edited = c.document.toDelta();
        final selected = c.selection;
        expect(c.document.history.stack.undo, hasLength(1));
        c.undo();
        expect(c.document.toDelta(), before);
        expect(c.selection, originalSelection);
        expect(c.document.history.stack.undo, isEmpty);
        c.redo();
        expect(c.document.toDelta(), edited);
        expect(c.selection, selected);
        expect(await session.flush(), isTrue);

        final reopened = RichEditorSession(
          initialMarkdown: saved,
          onMarkdownChanged: (_) {},
        );
        addTearDown(reopened.dispose);
        expect(
          colorDeltaUnits(reopened.controller.document.toDelta()),
          expected,
        );
        _expectBlocks(reopened.controller.document);
        expect(await reopened.flush(), isTrue);
        expect(reopened.localMarkdown, saved);
      });
    }
  }

  test('分隔线旁含字体粘贴按补边界后的完整长度拒绝，保留正文和历史', () async {
    final session = RichEditorSession(
      initialMarkdown: '前\n\n---\n\n后',
      maximumSerializedLength: 40,
      onMarkdownChanged: (_) {},
      clipboardGateway: const _Gateway(EditorClipboardSnapshot(text: '新')),
    );
    addTearDown(session.dispose);
    final c = session.controller;
    final divider = c.document.toPlainText().indexOf('\uFFFC');
    c.updateSelection(
      TextSelection.collapsed(offset: divider + 1),
      ChangeSource.local,
    );
    c.useFontForTyping('wenkai');
    c.useColorForTyping('#D14343');
    final before = c.document.toDelta();
    final selection = c.selection;
    await pasteEditorClipboard(c);
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.contentTooLong,
    );
    expect(c.document.toDelta(), before);
    expect(c.selection, selection);
    expect(c.document.history.stack.undo, isEmpty);
  });

  test('分隔线换行去除字体和颜色，同时保留真实文字属性', () {
    final source = Delta()
      ..insert('前', {'font': 'wenkai', 'color': '#D14343'})
      ..insert({
        MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
      })
      ..insert('\n', {'font': 'wenkai', 'color': '#D14343', 'header': 2});
    final actual = normalizeEditorDividerBlocks(source);
    expect(actual.toJson(), [
      {
        'insert': '前',
        'attributes': {'font': 'wenkai', 'color': '#D14343'},
      },
      {
        'insert': '\n',
        'attributes': {'header': 2},
      },
      {
        'insert': {
          MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
        },
      },
      {'insert': '\n'},
    ]);
    expect(normalizeEditorDividerBlocks(actual), actual);
  });
}

void _expectBlocks(Document document) {
  final divider = document.toPlainText().indexOf('\uFFFC');
  final line = document.queryChild(divider).node! as Line;
  expect(line.toPlainText(), '\uFFFC\n');
  expect(
    line.style.attributes.keys.where(
      const {'header', 'list', 'blockquote', 'align', 'font', 'color'}.contains,
    ),
    isEmpty,
  );
  expect(document.collectStyle(0, 1).attributes['header']?.value, 2);
  for (final op in document.toDelta().operations) {
    if (op.data is! String || op.data == '\n') {
      expect(op.attributes?['font'], isNull);
      expect(op.attributes?['color'], isNull);
    }
  }
}

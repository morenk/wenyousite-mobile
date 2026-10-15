import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/editor/quill_document_range.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_atomic_text_editor.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/literal_text_quill_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';
import 'rich_editor_session_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('所有合法范围保持 UTF-16、样式分段、换行和 Embed 的原始坐标', () {
    final document = Document.fromDelta(
      Delta()
        ..insert('前😀', {'bold': true})
        ..insert('中')
        ..insert({
          'mention': {'label': '@长名字', 'userId': 'user-1'},
        })
        ..insert('后\n', {'italic': true})
        ..insert('\n')
        ..insert({'image': 'https://example.com/a.png'})
        ..insert('\n')
        ..insert('末👩‍💻')
        ..insert('\n', {'blockquote': true}),
    );
    addTearDown(document.close);
    // 独立预期：所有 Embed 占一个坐标，不展开标签、图片 URL 或 Markdown。
    const expected = '前😀中\uFFFC后\n\n\uFFFC\n末👩‍💻';
    final before = document.toDelta().toJson();
    expect(document.length, expected.length + 1);
    for (var start = 0; start <= expected.length; start++) {
      for (var end = start; end <= expected.length; end++) {
        expect(
          readQuillDocumentRange(document, start, end - start),
          expected.substring(start, end),
          reason: '$start..$end',
        );
      }
    }
    expect(document.toDelta().toJson(), before);
  });

  test('空文档和末尾允许零长度读取，非法范围不截取近似范围', () {
    final document = Document();
    addTearDown(document.close);
    expect(readQuillDocumentRange(document, 0, 0), '');
    for (final (start, length) in [(-1, 0), (0, -1), (0, 1), (1, 0)]) {
      expect(readQuillDocumentRange(document, start, length), isNull);
    }
    expect(
      readQuillDocumentRange(document, 0, 1, includeTerminalNewline: true),
      '\n',
    );
    expect(
      readQuillDocumentRange(document, 1, 0, includeTerminalNewline: true),
      isNull,
    );
  });

  test('结构替换可包含末尾换行以保留块属性，不能超过文档末尾', () {
    final controller = LiteralTextQuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
      config: const QuillControllerConfig(),
    );
    addTearDown(controller.dispose);
    controller.replaceText(
      0,
      1,
      Delta()
        ..insert('段落')
        ..insert('\n', {'align': 'center'}),
      const TextSelection.collapsed(offset: 2),
    );
    expect(controller.document.toPlainText(), '段落\n');
    expect(
      controller.document.toDelta().operations.last.attributes?['align'],
      'center',
    );
    final before = controller.document.toDelta().toJson();
    final selection = controller.selection;
    controller.replaceText(
      controller.document.length,
      0,
      '拒绝在保护换行之后插入',
      const TextSelection.collapsed(offset: 0),
    );
    expect(controller.document.toDelta().toJson(), before);
    expect(controller.selection, selection);
    controller.replaceText(
      0,
      controller.document.length + 1,
      Delta()..insert('拒绝\n'),
      const TextSelection.collapsed(offset: 0),
    );
    expect(controller.document.toDelta().toJson(), before);
  });

  for (final (start, length) in [(-1, 0), (8, 0), (0, 8), (1, -1)]) {
    test('失效替换 $start/$length 保留正文、选区和撤销历史', () {
      final controller = LiteralTextQuillController(
        document: Document.fromDelta(Delta()..insert('前😀后\n')),
        selection: const TextSelection.collapsed(offset: 2),
        config: const QuillControllerConfig(),
      );
      addTearDown(controller.dispose);
      final before = controller.document.toDelta().toJson();
      controller.replaceText(
        start,
        length,
        'https://wenyou.site/join/AbCdEfGh_123-XYZ',
        const TextSelection.collapsed(offset: 1),
      );
      expect(controller.document.toDelta().toJson(), before);
      expect(controller.selection.baseOffset, 2);
      expect(controller.hasUndo, isFalse);
    });
  }

  test('跨行和 Embed 的替换按原坐标执行并可撤销重做', () {
    final controller = LiteralTextQuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('前😀\n')
          ..insert({'image': 'x'})
          ..insert('\n尾\n'),
      ),
      selection: const TextSelection(baseOffset: 6, extentOffset: 1),
      config: const QuillControllerConfig(),
    );
    addTearDown(controller.dispose);
    final before = controller.document.toDelta().toJson();
    controller.replaceText(
      1,
      5,
      '新😀',
      const TextSelection.collapsed(offset: 4),
    );
    expect(controller.document.toPlainText(), '前新😀尾\n');
    controller.undo();
    expect(controller.document.toDelta().toJson(), before);
    expect(
      controller.selection,
      const TextSelection(baseOffset: 6, extentOffset: 1),
    );
    controller.redo();
    expect(controller.document.toPlainText(), '前新😀尾\n');
    expect(controller.selection.baseOffset, 4);
  });

  for (final offset in [-1, 100]) {
    test('无效替换 $offset 不进入事务或修正现有分隔线结构', () {
      final controller = LiteralTextQuillController(
        document: Document.fromDelta(
          Delta()
            ..insert('前', {'bold': true})
            ..insert({
              MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
            })
            ..insert('后\n'),
        ),
        selection: const TextSelection.collapsed(offset: 0),
        config: const QuillControllerConfig(),
      );
      addTearDown(controller.dispose);
      final before = controller.document.toDelta().toJson();
      controller.replaceText(
        offset,
        0,
        '拒绝',
        const TextSelection.collapsed(offset: 1),
      );
      expect(controller.document.toDelta().toJson(), before);
      expect(controller.document.toPlainText(), '前\uFFFC后\n');
      expect(controller.selection, const TextSelection.collapsed(offset: 0));
      expect(controller.hasUndo, isFalse);
    });
  }

  test('正文缩短后的过期选区粘贴保留草稿并报告重新粘贴', () async {
    final clipboard = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..snapshot = const EditorClipboardSnapshot(text: '新增');
    final session = RichEditorSession(
      initialMarkdown: '保留正文',
      onMarkdownChanged: (_) {},
      clipboardGateway: clipboard,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 2, extentOffset: 4),
      ChangeSource.local,
    );
    session.controller.document.delete(0, 3);
    await Future<void>.delayed(Duration.zero);
    expect(await session.flush(), isTrue);
    final undoEntries = session.controller.document.history.stack.undo.length;
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(session.controller.document.toPlainText(), '文\n');
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.documentChanged,
    );
    expect(session.localMarkdown, '文');
    expect(session.controller.document.history.stack.undo.length, undoEntries);
  });

  test('简短正文的失效粘贴与替换也保留原文', () {
    final controller = WenyouAtomicTextController(
      initialMarkdown: '保留正文',
      maximumMarkdownLength: 200,
    );
    addTearDown(controller.dispose);
    controller.quillController.updateSelection(
      const TextSelection.collapsed(offset: -1),
      ChangeSource.local,
    );
    expect(controller.pasteText('新增'), isFalse);
    controller.quillController.replaceText(
      1,
      20,
      '新增',
      const TextSelection.collapsed(offset: 3),
    );
    expect(controller.quillController.document.toPlainText(), '保留正文\n');
    expect(controller.quillController.hasUndo, isFalse);
  });
}

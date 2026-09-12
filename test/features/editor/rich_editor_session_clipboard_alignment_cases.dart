import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'rich_editor_session_test_support.dart';

void registerRichEditorSessionClipboardAlignmentCases() {
  testWidgets('只读编辑器允许复制骰子但拒绝剪切', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    const markdown = '[[dice:v1:$nodeId:1d20]]';
    String? clipboardText;
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: markdown,
      onMarkdownChanged: emitted.add,
      clipboardStore: WenyouEditorClipboardStore(),
      readClipboardText: () async => clipboardText,
      writeClipboardText: (text) async => clipboardText = text,
    );
    addTearDown(session.dispose);
    session.readOnly = true;
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );

    expect(await session.copySelection(), isTrue);
    expect(clipboardText, '1d20 = ?');
    expect(await session.copySelection(cut: true), isFalse);
    session.controller.updateSelection(
      TextSelection.collapsed(offset: session.controller.document.length - 1),
      ChangeSource.local,
    );
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(await session.flush(), isTrue);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      markdown,
    );
    expect(emitted, isEmpty);
  });

  testWidgets('写入系统剪贴板失败后不应残留可粘贴的内部载荷', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    const markdown = '[[dice:v1:$nodeId:1d20]]';
    final emitted = <String>[];
    final store = WenyouEditorClipboardStore();
    final session = RichEditorSession(
      initialMarkdown: markdown,
      onMarkdownChanged: emitted.add,
      clipboardStore: store,
      readClipboardText: () async => markdown,
      writeClipboardText: (_) async => throw StateError('剪贴板不可用'),
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );

    expect(await session.copySelection(), isFalse);
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.clipboardWrite,
    );
    expect(await session.flush(), isTrue);
    final resolution = store.resolve(markdown);
    expect(resolution.delta, isNull);
    expect(resolution.usePlainText, isFalse);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      markdown,
    );
    expect(emitted, isEmpty);
  });

  testWidgets('编辑器自动清除列表继承的非法对齐属性', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '正文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 2),
      ChangeSource.local,
    );

    session.controller.formatSelection(Attribute.ul);
    session.controller.formatSelection(Attribute.centerAlignment);
    await tester.pump();

    expect(
      session.controller.document.toDelta().operations.last.attributes,
      isNot(contains('align')),
    );
    expect(await session.flush(), isTrue);
    expect(emitted.last, '- 正文');
  });

  testWidgets('同一 Markdown 段落出现混合对齐时统一清回左对齐', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '第一行\n第二行',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 3),
      ChangeSource.local,
    );

    session.controller.formatSelection(Attribute.centerAlignment);
    await tester.pump();

    final newlineOperations = session.controller.document
        .toDelta()
        .operations
        .where((operation) => operation.data == '\n');
    expect(
      newlineOperations.every(
        (operation) => !(operation.attributes?.containsKey('align') ?? false),
      ),
      isTrue,
    );
    expect(await session.flush(), isTrue);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '第一行\n第二行',
    );
    expect(emitted, isEmpty);
  });
}

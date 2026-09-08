import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import 'rich_editor_session_test_support.dart';

void registerRichEditorSessionDocumentTransactionsCases() {
  testWidgets('无损证明失败保留当前 Delta 与上次草稿，修正后可保存', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '原草稿',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    // Simulate an invalid producer bypassing literal input metadata.
    session.controller.document = Document()..insert(0, '**源码字符**');
    final before = session.controller.document.toDelta().toJson();
    expect(await session.flush(), isFalse);
    expect(emitted, isEmpty);
    expect(session.controller.document.toDelta().toJson(), before);
    expect(session.codecFailure, isNot(contains('源码字符')));
    session.controller.document.format(
      0,
      8,
      Attribute<bool>(
        MarkdownDeltaCodec.literalTextAttribute,
        AttributeScope.inline,
        true,
      ),
    );
    expect(await session.flush(), isTrue);
    expect(emitted.single, r'\*\*源码字符\*\*');
  });

  testWidgets('正文输入空闲后才编码 Markdown，显式 flush 会立即同步', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      codecDebounce: const Duration(milliseconds: 100),
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    session.controller.replaceText(
      0,
      0,
      '温油',
      const TextSelection.collapsed(offset: 2),
    );
    await tester.pump(const Duration(milliseconds: 99));
    expect(emitted, isEmpty);

    expect(await session.flush(), isTrue);
    expect(emitted, ['温油']);
  });

  for (final testCase in const [
    (label: '文首', source: '正文', offset: 0, expected: '---\n\n正文'),
    (label: '文中', source: '上文下文', offset: 2, expected: '上文\n\n---\n\n下文'),
    (label: '行上方', source: '上文\n下文', offset: 3, expected: '上文\n\n---\n\n下文'),
    (label: '行下方', source: '上文\n下文', offset: 2, expected: '上文\n\n---\n\n下文'),
    (label: '文尾', source: '正文', offset: 2, expected: '正文\n\n---'),
  ]) {
    testWidgets('${testCase.label}插入分隔线后保存为独占块', (tester) async {
      final emitted = <String>[];
      final session = RichEditorSession(
        initialMarkdown: testCase.source,
        onMarkdownChanged: emitted.add,
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        TextSelection.collapsed(offset: testCase.offset),
        ChangeSource.local,
      );

      session.insertHorizontalRule();
      await tester.pump();

      expect(await session.flush(), isTrue);
      expect(emitted.last, testCase.expected);
      final reopened = RichEditorSession(
        initialMarkdown: emitted.last,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        MarkdownDeltaCodec.encode(reopened.controller.document.toDelta()),
        testCase.expected,
      );
    });
  }

  testWidgets('分隔线插入和撤销各保持单个 Delta 事务', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '上文下文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final before = session.controller.document.toDelta().toJson();
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );

    session.insertHorizontalRule();
    await tester.pump();
    expect(session.controller.hasUndo, isTrue);
    expect(emitted.last, '上文\n\n---\n\n下文');

    session.controller.undo();
    await tester.pump();
    expect(session.controller.document.toDelta().toJson(), before);
    expect(session.controller.hasUndo, isFalse);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '上文下文');
  });

  testWidgets('保存前即使会话未标脏也从当前 Delta 重新编码', (tester) async {
    const unsupported = '| 名称 | 数值 |\n| --- | ---: |\n| 骰子 | 20 |';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: unsupported,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    expect(session.isDirty, isFalse);
    expect(await session.flush(), isTrue);
    expect(emitted, [MarkdownContent.literalizeUnsupported(unsupported)]);
  });

  testWidgets('历史空段重开编辑后写入规范标记且段数不变', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '第一段\n\n\n\n第二段',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    final initialEmptyParagraphCount = session.controller.document
        .toDelta()
        .operations
        .where(
          (operation) =>
              operation.attributes?[MarkdownDeltaCodec
                  .emptyParagraphAttribute] ==
              true,
        )
        .fold<int>(
          0,
          (count, operation) =>
              count + '\n'.allMatches(operation.data as String).length,
        );
    expect(initialEmptyParagraphCount, 2);

    final end = session.controller.document.length - 1;
    session.controller.replaceText(
      end,
      0,
      '（已改）',
      TextSelection.collapsed(offset: end + 4),
    );
    expect(await session.flush(), isTrue);
    expect(emitted.single, '第一段\n<br />\n<br />\n第二段（已改）');

    final reopened = RichEditorSession(
      initialMarkdown: emitted.single,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(
      MarkdownDeltaCodec.encode(reopened.controller.document.toDelta()),
      emitted.single,
    );
  });

  testWidgets('连续回车新建空段后保存为可见空段标记', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    void insertAtEnd(String text) {
      final offset = session.controller.document.length - 1;
      session.controller.replaceText(
        offset,
        0,
        text,
        TextSelection.collapsed(offset: offset + text.length),
      );
    }

    insertAtEnd('第一段');
    insertAtEnd('\n');
    insertAtEnd('\n');
    insertAtEnd('第二段');

    expect(await session.flush(), isTrue);
    expect(emitted.last, '第一段\n<br />\n第二段');
  });

  testWidgets('行尾回车和外部粘贴的空段同样保留', (tester) async {
    final typed = <String>[];
    final typedSession = RichEditorSession(
      initialMarkdown: '正文',
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: typed.add,
    );
    addTearDown(typedSession.dispose);
    final end = typedSession.controller.document.length - 1;
    typedSession.controller.replaceText(
      end,
      0,
      '\n',
      TextSelection.collapsed(offset: end + 1),
    );

    expect(await typedSession.flush(), isTrue);
    expect(typed.last, '正文\n<br />');

    final pasted = <String>[];
    final pastedSession = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: pasted.add,
      readClipboardText: () async => '第一段\n\n第二段',
    );
    addTearDown(pastedSession.dispose);

    expect(await pasteEditorClipboard(pastedSession.controller), isTrue);
    expect(pasted.last, '第一段\n<br />\n第二段');
  });

  testWidgets('编辑普通 Markdown 段落时不把结构分隔升级为空段', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '第一段\n\n第二段',
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final end = session.controller.document.length - 1;
    session.controller.replaceText(
      end,
      0,
      '（已改）',
      TextSelection.collapsed(offset: end + 4),
    );

    expect(await session.flush(), isTrue);
    expect(emitted.last, '第一段\n\n第二段（已改）');

    final editedSeparator = <String>[];
    final separatorSession = RichEditorSession(
      initialMarkdown: 'A\n\nB',
      onMarkdownChanged: editedSeparator.add,
    );
    addTearDown(separatorSession.dispose);
    separatorSession.controller.replaceText(
      2,
      0,
      'X',
      const TextSelection.collapsed(offset: 3),
    );

    expect(await separatorSession.flush(), isTrue);
    expect(separatorSession.controller.document.toPlainText(), 'A\nXB\n');
    expect(editedSeparator.last, 'A\n\nXB');
  });

  testWidgets('H2 H3 与加粗切换后立即保存当前 Delta', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '标题',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 2),
      ChangeSource.local,
    );

    session.controller.formatSelection(Attribute.h2);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '## 标题');

    session.controller.formatSelection(Attribute.h3);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '### 标题');

    session.controller.formatSelection(Attribute.bold);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '### **标题**');
  });

  testWidgets('外部 revision 替换文档时不回写并按要求移动光标', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '旧正文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    session.scheduleExternalMarkdown(
      markdown: '云端\n正文',
      revision: 2,
      selection: RichEditorSelectionPlacement.end,
    );
    await tester.pump();

    expect(session.controller.document.toPlainText(), '云端\n正文\n');
    expect(session.controller.selection.baseOffset, 5);
    expect(emitted, isEmpty);
    expect(session.isDirty, isFalse);
  });

  testWidgets('图片和表情插入统一处理选区并立即生成 Markdown', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '替换我',
      initialSelection: RichEditorSelectionPlacement.end,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 3),
      ChangeSource.local,
    );

    session.insertBlockImage(url: 'https://cdn.example.com/image.png');
    expect(emitted.last, contains('![图片](https://cdn.example.com/image.png)'));
    expect(emitted.last, isNot(contains('替换我')));

    session.insertSticker(
      selection: session.controller.selection,
      assetId: 'cm12345678901234567890',
      url: 'https://cdn.example.com/sticker.png',
    );
    expect(emitted.last, contains('wenyousite-sticker:v1:'));
  });

  testWidgets('正文光标带待应用样式时表情仍以无属性原子节点安全保存', (tester) async {
    const assetId = 'cm1234567890123456789012';
    const url = 'https://cdn.example.com/stickers/mixed.webp';
    const expected = '前文![表情]($url "wenyousite-sticker:v1:$assetId")后文';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '前文后文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    session.controller.formatSelection(Attribute.bold);
    expect(
      session.controller.toggledStyle.attributes,
      contains(Attribute.bold.key),
    );

    session.insertSticker(
      selection: session.controller.selection,
      assetId: assetId,
      url: url,
    );
    await tester.pump();

    expect(await session.flush(), isTrue);
    expect(session.codecFailure, isNull);
    expect(emitted.last, expected);
    final stickerOperation = session.controller.document
        .toDelta()
        .operations
        .singleWhere(
          (operation) =>
              operation.data is Map &&
              (operation.data as Map).containsKey(
                MarkdownDeltaCodec.stickerEmbed,
              ),
        );
    expect(stickerOperation.attributes, isNull);

    final reopened = RichEditorSession(
      initialMarkdown: emitted.last,
      onMarkdownChanged: (_) {},
    );
    addTearDown(reopened.dispose);
    expect(
      MarkdownDeltaCodec.encode(reopened.controller.document.toDelta()),
      expected,
    );
  });

  testWidgets('异步表情选择完成后按打开选择器前的选区插入', (tester) async {
    const assetId = 'cm1234567890123456789012';
    const url = 'https://cdn.example.com/stickers/anchored.webp';
    const targetSelection = TextSelection.collapsed(offset: 2);
    const expected = '前文![表情]($url "wenyousite-sticker:v1:$assetId")后文';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '前文后文',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 4),
      ChangeSource.local,
    );

    session.insertSticker(
      selection: targetSelection,
      assetId: assetId,
      url: url,
    );
    await tester.pump();

    expect(await session.flush(), isTrue);
    expect(emitted.last, expected);
    expect(
      session.controller.selection,
      const TextSelection.collapsed(offset: 3),
    );
  });

  testWidgets('粘贴合法站内链接会替换选区为原子传送门', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '替换这段文字',
      onMarkdownChanged: emitted.add,
      readClipboardText: () async =>
          'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd',
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 6),
      ChangeSource.local,
    );
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(
      emitted.last,
      '[替换这段文字](/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd)',
    );
    expect(
      session.controller.document.toDelta().operations.any(
        (operation) =>
            operation.data is Map &&
            (operation.data as Map).containsKey(
              MarkdownDeltaCodec.internalReferenceEmbed,
            ),
      ),
      isTrue,
    );
  });

  testWidgets('普通外部粘贴由会话接管并把不支持结构安全降级', (tester) async {
    const clipboard =
        '| 名称 | 数值 |\r\n'
        '| --- | ---: |\r\n'
        '| 骰子 | 20 |\r\n'
        '<div>正文</div>  ';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
      clipboardStore: WenyouEditorClipboardStore(),
      readClipboardText: () async => clipboard,
    );
    addTearDown(session.dispose);

    expect(await pasteEditorClipboard(session.controller), isTrue);

    const normalized =
        '| 名称 | 数值 |\n'
        '| --- | ---: |\n'
        '| 骰子 | 20 |\n'
        '<div>正文</div>  ';
    expect(session.controller.document.toPlainText(), '$normalized\n');
    final expected = normalized
        .split('\n')
        .map(MarkdownContent.literalizeInlineText)
        .map(MarkdownContent.protectUnsafeWhitespace)
        .join('\n');
    expect(emitted.last, expected);
    expect(MarkdownContent.unsupportedLineIndexes(emitted.last), isEmpty);
  });

  testWidgets('普通外部粘贴没有文本时也不回落到 Quill 默认路径', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '原文',
      onMarkdownChanged: emitted.add,
      readClipboardText: () async => null,
    );
    addTearDown(session.dispose);

    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(session.controller.document.toPlainText(), '原文\n');
    expect(emitted, isEmpty);
  });
}

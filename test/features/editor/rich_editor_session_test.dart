// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_embed_builders.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
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

    expect(await pastedSession.controller.clipboardPaste(), isTrue);
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
    expect(editedSeparator.last, 'A\nX\nB');
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
    expect(await session.controller.clipboardPaste(), isTrue);
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

    expect(await session.controller.clipboardPaste(), isTrue);

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

    expect(await session.controller.clipboardPaste(), isTrue);
    expect(session.controller.document.toPlainText(), '原文\n');
    expect(emitted, isEmpty);
  });

  testWidgets('外部粘贴的受支持 Markdown 也只作为可见普通文本', (tester) async {
    const clipboard =
        '## 标题\n**粗体** [链接](https://example.com)\n---\n'
        '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]';
    final emitted = <String>[];
    final clipboardGateway = _MemoryEditorClipboardGateway()
      ..snapshot = const EditorClipboardSnapshot(text: clipboard);
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);

    expect(session.controller.document.toPlainText(), '$clipboard\n');
    final delta = session.controller.document.toDelta();
    expect(
      delta.operations.where((operation) => operation.data is Map),
      isEmpty,
    );
    expect(
      delta.operations.any(
        (operation) =>
            operation.attributes?[Attribute.header.key] != null ||
            operation.attributes?[Attribute.bold.key] != null,
      ),
      isFalse,
    );
    expect(emitted.last, contains(r'\#\# 标题'));
    expect(emitted.last, contains(r'\*\*粗体\*\*'));
    expect(emitted.last, contains(r'\-\-\-'));
    expect(MarkdownContent.unsupportedLineIndexes(emitted.last), isEmpty);
  });

  testWidgets('手输或 IME 提交的 Markdown 标记在编码出口保持字面文本', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    session.controller.replaceText(
      0,
      0,
      '**粗体**\n---\n# 非法标题',
      const TextSelection.collapsed(offset: 17),
    );

    expect(await session.flush(), isTrue);
    expect(
      emitted.last,
      r'\*\*粗体\*\*'
      '\n'
      r'\-\-\-'
      '\n'
      r'\# 非法标题',
    );
    expect(MarkdownContent.unsupportedLineIndexes(emitted.last), isEmpty);
  });

  testWidgets('逐字输入 Markdown 前缀不会触发 Quill 自动结构或行尾断言', (tester) async {
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);

    const input = '- [ ] 任务';
    for (var index = 0; index < input.length; index++) {
      session.controller.replaceText(
        index,
        0,
        input[index],
        TextSelection.collapsed(offset: index + 1),
      );
    }

    expect(await session.flush(), isTrue);
    expect(emitted.last, r'\- \[ \] 任务');
    expect(
      session.controller.document.toDelta().operations.last.attributes?['list'],
      isNull,
    );
  });

  testWidgets('粘贴序列化后超限时整次拒绝且正文不发生部分写入', (tester) async {
    final emitted = <String>[];
    final clipboardGateway = _MemoryEditorClipboardGateway()
      ..snapshot = const EditorClipboardSnapshot(text: '**********');
    final session = RichEditorSession(
      initialMarkdown: '原文',
      maximumSerializedLength: 10,
      onMarkdownChanged: emitted.add,
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await session.controller.clipboardPaste(), isTrue);

    expect(session.controller.document.toPlainText(), '原文\n');
    expect(emitted, isEmpty);
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.contentTooLong,
    );
  });

  testWidgets('保存会等待在途粘贴并从完成后的当前 Delta 编码', (tester) async {
    final emitted = <String>[];
    final clipboardGateway = _MemoryEditorClipboardGateway()..delayReads();
    final session = RichEditorSession(
      initialMarkdown: '前',
      onMarkdownChanged: emitted.add,
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 1),
      ChangeSource.local,
    );

    final paste = session.controller.clipboardPaste();
    final save = session.flush();
    clipboardGateway.completeRead(const EditorClipboardSnapshot(text: '**后**'));

    expect(await paste, isTrue);
    expect(await save, isTrue);
    expect(emitted.last, r'前\*\*后\*\*');
  });

  testWidgets('读取剪贴板期间正文变化时拒绝把旧选区粘贴到新文档', (tester) async {
    final clipboardGateway = _MemoryEditorClipboardGateway()..delayReads();
    final session = RichEditorSession(
      initialMarkdown: '原文',
      onMarkdownChanged: (_) {},
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    final paste = session.controller.clipboardPaste();
    session.controller.replaceText(
      0,
      0,
      '新',
      const TextSelection.collapsed(offset: 1),
    );
    await tester.pump();
    clipboardGateway.completeRead(const EditorClipboardSnapshot(text: '剪贴板'));

    expect(await paste, isTrue);
    expect(session.controller.document.toPlainText(), '新原文\n');
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.documentChanged,
    );
    expect(await session.flush(), isTrue);
  });

  testWidgets('读取剪贴板期间光标移动时不再使用旧选区', (tester) async {
    final clipboardGateway = _MemoryEditorClipboardGateway()..delayReads();
    final session = RichEditorSession(
      initialMarkdown: '原文',
      onMarkdownChanged: (_) {},
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    final paste = session.controller.clipboardPaste();
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    clipboardGateway.completeRead(const EditorClipboardSnapshot(text: '剪贴板'));

    expect(await paste, isTrue);
    expect(session.controller.document.toPlainText(), '原文\n');
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.documentChanged,
    );
  });

  testWidgets('Quill 原始编辑器粘贴入口立即渲染站内传送门', (tester) async {
    const url =
        'https://wenyou.site/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '前文 后文',
      onMarkdownChanged: emitted.add,
      readClipboardText: () async => url,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection.collapsed(offset: 3),
      ChangeSource.local,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final rawEditor = tester.state<QuillRawEditorState>(
      find.byType(QuillRawEditor),
    );
    await rawEditor.pasteText(SelectionChangedCause.toolbar);
    await tester.pump();

    expect(find.byKey(const Key('editor-internal-reference')), findsOneWidget);
    expect(
      emitted.last,
      '前文 [传送门](/threads/cmsewdo0h000x7qv6aa77ll1v?post=cmsewdqcr001a7qv6cy0y38bd)后文',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android 输入通道直接提交邀请链接时跳过 Quill 自动链接', (tester) async {
    const url = 'https://wenyou.site/join/AbCdEfGh_123-XYZ';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    session.focusNode.requestFocus();
    await tester.pump();

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '$url\n',
        selection: TextSelection.collapsed(offset: url.length),
      ),
    );
    await tester.idle();
    await tester.pump();

    expect(find.byKey(const Key('editor-internal-reference')), findsOneWidget);
    expect(find.text(internalReferenceDefaultLabel), findsOneWidget);
    expect(find.text(url), findsNothing);
    expect(await session.flush(), isTrue);
    expect(emitted.last, '[传送门](/join/AbCdEfGh_123-XYZ)');
    expect(
      session.controller.selection,
      const TextSelection.collapsed(offset: 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android 输入通道的外链和非法邀请不生成站内传送门', (tester) async {
    for (final value in const [
      'https://example.com/join/AbCdEfGh_123-XYZ',
      'https://wenyou.site/join/too-short',
      '入口 https://wenyou.site/join/AbCdEfGh_123-XYZ',
    ]) {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);

      session.controller.replaceText(
        0,
        0,
        value,
        TextSelection.collapsed(offset: value.length),
      );

      expect(
        session.controller.document.toDelta().operations.any(
          (operation) =>
              operation.data is Map &&
              (operation.data as Map).containsKey(
                MarkdownDeltaCodec.internalReferenceEmbed,
              ),
        ),
        isFalse,
        reason: value,
      );
      expect(await session.flush(), isTrue, reason: value);
    }
  });

  testWidgets('历史 URL 自标签在编辑态显示为传送门且保存不改原文', (tester) async {
    const source =
        '[https://wenyou.site/join/AbCdEfGh_123-XYZ]'
        '(/join/AbCdEfGh_123-XYZ)';
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('zh', 'CN'),
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: QuillEditor(
            controller: session.controller,
            focusNode: session.focusNode,
            scrollController: session.scrollController,
            config: QuillEditorConfig(
              scrollable: false,
              embedBuilders: wenyouEditorEmbedBuilders(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(internalReferenceDefaultLabel), findsOneWidget);
    expect(
      find.text('https://wenyou.site/join/AbCdEfGh_123-XYZ'),
      findsNothing,
    );
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      source,
    );
  });

  testWidgets('复制骰子后粘贴会生成新身份并保留其他协议节点', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    const markdown =
        '[@张三](/users/user-zhang) [[dice:v1:$nodeId:2d6+1]] '
        '![表情](https://cdn.example.com/stickers/a.webp '
        '"wenyousite-sticker:v1:cm1234567890123456789012")';
    String? clipboardText;
    final emitted = <String>[];
    final store = WenyouEditorClipboardStore();
    final session = RichEditorSession(
      initialMarkdown: markdown,
      onMarkdownChanged: emitted.add,
      clipboardStore: store,
      readClipboardText: () async => clipboardText,
      writeClipboardText: (text) async => clipboardText = text,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: session.controller.document.length - 1,
      ),
      ChangeSource.local,
    );

    expect(await session.copySelection(), isTrue);
    session.controller.updateSelection(
      TextSelection.collapsed(offset: session.controller.document.length - 1),
      ChangeSource.local,
    );
    expect(await session.controller.clipboardPaste(), isTrue);

    final result = emitted.last;
    final ids = _diceNodeIds(result);
    expect(ids, hasLength(2));
    expect(ids.toSet(), hasLength(2));
    expect(result.split('[@张三](/users/user-zhang)'), hasLength(3));
    expect(result.split('wenyousite-sticker:v1:'), hasLength(3));
  });

  testWidgets('剪切首次粘贴保留身份，再次粘贴改为复制语义', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    String? clipboardText;
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: '[[dice:v1:$nodeId:1d20]]',
      onMarkdownChanged: emitted.add,
      clipboardStore: WenyouEditorClipboardStore(),
      readClipboardText: () async => clipboardText,
      writeClipboardText: (text) async => clipboardText = text,
    );
    addTearDown(session.dispose);
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );

    expect(await session.copySelection(cut: true), isTrue);
    expect(await session.controller.clipboardPaste(), isTrue);
    expect(_diceNodeIds(emitted.last), [nodeId]);

    session.controller.updateSelection(
      TextSelection.collapsed(offset: session.controller.document.length - 1),
      ChangeSource.local,
    );
    expect(await session.controller.clipboardPaste(), isTrue);
    final ids = _diceNodeIds(emitted.last);
    expect(ids, hasLength(2));
    expect(ids.first, nodeId);
    expect(ids.last, isNot(nodeId));
  });

  testWidgets('跨编辑器复制骰子仍生成新身份', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    final store = WenyouEditorClipboardStore();
    final clipboard = _MemoryEditorClipboardGateway();
    final source = RichEditorSession(
      initialMarkdown: '[[dice:v1:$nodeId:1d20]]',
      onMarkdownChanged: (_) {},
      clipboardStore: store,
      clipboardGateway: clipboard,
    );
    final targetOutput = <String>[];
    final target = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: targetOutput.add,
      clipboardStore: store,
      clipboardGateway: clipboard,
    );
    addTearDown(source.dispose);
    addTearDown(target.dispose);
    source.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 1),
      ChangeSource.local,
    );

    expect(await source.copySelection(), isTrue);
    expect(await target.controller.clipboardPaste(), isTrue);
    final pastedId = _diceNodeIds(targetOutput.last).single;
    expect(pastedId, isNot(nodeId));
  });

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
    expect(await session.controller.clipboardPaste(), isTrue);
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

List<String> _diceNodeIds(String markdown) => RegExp(
  r'\[\[dice:v1:([0-9a-f-]{36}):',
).allMatches(markdown).map((match) => match.group(1)!).toList();

class _MemoryEditorClipboardGateway implements EditorClipboardGateway {
  EditorClipboardSnapshot snapshot = const EditorClipboardSnapshot(text: null);
  Completer<EditorClipboardSnapshot>? _pendingRead;

  void delayReads() {
    _pendingRead = Completer<EditorClipboardSnapshot>();
  }

  void completeRead(EditorClipboardSnapshot value) {
    _pendingRead!.complete(value);
  }

  @override
  Future<EditorClipboardSnapshot> read() async =>
      _pendingRead?.future ?? snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}

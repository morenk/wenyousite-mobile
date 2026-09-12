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
import 'rich_editor_session_test_support.dart';

void registerRichEditorSessionClipboardInputCases() {
  testWidgets('外部粘贴的受支持 Markdown 也只作为可见普通文本', (tester) async {
    const clipboard =
        '## 标题\n**粗体** [链接](https://example.com)\n---\n'
        '[[dice:v1:550e8400-e29b-41d4-a716-446655440000:1d20]]';
    final emitted = <String>[];
    final clipboardGateway = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..snapshot = const EditorClipboardSnapshot(text: clipboard);
    final session = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: emitted.add,
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await pasteEditorClipboard(session.controller), isTrue);

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
    final clipboardGateway = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..snapshot = const EditorClipboardSnapshot(text: '**********');
    final session = RichEditorSession(
      initialMarkdown: '原文',
      maximumSerializedLength: 10,
      onMarkdownChanged: emitted.add,
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    expect(await pasteEditorClipboard(session.controller), isTrue);

    expect(session.controller.document.toPlainText(), '原文\n');
    expect(emitted, isEmpty);
    expect(
      session.operationFailure?.kind,
      RichEditorOperationFailureKind.contentTooLong,
    );
  });

  testWidgets('保存会等待在途粘贴并从完成后的当前 Delta 编码', (tester) async {
    final emitted = <String>[];
    final clipboardGateway = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..delayReads();
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

    final paste = pasteEditorClipboard(session.controller);
    final save = session.flush();
    clipboardGateway.completeRead(const EditorClipboardSnapshot(text: '**后**'));

    expect(await paste, isTrue);
    expect(await save, isTrue);
    expect(emitted.last, r'前\*\*后\*\*');
  });

  testWidgets('读取剪贴板期间正文变化时拒绝把旧选区粘贴到新文档', (tester) async {
    final clipboardGateway = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..delayReads();
    final session = RichEditorSession(
      initialMarkdown: '原文',
      onMarkdownChanged: (_) {},
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    final paste = pasteEditorClipboard(session.controller);
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
    final clipboardGateway = RichEditorSessionTestMemoryEditorClipboardGateway()
      ..delayReads();
    final session = RichEditorSession(
      initialMarkdown: '原文',
      onMarkdownChanged: (_) {},
      clipboardGateway: clipboardGateway,
      clipboardStore: WenyouEditorClipboardStore(),
    );
    addTearDown(session.dispose);

    final paste = pasteEditorClipboard(session.controller);
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
    expect(await pasteEditorClipboard(session.controller), isTrue);

    final result = emitted.last;
    final ids = richEditorSessionTestDiceNodeIds(result);
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
    expect(await pasteEditorClipboard(session.controller), isTrue);
    expect(richEditorSessionTestDiceNodeIds(emitted.last), [nodeId]);

    session.controller.updateSelection(
      TextSelection.collapsed(offset: session.controller.document.length - 1),
      ChangeSource.local,
    );
    expect(await pasteEditorClipboard(session.controller), isTrue);
    final ids = richEditorSessionTestDiceNodeIds(emitted.last);
    expect(ids, hasLength(2));
    expect(ids.first, nodeId);
    expect(ids.last, isNot(nodeId));
  });

  testWidgets('跨编辑器复制骰子仍生成新身份', (tester) async {
    const nodeId = '550e8400-e29b-41d4-a716-446655440000';
    final store = WenyouEditorClipboardStore();
    final clipboard = RichEditorSessionTestMemoryEditorClipboardGateway();
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
    expect(await pasteEditorClipboard(target.controller), isTrue);
    final pastedId = richEditorSessionTestDiceNodeIds(targetOutput.last).single;
    expect(pastedId, isNot(nodeId));
  });
}

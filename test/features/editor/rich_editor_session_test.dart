// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
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

    expect(session.flush(), isTrue);
    expect(emitted, ['温油']);
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
      assetId: 'cm12345678901234567890',
      url: 'https://cdn.example.com/sticker.png',
    );
    expect(emitted.last, contains('wenyousite-sticker:v1:'));
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
    String? clipboardText;
    final store = WenyouEditorClipboardStore();
    final source = RichEditorSession(
      initialMarkdown: '[[dice:v1:$nodeId:1d20]]',
      onMarkdownChanged: (_) {},
      clipboardStore: store,
      readClipboardText: () async => clipboardText,
      writeClipboardText: (text) async => clipboardText = text,
    );
    final targetOutput = <String>[];
    final target = RichEditorSession(
      initialMarkdown: '',
      onMarkdownChanged: targetOutput.add,
      clipboardStore: store,
      readClipboardText: () async => clipboardText,
      writeClipboardText: (text) async => clipboardText = text,
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
    expect(clipboardText, markdown);
    expect(await session.copySelection(cut: true), isFalse);
    session.controller.updateSelection(
      TextSelection.collapsed(offset: session.controller.document.length - 1),
      ChangeSource.local,
    );
    expect(await session.controller.clipboardPaste(), isTrue);
    expect(session.flush(), isTrue);
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

    await expectLater(session.copySelection(), throwsStateError);
    expect(session.flush(), isTrue);
    final resolution = store.resolve(markdown);
    expect(resolution.delta, isNull);
    expect(resolution.usePlainText, isFalse);
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      markdown,
    );
    expect(emitted, isEmpty);
  });
}

List<String> _diceNodeIds(String markdown) => RegExp(
  r'\[\[dice:v1:([0-9a-f-]{36}):',
).allMatches(markdown).map((match) => match.group(1)!).toList();

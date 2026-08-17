// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
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
}

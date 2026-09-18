import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/app/app_theme.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_inline_text_elements.dart';
import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_styles.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_toolbar.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/deterministic_test_fonts.dart';
import 'thread_compose_page_test_support.dart';

void main() {
  setUpAll(loadDeterministicTestFonts);
  test('站内阅读和编辑剪贴板保留代码外侧全部行内格式', () {
    for (final source in ['reader', 'editor']) {
      for (final content in [
        '<strong><em><del><a href="https://example.com/a"><code>正文*</code></a></del></em></strong>',
        '<code><strong><em><del><a href="https://example.com/a">正文*</a></del></em></strong></code>',
      ]) {
        final delta = const WenyouSiteClipboardParser().parse(
          '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="$source"><p>$content</p></div>',
        );
        expect(delta, isNotNull);
        final text = delta!.operations.first;
        expect(text.data, '正文*');
        for (final mark in ['code', 'bold', 'italic', 'strike']) {
          expect(text.attributes?[mark], true);
        }
        expect(text.attributes?['link'], 'https://example.com/a');
        expect(MarkdownDeltaCodec.encode(delta), contains('`正文*`'));
      }
    }
  });
  for (final mark in ['bold', 'italic', 'strike']) {
    for (final selection in [
      const TextSelection(baseOffset: 0, extentOffset: 4),
      const TextSelection(baseOffset: 3, extentOffset: 1),
      const TextSelection(baseOffset: 7, extentOffset: 2),
    ]) {
      testWidgets('长按后 $mark 保留代码、选区、取消及撤销 $selection', (tester) async {
        final session = RichEditorSession(
          initialMarkdown: '`code` xyz',
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);
        await _pump(tester, session);
        final raw = tester.state<QuillRawEditorState>(
          find.byType(QuillRawEditor),
        );
        await tester.longPressAt(
          raw.renderEditor.localToGlobal(
            raw.renderEditor
                .getLocalRectForCaret(const TextPosition(offset: 2))
                .center,
          ),
        );
        await tester.pumpAndSettle();
        expect(session.controller.selection.isCollapsed, isFalse);
        if (selection.start == 0 && selection.end == 4) {
          expect(session.controller.selection, selection);
        } else {
          session.controller.updateSelection(selection, ChangeSource.local);
        }
        raw.hideToolbar();
        final original = session.controller.document.toDelta().toJson();
        session.controller.document.history.clear();
        if (mark == 'strike') {
          await tester.tap(find.byKey(const Key('editor-more')));
          await tester.pumpAndSettle();
        }
        await tester.tap(
          mark == 'strike'
              ? find.byTooltip('删除线')
              : find.byKey(Key('editor-$mark')),
        );
        await tester.pumpAndSettle();
        expect(session.controller.selection, selection);
        expect(session.controller.document.toPlainText(), 'code xyz\n');
        for (var offset = 0; offset < 8; offset++) {
          final attrs = session.controller.document
              .collectStyle(offset, 1)
              .attributes;
          expect(attrs['code']?.value, offset < 4 ? true : null);
          expect(
            attrs[mark]?.value,
            offset >= selection.start && offset < selection.end ? true : null,
          );
        }
        expect(await session.flush(), isTrue);
        final formatted = session.controller.document.toDelta().toJson();
        session.controller.undo();
        expect(session.controller.document.toDelta().toJson(), original);
        expect(session.controller.selection, selection);
        session.controller.redo();
        expect(session.controller.document.toDelta().toJson(), formatted);
        expect(session.controller.selection, selection);
        await tester.tap(
          mark == 'strike'
              ? find.byTooltip('删除线')
              : find.byKey(Key('editor-$mark')),
        );
        await tester.pumpAndSettle();
        expect(session.controller.document.toDelta().toJson(), original);
        expect(await session.flush(), isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('主题真实页面格式、输入、落盘重开及发布保留 code+italic', (tester) async {
    final store = ThreadComposePageTestMemorySnapshotStore();
    final repository = ThreadComposePageTestFakeRepository();
    final controller =
        await threadComposePageTestReadyController(
            store,
            repository: repository,
          )
          ..updateTitle('组合格式回归')
          ..updateCategory('TRPG')
          ..updateBody('`culti`');
    await threadComposePageTestPumpPage(
      tester,
      controller,
      withThreadRoute: true,
    );
    final editor = tester.widget<QuillEditor>(
      find.byKey(const Key('compose-body')),
    );
    editor.controller.updateSelection(
      const TextSelection(baseOffset: 5, extentOffset: 0),
      ChangeSource.local,
    );
    await tester.tap(find.byKey(const Key('editor-italic')));
    await tester.pumpAndSettle();
    editor.controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    editor.controller.replaceText(
      2,
      0,
      '新',
      const TextSelection.collapsed(offset: 3),
    );
    await tester.pump(const Duration(seconds: 1));
    await controller.flushLocalSnapshot();
    final saved = store.snapshot!.body;
    expect(
      MarkdownDeltaCodec.decode(saved).delta.operations.first.data,
      'cu新lti',
    );
    final marks = MarkdownDeltaCodec.decode(
      saved,
    ).delta.operations.first.attributes!;
    expect(marks['code'], isTrue);
    expect(marks['italic'], isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    final reopened = await threadComposePageTestReadyController(
      store,
      repository: repository,
    );
    await threadComposePageTestPumpPage(
      tester,
      reopened,
      withThreadRoute: true,
    );
    final restored = tester
        .widget<QuillEditor>(find.byKey(const Key('compose-body')))
        .controller;
    expect(restored.document.toPlainText(), 'cu新lti\n');
    expect(
      restored.document.collectStyle(0, 6).attributes['italic']?.value,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('compose-publish')));
    await tester.pumpAndSettle();
    expect(repository.savedBody, saved);
    expect(tester.takeException(), isNull);
  });

  testWidgets('物理快捷键维持既有禁用规则，不产生隐藏格式', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '`code`',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    await _pump(tester, session);
    session.focusNode.requestFocus();
    await tester.pump();
    session.controller.updateSelection(
      const TextSelection(baseOffset: 0, extentOffset: 4),
      ChangeSource.local,
    );
    for (final key in [
      LogicalKeyboardKey.keyB,
      LogicalKeyboardKey.keyI,
      LogicalKeyboardKey.keyU,
    ]) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(key);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }
    expect(
      MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
      '`code`',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('发布阅读中的行内代码保留粗体斜体删除线', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: WenyouMarkdown(data: '***~~`culti`~~***')),
      ),
    );
    final surface = find.byType(WenyouInlineCodeSurface);
    expect(surface, findsOneWidget);
    final text = tester.widget<Text>(
      find.descendant(of: surface, matching: find.byType(Text)),
    );
    expect(text.data, 'culti');
    expect(text.style!.fontWeight, FontWeight.w700);
    expect(text.style!.fontStyle, FontStyle.italic);
    expect(
      text.style!.decoration!.contains(TextDecoration.lineThrough),
      isTrue,
    );
  });

  testWidgets('编辑器实际文字保留代码粗体斜体删除线', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '***~~`culti`~~***',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    await _pump(tester, session);
    final styles = <TextStyle>[];
    void visit(InlineSpan span, TextStyle inherited) {
      if (span is! TextSpan) return;
      final style = inherited.merge(span.style);
      if (span.text == 'culti') styles.add(style);
      for (final child in span.children ?? <InlineSpan>[]) {
        visit(child, style);
      }
    }

    for (final rich in tester.widgetList<RichText>(
      find.descendant(
        of: find.byType(QuillEditor),
        matching: find.byType(RichText),
      ),
    )) {
      visit(rich.text, const TextStyle());
    }
    expect(styles, hasLength(1));
    expect(styles.single.fontWeight, FontWeight.bold);
    expect(styles.single.fontStyle, FontStyle.italic);
    expect(
      styles.single.decoration!.contains(TextDecoration.lineThrough),
      true,
    );
    expect(styles.single.fontFamily, 'monospace');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pump(WidgetTester tester, RichEditorSession session) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates:
            FlutterQuillLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                Expanded(
                  child: QuillEditor(
                    controller: session.controller,
                    focusNode: session.focusNode,
                    scrollController: session.scrollController,
                    config: QuillEditorConfig(
                      customStyles: wenyouEditorTextStyles(context),
                      contextMenuBuilder: session.buildContextMenu,
                      customShortcuts: session.clipboardShortcuts,
                      customActions: session.clipboardActions,
                    ),
                  ),
                ),
                WenyouEditorToolbar(
                  controller: session.controller,
                  enabled: true,
                  editorFocusNode: session.focusNode,
                  onSaveDraft: () async {},
                  onInsertImage: () async {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

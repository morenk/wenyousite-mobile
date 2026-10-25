import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_site_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

import '../../support/editor_test_paste.dart';
import '../../support/text_color_assertions.dart';

class _Gateway implements EditorClipboardGateway {
  _Gateway(this.snapshot);
  final EditorClipboardSnapshot snapshot;
  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;
  @override
  Future<void> write({required String text, required String marker}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final internal in [false, true]) {
    for (final font in ['xiaocheng-lafeng', 'wenkai']) {
      test('新主题粘贴${internal ? '内部Delta' : '站内HTML'}：$font', () async {
        final store = WenyouEditorClipboardStore();
        if (internal) {
          store.capture(
            delta: MarkdownDeltaCodec.decode(
              '<span data-wenyou-font-v1="$font" data-wenyou-color-v1="#D14343">**来源**</span>',
            ).delta.slice(0, 2),
            plainTextFallback: '来源',
            operation: WenyouEditorClipboardOperation.copy,
            marker: 'new-theme',
          );
        }
        final session = RichEditorSession(
          initialMarkdown: '',
          onMarkdownChanged: (_) {},
          clipboardStore: store,
          clipboardGateway: _Gateway(
            EditorClipboardSnapshot(
              text: '来源',
              marker: internal ? 'new-theme' : null,
              html: internal
                  ? null
                  : '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
                        '<span data-wenyou-font-v1="$font" data-wenyou-color-v1="#D14343"><strong>来源</strong></span></div>',
            ),
          ),
        );
        addTearDown(session.dispose);
        await pasteEditorClipboard(session.controller);
        expect(session.controller.document.toPlainText(), '来源\n');
        final expected = colorExpectedUnits([
          (
            '来源',
            {
              if (font == 'wenkai') 'font': 'wenkai',
              'color': '#D14343',
              'bold': true,
            },
          ),
        ]);
        expect(
          colorDeltaUnits(session.controller.document.toDelta()).take(2),
          expected,
        );
        expect(await session.flush(), isTrue);
        final saved = session.localMarkdown;
        expect(saved.contains('xiaocheng-lafeng'), isFalse);
        expect(colorReaderUnits(colorReaderNodes(saved)).take(2), expected);
        final reopened = RichEditorSession(
          initialMarkdown: saved,
          onMarkdownChanged: (_) {},
        );
        addTearDown(reopened.dispose);
        expect(
          colorDeltaUnits(reopened.controller.document.toDelta()).take(2),
          expected,
        );
        session.controller.undo();
        expect(session.controller.document.toPlainText(), '\n');
      });
    }
  }
  for (final font in <String?>[
    null,
    'future-font',
    'xiaocheng-lafeng',
    'zhuque',
  ]) {
    test('跨字体边界替换和撤销只影响插入范围，来源 $font', () async {
      final session = RichEditorSession(
        initialMarkdown: '<span data-wenyou-font-v1="wenkai">甲乙</span>丙',
        onMarkdownChanged: (_) {},
        clipboardGateway: _Gateway(
          EditorClipboardSnapshot(
            text: '来源',
            html: font == null
                ? null
                : '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
                      '<span data-wenyou-font-v1="$font" data-wenyou-color-v1="#D14343"><strong>来源</strong></span></div>',
          ),
        ),
        clipboardStore: WenyouEditorClipboardStore(),
      );
      addTearDown(session.dispose);
      final before = session.controller.document.toDelta();
      session.controller.updateSelection(
        const TextSelection(baseOffset: 1, extentOffset: 3),
        ChangeSource.local,
      );
      session.controller.document.history.clear();
      await pasteEditorClipboard(session.controller);
      expect(session.controller.document.toPlainText(), '甲来源\n');
      final marks = session.controller.document.collectStyle(1, 2).attributes;
      expect(marks['font']?.value, font == 'zhuque' ? 'zhuque' : null);
      if (font != null) {
        expect(marks['color']?.value, '#D14343');
        expect(marks['bold']?.value, true);
      }
      expect(
        session.controller.document
            .collectStyle(0, 1)
            .attributes['font']
            ?.value,
        'wenkai',
      );
      session.controller.undo();
      expect(session.controller.document.toDelta(), before);
    });
  }
  for (final font in ['xiaocheng-lafeng', 'wenkai']) {
    test('内部Delta粘贴去退役字体、保留格式与原帖历史范围：$font', () async {
      final store = WenyouEditorClipboardStore();
      final source = MarkdownDeltaCodec.decode(
        '<span data-wenyou-font-v1="$font" data-wenyou-color-v1="#D14343">**来源**</span>',
      ).delta.slice(0, 2);
      expect(source.operations.first.attributes?['font'], font);
      store.capture(
        delta: source,
        plainTextFallback: '来源',
        operation: WenyouEditorClipboardOperation.copy,
        marker: 'font-marker',
        scope: 'account',
      );
      const original = '<span data-wenyou-font-v1="xiaocheng-lafeng">甲乙</span>';
      final session = RichEditorSession(
        initialMarkdown: original,
        onMarkdownChanged: (_) {},
        clipboardScope: 'account',
        clipboardStore: store,
        clipboardGateway: _Gateway(
          const EditorClipboardSnapshot(text: '来源', marker: 'font-marker'),
        ),
      );
      addTearDown(session.dispose);
      final before = session.controller.document.toDelta();
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      session.controller.formatSelection(
        Attribute.clone(Attribute.font, 'xiaocheng-lafeng'),
      );
      session.controller.document.history.clear();
      await pasteEditorClipboard(session.controller);
      expect(session.controller.document.toPlainText(), '甲来源乙\n');
      for (final offset in [1, 2]) {
        final inserted = session.controller.document
            .collectStyle(offset, 1)
            .attributes;
        expect(inserted['font']?.value, font == 'wenkai' ? font : null);
        expect(inserted['color']?.value, '#D14343');
        expect(inserted['bold']?.value, true);
      }
      for (final offset in [0, 3]) {
        expect(
          session.controller.document
              .collectStyle(offset, 1)
              .attributes['font']
              ?.value,
          'xiaocheng-lafeng',
        );
      }
      expect(await session.flush(), isTrue);
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        reopened.controller.document.toDelta(),
        session.controller.document.toDelta(),
      );
      session.controller.undo();
      expect(session.controller.document.toDelta(), before);
      expect(await session.flush(), isTrue);
      expect(session.localMarkdown, original);
    });
  }
  test('未知字体只丢字体，合法颜色和其他样式保留', () {
    final delta = const WenyouSiteClipboardParser().parse(
      '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
      '<p><span data-wenyou-font-v1="future-font" data-wenyou-color-v1="#D14343">'
      '<strong>原文</strong></span></p></div>',
    );
    expect(delta, isNotNull);
    expect(
      colorDeltaUnits(delta!),
      colorExpectedUnits([
        ('原文', {'bold': true, 'color': '#D14343'}),
      ]),
    );
  });
  for (final html in <String?>[
    null,
    '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
        '<span style="font-family:external;src:url(https://example.com/font.ttf)">来源</span></div>',
    '<div data-wenyou-clipboard="2" data-wenyou-clipboard-source="editor">'
        '<span data-wenyou-font-v1="future-font">来源</span></div>',
  ]) {
    test('带字体光标粘贴默认字体：${html ?? '纯文本'}', () async {
      final session = RichEditorSession(
        initialMarkdown: '<span data-wenyou-font-v1="wenkai">甲乙</span>',
        onMarkdownChanged: (_) {},
        clipboardGateway: _Gateway(
          EditorClipboardSnapshot(text: '来源', html: html),
        ),
        clipboardStore: WenyouEditorClipboardStore(),
      );
      addTearDown(session.dispose);
      session.controller.updateSelection(
        const TextSelection.collapsed(offset: 1),
        ChangeSource.local,
      );
      session.controller.formatSelection(
        Attribute.clone(Attribute.font, 'wenkai'),
      );
      await pasteEditorClipboard(session.controller);
      expect(session.controller.document.toPlainText(), '甲来源乙\n');
      expect(
        session.controller.document
            .collectStyle(1, 2)
            .attributes['font']
            ?.value,
        isNull,
      );
      expect(
        session.controller.document
            .collectStyle(0, 1)
            .attributes['font']
            ?.value,
        'wenkai',
      );
      expect(
        session.controller.document
            .collectStyle(3, 1)
            .attributes['font']
            ?.value,
        'wenkai',
      );
      expect(await session.flush(), isTrue);
    });
  }
}

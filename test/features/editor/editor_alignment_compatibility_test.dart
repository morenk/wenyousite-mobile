// ignore_for_file: experimental_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/network/session_controller.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_clipboard_gateway.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  group('编辑格式操作兼容性', () {
    test('直接设置对齐可单步撤销、重做并在保存重开后保持', () {
      final controller = QuillController(
        document: Document.fromDelta(
          MarkdownDeltaCodec.decode(
            '[wenyousite-align-v1-center]: #\n正文',
          ).delta,
        ),
        selection: const TextSelection(baseOffset: 0, extentOffset: 2),
      );
      addTearDown(controller.dispose);

      WenyouEditorFormatPolicy.applyAlignment(
        controller,
        WenyouTextAlignment.right,
      );
      expect(controller.hasUndo, isTrue);
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        '[wenyousite-align-v1-right]: #\n正文',
      );

      controller.undo();
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        '[wenyousite-align-v1-center]: #\n正文',
      );
      controller.redo();
      final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
      expect(saved, '[wenyousite-align-v1-right]: #\n正文');

      final reopened = QuillController(
        document: Document.fromDelta(MarkdownDeltaCodec.decode(saved).delta),
        selection: const TextSelection.collapsed(offset: 1),
      );
      addTearDown(reopened.dispose);
      expect(
        WenyouEditorFormatPolicy.alignmentSelection(reopened).alignment,
        WenyouTextAlignment.right,
      );
    });

    test('正文与 H2/H3 互转保持对齐，转为列表或引用时清除', () {
      for (final target in [2, 3, 0]) {
        final controller = _alignedController('right');
        addTearDown(controller.dispose);

        WenyouEditorFormatPolicy.applyHeading(controller, target);
        expect(
          WenyouEditorFormatPolicy.alignmentSelection(controller).alignment,
          WenyouTextAlignment.right,
        );
        expect(
          MarkdownDeltaCodec.encode(controller.document.toDelta()),
          contains('[wenyousite-align-v1-right]: #'),
        );
      }

      for (final Attribute attribute in [
        Attribute.ul,
        Attribute.ol,
        Attribute.blockQuote,
      ]) {
        final controller = _alignedController('center');
        addTearDown(controller.dispose);

        WenyouEditorFormatPolicy.toggle(controller, attribute);
        expect(
          WenyouEditorFormatPolicy.alignmentSelection(controller).canApply,
          isFalse,
        );
        expect(
          MarkdownDeltaCodec.encode(controller.document.toDelta()),
          isNot(contains('wenyousite-align')),
        );
      }
    });

    for (final alignment in const ['center', 'right']) {
      testWidgets('$alignment 段落中回车后两个物理行保持同方向', (tester) async {
        final session = RichEditorSession(
          initialMarkdown: '[wenyousite-align-v1-$alignment]: #\n正文',
          onMarkdownChanged: (_) {},
        );
        addTearDown(session.dispose);

        session.controller.replaceText(
          1,
          0,
          '\n',
          const TextSelection.collapsed(offset: 2),
        );
        await tester.pump();

        expect(await session.flush(), isTrue);
        expect(
          MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
          '[wenyousite-align-v1-$alignment]: #\n正\n文',
        );
      });
    }

    testWidgets('居中段尾回车并继续输入不会把原段清回左对齐', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);

      session.controller.replaceText(
        0,
        0,
        '第一行',
        const TextSelection.collapsed(offset: 3),
      );
      WenyouEditorFormatPolicy.applyAlignment(
        session.controller,
        WenyouTextAlignment.center,
      );
      session.controller.replaceText(
        3,
        0,
        '\n',
        const TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      expect(
        WenyouEditorFormatPolicy.alignmentSelection(
          session.controller,
        ).alignment,
        WenyouTextAlignment.center,
      );
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '[wenyousite-align-v1-center]: #\n第一行\n<br />',
      );
      session.controller.replaceText(
        4,
        0,
        '第二行',
        const TextSelection.collapsed(offset: 7),
      );
      await tester.pump();

      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '[wenyousite-align-v1-center]: #\n第一行\n第二行',
      );
    });

    testWidgets('居中段尾回车后立即输入也保持整个段落方向', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);

      session.controller.replaceText(
        0,
        0,
        '第一行',
        const TextSelection.collapsed(offset: 3),
      );
      WenyouEditorFormatPolicy.applyAlignment(
        session.controller,
        WenyouTextAlignment.center,
      );
      session.controller.replaceText(
        3,
        0,
        '\n',
        const TextSelection.collapsed(offset: 4),
      );
      session.controller.replaceText(
        4,
        0,
        '第二行',
        const TextSelection.collapsed(offset: 7),
      );
      await tester.pump();

      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '[wenyousite-align-v1-center]: #\n第一行\n第二行',
      );
    });

    testWidgets('居中空行再次回车时光标与后续输入保持同一方向', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);

      session.controller.replaceText(
        0,
        0,
        '第一行',
        const TextSelection.collapsed(offset: 3),
      );
      WenyouEditorFormatPolicy.applyAlignment(
        session.controller,
        WenyouTextAlignment.center,
      );
      session.controller.replaceText(
        3,
        0,
        '\n',
        const TextSelection.collapsed(offset: 4),
      );
      await tester.pump();
      session.controller.replaceText(
        4,
        0,
        '\n',
        const TextSelection.collapsed(offset: 5),
      );
      await tester.pump();

      expect(
        WenyouEditorFormatPolicy.alignmentSelection(
          session.controller,
        ).alignment,
        isNull,
      );

      final typingOffset = session.controller.selection.extentOffset;
      session.controller.replaceText(
        typingOffset,
        0,
        '第三行',
        TextSelection.collapsed(offset: typingOffset + 3),
      );
      await tester.pump();
      expect(
        WenyouEditorFormatPolicy.alignmentSelection(
          session.controller,
        ).alignment,
        WenyouTextAlignment.left,
      );
      expect(await session.flush(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
        '[wenyousite-align-v1-center]: #\n第一行\n<br />\n第三行',
      );
    });
  });

  group('移动编辑器结构复制保持块对齐', () {
    testWidgets('v5 独立图片块复制粘贴保留对齐', (tester) async {
      const markdown =
          '[wenyousite-align-v1-center]: #\n'
          '![图片](https://cdn.example.com/image.webp)';
      final gateway = _MemoryClipboardGateway();
      final store = WenyouEditorClipboardStore();
      const scope = SessionScope(accountId: 'account', generation: 5);
      final source = RichEditorSession(
        initialMarkdown: markdown,
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
        imageAlignment: true,
      );
      addTearDown(source.dispose);
      source.controller.updateSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: source.controller.document.length - 1,
        ),
        ChangeSource.local,
      );

      expect(await source.copySelection(), isTrue);
      expect(gateway.snapshot.text, '[图片]');

      final target = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
        imageAlignment: true,
      );
      addTearDown(target.dispose);
      expect(await target.controller.clipboardPaste(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(
          target.controller.document.toDelta(),
          imageAlignment: true,
        ),
        markdown,
      );
    });

    for (final alignment in const ['center', 'right']) {
      testWidgets('$alignment 单段全选复制粘贴保留终止换行属性', (tester) async {
        final gateway = _MemoryClipboardGateway();
        final store = WenyouEditorClipboardStore();
        const scope = SessionScope(accountId: 'account', generation: 1);
        final markdown = '[wenyousite-align-v1-$alignment]: #\n正文';
        final source = RichEditorSession(
          initialMarkdown: markdown,
          onMarkdownChanged: (_) {},
          clipboardScope: scope,
          clipboardGateway: gateway,
          clipboardStore: store,
        );
        addTearDown(source.dispose);
        source.controller.updateSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: source.controller.document.length - 1,
          ),
          ChangeSource.local,
        );

        expect(await source.copySelection(), isTrue);
        expect(gateway.snapshot.text, '正文');
        expect(gateway.snapshot.text, isNot(contains('wenyousite-align')));

        final target = RichEditorSession(
          initialMarkdown: '',
          onMarkdownChanged: (_) {},
          clipboardScope: scope,
          clipboardGateway: gateway,
          clipboardStore: store,
        );
        addTearDown(target.dispose);
        expect(await target.controller.clipboardPaste(), isTrue);
        expect(
          MarkdownDeltaCodec.encode(target.controller.document.toDelta()),
          markdown,
        );
      });
    }

    testWidgets('多段全选复制不会丢最后一段居右属性', (tester) async {
      const markdown =
          '[wenyousite-align-v1-center]: #\n第一段\n\n'
          '[wenyousite-align-v1-right]: #\n第二段';
      final gateway = _MemoryClipboardGateway();
      final store = WenyouEditorClipboardStore();
      const scope = SessionScope(accountId: 'account', generation: 2);
      final source = RichEditorSession(
        initialMarkdown: markdown,
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
      );
      addTearDown(source.dispose);
      source.controller.updateSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: source.controller.document.length - 1,
        ),
        ChangeSource.local,
      );
      expect(await source.copySelection(), isTrue);

      final target = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
      );
      addTearDown(target.dispose);
      expect(await target.controller.clipboardPaste(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(target.controller.document.toDelta()),
        markdown,
      );
    });

    testWidgets('整段剪切首次粘贴同样保留居中属性', (tester) async {
      const markdown = '[wenyousite-align-v1-center]: #\n正文';
      final gateway = _MemoryClipboardGateway();
      final store = WenyouEditorClipboardStore();
      const scope = SessionScope(accountId: 'account', generation: 3);
      final source = RichEditorSession(
        initialMarkdown: markdown,
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
      );
      addTearDown(source.dispose);
      source.controller.updateSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: source.controller.document.length - 1,
        ),
        ChangeSource.local,
      );
      expect(await source.copySelection(cut: true), isTrue);

      final target = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: (_) {},
        clipboardScope: scope,
        clipboardGateway: gateway,
        clipboardStore: store,
      );
      addTearDown(target.dispose);
      expect(await target.controller.clipboardPaste(), isTrue);
      expect(
        MarkdownDeltaCodec.encode(target.controller.document.toDelta()),
        markdown,
      );
    });
  });

  group('在对齐段落中粘贴结构块', () {
    for (final alignment in const ['center', 'right']) {
      for (final position in const [0, 1, 2]) {
        testWidgets('$alignment 段落位置 $position 粘贴 H2 后两侧残段不丢方向', (
          tester,
        ) async {
          final gateway = _MemoryClipboardGateway(
            const EditorClipboardSnapshot(
              text: '标题',
              html:
                  '<div data-wenyou-clipboard="2" '
                  'data-wenyou-clipboard-source="editor">'
                  '<h2>标题</h2></div>',
            ),
          );
          final session = RichEditorSession(
            initialMarkdown: '[wenyousite-align-v1-$alignment]: #\n正文',
            onMarkdownChanged: (_) {},
            clipboardGateway: gateway,
            clipboardStore: WenyouEditorClipboardStore(),
          );
          addTearDown(session.dispose);
          session.controller.updateSelection(
            TextSelection.collapsed(offset: position),
            ChangeSource.local,
          );

          expect(await session.controller.clipboardPaste(), isTrue);
          final marker = '[wenyousite-align-v1-$alignment]: #';
          final expected = switch (position) {
            0 => '## 标题\n\n$marker\n正文',
            1 => '$marker\n正\n\n## 标题\n\n$marker\n文',
            _ => '$marker\n正文\n\n## 标题',
          };
          expect(
            MarkdownDeltaCodec.encode(session.controller.document.toDelta()),
            expected,
          );
        });
      }
    }
  });
}

QuillController _alignedController(String alignment) => QuillController(
  document: Document.fromDelta(
    MarkdownDeltaCodec.decode('[wenyousite-align-v1-$alignment]: #\n正文').delta,
  ),
  selection: const TextSelection(baseOffset: 0, extentOffset: 2),
);

class _MemoryClipboardGateway implements EditorClipboardGateway {
  _MemoryClipboardGateway([
    this.snapshot = const EditorClipboardSnapshot(text: null),
  ]);

  EditorClipboardSnapshot snapshot;

  @override
  Future<EditorClipboardSnapshot> read() async => snapshot;

  @override
  Future<void> write({required String text, required String marker}) async {
    snapshot = EditorClipboardSnapshot(text: text, marker: marker);
  }
}

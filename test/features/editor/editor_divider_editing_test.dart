import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_quote_paragraphs.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_divider_structure.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_format_policy.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  for (final edit in [
    'type-after',
    'delete-before',
    'delete-after',
    'heading',
  ]) {
    testWidgets('分隔线边界编辑 $edit 保持可保存块', (tester) async {
      final session = RichEditorSession(
        initialMarkdown: '前文\n\n---\n\n后文',
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      final controller = session.controller;
      expect(controller.document.toPlainText(), '前文\n\n\uFFFC\n\n后文\n');
      switch (edit) {
        case 'type-after':
          controller.replaceText(
            5,
            0,
            '新',
            const TextSelection.collapsed(offset: 6),
          );
        case 'delete-before':
          controller.replaceText(
            2,
            2,
            '',
            const TextSelection.collapsed(offset: 2),
          );
        case 'delete-after':
          controller.replaceText(
            5,
            2,
            '',
            const TextSelection.collapsed(offset: 5),
          );
        case 'heading':
          controller.updateSelection(
            const TextSelection(baseOffset: 0, extentOffset: 9),
            ChangeSource.local,
          );
          WenyouEditorFormatPolicy.applyHeading(controller, 2);
      }
      await tester.pump();
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
      if (edit != 'heading') {
        expect(
          saved,
          edit == 'type-after' ? '前文\n\n---\n\n新\n\n后文' : '前文\n\n---\n\n后文',
        );
      }
      final reopened = RichEditorSession(
        initialMarkdown: saved,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(
        reopened.controller.document.toPlainText().replaceAll('\n', ''),
        edit == 'type-after' ? '前文\uFFFC新后文' : '前文\uFFFC后文',
      );
      final dividerOffset = reopened.controller.document.toPlainText().indexOf(
        '\uFFFC',
      );
      final dividerLine =
          reopened.controller.document.queryChild(dividerOffset).node! as Line;
      expect(dividerLine.toPlainText(), '\uFFFC\n');
      expect(
        dividerLine.style.attributes.keys.where(
          const {'header', 'list', 'blockquote', 'align'}.contains,
        ),
        isEmpty,
      );
      if (edit == 'heading') {
        expect(
          reopened.controller.document
              .collectStyle(0, 1)
              .attributes['header']
              ?.value,
          2,
        );
      }
      expect(await reopened.flush(), isTrue);
    });
  }

  testWidgets('边界修补与输入在同一次撤销／重做中保留空段和粗体', (tester) async {
    const source = '**前😀**\n\n---\n\n<br />\n\n后文';
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    final before = controller.document.toDelta().toJson();
    final divider = controller.document.toPlainText().indexOf('\uFFFC');
    controller.updateSelection(
      TextSelection.collapsed(offset: divider + 1),
      ChangeSource.local,
    );
    controller.replaceText(
      divider + 1,
      0,
      '新😀',
      TextSelection.collapsed(offset: divider + 4),
    );
    await tester.pump();
    expect(await session.flush(), isTrue, reason: session.codecFailure);
    final edited = controller.document.toDelta().toJson();
    final afterSelection = controller.selection;
    expect(
      controller.document.toPlainText().replaceAll('\n', ''),
      '前😀\uFFFC新😀后文',
    );
    expect(
      controller.document.collectStyle(0, 3).attributes['bold']?.value,
      true,
    );
    final saved = MarkdownDeltaCodec.encode(controller.document.toDelta());
    expect('<br />'.allMatches(saved), hasLength(1));
    final restored = MarkdownDeltaCodec.decode(saved).delta;
    expect(
      restored.operations.where(
        (op) => op.attributes?[MarkdownDeltaLineMetadata.emptyKey] == true,
      ),
      hasLength(1),
    );
    controller.undo();
    expect(controller.document.toDelta().toJson(), before);
    expect(await session.flush(), isTrue);
    controller.redo();
    expect(controller.document.toDelta().toJson(), edited);
    expect(controller.selection, afterSelection);
    expect(await session.flush(), isTrue);
  });

  testWidgets('选中分隔线节点本身仍可删除', (tester) async {
    final session = RichEditorSession(
      initialMarkdown: '---',
      onMarkdownChanged: (_) {},
    );
    addTearDown(session.dispose);
    session.controller.replaceText(
      0,
      1,
      '',
      const TextSelection.collapsed(offset: 0),
    );
    await tester.pump();
    expect(session.controller.document.toPlainText(), '\n');
    expect(await session.flush(), isTrue);
  });

  for (final offset in [-1, 100]) {
    test('相邻分隔线拆行保留数量、粗体与无效选区边界 $offset', () {
      final controller = QuillController(
        document: Document.fromDelta(
          Delta()
            ..insert('前', {'bold': true})
            ..insert({
              MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
            })
            ..insert({
              MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
            })
            ..insert('后', {'italic': true})
            ..insert('\n'),
        ),
        selection: TextSelection.collapsed(offset: offset),
      );
      addTearDown(controller.dispose);
      preserveEditorDividerBlocks(controller);
      expect(controller.document.toPlainText(), '前\n\uFFFC\n\uFFFC\n后\n');
      expect(
        controller.document.collectStyle(0, 1).attributes['bold']?.value,
        true,
      );
      expect(
        controller.document.collectStyle(6, 1).attributes['italic']?.value,
        true,
      );
      expect(
        controller.selection.baseOffset,
        offset < 0 ? -1 : controller.document.length - 1,
      );
      expect(
        MarkdownDeltaCodec.encode(controller.document.toDelta()),
        '**前**\n\n---\n\n---\n\n*后*',
      );
      final stable = controller.document.toDelta().toJson();
      preserveEditorDividerBlocks(controller);
      expect(controller.document.toDelta().toJson(), stable);
    });
  }

  test('补分隔线前边界不复制原行末的隐藏引用分段', () {
    final controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('前')
          ..insert({
            MarkdownDeltaCodec.horizontalRuleEmbed: {'version': 1},
          })
          ..insert('后')
          ..insert('\n', {
            'blockquote': true,
            MarkdownQuoteParagraphs.separatorCountKey: 1,
          })
          ..insert('续')
          ..insert('\n', {'blockquote': true}),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(controller.dispose);
    preserveEditorDividerBlocks(controller);
    expect(controller.document.toPlainText(), '前\n\uFFFC\n后\n续\n');
    final boundaries = controller.document.toDelta().operations.where(
      (op) => op.attributes?[MarkdownQuoteParagraphs.separatorCountKey] != null,
    );
    expect(boundaries, hasLength(1));
    expect(
      MarkdownDeltaCodec.encode(controller.document.toDelta()),
      '> 前\n\n---\n\n> 后\n>\n> 续',
    );
  });
}

import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_paragraph_boundaries.dart';
import 'package:wenyousite_mobile/features/editor/presentation/editor_text_color_selection.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';
import '../../support/text_color_assertions.dart';

void main() {
  for (final colorFirst in [false, true]) {
    test('真实输入如何呢，整段预设色与居中按任意顺序保存重开 $colorFirst', () async {
      final changes = <String>[];
      final session = RichEditorSession(
        initialMarkdown: '',
        onMarkdownChanged: changes.add,
      );
      addTearDown(session.dispose);
      session.controller.replaceText(
        0,
        0,
        '如何呢',
        const TextSelection.collapsed(offset: 3),
      );
      void color() => EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection(baseOffset: 0, extentOffset: 3),
        '#D14343',
      );
      if (colorFirst) color();
      session.controller.formatText(0, 3, Attribute.centerAlignment);
      if (!colorFirst) color();
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      expect(changes.last, session.localMarkdown);
      final segment = MarkdownAlignmentContract.renderSegments(
        session.localMarkdown,
      ).single;
      expect(segment.alignment, WenyouTextAlignment.center);
      expect(
        colorReaderUnits(colorReaderNodes(segment.markdown)),
        colorExpectedUnits([
          ('如何呢', {'color': '#D14343'}),
        ]),
      );
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(reopened.isSourceProtected, isFalse);
      expect(reopened.controller.document.toPlainText(), '如何呢\n');
      expect(
        reopened.controller.document
            .toDelta()
            .operations
            .last
            .attributes?['align'],
        'center',
      );
      expect(await reopened.flush(), isTrue);
      expect(reopened.localMarkdown, session.localMarkdown);
    });
  }

  final cases =
      <({String source, String text, List<Map<String, Object>> blocks})>[
        (source: '如何呢', text: '如何呢\n', blocks: [{}]),
        (
          source: '## 如何呢',
          text: '如何呢\n',
          blocks: [
            {'header': 2},
          ],
        ),
        (
          source: '### 如何呢',
          text: '如何呢\n',
          blocks: [
            {'header': 3},
          ],
        ),
        (
          source: '> 如何呢\n> 下一行',
          text: '如何呢\n下一行\n',
          blocks: [
            {'blockquote': true},
            {'blockquote': true},
          ],
        ),
        (
          source: '- 一级\n  - 二级\n    - 如何呢',
          text: '一级\n二级\n如何呢\n',
          blocks: [
            {'list': 'bullet'},
            {'list': 'bullet', 'indent': 1},
            {'list': 'bullet', 'indent': 2},
          ],
        ),
        (
          source: '1. 一级\n   1. 二级\n      1. 如何呢',
          text: '一级\n二级\n如何呢\n',
          blocks: [
            {'list': 'ordered'},
            {'list': 'ordered', 'indent': 1},
            {'list': 'ordered', 'indent': 2},
          ],
        ),
        (source: '首行\n下一行', text: '首行\n下一行\n', blocks: [{}, {}]),
        (
          source: '首段\n\n次段',
          text: '首段\n次段\n',
          blocks: [
            {MarkdownParagraphBoundaries.key: 1},
            {},
          ],
        ),
        (
          source: '首段\n\n<br />\n\n次段',
          text: '首段\n\n次段\n',
          blocks: [
            {MarkdownParagraphBoundaries.key: 1},
            {
              MarkdownDeltaCodec.emptyParagraphAttribute: true,
              MarkdownParagraphBoundaries.key: 1,
            },
            {},
          ],
        ),
      ];
  for (final item in cases) {
    test('真实会话跨块上色、部分恢复默认、保存重开 ${item.source}', () async {
      final session = RichEditorSession(
        initialMarkdown: item.source,
        onMarkdownChanged: (_) {},
      );
      addTearDown(session.dispose);
      expect(session.isSourceProtected, isFalse);
      expect(session.controller.document.toPlainText(), item.text);
      expect(_blocks(session.controller.document.toDelta()), item.blocks);
      final all = TextSelection(
        baseOffset: 0,
        extentOffset: session.controller.document.length - 1,
      );
      EditorTextColorPolicy.apply(session.controller, all, '#D14343');
      session.controller.formatText(0, 1, Attribute.bold);
      EditorTextColorPolicy.apply(
        session.controller,
        const TextSelection(baseOffset: 0, extentOffset: 1),
        null,
      );
      expect(await session.flush(), isTrue, reason: session.codecFailure);
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: (_) {},
      );
      addTearDown(reopened.dispose);
      expect(reopened.isSourceProtected, isFalse);
      expect(reopened.controller.document.toPlainText(), item.text);
      expect(_blocks(reopened.controller.document.toDelta()), item.blocks);
      final text = item.text.replaceAll('\n', '');
      expect(
        colorDeltaUnits(reopened.controller.document.toDelta()),
        colorExpectedUnits([
          (text.substring(0, 1), {'bold': true}),
          (text.substring(1), {'color': '#D14343'}),
        ]),
      );
      expect(await reopened.flush(), isTrue, reason: reopened.codecFailure);
      expect(reopened.localMarkdown, session.localMarkdown);
    });
  }

  test('跨行上色跳过协议原子，保留原子身份和前后文字格式', () async {
    const sources = [
      '前[@用户](/users/c111111111111111111111111)后',
      '前 @全体玩家 后',
      '前[[dice:v1:123e4567-e89b-42d3-a456-426614174000:1d6]]后',
      '前[传送门](/threads/c111111111111111111111111)后',
      '前![表情](https://example.com/sticker.png "wenyousite-sticker:v1:c111111111111111111111111")后',
      '前\n\n![图](https://example.com/image.png)\n\n后',
    ];
    for (final source in sources) {
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: (_) {},
      );
      final before = session.controller.document.toDelta();
      final atoms = before.operations
          .where((op) => op.data is Map)
          .map((op) => op.data)
          .toList();
      expect(atoms, isNotEmpty, reason: source);
      EditorTextColorPolicy.apply(
        session.controller,
        TextSelection(
          baseOffset: 0,
          extentOffset: session.controller.document.length - 1,
        ),
        '#2563EB',
      );
      expect(
        await session.flush(),
        isTrue,
        reason: '$source: ${session.codecFailure}',
      );
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: (_) {},
      );
      final after = reopened.controller.document.toDelta();
      expect(
        after.operations
            .where((op) => op.data is Map)
            .map((op) => op.data)
            .toList(),
        atoms,
      );
      expect(
        after.operations
            .where((op) => op.data is Map)
            .every((op) => op.attributes?['color'] == null),
        isTrue,
      );
      for (final op in after.operations) {
        if (op.data is String && (op.data as String).trim().isNotEmpty) {
          expect(op.attributes?['color'], '#2563EB');
        }
      }
      expect(
        reopened.controller.document.toPlainText(),
        session.controller.document.toPlainText(),
      );
      expect(await reopened.flush(), isTrue);
      expect(reopened.localMarkdown, session.localMarkdown);
      reopened.dispose();
      session.dispose();
    }
  });

  test('围栏代码及既有不支持硬换行保留完整彩色原文，不降级写入', () async {
    const colored = '<span data-wenyou-color-v1="#D14343">如何呢</span>';
    for (final source in [
      '$colored\n\n```text\n$colored\n```',
      '$colored  \n下一行',
      '$colored\\\n下一行',
    ]) {
      final emitted = <String>[];
      final session = RichEditorSession(
        initialMarkdown: source,
        onMarkdownChanged: emitted.add,
      );
      final before = session.controller.document.toDelta().toJson();
      expect(session.isSourceProtected, isTrue, reason: source);
      expect(session.canCloseProtectedSource, isTrue);
      expect(await session.flush(), isFalse);
      expect(emitted, isEmpty);
      expect(session.localMarkdown, source);
      expect(session.controller.document.toDelta().toJson(), before);
      final reopened = RichEditorSession(
        initialMarkdown: session.localMarkdown,
        onMarkdownChanged: emitted.add,
      );
      expect(reopened.isSourceProtected, isTrue);
      expect(reopened.localMarkdown, source);
      expect(reopened.controller.document.toDelta().toJson(), before);
      reopened.dispose();
      session.dispose();
    }
  });
}

List<Map<String, Object>> _blocks(Delta delta) => [
  for (final op in delta.operations)
    if (op.data is String)
      for (final _ in '\n'.allMatches(op.data as String))
        {
          for (final key in [
            'header',
            'blockquote',
            'list',
            'indent',
            MarkdownParagraphBoundaries.key,
            MarkdownDeltaCodec.emptyParagraphAttribute,
          ])
            if (op.attributes?[key] != null) key: op.attributes![key] as Object,
        },
];

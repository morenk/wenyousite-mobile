import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/features/editor/presentation/rich_editor_session.dart';

void main() {
  for (final content in ['甲', '\u00a0', '\u200b', '\u2060', '\u3000']) {
    for (final prefix in ['>', '>\t', '   >']) {
      test('引用可选空格不影响块归属：$prefix ${content.codeUnits}', () {
        final source = '> 上段\n$prefix$content\n> **下段** *~~样式~~*';
        final document = Document.fromDelta(
          MarkdownDeltaCodec.decode(source).delta,
        );
        addTearDown(document.close);
        expect(document.toPlainText(), '上段\n$content\n下段 样式\n');
        _expectSingleQuote(document, 3);
        final encoded = MarkdownDeltaCodec.encode(document.toDelta());
        expect(encoded, '> 上段\n> $content\n> **下段** *~~样式~~*');
        expect(
          md.markdownToHtml(
            encoded,
            extensionSet: md.ExtensionSet.gitHubFlavored,
          ),
          md.markdownToHtml(
            source,
            extensionSet: md.ExtensionSet.gitHubFlavored,
          ),
        );
        final reopened = Document.fromDelta(
          MarkdownDeltaCodec.decode(encoded).delta,
        );
        addTearDown(reopened.close);
        _expectSingleQuote(reopened, 3);
        expect(reopened.toPlainText(), document.toPlainText());
        expect(MarkdownDeltaCodec.encode(reopened.toDelta()), encoded);
      });
    }
  }

  for (final separator in ['>', '> ', '>\t', '>  ', '   >\t ']) {
    test('引用空行 $separator 保持同一个 Quill 引用块及段落间隔', () {
      final source = '> **甲**\n$separator\n> *乙*';
      final document = Document.fromDelta(
        MarkdownDeltaCodec.decode(source).delta,
      );
      addTearDown(document.close);
      expect(document.toPlainText(), '甲\n\n乙\n');
      _expectSingleQuote(document, 3);
      expect(document.collectStyle(0, 1).attributes['bold']?.value, isTrue);
      expect(document.collectStyle(3, 1).attributes['italic']?.value, isTrue);
      final encoded = MarkdownDeltaCodec.encode(document.toDelta());
      expect(encoded, '> **甲**\n>\n> *乙*');
      final readerBlocks = md.Document().parseLines(encoded.split('\n'));
      expect(readerBlocks, hasLength(1));
      final quote = readerBlocks.single as md.Element;
      expect(quote.tag, 'blockquote');
      expect(quote.children!.whereType<md.Element>().map((node) => node.tag), [
        'p',
        'p',
      ]);
      final reopened = Document.fromDelta(
        MarkdownDeltaCodec.decode(encoded).delta,
      );
      addTearDown(reopened.close);
      _expectSingleQuote(reopened, 3);
      expect(reopened.toPlainText(), document.toPlainText());
      expect(MarkdownDeltaCodec.encode(reopened.toDelta()), encoded);
      expect(
        MarkdownEditorDocument.parse(source).blockKinds,
        everyElement(MarkdownEditorBlockKind.quote),
      );
    });
  }

  testWidgets('真实编辑会话在引用空行输入粗体、保存、删除后不拆块', (tester) async {
    const source = '> **甲**\n>\n> *乙*';
    final emitted = <String>[];
    final session = RichEditorSession(
      initialMarkdown: source,
      onMarkdownChanged: emitted.add,
    );
    addTearDown(session.dispose);
    final controller = session.controller;
    _expectSingleQuote(controller.document, 3);
    controller.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    controller.formatSelection(Attribute.bold);
    controller.replaceText(2, 0, '丙', const TextSelection.collapsed(offset: 3));
    expect(await session.flush(), isTrue);
    expect(emitted.last, '> **甲**\n> **丙**\n> *乙*');
    _expectSingleQuote(controller.document, 3);
    controller.replaceText(2, 1, '', const TextSelection.collapsed(offset: 2));
    expect(await session.flush(), isTrue);
    expect(emitted.last, source);
    _expectSingleQuote(controller.document, 3);
  });

  for (final source in ['>', '>\n> 甲', '> 甲\n>', '> 甲\n>\n>\n> 乙']) {
    test('首尾及连续引用空行保持个数：$source', () {
      final document = Document.fromDelta(
        MarkdownDeltaCodec.decode(source).delta,
      );
      addTearDown(document.close);
      _expectSingleQuote(document, source.split('\n').length);
      expect(document.toPlainText(), isNot(contains('>')));
      expect(MarkdownDeltaCodec.encode(document.toDelta()), source);
    });
  }

  test('独立引用之间的普通空行不被并入引用', () {
    const source = '> 甲\n\n> 乙';
    final document = Document.fromDelta(
      MarkdownDeltaCodec.decode(source).delta,
    );
    addTearDown(document.close);
    expect(document.root.children.whereType<Block>(), hasLength(2));
    expect(MarkdownDeltaCodec.encode(document.toDelta()), source);
  });

  test('围栏代码内的空引用符号仍是源码文字', () {
    final document = Document.fromDelta(
      MarkdownDeltaCodec.decode('```\n>\n```').delta,
    );
    addTearDown(document.close);
    expect(document.toPlainText(), '```\n>\n```\n');
    expect(document.root.children.whereType<Block>(), isEmpty);
    final reopened = Document.fromDelta(
      MarkdownDeltaCodec.decode(
        MarkdownDeltaCodec.encode(document.toDelta()),
      ).delta,
    );
    addTearDown(reopened.close);
    expect(reopened.toPlainText(), contains('>'));
    expect(reopened.root.children.whereType<Block>(), isEmpty);
  });

  for (final source in [r'\>', '`>`', '    >', '> >']) {
    test('转义、代码和嵌套引用中的符号不被吞掉：$source', () {
      final document = Document.fromDelta(
        MarkdownDeltaCodec.decode(source).delta,
      );
      addTearDown(document.close);
      expect(document.toPlainText(), contains('>'));
      final encoded = MarkdownDeltaCodec.encode(document.toDelta());
      final reopened = Document.fromDelta(
        MarkdownDeltaCodec.decode(encoded).delta,
      );
      addTearDown(reopened.close);
      expect(reopened.toPlainText(), document.toPlainText());
    });
  }
}

void _expectSingleQuote(Document document, int lines) {
  expect(document.root.children, hasLength(1));
  final block = document.root.children.single;
  expect(block, isA<Block>());
  expect(block.style.attributes['blockquote']?.value, isTrue);
  expect((block as Block).childCount, lines);
}

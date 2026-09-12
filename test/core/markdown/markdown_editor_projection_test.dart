import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_projection.dart';

void main() {
  test('真实空行、空格式块、源码分隔是不同状态', () {
    final lines = MarkdownEditorDocument.parse(
      '##\n\n甲\n\n乙\n\n<br />\n\n>\n> <br />',
    ).editableLines();
    final heading = lines.singleWhere((line) => line.headingLevel == 2);
    expect(heading.content, isEmpty);
    expect(heading.kind, MarkdownEditorLineKind.text);
    final empty = lines.where(
      (line) => line.kind == MarkdownEditorLineKind.emptyParagraph,
    );
    expect(empty.map((line) => line.quote), [false, true]);
    expect(lines.where((line) => line.sourceSeparator), isNotEmpty);
    expect(empty.every((line) => !line.sourceSeparator), isTrue);
  });

  test('列表行携带实际父子归属，正文标记不成为新块', () {
    final lines = MarkdownEditorDocument.parse(
      '1. **甲**\n   - 乙\n\n<br />\n\n1. 丙\n1.',
    ).editableLines();
    final rows = lines.map((line) => line.listRow).nonNulls.toList();
    expect(rows.map((row) => row.content), ['**甲**', '乙', '丙', '']);
    expect(rows.map((row) => row.depth), [0, 1, 0, 0]);
    expect(rows.map((row) => row.parent), [null, 0, null, null]);
    expect(
      lines.where((line) => line.kind == MarkdownEditorLineKind.emptyParagraph),
      hasLength(1),
    );
  });

  test('不支持的列表以整组原文投影，不拆开或丢掉空子项', () {
    const source = '2. 甲\n   1.';
    final lines = MarkdownEditorDocument.parse(source).editableLines();
    expect(lines, hasLength(1));
    expect(lines.single.kind, MarkdownEditorLineKind.unsupportedList);
    expect(lines.single.source, source);
  });

  test('代码中的标记保持文字，跨行代码仍归属于列表项', () {
    final lines = MarkdownEditorDocument.parse(
      '- `甲\n[wenyousite-align-v1-center]: #\n  乙`',
    ).editableLines();
    expect(lines, hasLength(1));
    expect(lines.single.listRow?.ordered, isFalse);
    // 两个空格属于列表容器缩进；代码原始换行仍保留。
    expect(lines.single.content, '`甲\n[wenyousite-align-v1-center]: #\n乙`');
  });

  test('写出结构规范化与投影保持一致，源码分隔不落入分隔线内容', () {
    final doc = MarkdownEditorDocument.parse('甲\n---\n\n***\n\n乙');
    expect(doc.toMarkdown(), '## 甲\n\n---\n\n乙');
    final lines = doc.editableLines();
    expect(lines.first.headingLevel, 2);
    expect(lines.first.content, '甲');
    expect(
      lines.where((line) => line.kind == MarkdownEditorLineKind.horizontalRule),
      hasLength(1),
    );
    expect(lines.last.content, '乙');
    expect(lines.last.hasSourceBreak, isFalse);
  });
}

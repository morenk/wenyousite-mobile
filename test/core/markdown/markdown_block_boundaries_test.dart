import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import '../../support/block_boundary_fixtures.dart';

void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-block-boundary-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final id in [
    'center-paragraph-after-paragraph',
    'right-paragraph-after-paragraph',
    'center-paragraph-consecutive-aligned-blocks',
  ]) {
    final item = (fixture['cases'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((item) => item['id'] == id);
    test('共享块边界保存 $id', () {
      final doc = MarkdownDeltaCodec.decode(
        item['markdown'] as String,
        imageAlignment: true,
      );
      expect(
        MarkdownDeltaCodec.encode(doc.delta, imageAlignment: true),
        item['serialized'],
      );
    });
  }
  for (final source in [
    '<div>\n[wenyousite-align-v1-center]: #\n## title\n</div>',
    '`before\n[wenyousite-align-v1-center]: #\ntitle`',
    '😀 `代码\n[wenyousite-align-v1-center]: #\n正文`',
  ]) {
    test('真实解析保护区不消费 marker $source', () {
      expect(
        MarkdownAlignmentContract.analyze(source).validMarkerLines,
        isEmpty,
      );
      final doc = MarkdownDeltaCodec.decode(source, imageAlignment: true);
      expect(
        doc.delta.operations.any((op) => op.attributes?['align'] != null),
        isFalse,
      );
      expect(
        doc.delta.operations
            .where((op) => op.data is String)
            .map((op) => op.data)
            .join(),
        contains('[wenyousite-align-v1-center]: #'),
      );
    });
  }
  test('直接 CRLF 分析与 LF 的源码位置一致', () {
    final source = 'before\r\n[wenyousite-align-v1-center]: #\r\n## title';
    final analysis = MarkdownAlignmentContract.analyze(source);
    expect(analysis.validMarkerLines, {1});
    expect(analysis.blocks.single.startLine, 2);
  });
  for (final prefix in ['> # 标题', '> ## 标题', '> ```', '> ```\n> code\n> ```']) {
    test('引用非段落后 marker 不成为 lazy 行 $prefix', () {
      final source = '$prefix\n[wenyousite-align-v1-center]: #\n正文';
      expect(MarkdownAlignmentContract.analyze(source).validMarkerLines, {
        prefix.split('\n').length,
      });
    });
  }
  for (final (source, texts, alignments) in [
    (
      '前文\n[wenyousite-align-v1-center]: #\n`甲\n乙`',
      ['前文', '甲 乙'],
      ['left', 'center'],
    ),
    (
      '`甲\n乙`\n[wenyousite-align-v1-center]: #\n正文',
      ['甲 乙', '正文'],
      ['left', 'center'],
    ),
    ('[wenyousite-align-v1-center]: #\n`甲\n乙`', ['甲 乙'], ['center']),
    (
      '`甲\n乙` 和 `丙\n丁`\n[wenyousite-align-v1-center]: #\n正文',
      ['甲 乙 和 丙 丁', '正文'],
      ['left', 'center'],
    ),
  ]) {
    test('跨行代码保护不吞相邻合法块 $source', () {
      final delta = MarkdownDeltaCodec.decode(source).delta;
      final rows = boundaryRows(delta);
      expect(rows.map((row) => row['text']), texts);
      expect(rows.map((row) => row['alignment']), alignments);
      final saved = MarkdownDeltaCodec.encode(delta);
      final reopened = MarkdownDeltaCodec.decode(saved).delta;
      expect(boundaryRows(reopened), rows);
      expect(MarkdownDeltaCodec.encode(reopened), saved);
    });
  }
  for (final prefix in [
    '前 [链接](https://example.com/`)',
    '![图](https://example.com/`)',
    '前 [链接](https://example.com "`")',
  ]) {
    test('地址和 title 的反引号不伪造跨行 code 保护区 $prefix', () {
      final source = '$prefix\n[wenyousite-align-v1-center]: #\n正文 `code`';
      final analysis = MarkdownAlignmentContract.analyze(
        source,
        imageAlignment: true,
      );
      expect(analysis.validMarkerLines, {1});
      expect(analysis.blocks.single.startLine, 2);
    });
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/features/users/data/recent_reply_preview.dart';

void main() {
  const colored = '<span data-wenyou-color-v1="#D14343">中文😀</span>';
  for (final sample in <(String, String)>[
    (colored, '中文😀'),
    ('前$colored后', '前中文😀后'),
    ('## $colored\n\n> **引用**\n\n- _列表_', '中文😀 引用 列表'),
    ('[align:center]: #\n\n$colored', '中文😀'),
    ('<br />\n## $colored', '中文😀'),
    ('[链接](https://example.com) `a < b > c`', '链接 a < b > c'),
    ('![图片](https://example.com/a.png) <https://example.com>', '[图片] [链接]'),
    ('`![]()` ![]()', '![]()'),
    ('`[align:center]: #`', '[align:center]: #'),
    ('`$colored`', colored),
    ('```md\n$colored\n```', colored),
    ('    $colored', colored),
    ('\t$colored', colored),
    (r'\<span data-wenyou-color-v1="#D14343">中文😀\</span>', colored),
    ('&lt;span data-wenyou-color-v1="#D14343"&gt;中文😀&lt;/span&gt;', colored),
    ('<span>普通 HTML 字面</span>', '<span>普通 HTML 字面</span>'),
    ('普通 a < b > c', '普通 a < b > c'),
    (
      '<span data-wenyou-color-v1="#D14343">缺闭合',
      '<span data-wenyou-color-v1="#D14343">缺闭合',
    ),
    ('<span data-wenyou-color-v1="#D143', '<span data-wenyou-color-v1="#D143'),
    (
      '<span data-wenyou-color-v1="#D14343" title="额外">字</span>',
      '<span data-wenyou-color-v1="#D14343" title="额外">字</span>',
    ),
  ]) {
    test('共享摘要与最近回复可见文字一致：${sample.$1}', () {
      expect(MarkdownContent.toPlainTextPreview(sample.$1), sample.$2);
      expect(recentReplyPreview(sample.$1), sample.$2);
    });
  }

  test('完整解析颜色后按码点截断，不切断emoji或遗留半个标签', () {
    final source = '<span data-wenyou-color-v1="#D14343">${'中😀' * 100}</span>';
    expect(MarkdownContent.toPlainTextPreview(source), '${'中😀' * 89}中…');
    expect(MarkdownContent.toPlainTextPreview(source, maxLength: 3), '中😀…');
    expect(MarkdownContent.toPlainTextPreview(source, maxLength: 1), '…');
    expect(MarkdownContent.toPlainTextPreview(source, maxLength: 0), '');
  });

  test('仅实际骰子节点投影，占位格式按列表既有策略选择', () {
    const id = '12345678-1234-4234-8234-123456789abc';
    const node = '[[dice:v1:$id:2d6]]';
    expect(MarkdownContent.toPlainTextPreview('$node `$node`'), '[2d6] $node');
    expect(recentReplyPreview('$node `$node`'), '[2d6 = ?] $node');
    expect(recentReplyPreview(node, diceLabels: {id: '2d6 = 8'}), '[2d6 = 8]');
  });

  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-inline-combinations-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final item
      in (fixture['cases'] as List).cast<Map<String, dynamic>>().where(
        (item) => item['kind'] == 'canonical',
      )) {
    test('共享摘要符合独立行内组合文字：${item['id']}', () {
      final expected = (item['segments'] as List)
          .map((segment) => segment['text'] as String)
          .join()
          .replaceAll(RegExp(r'\s+', unicode: true), ' ')
          .trim();
      expect(
        MarkdownContent.toPlainTextPreview(item['canonical'] as String),
        expected,
      );
      expect(recentReplyPreview(item['canonical'] as String), expected);
    });
  }
}

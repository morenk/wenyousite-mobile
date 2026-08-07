import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';

void main() {
  final contract =
      jsonDecode(File('contracts/markdown-v2-fixtures.json').readAsStringSync())
          as Map<String, dynamic>;
  final cases = (contract['cases'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  test('加载的是 Markdown v2 黄金语料', () {
    expect(contract['version'], 2);
    expect(cases, isNotEmpty);
  });

  for (final fixture in cases) {
    final id = fixture['id'] as String;
    final input = fixture['input'] as String;
    final canonical = fixture['canonical'] as String;
    final visible = fixture['visible'] as bool;

    test('$id 规范化与发布可见性一致', () {
      expect(MarkdownContent.normalize(input), canonical);
      expect(MarkdownContent.hasVisibleContent(canonical), visible);
      expect(MarkdownContent.normalize(canonical), canonical);
    });
  }

  test('链接和图片仅允许明确的安全 scheme', () {
    expect(
      MarkdownContent.isSafeLink(Uri.parse('https://wenyou.site')),
      isTrue,
    );
    expect(
      MarkdownContent.isSafeLink(Uri.parse('javascript:alert(1)')),
      isFalse,
    );
    expect(
      MarkdownContent.isSafeImage(Uri.parse('data:image/png;base64,YQ==')),
      isFalse,
    );
  });
}

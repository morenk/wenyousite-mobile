import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

// 契约同步切片只核对独立定义的规范写法，不表示移动端 Codec 已实现契约。
// 原文读取、真实编辑和保存重开在列表修复切片中另行验收。
void main() {
  final fixture =
      jsonDecode(
            File(
              'contracts/markdown-editor-list-v1-fixtures.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final cases = (fixture['cases'] as List).cast<Map<String, dynamic>>();
  final casesById = {for (final row in cases) row['id'] as String: row};

  test('列表契约固定版本、三层上限与独立类型／空项矩阵', () {
    expect(fixture['contract'], 'wenyousite-editor-list');
    expect(fixture['version'], 1);
    expect(fixture['revision'], 2);
    expect(fixture['markdownContractVersion'], 5);
    expect(fixture['maxDepth'], 3);
    expect(fixture['indexBase'], 0);
    expect(casesById.length, cases.length);
    expect(
      cases.where((row) => (row['id'] as String).startsWith('chain-')),
      hasLength(84),
    );
  });

  for (final row in cases) {
    test('${row['id']} 规范写法保留独立阅读树和直属文字块', () {
      final items = _readingItems(row['canonical'] as String);
      expect(items, row['items']);
      expect(
        items.expand(
          (item) => (item['blocks'] as List).expand(
            (block) => block['lines'] as List,
          ),
        ),
        row['editableLines'],
      );
    });
  }

  for (final row
      in (fixture['editCases'] as List).cast<Map<String, dynamic>>()) {
    test('${row['id']} 操作结果与目标列表树一致', () {
      final expected = casesById[row['expectedCase']];
      expect(expected, isNotNull);
      expect(_readingItems(row['canonical'] as String), expected!['items']);
    });
  }
}

// 直接使用阅读解析器，不导入待测 Codec。预期来自后端固定机器夹具。
List<Map<String, Object?>> _readingItems(String source) {
  final items = <Map<String, Object?>>[];
  void visit(md.Element list, int depth, int? parent) {
    final type = list.tag == 'ol' ? 'ordered' : 'bullet';
    final start = type == 'ordered'
        ? int.parse(list.attributes['start'] ?? '1')
        : null;
    for (final item in list.children!.whereType<md.Element>()) {
      if (item.tag != 'li') continue;
      final blocks = <Map<String, Object?>>[];
      var inline = <md.Node>[];
      void flush() {
        if (inline.isEmpty) return;
        blocks.add({
          'type': 'paragraph',
          'lines': inline.map((node) => node.textContent).join().split('\n'),
        });
        inline = [];
      }

      for (final node in item.children ?? <md.Node>[]) {
        if (node is md.Element && ['ul', 'ol'].contains(node.tag)) {
          flush();
        } else if (node is md.Element && ['p', 'h2', 'h3'].contains(node.tag)) {
          flush();
          blocks.add({
            'type': node.tag == 'p'
                ? 'paragraph'
                : 'heading-${node.tag.substring(1)}',
            'lines': node.textContent.split('\n'),
          });
        } else {
          inline.add(node);
        }
      }
      flush();
      if (blocks.isEmpty) {
        blocks.add({
          'type': 'paragraph',
          'lines': [''],
        });
      }
      final text = blocks
          .expand((block) => block['lines'] as List<String>)
          .join('\n');
      final index = items.length;
      items.add({
        'type': type,
        'depth': depth,
        'parent': parent,
        'start': start,
        'text': text,
        'empty': text.isEmpty,
        'blocks': blocks,
      });
      for (final node
          in item.children?.whereType<md.Element>() ?? <md.Element>[]) {
        if (['ul', 'ol'].contains(node.tag)) visit(node, depth + 1, index);
      }
    }
  }

  final document = md.Document(
    extensionSet: md.ExtensionSet.gitHubFlavored,
    encodeHtml: false,
  );
  for (final node
      in document.parseLines(source.split('\n')).whereType<md.Element>()) {
    if (['ul', 'ol'].contains(node.tag)) visit(node, 0, null);
  }
  return items;
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';

// 独立契约阅读预期与 Codec 原文／规范写法消费分别验证；兼容保护明确
// 保留源码，不能把拒绝有损保存计为完整的可编辑支持。
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
    for (final field in ['markdown', 'canonical']) {
      test('${row['id']} $field 移动端读取、保存与独立阅读树一致', () {
        final source = row[field] as String;
        final document = MarkdownDeltaCodec.decode(source);
        const protected = {
          'legacy-two-space-ordered',
          'setext-is-heading',
          'wide-ordered-marker',
          'loose-item-blocks',
          'mention-marks-empty-child',
        };
        if (protected.contains(row['id'])) {
          expect(
            document.issues.map((issue) => issue.kind),
            contains(MarkdownCodecIssueKind.unsupportedList),
          );
          expect(document.issues.single.rawToken, source);
          expect(
            () => MarkdownDeltaCodec.encode(document.delta),
            throwsA(isA<MarkdownCodecException>()),
          );
          return;
        }
        expect(document.issues, isEmpty);
        final text = document.delta.operations.map((op) => op.data).join();
        expect(text, '${(row['editableLines'] as List).join('\n')}\n');
        final saved = MarkdownDeltaCodec.encode(document.delta);
        expect(_readingItems(saved), row['items']);
        final reopened = MarkdownDeltaCodec.decode(saved);
        expect(reopened.delta.operations.map((op) => op.data).join(), text);
        expect(MarkdownDeltaCodec.encode(reopened.delta), saved);
      });
    }
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

  for (final row
      in (fixture['rejected'] as List).cast<Map<String, dynamic>>()) {
    test('${row['id']} 拒绝结构不丢失原文或截断层级', () {
      final source = row['markdown'] as String;
      final document = MarkdownDeltaCodec.decode(source);
      if (['four-real-levels', 'list-html-row'].contains(row['id'])) {
        expect(document.issues.single.rawToken, source);
        expect(
          () => MarkdownDeltaCodec.encode(document.delta),
          throwsA(isA<MarkdownCodecException>()),
        );
      } else {
        expect(
          document.delta.operations.map((op) => op.data).join(),
          '$source\n',
        );
        expect(
          document.delta.operations.any((op) => op.attributes?['list'] != null),
          isFalse,
        );
        final saved = MarkdownDeltaCodec.encode(document.delta);
        expect(_readingItems(saved), isEmpty);
        expect(
          MarkdownDeltaCodec.decode(
            saved,
          ).delta.operations.map((op) => op.data).join(),
          '$source\n',
        );
      }
    });
  }
}

// 直接使用阅读解析器，不调用待测 Codec。预期来自后端固定机器夹具。
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

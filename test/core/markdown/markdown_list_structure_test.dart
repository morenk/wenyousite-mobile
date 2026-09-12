import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';

typedef _Row = ({String type, int depth, int? parent, String text});

void main() {
  for (var levels = 1; levels <= 3; levels++) {
    for (var types = 0; types < (1 << levels); types++) {
      for (var empty = 0; empty < (1 << levels); empty++) {
        final rows = <_Row>[
          for (var level = 0; level < levels; level++)
            (
              type: types & (1 << level) == 0 ? 'bullet' : 'ordered',
              depth: level,
              parent: level == 0 ? null : level - 1,
              text: empty & (1 << level) == 0 ? ['甲', '乙', '丙'][level] : '',
            ),
        ];
        final source = _referenceMarkdown(rows);
        final name = '层数 $levels 类型 $types 空项 $empty';
        test('读取列表树 $name', () {
          // 预期来自设计中的父子关系，并先与独立 CommonMark 阅读核对。
          expect(_readingRows(source), rows);
          final decoded = MarkdownDeltaCodec.decode(source);
          expect(_deltaRows(decoded.delta), rows);
        });
        test('保存列表树 $name', () {
          final delta = Delta();
          for (final row in rows) {
            if (row.text.isNotEmpty) delta.insert(row.text);
            delta.insert('\n', {
              'list': row.type,
              if (row.depth > 0) 'indent': row.depth,
            });
          }
          final saved = MarkdownDeltaCodec.encode(delta);
          expect(_readingRows(saved), rows);
          expect(_deltaRows(MarkdownDeltaCodec.decode(saved).delta), rows);
        });
      }
    }
  }

  test('旧两空格有序源码按实际阅读层级恢复，不推断历史意图', () {
    const source = '1. 甲\n  1. 乙\n    1. 丙';
    const expected = <_Row>[
      (type: 'ordered', depth: 0, parent: null, text: '甲'),
      (type: 'ordered', depth: 0, parent: null, text: '乙\n    1. 丙'),
    ];
    expect(_readingRows(source), expected);
    final items = MarkdownDeltaCodec.decode(
      source,
    ).editorDocument.blocks.whereType<MarkdownListItemBlock>().toList();
    expect(items.map((item) => item.content), expected.map((row) => row.text));
    expect(items.map((item) => item.indent), [0, 0]);
  });

  test('没有父项的前导两空格不制造虚假的第二层', () {
    const source = '  - 甲';
    const expected = <_Row>[
      (type: 'bullet', depth: 0, parent: null, text: '甲'),
    ];
    expect(_readingRows(source), expected);
    expect(_deltaRows(MarkdownDeltaCodec.decode(source).delta), expected);
  });

  test('根项、子项和下一根项类型切换保留父子归属', () {
    const source = '1. 甲\n   - 乙\n1. 丙\n   1. 丁';
    const expected = <_Row>[
      (type: 'ordered', depth: 0, parent: null, text: '甲'),
      (type: 'bullet', depth: 1, parent: 0, text: '乙'),
      (type: 'ordered', depth: 0, parent: null, text: '丙'),
      (type: 'ordered', depth: 1, parent: 2, text: '丁'),
    ];
    expect(_readingRows(source), expected);
    final delta = MarkdownDeltaCodec.decode(source).delta;
    expect(_deltaRows(delta), expected);
    expect(_readingRows(MarkdownDeltaCodec.encode(delta)), expected);
  });
}

// CommonMark 子项从父标记后的内容列开始；空父项本身已经提供段落分隔，
// 再加一行空白会结束它。此构造器只生成上面明确设计的单链测试输入。
String _referenceMarkdown(List<_Row> rows) {
  final output = <String>[];
  var column = 0;
  for (var index = 0; index < rows.length; index++) {
    final row = rows[index];
    if (index > 0 && row.text.isEmpty && rows[index - 1].text.isNotEmpty) {
      output.add('');
    }
    final marker = row.type == 'ordered' ? '1.' : '-';
    // 标准 Markdown 允许首个子项与空父项同一源码行，避免后面的语法
    // 空行结束空祖先；实际仍是两层。这也必须作为读取输入覆盖。
    if (index == 1 && rows.first.text.isEmpty && row.text.isNotEmpty) {
      output[0] += ' $marker ${row.text}';
      column += marker.length + 1;
      continue;
    }
    output.add(
      '${' ' * column}$marker${row.text.isEmpty ? '' : ' ${row.text}'}',
    );
    column += marker.length + 1;
  }
  return output.join('\n');
}

List<_Row> _readingRows(String source) {
  final rows = <_Row>[];
  void visit(Iterable<md.Node> nodes, int depth, int? parent) {
    for (final node in nodes.whereType<md.Element>()) {
      if (node.tag != 'ul' && node.tag != 'ol') continue;
      for (final item in node.children!.whereType<md.Element>()) {
        if (item.tag != 'li') continue;
        final own = item.children!.where(
          (child) => child is! md.Element || !['ul', 'ol'].contains(child.tag),
        );
        final index = rows.length;
        rows.add((
          type: node.tag == 'ol' ? 'ordered' : 'bullet',
          depth: depth,
          parent: parent,
          text: own.map((child) => child.textContent).join(),
        ));
        visit(item.children!, depth + 1, index);
      }
    }
  }

  visit(md.Document().parseLines(source.split('\n')), 0, null);
  return rows;
}

List<_Row> _deltaRows(Delta delta) {
  final rows = <_Row>[];
  final ancestors = <int, int>{};
  var line = '';
  for (final operation in delta.operations) {
    final data = operation.data;
    if (data is! String) {
      line += '\uFFFC';
      continue;
    }
    for (final character in data.split('')) {
      if (character != '\n') {
        line += character;
        continue;
      }
      final attributes = operation.attributes ?? const <String, dynamic>{};
      final type = attributes['list'] as String? ?? 'paragraph';
      final depth = attributes['indent'] as int? ?? 0;
      if (type == 'paragraph') ancestors.clear();
      rows.add((
        type: type,
        depth: depth,
        parent: depth == 0 ? null : ancestors[depth - 1],
        text: line,
      ));
      ancestors.removeWhere((key, value) => key >= depth);
      ancestors[depth] = rows.length - 1;
      line = '';
    }
  }
  return rows;
}

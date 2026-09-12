import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_source_protection.dart';

/// 列表层级取自 CommonMark 容器树，不取自源码空格数。原始行范围用于
/// 保留历史写法；写出时按父标记的内容列缩进，并再次核对完整树结构。
final class MarkdownListRow {
  const MarkdownListRow({
    required this.ordered,
    required this.depth,
    required this.content,
    this.parent,
    this.start = 1,
    this.simple = true,
  });

  final bool ordered;
  final int depth;
  final int? parent;
  final int start;
  final String content;
  final bool simple;
}

final class MarkdownListRange {
  const MarkdownListRange(this.start, this.end, this.source, this.rows);
  final int start;
  final int end;
  final String source;
  final List<MarkdownListRow> rows;
  bool get taskList =>
      rows.any((row) => RegExp(r'^\[[ xX]\](?:\s|$)').hasMatch(row.content));
  bool get editable => rows.every(
    (row) =>
        row.simple &&
        row.depth < 3 &&
        (!row.ordered || row.start == 1) &&
        !RegExp(
          r'(?:\*\*|\*|~~|__|_)\[@[^\]]+\]\(/users/[^)]+\)',
        ).hasMatch(row.content),
  );
}

abstract final class MarkdownListStructure {
  /// GFM 的列表扩展排在 Setext 之前会把 `- 甲\n  -` 中的甲吞掉。
  /// 显式恢复 CommonMark 优先级，保留 GFM 的行内能力。
  static List<md.BlockSyntax> blockSyntaxes() => [
    const md.SetextHeaderSyntax(),
  ];

  static Map<int, MarkdownListRange> parse(String source) {
    if (!RegExp(
      r'(^|\n) {0,3}(?:[-+*]|\d+[.)])(?:[\t ]|(?=\n|$))',
    ).hasMatch(source)) {
      return const {};
    }
    final lines = source.split('\n');
    final protection =
        source.contains('`') ||
            source.contains('[wenyousite-align') ||
            source.contains('<')
        ? MarkdownSourceProtection.analyze(lines)
        : null;
    final parserLines = lines.map(md.Line.new).toList();
    final boundaries = <md.Line>{
      for (var i = 0; i < lines.length; i++)
        if (!(protection?.codeLines.contains(i) ?? false) &&
            (RegExp(
                  r'^<br\s*/?>[\t ]*$',
                  caseSensitive: false,
                ).hasMatch(lines[i]) ||
                RegExp(
                  r'^\[wenyousite-align-v1-(?:center|right)\]: #$',
                ).hasMatch(lines[i])))
          parserLines[i],
    };
    final capture = _CaptureLists();
    final document = md.Document(
      blockSyntaxes: [
        _ProtocolBoundary(boundaries),
        ...blockSyntaxes(),
        capture,
      ],
      extensionSet: md.ExtensionSet.commonMark,
      encodeHtml: false,
    );
    md.BlockParser(parserLines, document).parseLines();
    return {
      for (final range in capture.ranges)
        // 代码与无效对齐定义继续走已有的源码保护路径，不能被列表重解释。
        if (!(protection?.multilineCodeRanges.entries.any(
                  (span) => span.key < range.end && span.value >= range.start,
                ) ??
                false) &&
            !lines
                .sublist(range.start, range.end)
                .any(
                  (line) => RegExp(r'^\s*\[wenyousite-align').hasMatch(line),
                ) &&
            !(protection != null &&
                !(_rows(range.node).every((row) => row.simple)) &&
                protection.blockLines.any(
                  (i) => i >= range.start && i < range.end,
                )))
          range.start: MarkdownListRange(
            range.start,
            range.end,
            lines.sublist(range.start, range.end).join('\n'),
            _rows(range.node),
          ),
    };
  }

  static List<MarkdownListRow> _rows(md.Node root) {
    final rows = <MarkdownListRow>[];
    void visit(md.Node node, int depth, int? parent) {
      if (node is! md.Element || !['ul', 'ol'].contains(node.tag)) return;
      final ordered = node.tag == 'ol';
      final start = int.tryParse(node.attributes['start'] ?? '1') ?? 1;
      for (final item in node.children!.whereType<md.Element>()) {
        final own = item.children!
            .where((n) => n is! md.Element || !['ul', 'ol'].contains(n.tag))
            .toList();
        String raw(md.Node n) => n is md.Element
            ? (n.children ?? []).map(raw).join()
            : n.textContent;
        final content = own.map(raw).join('\n');
        final simple =
            own.length <= 1 &&
            own.every(
              (n) =>
                  n is md.UnparsedContent ||
                  n is md.Text ||
                  (n is md.Element && n.tag == 'p'),
            ) &&
            !content.contains('\n') &&
            !RegExp(r'^\[[ xX]\](?:\s|$)').hasMatch(content) &&
            !RegExp(r'<br\s*/?>', caseSensitive: false).hasMatch(content);
        final index = rows.length;
        rows.add(
          MarkdownListRow(
            ordered: ordered,
            depth: depth,
            parent: parent,
            start: start,
            content: content,
            simple: simple,
          ),
        );
        for (final child in item.children!) {
          visit(child, depth + 1, index);
        }
      }
    }

    visit(root, 0, null);
    return rows;
  }

  static String write(List<MarkdownListRow> rows) {
    if (rows.isEmpty) return '';
    final parents = <int, int>{};
    final columns = <int, int>{};
    final lines = <String>[];
    final lineForItem = <int, int>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final depth = row.depth;
      if (depth < 0 ||
          depth > 2 ||
          (depth > 0 && !parents.containsKey(depth - 1))) {
        throw const MarkdownCodecException('列表最多支持三级，请先建立上一级条目');
      }
      final parent = depth == 0 ? null : parents[depth - 1];
      final column = parent == null
          ? 0
          : columns[parent]! + (rows[parent].ordered ? 3 : 2);
      final marker = row.ordered ? '1.' : '-';
      final content = row.content;
      // 空祖先后的语法空行会结束祖先。把首个非空子项写在空父项的
      // 标记后；全空链保持多行，避免 `- - -` 被当作分隔线。
      final inline =
          parent == i - 1 &&
          parent != null &&
          rows[parent].content.isEmpty &&
          content.isNotEmpty;
      if (inline) {
        lines[lineForItem[parent]!] += ' $marker $content';
        lineForItem[i] = lineForItem[parent]!;
      } else {
        if (i > 0 && content.isEmpty && rows[i - 1].content.isNotEmpty) {
          lines.add('');
        }
        lineForItem[i] = lines.length;
        lines.add(
          '${' ' * column}$marker${content.isEmpty ? '' : ' $content'}',
        );
      }
      columns[i] = column;
      parents.removeWhere((key, value) => key >= depth);
      parents[depth] = i;
    }
    final result = lines.join('\n');
    final read = <MarkdownListRow>[];
    // 跨行行内代码在阅读时投影为空格；持久化仍保留未编辑的源码换行。
    // 只对阅读校验使用实际代码消费范围的投影，不能提前改写条目内容。
    final readingSource = MarkdownSourceProtection.prepareForReader(result);
    for (final range in parse(readingSource).values) {
      final offset = read.length;
      read.addAll(
        range.rows.map(
          (row) => MarkdownListRow(
            ordered: row.ordered,
            depth: row.depth,
            parent: row.parent == null ? null : offset + row.parent!,
            start: row.start,
            content: row.content,
            simple: row.simple,
          ),
        ),
      );
    }
    // 校验层级、父子关系、类型和内容，空项数量相同并不能证明写对了。
    if (read.length != rows.length) {
      throw const MarkdownCodecException('列表结构无法安全保存，请调整列表缩进');
    }
    parents.clear();
    for (var i = 0; i < rows.length; i++) {
      final a = rows[i];
      final b = read[i];
      final parent = a.depth == 0 ? null : parents[a.depth - 1];
      if (a.ordered != b.ordered ||
          a.depth != b.depth ||
          parent != b.parent ||
          MarkdownSourceProtection.prepareForReader(a.content) != b.content ||
          !b.simple) {
        throw const MarkdownCodecException('列表内容无法安全保存，请调整列表缩进');
      }
      parents.removeWhere((key, value) => key >= a.depth);
      parents[a.depth] = i;
    }
    return result;
  }
}

class _CaptureLists extends md.UnorderedListSyntax {
  final ranges = <({int start, int end, md.Node node})>[];
  @override
  md.Node parse(md.BlockParser parser) {
    final start = parser.lines.indexOf(parser.current);
    final top = parser.parentSyntax == null;
    final node = super.parse(parser);
    if (top) {
      var end = parser.isDone
          ? parser.lines.length
          : parser.lines.indexOf(parser.current);
      while (end > start && parser.lines[end - 1].content.trim().isEmpty) {
        end--;
      }
      ranges.add((start: start, end: end, node: node));
    }
    return node;
  }
}

class _ProtocolBoundary extends md.BlockSyntax {
  const _ProtocolBoundary(this.lines);
  final Set<md.Line> lines;
  @override
  RegExp get pattern => RegExp(r'.*');
  @override
  bool canParse(md.BlockParser parser) => lines.contains(parser.current);
  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();
    return md.Element.empty('wenyou-empty');
  }
}

import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editable_block_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_blocks.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';

enum MarkdownEditorLineKind {
  text,
  sourceSeparator,
  emptyParagraph,
  horizontalRule,
  literal,
  unsupportedList,
}

/// 文档已经确定的编辑行。容器归属与空状态不再由 Quill 适配器猜测。
final class MarkdownEditorLine {
  const MarkdownEditorLine({
    required this.source,
    required this.content,
    this.kind = MarkdownEditorLineKind.text,
    this.headingLevel,
    this.quote = false,
    this.listRow,
    this.alignment = WenyouTextAlignment.left,
    this.hasSourceBreak = true,
    this.paragraphBoundaryAfter = false,
    this.sourceSeparator = false,
  });

  final String source;
  final String content;
  final MarkdownEditorLineKind kind;
  final int? headingLevel;
  final bool quote;
  final MarkdownListRow? listRow;
  final WenyouTextAlignment alignment;
  final bool hasSourceBreak;
  final bool paragraphBoundaryAfter;
  final bool sourceSeparator;
}

typedef MarkdownOwnedSourceLine = ({String source, MarkdownEditorBlock? block});

abstract final class MarkdownEditorProjection {
  /// 写出和投影共用块到源码行的归属表，源码分隔不伪装成正文块。
  static List<MarkdownOwnedSourceLine> sourceLines(
    List<MarkdownEditorBlock> blocks,
    int trailingBlankLines,
  ) {
    final lines = <MarkdownOwnedSourceLine>[];
    MarkdownEditorBlock? previous;
    for (final block in blocks) {
      final source = block.sourceLines;
      if (source.isEmpty) continue;
      final gap = previous == null
          ? block.blankLinesBefore
          : previous is MarkdownHorizontalRuleBlock ||
                block is MarkdownHorizontalRuleBlock
          ? 1
          : block.blankLinesBefore;
      for (var i = 0; i < gap; i++) {
        lines.add((source: '', block: null));
      }
      lines.addAll(source.map((line) => (source: line, block: block)));
      previous = block;
    }
    if (previous != null && previous is! MarkdownHorizontalRuleBlock) {
      for (var i = 0; i < trailingBlankLines; i++) {
        lines.add((source: '', block: null));
      }
    }
    return List.unmodifiable(lines);
  }

  static List<MarkdownEditorLine> project(
    List<MarkdownEditorBlock> blocks,
    int trailingBlankLines, {
    bool imageAlignment = false,
    bool readerClipboard = false,
  }) {
    final owned = sourceLines(blocks, trailingBlankLines);
    if (owned.isEmpty) {
      return const [
        MarkdownEditorLine(source: '', content: '', hasSourceBreak: false),
      ];
    }
    final sources = owned.map((line) => line.source).toList();
    // 只处理代码保护和对齐标记位置；块类型来自 owned，不重新解析列表。
    final alignment = MarkdownAlignmentContract.analyzeLines(
      sources,
      imageAlignment: imageAlignment,
    );
    final markers = alignment.validMarkerLines;
    final output = <MarkdownEditorLine>[];
    for (var i = 0; i < owned.length; i++) {
      if (markers.contains(i)) continue;
      final block = owned[i].block;
      final raw = owned[i].source;
      if (block is MarkdownListItemBlock && block.listRange != null) {
        final list = block.listRange!;
        final end = i + block.sourceLines.length;
        if (!list.editable &&
            !(readerClipboard &&
                list.rows.every((row) => row.simple && row.depth < 3))) {
          output.add(
            MarkdownEditorLine(
              source: list.source,
              content: list.source,
              kind: MarkdownEditorLineKind.unsupportedList,
              hasSourceBreak: end < owned.length,
            ),
          );
        } else {
          for (var rowIndex = 0; rowIndex < list.rows.length; rowIndex++) {
            final row = list.rows[rowIndex];
            output.add(
              MarkdownEditorLine(
                source: row.content,
                content: row.content,
                listRow: row,
                hasSourceBreak:
                    rowIndex + 1 < list.rows.length || end < owned.length,
              ),
            );
          }
        }
        i = end - 1;
        continue;
      }
      if (block == null && i > 0 && i + 1 < owned.length) {
        final next = owned[i + 1].block;
        if (next is MarkdownListItemBlock && next.content.isEmpty) continue;
      }
      var end = i;
      var source = raw;
      final codeEnd = alignment.protection.multilineCodeRanges[i];
      if (block is! MarkdownCompatibilityBlock && codeEnd != null) {
        end = codeEnd;
        source = alignment.protection.multilineCodeSources[i]!;
      }
      final quote = block is MarkdownQuoteBlock;
      final header = block is MarkdownHeadingBlock ? block.level : null;
      var content = source;
      if (block is MarkdownHeadingBlock) {
        content = block.content.isEmpty
            ? ''
            : source.substring(block.level + 1);
        if (readerClipboard) {
          content =
              MarkdownEditableBlockSyntax.readerHeading(source)?.content ??
              content;
        }
      } else if (block is MarkdownQuoteBlock) {
        content = source.length == 1 ? '' : source.substring(2);
      } else if (block is MarkdownListItemBlock) {
        content = end == i
            ? block.content
            : source.substring(raw.length - block.content.length);
      }
      final empty =
          block is MarkdownProtocolEmptyBlock ||
          (quote && MarkdownContent.isQuotedEmptyParagraphLine(source));
      final kind = switch (block) {
        MarkdownCompatibilityBlock() => MarkdownEditorLineKind.literal,
        MarkdownHorizontalRuleBlock() => MarkdownEditorLineKind.horizontalRule,
        _ when empty => MarkdownEditorLineKind.emptyParagraph,
        null => MarkdownEditorLineKind.sourceSeparator,
        _ => MarkdownEditorLineKind.text,
      };
      output.add(
        MarkdownEditorLine(
          source: source,
          content: empty ? '' : content,
          kind: kind,
          headingLevel: header,
          quote: quote,
          listRow: block is MarkdownListItemBlock
              ? MarkdownListRow(
                  ordered: block.ordered,
                  depth: block.indent,
                  content: content,
                )
              : null,
          alignment: alignment.alignmentForLine(i),
          hasSourceBreak: end + 1 < owned.length,
          paragraphBoundaryAfter:
              markers.contains(end + 1) &&
              content.isNotEmpty &&
              header == null &&
              !quote &&
              block is! MarkdownListItemBlock,
          sourceSeparator:
              (raw.isEmpty && owned.length > 1) ||
              (quote && content.isEmpty && !empty),
        ),
      );
      i = end;
    }
    return List.unmodifiable(output);
  }
}

import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editable_block_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_blocks.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_projection.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_empty_paragraphs.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';

export 'package:wenyousite_mobile/core/markdown/markdown_editor_blocks.dart';

/// Quill 与持久化 Markdown 之间的中立块文档。
///
/// 段内 [MarkdownParagraphBlock.softLines] 保留单 LF；块间空行单独记录，
/// 协议空段则始终是独占 `<br />` 块。这样分隔线、标题与用户空段不会再
/// 依赖逐行字符串猜测。
class MarkdownEditorDocument {
  const MarkdownEditorDocument._({
    required this.blocks,
    required this.trailingBlankLines,
  });

  final List<MarkdownEditorBlock> blocks;
  final int trailingBlankLines;

  /// In-memory encoder marker used to retain an explicit Quill HR until the
  /// canonical writer has assigned its surrounding block separators.
  static const horizontalRuleMarker = '\uE001wenyou-horizontal-rule\uE001';

  List<MarkdownEditorBlockKind> get blockKinds =>
      List.unmodifiable(blocks.map((block) => block.kind));

  static MarkdownEditorDocument parse(
    String markdown, {
    bool imageAlignment = false,
  }) {
    final prepared = MarkdownEmptyParagraphs.prepareForLineEditor(markdown);
    return parsePrepared(
      MarkdownContent.normalize(prepared),
      imageAlignment: imageAlignment,
    );
  }

  static MarkdownEditorDocument parsePrepared(
    String source, {
    bool imageAlignment = false,
  }) {
    if (source.isEmpty) {
      return const MarkdownEditorDocument._(blocks: [], trailingBlankLines: 0);
    }
    final lines = source.split('\n');
    final lists = MarkdownListStructure.parse(source);
    final literalLines = MarkdownContent.unsupportedLineIndexes(
      source,
      imageAlignment: imageAlignment,
    );
    final alignmentAnalysis = MarkdownAlignmentContract.analyzeLines(
      lines,
      imageAlignment: imageAlignment,
    );
    final validAlignmentMarkers = alignmentAnalysis.validMarkerLines;
    final blocks = <MarkdownEditorBlock>[];
    var pendingBlankLines = 0;
    var index = 0;

    while (index < lines.length) {
      if (lines[index].isEmpty && !literalLines.contains(index)) {
        pendingBlankLines += 1;
        index += 1;
        continue;
      }
      final blankLinesBefore = pendingBlankLines;
      pendingBlankLines = 0;

      if (validAlignmentMarkers.contains(index)) {
        index += 1;
        pendingBlankLines = blankLinesBefore;
        continue;
      }

      final blockAlignment =
          alignmentAnalysis.blockStartingAt(index)?.alignment ??
          WenyouTextAlignment.left;

      if (lists[index] case final list? when !list.taskList) {
        for (var rowIndex = 0; rowIndex < list.rows.length; rowIndex++) {
          final row = list.rows[rowIndex];
          blocks.add(
            MarkdownListItemBlock(
              ordered: row.ordered,
              indent: row.depth,
              content: row.content,
              blankLinesBefore: rowIndex == 0 ? blankLinesBefore : 0,
              originalLines: rowIndex == 0 ? list.source.split('\n') : const [],
              listRange: rowIndex == 0 ? list : null,
            ),
          );
        }
        index = list.end;
        continue;
      }

      if (literalLines.contains(index)) {
        final compatibilityLines = <String>[];
        while (index < lines.length && literalLines.contains(index)) {
          compatibilityLines.add(lines[index]);
          index += 1;
        }
        blocks.add(
          MarkdownCompatibilityBlock(
            lines: List.unmodifiable(compatibilityLines),
            blankLinesBefore: blankLinesBefore,
          ),
        );
        continue;
      }

      final line = lines[index];
      if (_isSetextHeading(lines, literalLines, index)) {
        blocks.add(
          MarkdownHeadingBlock(
            level: 2,
            content: line,
            blankLinesBefore: blankLinesBefore,
            alignment: blockAlignment,
          ),
        );
        index += 2;
        continue;
      }
      final single = _singleLineBlock(
        line,
        blankLinesBefore,
        alignment: blockAlignment,
      );
      if (single != null) {
        blocks.add(single);
        index += 1;
        continue;
      }

      final softLines = <String>[line];
      index += 1;
      while (index < lines.length &&
          lines[index].isNotEmpty &&
          !literalLines.contains(index) &&
          !_isSetextHeading(lines, literalLines, index) &&
          !lists.containsKey(index) &&
          _singleLineBlock(lines[index], 0) == null &&
          !validAlignmentMarkers.contains(index)) {
        softLines.add(lines[index]);
        index += 1;
      }
      blocks.add(
        MarkdownParagraphBlock(
          softLines: List.unmodifiable(softLines),
          blankLinesBefore: blankLinesBefore,
          alignment: blockAlignment,
        ),
      );
    }

    return MarkdownEditorDocument._(
      blocks: List.unmodifiable(blocks),
      trailingBlankLines: pendingBlankLines,
    );
  }

  String toMarkdown() => MarkdownEditorProjection.sourceLines(
    blocks,
    trailingBlankLines,
  ).map((line) => line.source).join('\n');

  List<MarkdownEditorLine> editableLines({
    bool imageAlignment = false,
    bool readerClipboard = false,
  }) => MarkdownEditorProjection.project(
    blocks,
    trailingBlankLines,
    imageAlignment: imageAlignment,
    readerClipboard: readerClipboard,
  );

  bool structurallyEquivalentTo(MarkdownEditorDocument other) {
    final own = _structuralSignature();
    final candidate = other._structuralSignature();
    if (own.length != candidate.length) return false;
    for (var index = 0; index < own.length; index++) {
      if (own[index] != candidate[index]) return false;
    }
    return true;
  }

  List<String> _structuralSignature() {
    final signature = <String>[];
    MarkdownEditorBlock? previous;
    for (final block in blocks) {
      final gap = previous == null
          ? block.blankLinesBefore
          : previous.kind == MarkdownEditorBlockKind.horizontalRule ||
                block.kind == MarkdownEditorBlockKind.horizontalRule
          ? 1
          : block.blankLinesBefore;
      signature.add('$gap:${block.structuralKey}');
      previous = block;
    }
    signature.add(
      'trailing:${previous?.kind == MarkdownEditorBlockKind.horizontalRule ? 0 : trailingBlankLines}',
    );
    return signature;
  }

  static MarkdownEditorBlock? _singleLineBlock(
    String line,
    int blankLinesBefore, {
    WenyouTextAlignment alignment = WenyouTextAlignment.left,
  }) {
    if (MarkdownAlignmentContract.isThematicBreak(line) ||
        line == horizontalRuleMarker) {
      return MarkdownHorizontalRuleBlock(blankLinesBefore: blankLinesBefore);
    }
    if (line == '<br />') {
      return MarkdownProtocolEmptyBlock(blankLinesBefore: blankLinesBefore);
    }
    final heading = MarkdownEditableBlockSyntax.heading(line);
    if (heading != null) {
      return MarkdownHeadingBlock(
        level: heading.level,
        content: heading.content,
        blankLinesBefore: blankLinesBefore,
        alignment: alignment,
      );
    }
    final quote = MarkdownContent.quoteLineContent(line);
    if (quote != null) {
      return MarkdownQuoteBlock(
        content: quote,
        blankLinesBefore: blankLinesBefore,
      );
    }
    final list = MarkdownEditableBlockSyntax.listItem(line);
    if (list != null) {
      return MarkdownListItemBlock(
        ordered: list.ordered,
        indent: list.indent,
        content: list.content,
        blankLinesBefore: blankLinesBefore,
      );
    }
    return null;
  }

  static bool _isSetextHeading(
    List<String> lines,
    Set<int> literalLines,
    int index,
  ) {
    if (index + 1 >= lines.length ||
        lines[index].isEmpty ||
        !RegExp(r'^ {0,3}-+[\t ]*$').hasMatch(lines[index + 1]) ||
        literalLines.contains(index) ||
        literalLines.contains(index + 1) ||
        _singleLineBlock(lines[index], 0) != null) {
      return false;
    }
    final nodes = md.Document().parseLines([lines[index], lines[index + 1]]);
    return nodes.length == 1 &&
        nodes.single is md.Element &&
        (nodes.single as md.Element).tag == 'h2';
  }
}

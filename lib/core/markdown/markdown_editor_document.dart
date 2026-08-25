import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_empty_paragraphs.dart';

enum MarkdownEditorBlockKind {
  paragraph,
  heading2,
  heading3,
  quote,
  bulletListItem,
  orderedListItem,
  horizontalRule,
  protocolEmptyParagraph,
  compatibilityText,
}

sealed class MarkdownEditorBlock {
  const MarkdownEditorBlock({required this.blankLinesBefore});

  final int blankLinesBefore;
  MarkdownEditorBlockKind get kind;
  List<String> get sourceLines;
  String get structuralKey => kind.name;
}

final class MarkdownParagraphBlock extends MarkdownEditorBlock {
  const MarkdownParagraphBlock({
    required this.softLines,
    required super.blankLinesBefore,
  });

  final List<String> softLines;

  @override
  MarkdownEditorBlockKind get kind => MarkdownEditorBlockKind.paragraph;

  @override
  List<String> get sourceLines => softLines;

  @override
  String get structuralKey => '${kind.name}:${softLines.length}';
}

final class MarkdownHeadingBlock extends MarkdownEditorBlock {
  const MarkdownHeadingBlock({
    required this.level,
    required this.content,
    required super.blankLinesBefore,
  });

  final int level;
  final String content;

  @override
  MarkdownEditorBlockKind get kind => level == 2
      ? MarkdownEditorBlockKind.heading2
      : MarkdownEditorBlockKind.heading3;

  @override
  List<String> get sourceLines => ['${'#' * level} $content'];
}

final class MarkdownQuoteBlock extends MarkdownEditorBlock {
  const MarkdownQuoteBlock({
    required this.content,
    required super.blankLinesBefore,
  });

  final String content;

  @override
  MarkdownEditorBlockKind get kind => MarkdownEditorBlockKind.quote;

  @override
  List<String> get sourceLines => ['> $content'];
}

final class MarkdownListItemBlock extends MarkdownEditorBlock {
  const MarkdownListItemBlock({
    required this.ordered,
    required this.indent,
    required this.content,
    required super.blankLinesBefore,
  });

  final bool ordered;
  final int indent;
  final String content;

  @override
  MarkdownEditorBlockKind get kind => ordered
      ? MarkdownEditorBlockKind.orderedListItem
      : MarkdownEditorBlockKind.bulletListItem;

  @override
  List<String> get sourceLines => [
    '${'  ' * indent}${ordered ? '1.' : '-'} $content',
  ];

  @override
  String get structuralKey => '${kind.name}:$indent';
}

final class MarkdownHorizontalRuleBlock extends MarkdownEditorBlock {
  const MarkdownHorizontalRuleBlock({required super.blankLinesBefore});

  @override
  MarkdownEditorBlockKind get kind => MarkdownEditorBlockKind.horizontalRule;

  @override
  List<String> get sourceLines => const ['---'];
}

final class MarkdownProtocolEmptyBlock extends MarkdownEditorBlock {
  const MarkdownProtocolEmptyBlock({required super.blankLinesBefore});

  @override
  MarkdownEditorBlockKind get kind =>
      MarkdownEditorBlockKind.protocolEmptyParagraph;

  @override
  List<String> get sourceLines => const ['<br />'];
}

final class MarkdownCompatibilityBlock extends MarkdownEditorBlock {
  const MarkdownCompatibilityBlock({
    required this.lines,
    required super.blankLinesBefore,
  });

  final List<String> lines;

  @override
  MarkdownEditorBlockKind get kind => MarkdownEditorBlockKind.compatibilityText;

  @override
  List<String> get sourceLines => lines;

  @override
  String get structuralKey => '${kind.name}:${lines.length}';
}

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

  static MarkdownEditorDocument parse(String markdown) {
    final prepared = MarkdownEmptyParagraphs.prepareForLineEditor(markdown);
    return parsePrepared(MarkdownContent.normalize(prepared));
  }

  static MarkdownEditorDocument parsePrepared(String source) {
    if (source.isEmpty) {
      return const MarkdownEditorDocument._(blocks: [], trailingBlankLines: 0);
    }
    final lines = source.split('\n');
    final literalLines = MarkdownContent.unsupportedLineIndexes(source);
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
          ),
        );
        index += 2;
        continue;
      }
      final single = _singleLineBlock(line, blankLinesBefore);
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
          _singleLineBlock(lines[index], 0) == null) {
        softLines.add(lines[index]);
        index += 1;
      }
      blocks.add(
        MarkdownParagraphBlock(
          softLines: List.unmodifiable(softLines),
          blankLinesBefore: blankLinesBefore,
        ),
      );
    }

    return MarkdownEditorDocument._(
      blocks: List.unmodifiable(blocks),
      trailingBlankLines: pendingBlankLines,
    );
  }

  String toMarkdown() {
    if (blocks.isEmpty) return '';
    final output = StringBuffer();
    MarkdownEditorBlock? previous;
    for (final block in blocks) {
      final gap = previous == null
          ? block.blankLinesBefore
          : previous.kind == MarkdownEditorBlockKind.horizontalRule ||
                block.kind == MarkdownEditorBlockKind.horizontalRule
          ? 1
          : block.blankLinesBefore;
      if (output.isNotEmpty || gap > 0) {
        output.write('\n' * (previous == null ? gap : gap + 1));
      }
      output.write(block.sourceLines.join('\n'));
      previous = block;
    }
    if (trailingBlankLines > 0 &&
        previous?.kind != MarkdownEditorBlockKind.horizontalRule) {
      output.write('\n' * trailingBlankLines);
    }
    return output.toString();
  }

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
    int blankLinesBefore,
  ) {
    if (line == '---' || line == horizontalRuleMarker) {
      return MarkdownHorizontalRuleBlock(blankLinesBefore: blankLinesBefore);
    }
    if (line == '<br />') {
      return MarkdownProtocolEmptyBlock(blankLinesBefore: blankLinesBefore);
    }
    final heading = RegExp(r'^(#{2,3}) (.+)$').firstMatch(line);
    if (heading != null) {
      return MarkdownHeadingBlock(
        level: heading.group(1)!.length,
        content: heading.group(2)!,
        blankLinesBefore: blankLinesBefore,
      );
    }
    final quote = RegExp(r'^> (.+)$').firstMatch(line);
    if (quote != null) {
      return MarkdownQuoteBlock(
        content: quote.group(1)!,
        blankLinesBefore: blankLinesBefore,
      );
    }
    final list = RegExp(r'^( {0,6})(- |1\. )(.+)$').firstMatch(line);
    if (list != null && list.group(1)!.length.isEven) {
      return MarkdownListItemBlock(
        ordered: list.group(2) == '1. ',
        indent: list.group(1)!.length ~/ 2,
        content: list.group(3)!,
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
        lines[index + 1] != '---' ||
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

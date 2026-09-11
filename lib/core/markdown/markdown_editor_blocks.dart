import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editable_block_syntax.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';

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
  const MarkdownEditorBlock({
    required this.blankLinesBefore,
    this.alignment = WenyouTextAlignment.left,
  });

  final int blankLinesBefore;
  final WenyouTextAlignment alignment;
  MarkdownEditorBlockKind get kind;
  List<String> get sourceLines;
  String get structuralKey => '${kind.name}:${alignment.name}';
}

final class MarkdownParagraphBlock extends MarkdownEditorBlock {
  const MarkdownParagraphBlock({
    required this.softLines,
    required super.blankLinesBefore,
    super.alignment,
  });

  final List<String> softLines;

  @override
  MarkdownEditorBlockKind get kind => MarkdownEditorBlockKind.paragraph;

  @override
  List<String> get sourceLines => _withAlignmentMarker(softLines, alignment);

  @override
  String get structuralKey =>
      '${kind.name}:${alignment.name}:${softLines.length}';
}

final class MarkdownHeadingBlock extends MarkdownEditorBlock {
  const MarkdownHeadingBlock({
    required this.level,
    required this.content,
    required super.blankLinesBefore,
    super.alignment,
  });

  final int level;
  final String content;

  @override
  MarkdownEditorBlockKind get kind => level == 2
      ? MarkdownEditorBlockKind.heading2
      : MarkdownEditorBlockKind.heading3;

  @override
  List<String> get sourceLines => _withAlignmentMarker([
    MarkdownEditableBlockSyntax.headingLine(level, content),
  ], alignment);
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
  List<String> get sourceLines => [content.isEmpty ? '>' : '> $content'];
}

final class MarkdownListItemBlock extends MarkdownEditorBlock {
  const MarkdownListItemBlock({
    required this.ordered,
    required this.indent,
    required this.content,
    required super.blankLinesBefore,
    this.originalLines,
    this.listRange,
  });

  final bool ordered;
  final int indent;
  final String content;
  final List<String>? originalLines;
  final MarkdownListRange? listRange;

  @override
  MarkdownEditorBlockKind get kind => ordered
      ? MarkdownEditorBlockKind.orderedListItem
      : MarkdownEditorBlockKind.bulletListItem;

  @override
  List<String> get sourceLines =>
      originalLines ??
      [
        MarkdownEditableBlockSyntax.listLine(
          ordered: ordered,
          indent: indent,
          content: content,
        ),
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

List<String> _withAlignmentMarker(
  List<String> lines,
  WenyouTextAlignment alignment,
) {
  final marker = MarkdownAlignmentContract.markerFor(alignment);
  return marker.isEmpty ? lines : [marker, ...lines];
}

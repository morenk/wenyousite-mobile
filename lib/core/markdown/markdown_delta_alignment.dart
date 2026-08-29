import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';

abstract final class MarkdownDeltaAlignment {
  static const attribute = 'align';

  static WenyouTextAlignment selectionAlignment(
    Delta delta, {
    required int start,
    required int end,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final blocks = _selectedBlocks(
      delta,
      start: start,
      end: end,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    if (blocks.isEmpty) return WenyouTextAlignment.left;
    final first = blocks.first.alignment;
    return blocks.every((block) => block.alignment == first)
        ? first
        : WenyouTextAlignment.left;
  }

  static Delta cycleSelection(
    Delta delta, {
    required int start,
    required int end,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final blocks = _selectedBlocks(
      delta,
      start: start,
      end: end,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    if (blocks.isEmpty) return Delta();
    final current =
        blocks.every((block) => block.alignment == blocks.first.alignment)
        ? blocks.first.alignment
        : WenyouTextAlignment.left;
    final next = switch (current) {
      WenyouTextAlignment.left => WenyouTextAlignment.center,
      WenyouTextAlignment.center => WenyouTextAlignment.right,
      WenyouTextAlignment.right => WenyouTextAlignment.left,
    };
    return _attributePatch([for (final block in blocks) ...block.lines], next);
  }

  /// Removes inherited or malformed alignment and keeps every physical line
  /// in one Markdown paragraph on the same alignment value.
  static Delta sanitize(
    Delta delta, {
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final lines = _readLines(
      delta,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    final desired = <_DeltaLine, WenyouTextAlignment>{};
    final paragraph = <_DeltaLine>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      final valid = paragraph.every((line) => line.isEligibleParagraphLine);
      final stored = paragraph.map((line) => line.alignment).toSet();
      final alignment = valid && stored.length == 1
          ? stored.single
          : WenyouTextAlignment.left;
      for (final line in paragraph) {
        desired[line] = alignment;
      }
      paragraph.clear();
    }

    for (final line in lines) {
      if (line.isParagraphShape) {
        paragraph.add(line);
        continue;
      }
      flushParagraph();
      desired[line] = line.isEligibleHeading
          ? line.alignment
          : WenyouTextAlignment.left;
    }
    flushParagraph();

    final changes = <_LineAlignmentChange>[];
    for (final line in lines) {
      final target = desired[line] ?? WenyouTextAlignment.left;
      final raw = line.attributes[attribute];
      final expected = target == WenyouTextAlignment.left ? null : target.name;
      if (raw != expected) {
        changes.add(_LineAlignmentChange(line.newlineOffset, target));
      }
    }
    return _changesPatch(changes);
  }

  static List<_AlignmentBlock> _selectedBlocks(
    Delta delta, {
    required int start,
    required int end,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final lines = _readLines(
      delta,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    final blocks = <_AlignmentBlock>[];
    final paragraph = <_DeltaLine>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      if (paragraph.every((line) => line.isEligibleParagraphLine)) {
        blocks.add(_AlignmentBlock(List.unmodifiable(paragraph)));
      }
      paragraph.clear();
    }

    for (final line in lines) {
      if (line.isParagraphShape) {
        paragraph.add(line);
        continue;
      }
      flushParagraph();
      if (line.isEligibleHeading) {
        blocks.add(_AlignmentBlock([line]));
      }
    }
    flushParagraph();

    final collapsed = start == end;
    return blocks
        .where((block) {
          if (collapsed) return start >= block.start && start < block.end;
          return start < block.end && end > block.start;
        })
        .toList(growable: false);
  }

  static Delta _attributePatch(
    List<_DeltaLine> lines,
    WenyouTextAlignment alignment,
  ) => _changesPatch([
    for (final line in lines)
      _LineAlignmentChange(line.newlineOffset, alignment),
  ]);

  static Delta _changesPatch(List<_LineAlignmentChange> changes) {
    if (changes.isEmpty) return Delta();
    changes.sort((left, right) => left.offset.compareTo(right.offset));
    final patch = Delta();
    var cursor = 0;
    for (final change in changes) {
      if (change.offset > cursor) patch.retain(change.offset - cursor);
      patch.retain(1, {
        attribute: change.alignment == WenyouTextAlignment.left
            ? null
            : change.alignment.name,
      });
      cursor = change.offset + 1;
    }
    return patch;
  }

  static List<_DeltaLine> _readLines(
    Delta delta, {
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final lines = <_DeltaLine>[];
    var documentOffset = 0;
    var lineStart = 0;
    var hasMeaningfulContent = false;
    var hasRegularImage = false;
    var hasHorizontalRule = false;

    void finishLine(Map<String, dynamic>? attributes) {
      lines.add(
        _DeltaLine(
          startOffset: lineStart,
          newlineOffset: documentOffset,
          hasMeaningfulContent: hasMeaningfulContent,
          hasRegularImage: hasRegularImage,
          hasHorizontalRule: hasHorizontalRule,
          attributes: Map.unmodifiable(attributes ?? const {}),
        ),
      );
      lineStart = documentOffset + 1;
      hasMeaningfulContent = false;
      hasRegularImage = false;
      hasHorizontalRule = false;
    }

    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is String) {
        var segmentStart = 0;
        for (var index = 0; index < data.length; index++) {
          if (data[index] != '\n') continue;
          if (data.substring(segmentStart, index).trim().isNotEmpty) {
            hasMeaningfulContent = true;
          }
          documentOffset += index - segmentStart;
          finishLine(operation.attributes);
          documentOffset += 1;
          segmentStart = index + 1;
        }
        if (segmentStart < data.length) {
          if (data.substring(segmentStart).trim().isNotEmpty) {
            hasMeaningfulContent = true;
          }
          documentOffset += data.length - segmentStart;
        }
        continue;
      }

      if (data is Map) {
        final embed = Map<String, dynamic>.from(data);
        hasRegularImage = hasRegularImage || embed.containsKey(imageEmbed);
        hasHorizontalRule =
            hasHorizontalRule || embed.containsKey(horizontalRuleEmbed);
        hasMeaningfulContent = hasMeaningfulContent || !hasHorizontalRule;
      }
      documentOffset += operation.length ?? 0;
    }
    return List.unmodifiable(lines);
  }
}

final class _DeltaLine {
  const _DeltaLine({
    required this.startOffset,
    required this.newlineOffset,
    required this.hasMeaningfulContent,
    required this.hasRegularImage,
    required this.hasHorizontalRule,
    required this.attributes,
  });

  final int startOffset;
  final int newlineOffset;
  final bool hasMeaningfulContent;
  final bool hasRegularImage;
  final bool hasHorizontalRule;
  final Map<String, dynamic> attributes;

  WenyouTextAlignment get alignment => switch (attributes['align']) {
    'center' => WenyouTextAlignment.center,
    'right' => WenyouTextAlignment.right,
    _ => WenyouTextAlignment.left,
  };

  bool get _hasExcludedAttributes =>
      attributes['list'] != null ||
      attributes['blockquote'] == true ||
      attributes['indent'] != null ||
      attributes['wenyou_empty_paragraph'] == true ||
      attributes['wenyou_literal_line'] == true;

  bool get isParagraphShape =>
      attributes['header'] == null &&
      !_hasExcludedAttributes &&
      !hasHorizontalRule &&
      (hasMeaningfulContent || hasRegularImage);

  bool get isEligibleParagraphLine =>
      isParagraphShape && hasMeaningfulContent && !hasRegularImage;

  bool get isEligibleHeading =>
      (attributes['header'] == 2 || attributes['header'] == 3) &&
      !_hasExcludedAttributes &&
      hasMeaningfulContent &&
      !hasRegularImage &&
      !hasHorizontalRule;
}

final class _AlignmentBlock {
  const _AlignmentBlock(this.lines);

  final List<_DeltaLine> lines;

  int get start => lines.first.startOffset;
  int get end => lines.last.newlineOffset + 1;

  WenyouTextAlignment get alignment {
    final first = lines.first.alignment;
    return lines.every((line) => line.alignment == first)
        ? first
        : WenyouTextAlignment.left;
  }
}

final class _LineAlignmentChange {
  const _LineAlignmentChange(this.offset, this.alignment);

  final int offset;
  final WenyouTextAlignment alignment;
}

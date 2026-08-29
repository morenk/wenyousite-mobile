import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';

abstract final class MarkdownDeltaAlignment {
  static const attribute = 'align';

  static MarkdownAlignmentSelectionState selectionState(
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
    if (blocks.isEmpty) {
      return const MarkdownAlignmentSelectionState.unavailable();
    }
    final alignments = {
      for (final block in blocks)
        for (final line in block.lines) line.alignment,
    };
    return MarkdownAlignmentSelectionState(
      canApply: true,
      alignment: alignments.length == 1 ? alignments.single : null,
    );
  }

  static WenyouTextAlignment selectionAlignment(
    Delta delta, {
    required int start,
    required int end,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    return selectionState(
          delta,
          start: start,
          end: end,
          imageEmbed: imageEmbed,
          horizontalRuleEmbed: horizontalRuleEmbed,
        ).alignment ??
        WenyouTextAlignment.left;
  }

  static Delta applySelection(
    Delta delta, {
    required int start,
    required int end,
    required WenyouTextAlignment alignment,
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
    return _attributePatch([
      for (final block in blocks) ...block.lines,
    ], alignment);
  }

  static Delta cycleSelection(
    Delta delta, {
    required int start,
    required int end,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final state = selectionState(
      delta,
      start: start,
      end: end,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    if (!state.canApply) return Delta();
    final current = state.alignment ?? WenyouTextAlignment.left;
    final next = switch (current) {
      WenyouTextAlignment.left => WenyouTextAlignment.center,
      WenyouTextAlignment.center => WenyouTextAlignment.right,
      WenyouTextAlignment.right => WenyouTextAlignment.left,
    };
    return applySelection(
      delta,
      start: start,
      end: end,
      alignment: next,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
  }

  /// Normalizes Enter at the end of an aligned paragraph.
  ///
  /// The first Enter carries the alignment onto the new empty line. Quill's
  /// block auto-exit rule consumes a second Enter by only clearing alignment;
  /// turn that event into an actual empty paragraph so the following left
  /// aligned input cannot be merged back into the preceding aligned paragraph.
  static Delta repairTrailingNewlineAlignment({
    required Delta before,
    required Delta after,
    required String imageEmbed,
    required String horizontalRuleEmbed,
  }) {
    final beforeLines = _readLines(
      before,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    final afterLines = _readLines(
      after,
      imageEmbed: imageEmbed,
      horizontalRuleEmbed: horizontalRuleEmbed,
    );
    if (beforeLines.isEmpty) {
      return Delta();
    }
    if (afterLines.length == beforeLines.length) {
      final previousPendingLine = beforeLines.last;
      final exitedLine = afterLines.last;
      if (previousPendingLine.isTrailingEmptyLine &&
          previousPendingLine.alignment != WenyouTextAlignment.left &&
          exitedLine.isTrailingEmptyLine &&
          exitedLine.alignment == WenyouTextAlignment.left &&
          exitedLine.startOffset == previousPendingLine.startOffset &&
          exitedLine.newlineOffset == previousPendingLine.newlineOffset) {
        return Delta()
          ..retain(exitedLine.newlineOffset)
          ..insert('\n');
      }
      return Delta();
    }
    if (afterLines.length != beforeLines.length + 1) return Delta();
    final previousLine = afterLines[afterLines.length - 2];
    final pendingLine = afterLines.last;
    if (!beforeLines.last.isEligibleParagraphLine ||
        beforeLines.last.alignment == WenyouTextAlignment.left ||
        !previousLine.isEligibleParagraphLine ||
        previousLine.alignment != beforeLines.last.alignment ||
        !pendingLine.isTrailingEmptyLine ||
        pendingLine.alignment != WenyouTextAlignment.left) {
      return Delta();
    }
    return _changesPatch([
      _LineAlignmentChange(pendingLine.newlineOffset, previousLine.alignment),
    ]);
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
      final last = paragraph.last;
      final valid = paragraph.every(
        (line) =>
            line.isEligibleParagraphLine ||
            (identical(line, last) && line.isTrailingEmptyLine),
      );
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
      final joinsTrailingEmptyLine =
          line.isTrailingEmptyLine &&
          paragraph.isNotEmpty &&
          line.alignment != WenyouTextAlignment.left &&
          line.alignment == paragraph.last.alignment;
      if (line.isParagraphShape || joinsTrailingEmptyLine) {
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
      final last = paragraph.last;
      if (paragraph.every(
        (line) =>
            line.isEligibleParagraphLine ||
            (identical(line, last) && line.isTrailingEmptyLine),
      )) {
        blocks.add(_AlignmentBlock(List.unmodifiable(paragraph)));
      }
      paragraph.clear();
    }

    for (final line in lines) {
      final joinsTrailingEmptyLine =
          line.isTrailingEmptyLine &&
          paragraph.isNotEmpty &&
          line.alignment != WenyouTextAlignment.left &&
          line.alignment == paragraph.last.alignment;
      if (line.isParagraphShape || joinsTrailingEmptyLine) {
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

final class MarkdownAlignmentSelectionState {
  const MarkdownAlignmentSelectionState({
    required this.canApply,
    required this.alignment,
  });

  const MarkdownAlignmentSelectionState.unavailable()
    : canApply = false,
      alignment = null;

  final bool canApply;
  final WenyouTextAlignment? alignment;
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

  bool get isPlainEmptyLine =>
      attributes['header'] == null &&
      !_hasExcludedAttributes &&
      attributes['wenyou_source_separator'] != true &&
      !hasMeaningfulContent &&
      !hasRegularImage &&
      !hasHorizontalRule;

  bool get isTrailingEmptyLine =>
      isPlainEmptyLine && attributes['wenyou_source_break'] == false;
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

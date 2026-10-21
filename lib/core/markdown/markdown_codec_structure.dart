import 'package:flutter_quill/quill_delta.dart';

/// 只保留数量与固定类别；不持有正文、节点载荷、链接或 Delta。
final class MarkdownCodecStructure {
  const MarkdownCodecStructure({
    required this.lines,
    required this.textUnits,
    required this.embeds,
    required this.dividers,
    required this.images,
    required this.emptyLines,
    required this.listLines,
    required this.alignedLines,
    required this.styledRuns,
    this.differenceLine,
    this.differenceKind,
  });

  factory MarkdownCodecStructure.inspect(
    Delta delta, {
    ({int line, String kind})? difference,
  }) {
    var lines = 0;
    var textUnits = 0;
    var embeds = 0;
    var dividers = 0;
    var images = 0;
    var emptyLines = 0;
    var listLines = 0;
    var alignedLines = 0;
    var styledRuns = 0;
    var hasContent = false;
    for (final op in delta.operations) {
      if (!op.isInsert) continue;
      final value = op.data;
      if (value is! String) {
        embeds++;
        hasContent = true;
        if (value is Map) {
          if (value.containsKey('wenyou_horizontal_rule')) dividers++;
          if (value.containsKey('wenyou_image')) images++;
        }
        continue;
      }
      if (op.attributes?.keys.any(
            const {
              'bold',
              'italic',
              'strike',
              'code',
              'link',
              'color',
            }.contains,
          ) ==
          true) {
        styledRuns++;
      }
      for (final unit in value.codeUnits) {
        if (unit != 10) {
          textUnits++;
          hasContent = true;
          continue;
        }
        lines++;
        if (!hasContent) emptyLines++;
        if (op.attributes?['list'] != null) listLines++;
        if (op.attributes?['align'] != null) alignedLines++;
        hasContent = false;
      }
    }
    return MarkdownCodecStructure(
      lines: lines,
      textUnits: textUnits,
      embeds: embeds,
      dividers: dividers,
      images: images,
      emptyLines: emptyLines,
      listLines: listLines,
      alignedLines: alignedLines,
      styledRuns: styledRuns,
      differenceLine: difference?.line,
      differenceKind: difference?.kind,
    );
  }

  final int lines;
  final int textUnits;
  final int embeds;
  final int dividers;
  final int images;
  final int emptyLines;
  final int listLines;
  final int alignedLines;
  final int styledRuns;
  final int? differenceLine;
  final String? differenceKind;

  Map<String, Object?> get diagnosticFields => {
    'codecStructureVersion': 1,
    'codecLines': lines,
    'codecTextUnits': textUnits,
    'codecEmbeds': embeds,
    'codecDividers': dividers,
    'codecImages': images,
    'codecEmptyLines': emptyLines,
    'codecListLines': listLines,
    'codecAlignedLines': alignedLines,
    'codecStyledRuns': styledRuns,
    if (differenceLine != null) 'codecDifferenceLine': differenceLine,
    if (differenceKind != null) 'codecDifferenceKind': differenceKind,
  };
}

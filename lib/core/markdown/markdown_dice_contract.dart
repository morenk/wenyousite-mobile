import 'package:flutter_quill/quill_delta.dart';

/// Mobile compatibility guard for the backend-owned Markdown dice protocol.
class MarkdownDiceContract {
  MarkdownDiceContract._();

  static const embedType = 'wenyou_dice';
  static const maximumNodesPerPost = 20;
  static const minimumQuantity = 1;
  static const maximumQuantity = 100;
  static const minimumSides = 2;
  static const maximumSides = 1000;
  static const maximumModifierMagnitude = 10000;

  static final nodeAtStart = RegExp(
    r'^\[\[dice:v1:([0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}):([^\]\r\n]{1,32})\]\]',
    caseSensitive: false,
  );
  static final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  static final _notation = RegExp(
    r'^\s*(?:(\d+)\s*)?[dD]\s*(\d+)(?:\s*([+-])\s*(\d+))?\s*$',
  );
  static final _fence = RegExp(r'^ {0,3}(`{3,}|~{3,})');

  static String? normalizeNotation(String value) {
    final match = _notation.firstMatch(value);
    if (match == null) return null;
    final quantity = int.tryParse(match.group(1) ?? '1');
    final sides = int.tryParse(match.group(2)!);
    final magnitude = int.tryParse(match.group(4) ?? '0');
    if (quantity == null ||
        sides == null ||
        magnitude == null ||
        quantity < minimumQuantity ||
        quantity > maximumQuantity ||
        sides < minimumSides ||
        sides > maximumSides ||
        magnitude > maximumModifierMagnitude) {
      return null;
    }
    final sign = match.group(3);
    final modifier = magnitude == 0
        ? ''
        : '${sign == '-' ? '-' : '+'}$magnitude';
    return '${quantity}d$sides$modifier';
  }

  static int countDeltaNodes(Delta delta) =>
      delta.operations.where((operation) {
        final data = operation.data;
        return data is Map && data[embedType] is Map;
      }).length;

  static int countMarkdownNodes(String markdown) {
    var count = 0;
    _transformMarkdownNodes(markdown, onNode: (_) => count += 1);
    return count;
  }

  static String removeMarkdownNodes(String markdown) =>
      _transformMarkdownNodes(markdown);

  static String _transformMarkdownNodes(
    String markdown, {
    void Function(Match match)? onNode,
  }) {
    final lines = markdown.replaceAll(RegExp(r'\r\n?'), '\n').split('\n');
    String? fenceMarker;
    var fenceLength = 0;
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final fence = _fence.firstMatch(line)?.group(1);
      if (fenceMarker != null) {
        if (fence != null &&
            fence[0] == fenceMarker &&
            fence.length >= fenceLength &&
            RegExp(
              '^ {0,3}${RegExp.escape(fenceMarker)}{$fenceLength,}[\\t ]*\$',
            ).hasMatch(line)) {
          fenceMarker = null;
          fenceLength = 0;
        }
        continue;
      }
      if (fence != null) {
        fenceMarker = fence[0];
        fenceLength = fence.length;
        continue;
      }
      lines[lineIndex] = _transformLine(line, onNode);
    }
    return lines.join('\n');
  }

  static String _transformLine(
    String line,
    void Function(Match match)? onNode,
  ) {
    final output = StringBuffer();
    var index = 0;
    while (index < line.length) {
      if (line[index] == r'\' && index + 1 < line.length) {
        output.write(line.substring(index, index + 2));
        index += 2;
        continue;
      }
      if (line[index] == '`') {
        var runLength = 1;
        while (index + runLength < line.length &&
            line[index + runLength] == '`') {
          runLength += 1;
        }
        final delimiter = '`' * runLength;
        final closing = line.indexOf(delimiter, index + runLength);
        if (closing == -1) {
          output.write(line.substring(index));
          break;
        }
        output.write(line.substring(index, closing + runLength));
        index = closing + runLength;
        continue;
      }
      final match = nodeAtStart.firstMatch(line.substring(index));
      if (match != null && normalizeNotation(match.group(2)!) != null) {
        onNode?.call(match);
        index += match.group(0)!.length;
        continue;
      }
      output.write(line[index]);
      index += 1;
    }
    return output.toString();
  }
}

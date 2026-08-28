import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// Projects Markdown or an editor Delta to the text visible to a reader.
///
/// Generated Markdown delimiters, hidden atom identities and media URLs never
/// enter the system clipboard fallback. Literal characters typed by the user
/// remain visible because the codec distinguishes them from generated syntax.
abstract final class MarkdownClipboardText {
  static String project(
    String markdown, {
    Map<String, String> diceLabels = const {},
  }) => projectDelta(
    MarkdownDeltaCodec.decode(markdown).delta,
    diceLabels: diceLabels,
  );

  static String projectDelta(
    Delta delta, {
    Map<String, String> diceLabels = const {},
  }) {
    final lines = <String>[];
    final line = StringBuffer();
    var omitLine = false;

    void finishLine(Map<String, dynamic>? attributes) {
      if (!omitLine) {
        var value = line.toString();
        final list = attributes?['list'];
        if (value.isNotEmpty && list == 'bullet') {
          value = '• $value';
        } else if (value.isNotEmpty && list == 'ordered') {
          value = '1. $value';
        }
        lines.add(value);
      }
      line.clear();
      omitLine = false;
    }

    for (final operation in delta.operations) {
      final data = operation.data;
      if (data is String) {
        var start = 0;
        for (var index = 0; index < data.length; index++) {
          if (data[index] != '\n') continue;
          if (index > start) line.write(data.substring(start, index));
          finishLine(operation.attributes);
          start = index + 1;
        }
        if (start < data.length) line.write(data.substring(start));
        continue;
      }
      if (data is! Map || data.length != 1) continue;
      final embed = Map<String, dynamic>.from(data);
      final type = embed.keys.single;
      final rawPayload = embed[type];
      if (rawPayload is! Map) continue;
      final payload = Map<String, dynamic>.from(rawPayload);
      switch (type) {
        case MarkdownDeltaCodec.mentionEmbed:
          line.write(payload['label'] as String? ?? '@全体玩家');
        case MarkdownDeltaCodec.diceEmbed:
          final nodeId = (payload['nodeId'] as String?)?.toLowerCase();
          final notation = payload['notation'] as String? ?? '骰子';
          line.write(
            nodeId == null
                ? '$notation = ?'
                : diceLabels[nodeId] ?? '$notation = ?',
          );
        case MarkdownDeltaCodec.stickerEmbed:
          line.write('[表情]');
        case MarkdownDeltaCodec.imageEmbed:
          line.write('[图片]');
        case MarkdownDeltaCodec.internalReferenceEmbed:
          final rawLabel =
              payload['label'] as String? ?? internalReferenceDefaultLabel;
          final rawLocation = payload['location'] as String?;
          final reference = rawLocation == null
              ? null
              : parseInternalReference(rawLocation);
          line.write(
            reference == null
                ? rawLabel
                : resolveInternalReferenceLabel(
                    label: rawLabel,
                    reference: reference,
                  ),
          );
        case MarkdownDeltaCodec.compatibilityEmbed:
          line.write(payload['raw'] as String? ?? '');
        case MarkdownDeltaCodec.horizontalRuleEmbed:
          omitLine = true;
      }
    }
    if (line.isNotEmpty && !omitLine) lines.add(line.toString());

    while (lines.isNotEmpty && lines.first.isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }
    final compact = <String>[];
    for (final value in lines) {
      if (value.isEmpty && compact.isNotEmpty && compact.last.isEmpty) continue;
      compact.add(value);
    }
    return compact.join('\n').replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }
}

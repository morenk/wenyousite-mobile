import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// Projects persisted content to the text written by reading-surface copy
/// actions.
///
/// Ordinary Markdown stays source-identical. Only supported inline atomic
/// nodes become their visible label, and protected code or escaped source is
/// never interpreted as an atom.
abstract final class MarkdownClipboardText {
  static const _stickerPrefix = 'wenyousite-sticker:v1:';
  static const _stickerLabel = '[表情]';

  static final _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  static final _mention = RegExp(
    r'^\[(@[^\]\r\n]{1,32})\]\(/users/([a-zA-Z0-9_-]+)\)',
  );
  static final _markdownLink = RegExp(
    r'^\[((?:\\[\\\[\]]|[^\[\]\\\r\n])*)\]\([^)\r\n]+\)',
  );
  static final _image = RegExp(
    r'''^!\[([^\]\n]*)\]\(\s*([^\s)]+)(?:\s+["']([^"'\n]*)["'])?\s*\)''',
  );
  static final _stickerAssetId = RegExp(r'^c[a-z0-9]{20,}$');

  static String project(
    String markdown, {
    Map<String, String> diceLabels = const {},
  }) {
    final output = StringBuffer();
    String? fenceMarker;
    var fenceLength = 0;
    var offset = 0;
    for (final separator in RegExp(r'\r\n|\r|\n').allMatches(markdown)) {
      final line = markdown.substring(offset, separator.start);
      final transformed = _transformLine(
        line,
        diceLabels,
        fenceMarker: fenceMarker,
        fenceLength: fenceLength,
      );
      output
        ..write(transformed.text)
        ..write(separator.group(0));
      fenceMarker = transformed.fenceMarker;
      fenceLength = transformed.fenceLength;
      offset = separator.end;
    }
    final transformed = _transformLine(
      markdown.substring(offset),
      diceLabels,
      fenceMarker: fenceMarker,
      fenceLength: fenceLength,
    );
    output.write(transformed.text);
    return output.toString();
  }

  static ({String text, String? fenceMarker, int fenceLength}) _transformLine(
    String line,
    Map<String, String> diceLabels, {
    required String? fenceMarker,
    required int fenceLength,
  }) {
    final fence = _openingFence.firstMatch(line)?.group(1);
    if (fenceMarker != null) {
      final closing = RegExp(
        '^ {0,3}${RegExp.escape(fenceMarker)}{$fenceLength,}[\\t ]*\$',
      );
      if (closing.hasMatch(line)) {
        return (text: line, fenceMarker: null, fenceLength: 0);
      }
      return (text: line, fenceMarker: fenceMarker, fenceLength: fenceLength);
    }
    if (fence != null) {
      return (text: line, fenceMarker: fence[0], fenceLength: fence.length);
    }
    return (
      text: _transformInline(line, diceLabels),
      fenceMarker: null,
      fenceLength: 0,
    );
  }

  static String _transformInline(String line, Map<String, String> diceLabels) {
    final output = StringBuffer();
    var copiedUntil = 0;
    var index = 0;
    while (index < line.length) {
      if (line[index] == r'\') {
        index = _escapedConstructEnd(line, index);
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
        if (closing >= 0) {
          index = closing + runLength;
          continue;
        }
      }

      final atom = _matchAtom(line, index, diceLabels);
      if (atom == null) {
        final protectedEnd = _protectedConstructEnd(line, index);
        if (protectedEnd != null) {
          index = protectedEnd;
          continue;
        }
        index += 1;
        continue;
      }
      output
        ..write(line.substring(copiedUntil, index))
        ..write(atom.label);
      index = atom.end;
      copiedUntil = atom.end;
    }
    output.write(line.substring(copiedUntil));
    return output.toString();
  }

  static int _escapedConstructEnd(String line, int index) {
    if (index + 1 >= line.length) return line.length;
    final escaped = line.substring(index + 1);
    final construct = escaped.startsWith('!')
        ? _image.firstMatch(escaped)
        : escaped.startsWith('[')
        ? _markdownLink.firstMatch(escaped)
        : null;
    return construct == null
        ? (index + 2).clamp(0, line.length)
        : index + 1 + construct.group(0)!.length;
  }

  static int? _protectedConstructEnd(String line, int index) {
    final remaining = line.substring(index);
    final construct = line[index] == '!'
        ? _image.firstMatch(remaining)
        : line[index] == '['
        ? _markdownLink.firstMatch(remaining)
        : null;
    return construct == null ? null : index + construct.group(0)!.length;
  }

  static ({int end, String label})? _matchAtom(
    String line,
    int index,
    Map<String, String> diceLabels,
  ) {
    final character = line[index];
    if (character == '[') {
      final remaining = line.substring(index);
      final mention = _mention.firstMatch(remaining);
      if (mention != null) {
        return (
          end: index + mention.group(0)!.length,
          label: mention.group(1)!,
        );
      }
      if (remaining.startsWith('[[')) {
        final dice = MarkdownDiceContract.nodeAtStart.firstMatch(remaining);
        if (dice != null &&
            MarkdownDiceContract.normalizeNotation(dice.group(2)!) != null) {
          final nodeId = dice.group(1)!.toLowerCase();
          final notation = dice.group(2)!.trim();
          return (
            end: index + dice.group(0)!.length,
            label: diceLabels[nodeId] ?? '$notation = ?',
          );
        }
      }
    }
    if (character == '!') {
      final image = _image.firstMatch(line.substring(index));
      final title = image?.group(3);
      if (image != null && title?.startsWith(_stickerPrefix) == true) {
        final assetId = title!.substring(_stickerPrefix.length);
        final uri = Uri.tryParse(image.group(2)!);
        if (_stickerAssetId.hasMatch(assetId) &&
            uri != null &&
            uri.hasScheme &&
            MarkdownContent.isSafeImage(uri)) {
          return (end: index + image.group(0)!.length, label: _stickerLabel);
        }
      }
    }
    if (character == '[' || character == 'h' || character == '/') {
      final portal = matchInternalReferencePortalAt(line, index);
      if (portal != null) {
        return (end: portal.end, label: portal.portal.label);
      }
    }
    return null;
  }
}

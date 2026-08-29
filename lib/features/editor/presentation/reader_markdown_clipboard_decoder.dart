import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_codec.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

/// Decodes reader Markdown while keeping protocol atoms independent from the
/// surrounding inline styles that Quill cannot apply to embeds.
Delta decodeReaderMarkdownClipboard(String markdown) {
  final masked = _maskReaderAtoms(markdown);
  final decoded = MarkdownDeltaCodec.decodeReaderClipboard(masked.markdown);
  if (masked.atoms.isEmpty) return decoded.delta;

  final output = Delta();
  for (final operation in decoded.delta.operations) {
    final data = operation.data;
    if (data is! String || !masked.containsPlaceholder(data)) {
      output.insert(data, operation.attributes);
      continue;
    }
    var start = 0;
    for (var index = 0; index < data.length; index++) {
      final atom = masked.atoms[data[index]];
      if (atom == null) continue;
      _insertStyledText(
        output,
        data.substring(start, index),
        operation.attributes,
      );
      _insertReaderAtom(output, atom, operation.attributes);
      start = index + 1;
    }
    _insertStyledText(output, data.substring(start), operation.attributes);
  }
  return output;
}

void _insertReaderAtom(
  Delta output,
  _ReaderAtom atom,
  Map<String, dynamic>? surroundingAttributes,
) {
  for (final operation in atom.delta.operations) {
    final data = operation.data;
    if (data is Map && data.length == 1) {
      final type = data.keys.single;
      final label = switch (type) {
        MarkdownDeltaCodec.imageEmbed => '[图片]',
        MarkdownDeltaCodec.stickerEmbed => '[表情]',
        _ => null,
      };
      if (label == null) {
        output.insert(data);
      } else {
        output.insert(label, {
          ...?surroundingAttributes,
          MarkdownDeltaCodec.literalTextAttribute: true,
        });
      }
      continue;
    }
    if (data is String) {
      _insertStyledText(output, data, {
        ...?surroundingAttributes,
        ...?operation.attributes,
      });
    }
  }
}

void _insertStyledText(
  Delta output,
  String text,
  Map<String, dynamic>? attributes,
) {
  if (text.isEmpty) return;
  final effective = Map<String, dynamic>.from(attributes ?? const {});
  final hasInlineStyle = effective.keys.any(
    const {'bold', 'italic', 'strike', 'link', 'code'}.contains,
  );
  if (!hasInlineStyle || effective['code'] == true) {
    output.insert(text, effective.isEmpty ? null : effective);
    return;
  }
  final leading = RegExp(r'^\s+').firstMatch(text)?.group(0) ?? '';
  final trailing = RegExp(r'\s+$').firstMatch(text)?.group(0) ?? '';
  if (leading.length + trailing.length >= text.length) {
    output.insert(text);
    return;
  }
  if (leading.isNotEmpty) output.insert(leading);
  output.insert(
    text.substring(leading.length, text.length - trailing.length),
    effective,
  );
  if (trailing.isNotEmpty) output.insert(trailing);
}

_MaskedReaderMarkdown _maskReaderAtoms(String markdown) {
  final normalized = markdown.replaceAll(RegExp(r'\r\n?'), '\n');
  final lines = normalized.split('\n');
  final unsupported = MarkdownContent.unsupportedLineIndexes(normalized);
  final atoms = <String, _ReaderAtom>{};
  var placeholder = 0xE100;

  for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    if (unsupported.contains(lineIndex)) continue;
    final source = lines[lineIndex];
    final output = StringBuffer();
    var index = 0;
    while (index < source.length) {
      if (source[index] == r'\') {
        final end = (index + 2).clamp(0, source.length);
        output.write(source.substring(index, end));
        index = end;
        continue;
      }
      if (source[index] == '`') {
        var length = 1;
        while (index + length < source.length &&
            source[index + length] == '`') {
          length += 1;
        }
        final delimiter = '`' * length;
        final closing = source.indexOf(delimiter, index + length);
        if (closing >= 0) {
          final end = closing + length;
          output.write(source.substring(index, end));
          index = end;
          continue;
        }
      }
      final candidate = _readerAtomAt(source, index);
      if (candidate == null || placeholder > 0xF8FF) {
        output.write(source[index]);
        index += 1;
        continue;
      }
      while (placeholder <= 0xF8FF &&
          normalized.contains(String.fromCharCode(placeholder))) {
        placeholder += 1;
      }
      if (placeholder > 0xF8FF) {
        output.write(source[index]);
        index += 1;
        continue;
      }
      final marker = String.fromCharCode(placeholder++);
      atoms[marker] = candidate;
      output.write(marker);
      index += candidate.length;
    }
    lines[lineIndex] = output.toString();
  }
  return _MaskedReaderMarkdown(lines.join('\n'), atoms);
}

_ReaderAtom? _readerAtomAt(String source, int index) {
  final remaining = source.substring(index);
  final raw =
      _image.firstMatch(remaining)?.group(0) ??
      _link.firstMatch(remaining)?.group(0) ??
      MarkdownDiceContract.nodeAtStart.firstMatch(remaining)?.group(0) ??
      (_isAllPlayersAt(source, index) ? '@全体玩家' : null);
  if (raw == null) return null;

  try {
    final decoded = MarkdownDeltaCodec.decode(raw).delta;
    final length = MarkdownDeltaLineMetadata.documentLength(decoded);
    if (length <= 1) return null;
    final atom = decoded.slice(0, length - 1);
    final recognized = atom.operations.any((operation) {
      final data = operation.data;
      if (data is String) return operation.attributes?['link'] != null;
      if (data is! Map || data.length != 1) return false;
      return const {
        MarkdownDeltaCodec.internalReferenceEmbed,
        MarkdownDeltaCodec.mentionEmbed,
        MarkdownDeltaCodec.diceEmbed,
        MarkdownDeltaCodec.imageEmbed,
        MarkdownDeltaCodec.stickerEmbed,
      }.contains(data.keys.single);
    });
    return recognized ? _ReaderAtom(raw.length, atom) : null;
  } on Object {
    return null;
  }
}

bool _isAllPlayersAt(String source, int index) {
  const label = '@全体玩家';
  if (!source.startsWith(label, index)) return false;
  final left = index == 0 || !_mentionWord.hasMatch(source[index - 1]);
  final end = index + label.length;
  final right = end == source.length || !_mentionWord.hasMatch(source[end]);
  return left && right;
}

final _image = RegExp(
  r'''^!\[([^\]\n]*)\]\(\s*([^\s)]+)(?:\s+["']([^"'\n]*)["'])?\s*\)''',
);
final _link = RegExp(r'^\[([^\]\r\n]+)\]\(([^)\r\n]+)\)');
final _mentionWord = RegExp(r'[a-zA-Z0-9_\u4e00-\u9fff]');

class _MaskedReaderMarkdown {
  const _MaskedReaderMarkdown(this.markdown, this.atoms);

  final String markdown;
  final Map<String, _ReaderAtom> atoms;

  bool containsPlaceholder(String value) => atoms.keys.any(value.contains);
}

class _ReaderAtom {
  const _ReaderAtom(this.length, this.delta);

  final int length;
  final Delta delta;
}

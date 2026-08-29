import 'package:markdown/markdown.dart' as md;
import 'package:wenyousite_mobile/core/markdown/markdown_dice_contract.dart';

enum WenyouTextAlignment { left, center, right }

enum MarkdownAlignedBlockKind { paragraph, heading2, heading3 }

final class MarkdownAlignmentBlock {
  const MarkdownAlignmentBlock({
    required this.markerLine,
    required this.startLine,
    required this.endLine,
    required this.kind,
    required this.alignment,
  });

  final int markerLine;
  final int startLine;
  final int endLine;
  final MarkdownAlignedBlockKind kind;
  final WenyouTextAlignment alignment;
}

final class MarkdownAlignmentAnalysis {
  const MarkdownAlignmentAnalysis({
    required this.lines,
    required this.blocks,
    required this.invalidMarkerLines,
  });

  final List<String> lines;
  final List<MarkdownAlignmentBlock> blocks;
  final Set<int> invalidMarkerLines;

  Set<int> get validMarkerLines =>
      Set<int>.unmodifiable(blocks.map((block) => block.markerLine));

  MarkdownAlignmentBlock? blockStartingAt(int line) {
    for (final block in blocks) {
      if (block.startLine == line) return block;
    }
    return null;
  }

  WenyouTextAlignment alignmentForLine(int line) {
    for (final block in blocks) {
      if (line >= block.startLine && line <= block.endLine) {
        return block.alignment;
      }
    }
    return WenyouTextAlignment.left;
  }
}

final class MarkdownRenderSegment {
  const MarkdownRenderSegment({
    required this.markdown,
    this.alignment = WenyouTextAlignment.left,
    this.kind,
  });

  final String markdown;
  final WenyouTextAlignment alignment;
  final MarkdownAlignedBlockKind? kind;

  bool get isAligned => alignment != WenyouTextAlignment.left;
}

/// Shared Markdown v4 block-alignment protocol parser.
///
/// Only an exact top-level v1 marker immediately followed by a non-empty
/// paragraph or H2/H3 is consumed. Reserved but invalid markers remain visible
/// literal source through the normal unsupported-Markdown path.
abstract final class MarkdownAlignmentContract {
  static final RegExp _storedMarker = RegExp(
    r'^\[wenyousite-align-v1-(center|right)\]: #$',
  );
  static final RegExp _reservedMarker = RegExp(
    r'^\[wenyousite-align-v\d+-[a-z0-9_-]+\]: #[\t ]*$',
    caseSensitive: false,
  );
  static final RegExp _protocol = RegExp(
    r'\[wenyousite-align-v\d+-[a-z][a-z-]*\]:',
    caseSensitive: false,
  );
  static final RegExp _unknownProtocol = RegExp(
    r'\[\[([a-z][a-z0-9_-]*):v(\d+):',
    caseSensitive: false,
  );
  static final RegExp _htmlToken = RegExp(r'<[^>]*>');
  static final RegExp _heading = RegExp(r'^(#{2,3})[\t ]+(.+)$');
  static final RegExp _anyHeading = RegExp(r'^ {0,3}#{1,6}(?:[\t ]|$)');
  static final RegExp _list = RegExp(r'^ {0,6}(?:[-+*]|\d+[.)])[\t ]+');
  static final RegExp _thematicBreak = RegExp(
    r'^ {0,3}(?:(?:\*\s*){3,}|(?:-\s*){3,}|(?:_\s*){3,})$',
  );
  static final RegExp _emptyParagraph = RegExp(
    r'^ {0,3}<br\s*/?>[\t ]*$',
    caseSensitive: false,
  );
  static final RegExp _openingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})');
  static final RegExp _closingFence = RegExp(r'^ {0,3}(`{3,}|~{3,})[\t ]*$');
  static const _stickerTitlePrefix = 'wenyousite-sticker:v1:';
  static final RegExp _stickerAssetId = RegExp(r'^c[a-z0-9]{20,}$');

  static MarkdownAlignmentAnalysis analyze(String markdown) =>
      analyzeLines(markdown.split('\n'));

  static MarkdownAlignmentAnalysis analyzeLines(List<String> sourceLines) {
    final lines = List<String>.unmodifiable(sourceLines);
    final blocks = <MarkdownAlignmentBlock>[];
    final invalid = <int>{};
    _AlignmentFence? fence;

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (fence != null) {
        final closing = _closingFence.firstMatch(line)?.group(1);
        if (closing != null &&
            closing[0] == fence.marker &&
            closing.length >= fence.length) {
          fence = null;
        }
        continue;
      }
      final opening = _openingFence.firstMatch(line)?.group(1);
      if (opening != null) {
        fence = _AlignmentFence(opening[0], opening.length);
        continue;
      }
      if (line.startsWith('    ') || line.startsWith('\t')) continue;
      final marker = _storedMarker.firstMatch(line);
      if (marker == null) {
        if (isMarkerLine(line) || _hasUnescapedProtocol(line)) {
          invalid.add(index);
        }
        continue;
      }
      if (index + 1 >= lines.length) {
        invalid.add(index);
        continue;
      }
      final target = _targetAt(lines, index + 1);
      if (target == null || target.hasRegularImage || !target.hasContent) {
        invalid.add(index);
        continue;
      }
      blocks.add(
        MarkdownAlignmentBlock(
          markerLine: index,
          startLine: index + 1,
          endLine: target.endLine,
          kind: target.kind,
          alignment: marker.group(1) == 'center'
              ? WenyouTextAlignment.center
              : WenyouTextAlignment.right,
        ),
      );
    }

    return MarkdownAlignmentAnalysis(
      lines: lines,
      blocks: List.unmodifiable(blocks),
      invalidMarkerLines: Set.unmodifiable(invalid),
    );
  }

  static bool isMarkerLine(String line) => _reservedMarker.hasMatch(line);

  static String markerFor(WenyouTextAlignment alignment) => switch (alignment) {
    WenyouTextAlignment.left => '',
    WenyouTextAlignment.center => '[wenyousite-align-v1-center]: #',
    WenyouTextAlignment.right => '[wenyousite-align-v1-right]: #',
  };

  static String removeMarkerLines(String markdown) =>
      markdown.split('\n').where((line) => !isMarkerLine(line)).join('\n');

  static bool containsRegularImage(String markdown) {
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    ).parseLines(markdown.split('\n'));
    return nodes.any(_hasRegularImage);
  }

  static List<MarkdownRenderSegment> renderSegments(String markdown) {
    final analysis = analyze(markdown);
    if (analysis.blocks.isEmpty) {
      return [MarkdownRenderSegment(markdown: markdown)];
    }
    final segments = <MarkdownRenderSegment>[];
    var cursor = 0;
    for (final block in analysis.blocks) {
      if (block.markerLine > cursor) {
        _appendSegment(
          segments,
          analysis.lines.sublist(cursor, block.markerLine).join('\n'),
        );
      }
      _appendSegment(
        segments,
        analysis.lines.sublist(block.startLine, block.endLine + 1).join('\n'),
        alignment: block.alignment,
        kind: block.kind,
      );
      cursor = block.endLine + 1;
    }
    if (cursor < analysis.lines.length) {
      _appendSegment(segments, analysis.lines.sublist(cursor).join('\n'));
    }
    return List.unmodifiable(segments);
  }

  static void _appendSegment(
    List<MarkdownRenderSegment> output,
    String source, {
    WenyouTextAlignment alignment = WenyouTextAlignment.left,
    MarkdownAlignedBlockKind? kind,
  }) {
    final normalized = source
        .replaceFirst(RegExp(r'^\n+'), '')
        .replaceFirst(RegExp(r'\n+$'), '');
    if (normalized.isEmpty) return;
    output.add(
      MarkdownRenderSegment(
        markdown: normalized,
        alignment: alignment,
        kind: kind,
      ),
    );
  }

  static _AlignmentTarget? _targetAt(List<String> lines, int start) {
    final first = lines[start];
    if (first.trim().isEmpty || isMarkerLine(first)) return null;

    final heading = _heading.firstMatch(first);
    if (heading != null) {
      if (_hasUnsupportedParagraphSource(first)) return null;
      final node = _parseSingleBlock([first]);
      return _AlignmentTarget(
        endLine: start,
        kind: heading.group(1)!.length == 2
            ? MarkdownAlignedBlockKind.heading2
            : MarkdownAlignedBlockKind.heading3,
        hasContent: _hasMeaningfulContent(node),
        hasRegularImage: _hasRegularImage(node),
      );
    }

    if (start + 1 < lines.length &&
        _isSetextHeading(lines[start], lines[start + 1])) {
      if (_hasUnsupportedParagraphSource(lines[start])) return null;
      final node = _parseSingleBlock([lines[start], lines[start + 1]]);
      return _AlignmentTarget(
        endLine: start + 1,
        kind: MarkdownAlignedBlockKind.heading2,
        hasContent: _hasMeaningfulContent(node),
        hasRegularImage: _hasRegularImage(node),
      );
    }

    if (_startsNonParagraphBlock(first)) return null;
    var end = start;
    while (end + 1 < lines.length &&
        lines[end + 1].trim().isNotEmpty &&
        !isMarkerLine(lines[end + 1]) &&
        !_startsNonParagraphBlock(lines[end + 1]) &&
        !_isSetextHeading(lines[end], lines[end + 1])) {
      end += 1;
    }
    final paragraphLines = lines.sublist(start, end + 1);
    if (paragraphLines.any(_hasUnsupportedParagraphSource)) return null;
    final node = _parseSingleBlock(paragraphLines);
    if (node is! md.Element || node.tag != 'p') return null;
    return _AlignmentTarget(
      endLine: end,
      kind: MarkdownAlignedBlockKind.paragraph,
      hasContent: _hasMeaningfulContent(node),
      hasRegularImage: _hasRegularImage(node),
    );
  }

  static bool _startsNonParagraphBlock(String line) =>
      _anyHeading.hasMatch(line) ||
      RegExp(r'^ {0,3}>').hasMatch(line) ||
      _list.hasMatch(line) ||
      _thematicBreak.hasMatch(line) ||
      _emptyParagraph.hasMatch(line) ||
      RegExp(r'^ {0,3}(`{3,}|~{3,})').hasMatch(line) ||
      line.startsWith('    ') ||
      line.startsWith('\t');

  static bool _hasUnescapedProtocol(String line) {
    final masked = _maskInlineCode(line);
    for (final match in _protocol.allMatches(masked)) {
      if (!_isEscaped(line, match.start)) return true;
    }
    return false;
  }

  static bool _hasUnsupportedParagraphSource(String line) =>
      _hasHardBreak(line) ||
      _hasRawHtml(line) ||
      _hasUnsupportedInlineProtocol(line);

  static bool _hasHardBreak(String line) {
    final spaces = RegExp(r' +$').firstMatch(line)?.group(0)?.length ?? 0;
    final slashes = RegExp(r'\\+$').firstMatch(line)?.group(0)?.length ?? 0;
    return spaces >= 2 || slashes.isOdd;
  }

  static bool _hasRawHtml(String line) {
    final masked = _maskInlineCode(line);
    for (final match in _htmlToken.allMatches(masked)) {
      if (_isEscaped(line, match.start)) continue;
      if (RegExp(
        r'^<https?://[^\s<>]+>$',
        caseSensitive: false,
      ).hasMatch(match.group(0)!)) {
        continue;
      }
      return true;
    }
    return false;
  }

  static bool _hasUnsupportedInlineProtocol(String line) {
    final masked = _maskInlineCode(line);
    for (final match in _unknownProtocol.allMatches(masked)) {
      if (_isEscaped(line, match.start)) continue;
      if (match.group(1)!.toLowerCase() != 'dice' || match.group(2) != '1') {
        return true;
      }
    }

    var index = 0;
    final lower = masked.toLowerCase();
    while ((index = lower.indexOf('[[dice:', index)) >= 0) {
      if (_isEscaped(line, index)) {
        index += 2;
        continue;
      }
      final match = MarkdownDiceContract.nodeAtStart.firstMatch(
        line.substring(index),
      );
      if (match == null ||
          MarkdownDiceContract.normalizeNotation(match.group(2)!) == null) {
        return true;
      }
      index += match.group(0)!.length;
    }
    return false;
  }

  static String _maskInlineCode(String line) {
    final chars = List<String>.generate(
      line.length,
      (index) => line.substring(index, index + 1),
    );
    var index = 0;
    while (index < line.length) {
      if (line[index] != '`' || _isEscaped(line, index)) {
        index += 1;
        continue;
      }
      var length = 1;
      while (index + length < line.length && line[index + length] == '`') {
        length += 1;
      }
      final delimiter = '`' * length;
      final closing = line.indexOf(delimiter, index + length);
      if (closing < 0) {
        index += length;
        continue;
      }
      for (var cursor = index; cursor < closing + length; cursor++) {
        chars[cursor] = ' ';
      }
      index = closing + length;
    }
    return chars.join();
  }

  static bool _isEscaped(String line, int index) {
    var slashes = 0;
    for (
      var cursor = index - 1;
      cursor >= 0 && line[cursor] == r'\';
      cursor--
    ) {
      slashes += 1;
    }
    return slashes.isOdd;
  }

  static bool _isSetextHeading(String content, String delimiter) {
    if (content.trim().isEmpty ||
        !RegExp(r'^ {0,3}-{3,}[\t ]*$').hasMatch(delimiter)) {
      return false;
    }
    final node = _parseSingleBlock([content, delimiter]);
    return node is md.Element && node.tag == 'h2';
  }

  static md.Node? _parseSingleBlock(List<String> lines) {
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    ).parseLines(lines);
    return nodes.length == 1 ? nodes.single : null;
  }

  static bool _hasMeaningfulContent(md.Node? node) =>
      node != null &&
      (node.textContent.trim().isNotEmpty || _hasValidSticker(node));

  static bool _hasRegularImage(md.Node? node) {
    if (node is! md.Element) return false;
    if (node.tag == 'img') return !_isValidStickerImage(node);
    return node.children?.any(_hasRegularImage) ?? false;
  }

  static bool _hasValidSticker(md.Node node) {
    if (node is! md.Element) return false;
    if (_isValidStickerImage(node)) return true;
    return node.children?.any(_hasValidSticker) ?? false;
  }

  static bool _isValidStickerImage(md.Element node) {
    if (node.tag != 'img') return false;
    final title = node.attributes['title'];
    if (title == null || !title.startsWith(_stickerTitlePrefix)) return false;
    final assetId = title.substring(_stickerTitlePrefix.length);
    final source = node.attributes['src'];
    final uri = source == null ? null : Uri.tryParse(source);
    return _stickerAssetId.hasMatch(assetId) &&
        uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'https' || uri.scheme == 'http');
  }
}

final class _AlignmentTarget {
  const _AlignmentTarget({
    required this.endLine,
    required this.kind,
    required this.hasContent,
    required this.hasRegularImage,
  });

  final int endLine;
  final MarkdownAlignedBlockKind kind;
  final bool hasContent;
  final bool hasRegularImage;
}

final class _AlignmentFence {
  const _AlignmentFence(this.marker, this.length);

  final String marker;
  final int length;
}

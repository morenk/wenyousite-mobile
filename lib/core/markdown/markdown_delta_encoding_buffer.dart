import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';

/// Writes already-encoded Markdown lines while enforcing the alignment
/// marker rules across physical Quill lines that form one Markdown paragraph.
final class MarkdownDeltaEncodingBuffer {
  MarkdownDeltaEncodingBuffer({this.imageAlignment = false});

  final bool imageAlignment;
  final StringBuffer output = StringBuffer();

  WenyouTextAlignment? _openParagraphAlignment;
  var _openParagraphHasRegularImage = false;
  var _previousLineWasParagraphShape = false;
  var _previousLineWasImageBlock = false;

  void writeLine(
    String encodedLine,
    Map<String, dynamic>? attributes, {
    required String sourceBreakAttribute,
    required String literalLineAttribute,
    required String emptyParagraphAttribute,
  }) {
    final alignment = _alignmentFrom(attributes?['align']);
    final header = attributes?['header'];
    final isHeading = header == 2 || header == 3;
    final isLiteral = attributes?[literalLineAttribute] == true;
    final isEmptyParagraph = attributes?[emptyParagraphAttribute] == true;
    final isExcludedBlock =
        attributes?['list'] != null ||
        attributes?['blockquote'] == true ||
        attributes?['indent'] != null ||
        isLiteral ||
        isEmptyParagraph ||
        encodedLine == MarkdownEditorDocument.horizontalRuleMarker;
    final hasContent = encodedLine.trim().isNotEmpty;
    final hasRegularImage =
        hasContent &&
        MarkdownAlignmentContract.containsRegularImage(encodedLine);
    final isStandaloneRegularImage =
        hasRegularImage &&
        MarkdownAlignmentContract.isStandaloneRegularImage(encodedLine);
    final isImageBlock = imageAlignment && isStandaloneRegularImage;
    final isParagraphShape = hasContent && !isHeading && !isExcludedBlock;
    final joinsMarkdownParagraph = isParagraphShape && !isImageBlock;

    if (alignment != WenyouTextAlignment.left &&
        (!hasContent ||
            isExcludedBlock ||
            (hasRegularImage &&
                !(imageAlignment && isStandaloneRegularImage)) ||
            (header != null && !isHeading))) {
      throw const MarkdownCodecException('当前正文块不能使用对齐格式');
    }

    if ((isImageBlock || (_previousLineWasImageBlock && hasContent)) &&
        output.isNotEmpty) {
      _ensureBlankLine();
    }

    if (isLiteral && output.isNotEmpty && !output.toString().endsWith('\n\n')) {
      output.write('\n');
    }

    if (isImageBlock) {
      if (alignment != WenyouTextAlignment.left) {
        output
          ..write(MarkdownAlignmentContract.markerFor(alignment))
          ..write('\n');
      }
    } else if (isHeading && alignment != WenyouTextAlignment.left) {
      output
        ..write(MarkdownAlignmentContract.markerFor(alignment))
        ..write('\n');
    } else if (joinsMarkdownParagraph) {
      if (_previousLineWasParagraphShape &&
          (hasRegularImage || _openParagraphHasRegularImage) &&
          (alignment != WenyouTextAlignment.left ||
              _openParagraphAlignment != WenyouTextAlignment.left)) {
        throw const MarkdownCodecException('包含普通图片的段落不能使用对齐格式');
      }
      if (_previousLineWasParagraphShape) {
        if (_openParagraphAlignment != alignment) {
          throw const MarkdownCodecException('同一段落的多行文本必须使用相同对齐方式');
        }
        _openParagraphHasRegularImage =
            _openParagraphHasRegularImage || hasRegularImage;
      } else {
        _openParagraphAlignment = alignment;
        _openParagraphHasRegularImage = hasRegularImage;
        if (alignment != WenyouTextAlignment.left) {
          output
            ..write(MarkdownAlignmentContract.markerFor(alignment))
            ..write('\n');
        }
      }
    }

    output.write(encodedLine);
    if (attributes?[sourceBreakAttribute] != false) {
      output.write(isLiteral ? '\n\n' : '\n');
    }

    _previousLineWasParagraphShape = joinsMarkdownParagraph;
    _previousLineWasImageBlock = isImageBlock;
    if (!joinsMarkdownParagraph) {
      _openParagraphAlignment = null;
      _openParagraphHasRegularImage = false;
    }
  }

  void _ensureBlankLine() {
    final current = output.toString();
    if (!current.endsWith('\n')) output.write('\n');
    if (!current.endsWith('\n\n')) output.write('\n');
  }

  static WenyouTextAlignment _alignmentFrom(Object? value) => switch (value) {
    null || 'left' => WenyouTextAlignment.left,
    'center' => WenyouTextAlignment.center,
    'right' => WenyouTextAlignment.right,
    _ => throw const MarkdownCodecException('编辑器只支持左、中、右对齐'),
  };
}

import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_codec_types.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_editor_document.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_list_structure.dart';

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
  var _previousLineWasLiteral = false;
  final _listRows = <MarkdownListRow>[];
  bool _listEndsWithBreak = false;

  void finishLists() {
    if (_listRows.isEmpty) return;
    if (output.isNotEmpty &&
        (_listRows.first.content.isEmpty || _previousLineWasLiteral)) {
      _ensureBlankLine();
    }
    output.write(MarkdownListStructure.write(_listRows));
    if (_listEndsWithBreak) output.write('\n');
    _listRows.clear();
    _previousLineWasParagraphShape = false;
    _openParagraphAlignment = null;
  }

  void writeLine(
    String encodedLine,
    Map<String, dynamic>? attributes, {
    required String sourceBreakAttribute,
    required String literalLineAttribute,
    required String emptyParagraphAttribute,
  }) {
    if (attributes?['list'] case final String list) {
      if (_alignmentFrom(attributes?['align']) != WenyouTextAlignment.left) {
        throw const MarkdownCodecException('当前正文块不能使用对齐格式');
      }
      _listRows.add(
        MarkdownListRow(
          ordered: list == 'ordered',
          depth: attributes?['indent'] as int? ?? 0,
          content: encodedLine,
        ),
      );
      _listEndsWithBreak = attributes?[sourceBreakAttribute] != false;
      return;
    }
    final followsList = _listRows.isNotEmpty;
    finishLists();
    if (followsList && encodedLine.isNotEmpty) _ensureBlankLine();
    if (followsList && encodedLine.startsWith(' ')) {
      encodedLine = MarkdownContent.protectUnsafeWhitespace(
        encodedLine,
        minimumIndent: 1,
      );
    }
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

    if ((isLiteral || _previousLineWasLiteral) &&
        hasContent &&
        output.isNotEmpty &&
        !output.toString().endsWith('\n\n')) {
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
      output.write('\n');
    }

    _previousLineWasParagraphShape = joinsMarkdownParagraph;
    _previousLineWasImageBlock = isImageBlock;
    _previousLineWasLiteral = isLiteral;
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

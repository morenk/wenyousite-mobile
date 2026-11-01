import 'package:wenyousite_mobile/core/markdown/markdown_alignment.dart';
import 'package:wenyousite_mobile/core/navigation/internal_reference.dart';

/// 先按持久化 Markdown 判定对齐，再投影传送门。内部占位符不属于
/// Markdown 契约，不能反过来参与支持性判定，否则同行段落会丢失对齐。
({
  String data,
  List<MarkdownRenderSegment> segments,
  List<InternalReferencePortal> references,
})
projectMarkdownInternalReferences(String source) {
  final references = <InternalReferencePortal>[];
  final segments = [
    for (final segment in MarkdownAlignmentContract.renderSegments(
      source,
      imageAlignment: true,
    ))
      MarkdownRenderSegment(
        markdown: _projectSegment(segment.markdown, references),
        alignment: segment.alignment,
        kind: segment.kind,
      ),
  ];
  return (
    data: segments.map((segment) => segment.markdown).join('\n\n'),
    segments: segments,
    references: List.unmodifiable(references),
  );
}

final _markdownCodePattern = RegExp(
  r'(`{3,}[^\r\n]*\r?\n[\s\S]*?\r?\n`{3,}|~{3,}[^\r\n]*\r?\n[\s\S]*?\r?\n~{3,}|`[^`\r\n]*`)',
  unicode: true,
);

String _projectSegment(
  String source,
  List<InternalReferencePortal> references,
) {
  final output = StringBuffer();
  var offset = 0;
  for (final match in _markdownCodePattern.allMatches(source)) {
    _appendInternalReferenceChunk(
      source.substring(offset, match.start),
      output,
      references,
    );
    output.write(match.group(0));
    offset = match.end;
  }
  _appendInternalReferenceChunk(source.substring(offset), output, references);
  return output.toString();
}

void _appendInternalReferenceChunk(
  String source,
  StringBuffer output,
  List<InternalReferencePortal> references,
) {
  for (final segment in tokenizeInternalReferenceText(source)) {
    switch (segment) {
      case InternalReferencePlainText(:final value):
        output.write(value);
      case InternalReferencePortal(:final label, :final reference):
        final previous = output.isEmpty
            ? ''
            : output.toString()[output.length - 1];
        if (previous == '!' || previous == r'\') {
          output.write('[$label](${reference.location})');
          continue;
        }
        final index = references.length;
        references.add(segment);
        output.write('[[wenyou-internal-reference:v1:$index]]');
    }
  }
}

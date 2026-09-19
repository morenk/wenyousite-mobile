import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_delta_line_metadata.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_rich_line_decoder.dart';

class MarkdownCanonicalLiteralDecodeResult {
  const MarkdownCanonicalLiteralDecodeResult({
    required this.delta,
    required this.lineAttributes,
  });

  final Delta delta;
  final Map<String, dynamic> lineAttributes;
}

/// Restores the visible characters from the codec's canonical safety escapes
/// while preserving supported rich Markdown around those escaped characters.
class MarkdownCanonicalLiteralDecoder {
  MarkdownCanonicalLiteralDecoder._();

  static MarkdownCanonicalLiteralDecodeResult? decode(
    String source, {
    required String literalTextAttribute,
    required String internalReferenceEmbed,
    required String sourceBreakAttribute,
    bool inlineOnly = false,
    required bool Function(Delta candidate) preservesSource,
  }) {
    final masked = MarkdownContent.maskCanonicalLiteralLine(source);
    final hasEdgeSpaceEntities = MarkdownContent.hasBoundarySpaceEntities(
      source,
    );
    if (masked == null && !hasEdgeSpaceEntities) return null;
    final richLine = inlineOnly
        ? MarkdownRichLineDecoder.decodeInline(masked?.source ?? source)
        : MarkdownRichLineDecoder.decode(masked?.source ?? source);
    if (richLine == null) return null;

    final decoded = Delta();
    var literalIndex = 0;
    for (final span in richLine.spans) {
      final portal = span.internalReference;
      if (portal != null) {
        decoded.insert({
          internalReferenceEmbed: {
            'version': 1,
            'label': portal.label,
            'location': portal.reference.location.toString(),
          },
        });
        continue;
      }
      // 边界空格实体按原 Markdown 解析，不用非空白占位符改变强调的
      // flanking 规则；已解析文字保留 literal 来源供下次安全写回。
      final textAttributes = {
        ...?span.attributes,
        if (hasEdgeSpaceEntities) literalTextAttribute: true,
      };
      if (masked == null) {
        decoded.insert(span.text, textAttributes);
        continue;
      }
      var start = 0;
      while (start < span.text.length) {
        final marker = span.text.indexOf(masked.placeholder, start);
        if (marker < 0) {
          decoded.insert(span.text.substring(start), textAttributes);
          break;
        }
        if (marker > start) {
          decoded.insert(span.text.substring(start, marker), textAttributes);
        }
        if (literalIndex >= masked.literals.length) return null;
        decoded.insert(masked.literals[literalIndex], {
          ...?span.attributes,
          literalTextAttribute: true,
        });
        literalIndex += 1;
        start = marker + masked.placeholder.length;
      }
    }
    if (masked != null && literalIndex != masked.literals.length) return null;

    final lineAttributes = {
      ...richLine.lineAttributes,
      if (MarkdownContent.hasWhitespaceGuards(source))
        MarkdownDeltaLineMetadata.guardedWhitespaceKey: true,
      if (MarkdownContent.hasLeadingWhitespaceGuard(source))
        MarkdownDeltaLineMetadata.guardedLeadingWhitespaceKey: true,
    };
    final candidate = Delta.from(decoded)
      ..insert('\n', {...lineAttributes, sourceBreakAttribute: false});
    if (!preservesSource(candidate)) return null;
    return MarkdownCanonicalLiteralDecodeResult(
      delta: decoded,
      lineAttributes: lineAttributes,
    );
  }
}

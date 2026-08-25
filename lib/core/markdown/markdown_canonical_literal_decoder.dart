import 'package:flutter_quill/quill_delta.dart';
import 'package:wenyousite_mobile/core/markdown/markdown_content.dart';
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
    required bool Function(Delta candidate) preservesSource,
  }) {
    final masked = MarkdownContent.maskCanonicalLiteralLine(source);
    if (masked == null) return null;
    final richLine = MarkdownRichLineDecoder.decode(masked.source);
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
      var start = 0;
      while (start < span.text.length) {
        final marker = span.text.indexOf(masked.placeholder, start);
        if (marker < 0) {
          decoded.insert(span.text.substring(start), span.attributes);
          break;
        }
        if (marker > start) {
          decoded.insert(span.text.substring(start, marker), span.attributes);
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
    if (literalIndex != masked.literals.length) return null;

    final candidate = Delta.from(decoded)
      ..insert('\n', {...richLine.lineAttributes, sourceBreakAttribute: false});
    if (!preservesSource(candidate)) return null;
    return MarkdownCanonicalLiteralDecodeResult(
      delta: decoded,
      lineAttributes: richLine.lineAttributes,
    );
  }
}
